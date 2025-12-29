# 🚀 Training AI Model untuk Aplikasi Nutrix

## 📋 Deskripsi
Script training ini membuat model AI untuk mendeteksi makanan dari foto yang diambil melalui aplikasi Flutter Nutrix. Model ini akan mengklasifikasikan 101 jenis makanan menggunakan dataset Food-101.

## 🎯 Fitur Model
- **Transfer Learning** dengan EfficientNetB0 (pre-trained on ImageNet)
- **Data Augmentation** untuk model yang lebih robust
- **Top-5 Accuracy** tracking untuk evaluasi
- **TensorFlow Lite** conversion untuk mobile deployment
- **Callbacks**: Early Stopping, Model Checkpoint, Learning Rate Reduction

## 📦 Prerequisites

### 1. Akun Kaggle
1. Buat akun di [kaggle.com](https://www.kaggle.com)
2. Go to Account Settings → API → Create New API Token
3. Download file `kaggle.json`

### 2. Google Colab (Recommended)
- Gratis GPU/TPU untuk training
- Semua library sudah ter-install
- Link: [colab.research.google.com](https://colab.research.google.com)

## 🚀 Cara Menggunakan

### Step 1: Upload ke Google Colab
1. Buka [Google Colab](https://colab.research.google.com)
2. Upload file `training.py` (File → Upload notebook)
3. Atau copy-paste code ke notebook baru

### Step 2: Aktifkan GPU
1. Runtime → Change runtime type
2. Hardware accelerator → **GPU** (T4 or better)
3. Save

### Step 3: Run Training
1. Jalankan cell pertama - akan minta upload `kaggle.json`
2. Upload file `kaggle.json` Anda
3. Script akan otomatis:
   - Download dataset Food-101 (~5GB)
   - Extract dan prepare data
   - Train model dengan transfer learning
   - Save model dalam berbagai format
   - Generate visualisasi training

### Step 4: Download File Hasil
Setelah training selesai, Anda akan mendapat file:
- `food_detection_model.tflite` - Model untuk Flutter (PENTING!)
- `class_names.json` - List 101 kategori makanan
- `model_info.json` - Metadata model
- `training_history.png` - Grafik training

## 📱 Integrasi dengan Flutter

### 1. Setup Assets
Buat folder dan copy file:
```
project/
├── assets/
│   ├── models/
│   │   └── food_detection_model.tflite
│   └── class_names.json
```

### 2. Update pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  tflite_flutter: ^0.10.4
  image: ^4.1.7

flutter:
  assets:
    - assets/models/food_detection_model.tflite
    - assets/class_names.json
```

### 3. Install Package
```bash
cd project
flutter pub get
```

### 4. Buat Service untuk AI Detection

Buat file `lib/services/food_detection_service.dart`:

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
      // Load model
      _interpreter = await Interpreter.fromAsset(
        'assets/models/food_detection_model.tflite'
      );
      
      // Load labels
      final labelsData = await rootBundle.loadString('assets/class_names.json');
      _labels = List<String>.from(json.decode(labelsData));
      
      print('Model loaded: ${_labels?.length} classes');
    } catch (e) {
      print('Error loading model: $e');
    }
  }
  
  Future<Map<String, dynamic>?> detectFood(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }
    
    try {
      // Load dan preprocess image
      final imageData = File(imagePath).readAsBytesSync();
      img.Image? image = img.decodeImage(imageData);
      
      if (image == null) return null;
      
      // Resize ke 224x224
      img.Image resizedImage = img.copyResize(
        image, 
        width: INPUT_SIZE, 
        height: INPUT_SIZE
      );
      
      // Convert ke float32 list (normalized)
      var input = _imageToByteListFloat32(resizedImage);
      
      // Output buffer
      var output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);
      
      // Run inference
      _interpreter!.run(input, output);
      
      // Get predictions
      List<double> probabilities = output[0];
      
      // Get top 5 predictions
      var predictions = <Map<String, dynamic>>[];
      for (int i = 0; i < probabilities.length; i++) {
        predictions.add({
          'label': _labels![i],
          'confidence': probabilities[i],
          'index': i,
        });
      }
      
      predictions.sort((a, b) => 
        (b['confidence'] as double).compareTo(a['confidence'] as double)
      );
      
      var topPredictions = predictions.take(5).toList();
      
      return {
        'success': true,
        'food_name': topPredictions[0]['label'],
        'confidence': topPredictions[0]['confidence'],
        'top_predictions': topPredictions,
      };
      
    } catch (e) {
      print('Error detecting food: $e');
      return null;
    }
  }
  
  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image) {
    var convertedBytes = List.generate(
      1,
      (index) => List.generate(
        INPUT_SIZE,
        (y) => List.generate(
          INPUT_SIZE,
          (x) {
            var pixel = image.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1.0,  // Normalize to [-1, 1]
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );
    return convertedBytes;
  }
  
  void dispose() {
    _interpreter?.close();
  }
}
```

### 5. Update camera_detection_modal.dart

Edit file `lib/widgets/camera_detection_modal.dart`:

```dart
import '../services/food_detection_service.dart';

// Di dalam class, tambahkan:
final _foodDetectionService = FoodDetectionService();

@override
void initState() {
  super.initState();
  _initializeCamera();
  _foodDetectionService.loadModel(); // Load model saat init
}

// Update method _processImage:
Future<void> _processImage(XFile image, String source) async {
  // Show loading
  if (mounted) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 Mendeteksi makanan...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  // Detect food
  final result = await _foodDetectionService.detectFood(image.path);
  
  if (result != null && result['success']) {
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
      
      // TODO: Navigate ke halaman detail makanan atau simpan ke database
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

@override
void dispose() {
  _foodDetectionService.dispose();
  super.dispose();
}
```

## ⚙️ Konfigurasi Training

Anda bisa modify parameter di file `training.py`:

```python
IMG_SIZE = 224        # Ukuran input gambar
BATCH_SIZE = 32       # Batch size (sesuaikan dengan GPU)
EPOCHS = 30           # Jumlah epoch training
LEARNING_RATE = 0.001 # Learning rate
```

## 📊 Expected Results

Dengan setup ini, Anda bisa expect:
- **Training Accuracy**: ~85-90%
- **Validation Accuracy**: ~75-85%
- **Top-5 Accuracy**: ~90-95%
- **Training Time**: ~1-2 jam (dengan GPU T4)
- **Model Size**: ~15-20 MB (TFLite)

## 🐛 Troubleshooting

### Error: "Out of Memory"
```python
BATCH_SIZE = 16  # Kurangi batch size
```

### Error: "Dataset not found"
Pastikan kaggle.json sudah di-upload dengan benar

### Model Accuracy rendah
- Tambah epoch: `EPOCHS = 50`
- Unfreeze beberapa layer dari base model
- Gunakan data augmentation lebih banyak

### TFLite model tidak load di Flutter
- Cek path asset di pubspec.yaml
- Pastikan file .tflite sudah ada di folder assets/models/
- Run: `flutter clean && flutter pub get`

## 📚 Resources

- [TensorFlow Lite Flutter](https://pub.dev/packages/tflite_flutter)
- [Food-101 Dataset](https://www.kaggle.com/datasets/dansbecker/food-101)
- [EfficientNet Paper](https://arxiv.org/abs/1905.11946)
- [Transfer Learning Guide](https://www.tensorflow.org/tutorials/images/transfer_learning)

## 🤝 Support

Jika ada pertanyaan atau masalah:
1. Check error di console
2. Pastikan semua dependencies ter-install
3. Verifikasi GPU aktif di Colab

## 📝 Notes

- Model ini dioptimalkan untuk mobile deployment
- Menggunakan quantization untuk ukuran lebih kecil
- Support 101 kategori makanan dari Food-101 dataset
- Ready untuk production use di aplikasi Nutrix

---

**Happy Training! 🚀**
