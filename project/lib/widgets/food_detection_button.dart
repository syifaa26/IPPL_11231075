import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/nutrition_backend_service.dart';

class FoodDetectionButton extends StatefulWidget {
  const FoodDetectionButton({super.key});

  @override
  State<FoodDetectionButton> createState() => _FoodDetectionButtonState();
}

class _FoodDetectionButtonState extends State<FoodDetectionButton> {
  final ImagePicker _picker = ImagePicker();
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickAndDetectFood() async {
    try {
      // Pilih gambar dari gallery atau camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      setState(() {
        _isDetecting = true;
      });

      // Deteksi makanan via Backend
      final result = await NutritionBackendService.analyzeImage(
        File(image.path),
      );

      setState(() {
        _isDetecting = false;
      });

      // Tampilkan hasil
      if (result != null && mounted) {
        _showResultDialog(result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Gagal mendeteksi makanan via Backend.'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    // Backend returns flat map: { description, calories, protein, carbs, fat, foodDescription }
    final name = result['description'] ?? 'Unknown';
    final calories = result['calories'] ?? 0;
    final info = result['foodDescription'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍽️ Food Detected!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Kalori: $calories kkal',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            if (info.toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Info:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(info.toString()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isDetecting ? null : _pickAndDetectFood,
      icon: _isDetecting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.camera_alt),
      label: Text(_isDetecting ? 'Detecting...' : 'Detect Food'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup tidak perlu karena service adalah singleton
    super.dispose();
  }
}
