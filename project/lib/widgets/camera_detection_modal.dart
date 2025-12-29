import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'camera_permission_dialog.dart';
import 'dart:io';
import '../services/food_detection_service.dart';
import '../data/food_nutrition_database.dart';
import '../services/user_data_service.dart';
import '../services/auth_service.dart';
import 'food_detection_result_card.dart';
import '../services/nutrition_api_service.dart';
import '../services/nutrition_backend_service.dart';
import '../theme/app_theme.dart';

class CameraDetectionModal extends StatefulWidget {
  const CameraDetectionModal({super.key});

  @override
  State<CameraDetectionModal> createState() => _CameraDetectionModalState();
}

class _CameraDetectionModalState extends State<CameraDetectionModal> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isPermissionGranted = false;
  String? _errorMessage;
  bool _isDetecting = false; // overlay progress state
  List<Map<String, dynamic>> _inlineResults = []; // fallback tampilan hasil jika bottom sheet gagal muncul

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Check and request camera permission with custom dialog
      final hasPermission = await CameraPermissionDialog.requestPermission(context);
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'Izin kamera diperlukan untuk menggunakan fitur deteksi makanan.';
          _isPermissionGranted = false;
        });
        return;
      }

      setState(() {
        _isPermissionGranted = true;
      });

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada kamera yang tersedia pada perangkat ini.';
        });
        return;
      }

      // Initialize the camera controller
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } on CameraException catch (e) {
      setState(() {
        if (e.code == 'CameraAccessDenied') {
          _errorMessage = 'Akses kamera ditolak. Mohon izinkan akses kamera di pengaturan aplikasi.';
        } else {
          _errorMessage = 'Error kamera: ${e.description ?? e.code}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal menginisialisasi kamera. Pastikan aplikasi memiliki izin kamera.';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      await _processImage(image, 'kamera');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image, 'galeri');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _processImage(XFile image, String source) async {
    debugPrint('Image from $source: ${image.path}');
    // Tampilkan overlay loading di dalam modal, jangan tutup modal
    if (mounted) {
      setState(() => _isDetecting = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Memproses gambar dari $source...'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final file = File(image.path);
      // Pastikan service initialized (verbose untuk logging pertama kali)
      await FoodDetectionService.ensureInitialized(verbose: true);
      // Run the AI detection service (nama & komponen)
      final result = await FoodDetectionService.detectFood(file);
      debugPrint('Detection result: $result');

      if (result['success'] == true) {
        final List<dynamic>? items = (result['items'] as List?)?.whereType<dynamic>().toList();
        if (items != null && items.isNotEmpty) {
          if (items.length == 1) {
            final top = items.first as Map<String, dynamic>;
            final String detectedName = (top['name'] ?? 'unknown').toString();
            final String key = detectedName
                .toLowerCase()
                .replaceAll(RegExp(r"[^a-z0-9 ]"), '')
                .trim()
                .replaceAll(RegExp(r"\s+"), '_');
            final nutrition = FoodNutritionDatabase.getNutrition(key);

            if (mounted) {
              setState(() => _isDetecting = false);
              // Simpan juga ke inline fallback (agar tetap terlihat jika bottom sheet tidak muncul di web)
              _inlineResults = [
                {
                  'name': detectedName,
                  'confidenceValue': top['confidenceValue'] ?? 0.0,
                  'confidence': top['confidence'] ?? '0',
                }
              ];
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(ctx).viewInsets.bottom,
                      left: 16,
                      right: 16,
                      top: 24,
                    ),
                    child: _SingleDetectionResultSheet(
                      originalName: detectedName,
                      foodKey: key,
                      confidenceValue: (top['confidenceValue'] as double? ?? 0.0),
                      nutrition: nutrition,
                      parentContext: context,
                    ),
                  );
                },
              );
            }
          } else {
            // Multi-food: ambil nutrisi total dari backend Node API berbasis gambar
            Map<String, dynamic>? backendNut;
            try {
              backendNut = await NutritionBackendService.analyzeImage(file);
              debugPrint('Backend nutrition result: $backendNut');
            } catch (e) {
              debugPrint('Backend nutrition error: $e');
            }

            if (mounted) {
              setState(() => _isDetecting = false);
              // Inline fallback list
              _inlineResults = items
                  .whereType<Map>()
                  .map((e) => {
                        'name': e['name'] ?? 'unknown',
                        'confidenceValue': e['confidenceValue'] ?? 0.0,
                        'confidence': e['confidence'] ?? '0',
                      })
                  .cast<Map<String, dynamic>>()
                  .toList();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) {
                  return _AggregatedDetectionResultSheet(
                    items: items,
                    parentContext: context,
                    backendNutrition: backendNut,
                  );
                },
              );
            }
          }
        } else {
          // Fallback ke topPrediction lama jika items tidak tersedia
          final top = result['topPrediction'];
          String detectedName = top['name'] as String;
          String key = detectedName
              .toLowerCase()
              .replaceAll(RegExp(r"[^a-z0-9 ]"), '')
              .trim()
              .replaceAll(RegExp(r"\s+"), '_');
          final nutrition = FoodNutritionDatabase.getNutrition(key);
          if (mounted) {
            setState(() => _isDetecting = false);
            _inlineResults = [
              {
                'name': detectedName,
                'confidenceValue': top['confidenceValue'] ?? 0.0,
                'confidence': top['confidence'] ?? '0',
              }
            ];
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (ctx) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  child: _SingleDetectionResultSheet(
                    originalName: detectedName,
                    foodKey: key,
                    confidenceValue: (top['confidenceValue'] as double? ?? 0.0),
                    nutrition: nutrition,
                    parentContext: context,
                  ),
                );
              },
            );
          }
        }
      } else {
        if (mounted) {
          setState(() => _isDetecting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deteksi gagal: ${result['error'] ?? 'Unknown'}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Error running detection: $e');
      if (mounted) {
        setState(() => _isDetecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi error saat mendeteksi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Note: image source selection UI is integrated directly into the modal controls.

  // Source option builder removed; controls are implemented directly in the modal.

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: SafeArea(
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deteksi Makanan dengan AI',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Ambil foto dengan kamera atau pilih dari galeri untuk mendeteksi kalori dan nutrisi secara otomatis',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
            
            // Camera Preview or Error Message
            Expanded(
              child: _buildCameraContent(),
            ),
            
            // Bottom Controls
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  if (_isInitialized && _isPermissionGranted) ...[
                    // Camera Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Camera Button
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Galeri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Permission or initialization error
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Retry camera initialization
                            setState(() {
                              _errorMessage = null;
                              _isInitialized = false;
                              _isPermissionGranted = false;
                            });
                            await _initializeCamera();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Tutup',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraContent() {
    if (_errorMessage != null) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              SizedBox(height: 20),
              Text(
                'Mempersiapkan kamera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRect(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          children: [
            CameraPreview(_controller!),
            if (_isDetecting)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text('Mendeteksi makanan...', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            if (!_isDetecting && _inlineResults.isNotEmpty)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hasil Deteksi (Inline Fallback)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      for (final item in _inlineResults)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.fastfood, color: AppColors.primary, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              Text(
                                '${item['confidence']}%',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _inlineResults = []),
                            child: const Text('Sembunyikan', style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet single detection result card (sementara single-food sebelum multi-food)
class _SingleDetectionResultSheet extends StatefulWidget {
  final String foodKey;
  final String originalName;
  final double confidenceValue; // 0..1
  final FoodNutrition? nutrition;
  final BuildContext parentContext; // context camera modal untuk menutup modal
  const _SingleDetectionResultSheet({
    required this.foodKey,
    required this.originalName,
    required this.confidenceValue,
    required this.nutrition,
    required this.parentContext,
  });

  @override
  State<_SingleDetectionResultSheet> createState() => _SingleDetectionResultSheetState();
}

class _SingleDetectionResultSheetState extends State<_SingleDetectionResultSheet> {
  final TextEditingController _portionController = TextEditingController(text: '100');
  final List<String> _mealTypes = const ['Sarapan', 'Makan Siang', 'Makan Malam', 'Camilan'];
  late String _selectedType;
  FoodNutrition? _nutrition; // dynamic (local or API)
  bool _loadingNut = false;
  bool _nutError = false;

  @override
  void initState() {
    super.initState();
    // Heuristik sederhana default jenis makan berdasarkan jam
    final h = DateTime.now().hour;
    if (h >= 4 && h < 11) {
      _selectedType = 'Sarapan';
    } else if (h >= 11 && h < 16) {
      _selectedType = 'Makan Siang';
    } else if (h >= 16 && h <= 22) {
      _selectedType = 'Makan Malam';
    } else {
      _selectedType = 'Camilan';
    }
    _nutrition = widget.nutrition;
    if (_nutrition == null) {
      _fetchNutrition();
    }
  }
  int _parsePortion() {
    final v = int.tryParse(_portionController.text.trim());
    if (v == null || v <= 0) return 100;
    return v > 2000 ? 2000 : v;
  }
  int _calcCalories(int grams) {
    if (_nutrition == null) return 0;
    return ((_nutrition!.calories * grams) / 100).round();
  }
  Future<void> _fetchNutrition() async {
    setState(() { _loadingNut = true; _nutError = false; });
    final data = await NutritionApiService.searchNutrition(widget.originalName);
    if (!mounted) return;
    if (data != null) {
      FoodNutritionDatabase.addDynamic(widget.originalName, data);
      _nutrition = FoodNutritionDatabase.getNutrition(widget.originalName);
    } else {
      _nutError = true;
    }
    setState(() { _loadingNut = false; });
  }
  @override
  Widget build(BuildContext context) {
    final portion = _parsePortion();
    final calories = _calcCalories(portion);
    final confPct = (widget.confidenceValue * 100).toStringAsFixed(1);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.fastfood, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.originalName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Conf: $confPct%'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_nutrition != null) ...[
            Text('Kalori (100g): ${_nutrition!.calories} kkal'),
            Text('Protein: ${_nutrition!.protein} g | Karbo: ${_nutrition!.carbs} g | Lemak: ${_nutrition!.fat} g'),
            if (_nutrition!.category == 'API') const Text('(Sumber: API Gemini)', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ] else if (_loadingNut) ...[
            const SizedBox(height: 8),
            const Row(children: [SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)), SizedBox(width:8), Text('Mengambil nutrisi...')]),
          ] else ...[
            if (_nutError) const Text('Gagal mengambil nutrisi dari API.'),
            const Text('Data nutrisi tidak ditemukan. Estimasi kalori berdasarkan porsi manual.'),
            TextButton(onPressed: _fetchNutrition, child: const Text('Coba Ambil Nutrisi')),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: _mealTypes
                .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
            decoration: const InputDecoration(
              labelText: 'Jenis Makan',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _portionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Porsi (gram)',
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset ke 100g',
                      onPressed: () {
                        _portionController.text = '100';
                        setState(() {});
                      },
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimasi Kalori', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$calories kkal'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                              final auth = AuthService();
                              final userId = auth.currentUser?.id ?? 'demo';
                              final uds = UserDataService();

                              // Hitung makro per porsi jika tersedia
                              int protein = 0;
                              int carbs = 0;
                              int fat = 0;
                              if (_nutrition != null) {
                                protein = ((_nutrition!.protein * portion) / 100).round();
                                carbs = ((_nutrition!.carbs * portion) / 100).round();
                                fat = ((_nutrition!.fat * portion) / 100).round();
                              }

                              uds.addMeal(userId, Meal(
                                name: widget.originalName,
                                    type: _selectedType,
                                time: DateTime.now().toIso8601String(),
                                calories: calories,
                                protein: protein,
                                carbs: carbs,
                                fat: fat,
                              ));

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Disimpan: ${widget.originalName} ($calories kkal, porsi $portion g)'),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              // Tutup juga modal kamera (parent)
                              Future.microtask(() {
                                if (Navigator.of(widget.parentContext).canPop()) {
                                  Navigator.of(widget.parentContext).pop();
                                }
                              });
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Konfirmasi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Bottom sheet for multi-food detection results
class _MultiDetectionResultSheet extends StatefulWidget {
  final List<dynamic> items; // list of maps {name, confidenceValue, ...}
  final BuildContext parentContext; // context kamera untuk ditutup setelah semua tersimpan
  const _MultiDetectionResultSheet({required this.items, required this.parentContext});

  @override
  State<_MultiDetectionResultSheet> createState() => _MultiDetectionResultSheetState();
}

class _MultiDetectionResultSheetState extends State<_MultiDetectionResultSheet> {
  int _savedCount = 0;

  String _normalizeKey(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9 ]"), '')
      .trim()
      .replaceAll(RegExp(r"\s+"), '_');

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final uds = UserDataService();
    final userId = auth.currentUser?.id ?? 'demo';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hasil Deteksi (Multi-item)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final it = widget.items[i] as Map<String, dynamic>;
                    final name = (it['name'] ?? 'unknown').toString();
                    final key = _normalizeKey(name);
                    final confVal = (it['confidenceValue'] as double?) ?? 0.0;
                    final nutrition = FoodNutritionDatabase.getNutrition(key);
                    return FoodDetectionResultCard(
                      foodKey: key,
                      originalName: name,
                      confidence: confVal,
                      nutrition: nutrition,
                      onConfirm: (portionGrams, estCalories) {
                        // Save meal (default type: Lainnya)
                        int protein = 0;
                        int carbs = 0;
                        int fat = 0;
                        if (nutrition != null) {
                          protein = ((nutrition.protein * portionGrams) / 100).round();
                          carbs = ((nutrition.carbs * portionGrams) / 100).round();
                          fat = ((nutrition.fat * portionGrams) / 100).round();
                        }
                        uds.addMeal(userId, Meal(
                          name: name,
                          type: 'Lainnya',
                          time: DateTime.now().toIso8601String(),
                          calories: estCalories,
                          protein: protein,
                          carbs: carbs,
                          fat: fat,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Disimpan: $name ($estCalories kkal, porsi $portionGrams g)'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        setState(() => _savedCount++);
                        if (_savedCount >= widget.items.length) {
                          // Semua item sudah disimpan: tutup sheet lalu modal kamera
                          Navigator.pop(context); // tutup bottom sheet
                          Future.microtask(() {
                            if (Navigator.of(widget.parentContext).canPop()) {
                              Navigator.of(widget.parentContext).pop();
                            }
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
              if (_savedCount > 0 && _savedCount < widget.items.length)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Disimpan: $_savedCount / ${widget.items.length}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Aggregated bottom sheet (gabungkan multi-item menjadi satu makanan komposit)
class _AggregatedDetectionResultSheet extends StatefulWidget {
  final List<dynamic> items;
  final BuildContext parentContext;
  final Map<String, dynamic>? backendNutrition;
  const _AggregatedDetectionResultSheet({required this.items, required this.parentContext, this.backendNutrition});

  @override
  State<_AggregatedDetectionResultSheet> createState() => _AggregatedDetectionResultSheetState();
}

class _AggregatedDetectionResultSheetState extends State<_AggregatedDetectionResultSheet> {
  late TextEditingController _portionController;
  String _mealType = 'Lainnya';
  int _calories = 0;
  int _protein = 0;
  int _carbs = 0;
  int _fat = 0;
  String _displayName = 'Makanan';
  late List<String> _components;

  @override
  void initState() {
    super.initState();
    _portionController = TextEditingController(text: '100');
    _components = widget.items
      .whereType<Map<String, dynamic>>()
      .map((e) => (e['name'] ?? 'unknown').toString())
      .toList();
    _displayName = _deriveName(_components);
    _mealType = _suggestMealType();
    if (widget.backendNutrition != null) {
      _applyBackendNutrition(widget.backendNutrition!);
    } else {
      _recalculate();
    }
  }

  String _suggestMealType() {
    final h = DateTime.now().hour;
    if (h < 10) return 'Sarapan';
    if (h < 14) return 'Makan Siang';
    if (h < 18) return 'Camilan';
    return 'Makan Malam';
  }

  String _deriveName(List<String> comps) {
    // Heuristik: jika contains pizza/salad/burger gunakan nama utama, else gunakan item pertama capitalized
    final lower = comps.map((e) => e.toLowerCase()).toList();
    if (lower.any((e) => e.contains('pizza'))) return 'Pizza';
    if (lower.any((e) => e.contains('salad'))) return 'Salad';
    if (lower.any((e) => e.contains('burger'))) return 'Burger';
    final first = comps.first.replaceAll('_', ' ');
    return first.split(' ').map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  int _parsePortion() {
    final v = int.tryParse(_portionController.text.trim());
    return (v == null || v <= 0) ? 100 : v;
  }

  void _applyBackendNutrition(Map<String, dynamic> data) {
    final portion = _parsePortion();
    final cal = (data['calories'] as num?)?.toDouble() ?? 0;
    final p = (data['protein'] as num?)?.toDouble() ?? 0;
    final c = (data['carbs'] as num?)?.toDouble() ?? 0;
    final f = (data['fat'] as num?)?.toDouble() ?? 0;
    setState(() {
      // backend biasanya sudah estimasi untuk 1 porsi; kita skalakan sederhana proporsional
      _calories = (cal * portion / 100).round();
      _protein = (p * portion / 100).round();
      _carbs = (c * portion / 100).round();
      _fat = (f * portion / 100).round();
    });
  }

  void _recalculate() {
    final portion = _parsePortion();
    int cal = 0, p = 0, c = 0, f = 0;
    for (final comp in _components) {
      final key = comp.toLowerCase().replaceAll(RegExp(r"[^a-z0-9 ]"), '').trim().replaceAll(RegExp(r"\s+"), '_');
      final nut = FoodNutritionDatabase.getNutrition(key);
      if (nut != null) {
        cal += ((nut.calories * portion) / 100).round();
        p += ((nut.protein * portion) / 100).round();
        c += ((nut.carbs * portion) / 100).round();
        f += ((nut.fat * portion) / 100).round();
      }
    }
    setState(() {
      _calories = cal;
      _protein = p;
      _carbs = c;
      _fat = f;
    });
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final uds = UserDataService();
    final userId = auth.currentUser?.id ?? 'demo';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Hasil Deteksi (Gabungan)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: -4,
              children: _components.map((c) => Chip(label: Text(c.replaceAll('_', ' ')))).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _mealType,
                    decoration: const InputDecoration(labelText: 'Jenis Makan'),
                    items: const [
                      DropdownMenuItem(value: 'Sarapan', child: Text('Sarapan')),
                      DropdownMenuItem(value: 'Makan Siang', child: Text('Makan Siang')),
                      DropdownMenuItem(value: 'Makan Malam', child: Text('Makan Malam')),
                      DropdownMenuItem(value: 'Camilan', child: Text('Camilan')),
                      DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                    ],
                    onChanged: (v) => setState(() => _mealType = v ?? _mealType),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _portionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Porsi (g)'),
                    onChanged: (_) {
                      if (widget.backendNutrition != null) {
                        _applyBackendNutrition(widget.backendNutrition!);
                      } else {
                        _recalculate();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Estimasi Kalori Total: $_calories kkal'),
                    Text('Protein: $_protein g, Karbo: $_carbs g, Lemak: $_fat g'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final portion = _parsePortion();
                  uds.addMeal(userId, Meal(
                    name: _displayName,
                    type: _mealType,
                    time: DateTime.now().toIso8601String(),
                    calories: _calories,
                    protein: _protein,
                    carbs: _carbs,
                    fat: _fat,
                    components: _components,
                  ));
                  Navigator.pop(context); // close sheet
                  Future.microtask(() {
                    if (Navigator.of(widget.parentContext).canPop()) {
                      Navigator.of(widget.parentContext).pop();
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Disimpan: $_displayName ($_calories kkal, porsi $portion g)'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}