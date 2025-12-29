import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final List<PermissionStep> _steps = [
    PermissionStep(
      icon: Icons.camera_alt,
      title: 'Akses Kamera',
      description:
          'Izinkan aplikasi mengakses kamera untuk memindai barcode makanan dan mengenali nutrisi secara otomatis.',
      benefit: '📸 Scan barcode makanan dengan mudah',
    ),
    PermissionStep(
      icon: Icons.photo_library,
      title: 'Akses Galeri',
      description:
          'Izinkan aplikasi mengakses galeri untuk memilih foto makanan yang ingin Anda analisis nutrisinya.',
      benefit: '🖼️ Upload foto makanan dari galeri',
    ),
    PermissionStep(
      icon: Icons.notifications_active,
      title: 'Notifikasi',
      description:
          'Izinkan aplikasi mengirim notifikasi untuk mengingatkan Anda makan, minum air, dan mencatat asupan harian.',
      benefit: '⏰ Pengingat tepat waktu untuk kesehatan Anda',
    ),
  ];

  Future<void> _requestCurrentPermission() async {
    setState(() => _isLoading = true);

    try {
      bool granted = false;
      
      switch (_currentStep) {
        case 0: // Camera
          granted = await PermissionService.handleCameraPermissionRequest(context);
          break;
        case 1: // Gallery/Photos  
          granted = await PermissionService.handleCameraPermissionRequest(context);
          break;
        case 2: // Notifications
          // For notifications, we'll just continue
          granted = true;
          break;
      }
      
      print('Permission ${_currentStep} granted: $granted');
    } catch (e) {
      print('Error requesting permission: $e');
    }

    setState(() => _isLoading = false);

    // Move to next step or finish
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _finishPermissionSetup();
    }
  }

  void _skipPermission() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _finishPermissionSetup();
    }
  }

  void _finishPermissionSetup() {
    // Navigate to home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const NutrixHome(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pengaturan Izin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currentStep + 1}/${_steps.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / _steps.length,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            step.icon,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          step.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Benefit Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade700,
                                size: 28,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  step.benefit,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Allow Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading ? null : _requestCurrentPermission,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Izinkan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Skip Button
                        TextButton(
                          onPressed: _isLoading ? null : _skipPermission,
                          child: Text(
                            _currentStep < _steps.length - 1
                                ? 'Lewati untuk sekarang'
                                : 'Lewati dan Mulai',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Info Text
                        Text(
                          'Anda dapat mengubah izin ini kapan saja di pengaturan aplikasi',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionStep {
  final IconData icon;
  final String title;
  final String description;
  final String benefit;

  PermissionStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.benefit,
  });
}
