# 📱 COPY-PASTE GUIDE - Flutter Integration

## ✅ Training Selesai!

Model AI sudah siap. Sekarang copy ke Flutter:

---

## Step 1: Copy Files (PowerShell)

```powershell
# Navigate to API folder
cd d:\VSCODE\IPPL\API

# Copy ke Flutter project
$projectPath = "..\project"
mkdir "$projectPath\assets\models" -Force -ErrorAction SilentlyContinue
mkdir "$projectPath\assets" -Force -ErrorAction SilentlyContinue

Copy-Item "food_detection_model.tflite" -Destination "$projectPath\assets\models\"
Copy-Item "class_names.json" -Destination "$projectPath\assets\"

Write-Host "✅ Files copied!"
```

---

## Step 2: Update pubspec.yaml

File: `project/pubspec.yaml`

Add after dependencies:
```yaml
dependencies:
  tflite_flutter: ^0.10.4
  image: ^4.1.7
```

And add assets section:
```yaml
flutter:
  assets:
    - assets/models/food_detection_model.tflite
    - assets/class_names.json
```

Then run:
```bash
cd project
flutter pub get
```

---

## Step 3: Create AI Service

File: `project/lib/services/food_detection_service.dart`

Copy from `d:\VSCODE\IPPL\API\README_TRAINING.md` section "Buat Service untuk AI Detection"

**Or use this quick version:**

```dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FoodDetectionService {
  Interpreter? _interpreter;
  List<String>? _labels;
  
  static const int INPUT_SIZE = 224;
  
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/food_detection_model.tflite'
      );
      
      final labelsData = await rootBundle.loadString('assets/class_names.json');
      _labels = List<String>.from(json.decode(labelsData));
      
      print('✅ Model loaded: ${_labels?.length} classes');
    } catch (e) {
      print('❌ Error loading model: $e');
    }
  }
  
  Future<Map<String, dynamic>?> detectFood(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }
    
    try {
      final imageData = File(imagePath).readAsBytesSync();
      img.Image? image = img.decodeImage(imageData);
      
      if (image == null) return null;
      
      img.Image resizedImage = img.copyResize(
        image, 
        width: INPUT_SIZE, 
        height: INPUT_SIZE
      );
      
      var input = _imageToByteListFloat32(resizedImage);
      var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);
      
      _interpreter!.run(input, output);
      
      List<double> probabilities = output[0];
      
      var predictions = <Map<String, dynamic>>[];
      for (int i = 0; i < probabilities.length; i++) {
        predictions.add({
          'label': _labels![i],
          'confidence': probabilities[i],
        });
      }
      
      predictions.sort((a, b) => 
        (b['confidence'] as double).compareTo(a['confidence'] as double)
      );
      
      return {
        'food_name': predictions[0]['label'],
        'confidence': predictions[0]['confidence'],
        'top_predictions': predictions.take(5).toList(),
      };
      
    } catch (e) {
      print('❌ Error detecting food: $e');
      return null;
    }
  }
  
  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image) {
    return List.generate(
      1,
      (index) => List.generate(
        INPUT_SIZE,
        (y) => List.generate(
          INPUT_SIZE,
          (x) {
            var pixel = image.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1.0,
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );
  }
  
  void dispose() {
    _interpreter?.close();
  }
}
```

---

## Step 4: Update Camera Modal

File: `project/lib/widgets/camera_detection_modal.dart`

At the top, add:
```dart
import '../services/food_detection_service.dart';
```

In the class, add:
```dart
final _foodDetectionService = FoodDetectionService();

@override
void initState() {
  super.initState();
  _initializeCamera();
  _foodDetectionService.loadModel(); // Load model
}

@override
void dispose() {
  _foodDetectionService.dispose();
  super.dispose();
}
```

Replace `_processImage` method:
```dart
Future<void> _processImage(XFile image, String source) async {
  if (mounted) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Mendeteksi makanan...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  final result = await _foodDetectionService.detectFood(image.path);
  
  if (result != null) {
    final foodName = result['food_name'];
    final confidence = (result['confidence'] * 100).toStringAsFixed(1);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Terdeteksi: $foodName ($confidence%)'),
          backgroundColor: const Color(0xFF2ECC71),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal mendeteksi makanan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## Step 5: Test

```bash
cd project
flutter clean
flutter pub get
flutter run
```

**Test Steps:**
1. Open app
2. Navigate to camera detection
3. Take photo atau select from gallery
4. Wait for detection
5. Should show: "✅ Terdeteksi: [food_name] ([confidence]%)"

---

## ✅ Done!

Your app sekarang punya AI food detection! 🎉

---

## 🐛 Troubleshooting

### "No module named 'tflite_flutter'"
```bash
flutter pub add tflite_flutter
flutter pub get
```

### "Asset not found"
Check: `pubspec.yaml` indentation harus benar
```yaml
flutter:
  assets:
    - assets/models/food_detection_model.tflite
    - assets/class_names.json
```

### Model too slow
- Already optimized dengan TFLite
- Inference biasanya <3 detik
- Kalau masih lambat, reduce IMAGE_SIZE di training

### Accuracy rendah
- Current: Demo mode (synthetic data)
- Untuk accuracy lebih tinggi: train full Food-101 dataset
- Run: `python training.py` di API folder

---

**Questions?** Check `README_TRAINING.md` untuk detailed guide!

Happy coding! 🚀
