import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/food_detection_service.dart';

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
    // Initialize model saat widget pertama kali dimuat
    FoodDetectionService.initialize();
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

      // Deteksi makanan
      final result = await FoodDetectionService.detectFood(File(image.path));

      setState(() {
        _isDetecting = false;
      });

      // Tampilkan hasil
      if (result['success'] && mounted) {
        _showResultDialog(result);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      }
    } catch (e) {
      setState(() {
        _isDetecting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final topPrediction = result['topPrediction'];
    final allPredictions = result['allPredictions'] as List;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🍽️ Food Detected!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topPrediction['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${topPrediction['confidence']}%',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text(
              'Other possibilities:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...allPredictions.skip(1).map((pred) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${pred['name']} (${pred['confidence']}%)'),
                )),
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
