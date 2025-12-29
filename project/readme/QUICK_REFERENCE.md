# ⚡ QUICK REFERENCE - Food AI Training

## 🎯 Tujuan
Train AI model untuk deteksi 101 jenis makanan di aplikasi Flutter Nutrix

## 📋 Prerequisites Checklist
- [ ] Akun Kaggle (kaggle.com)
- [ ] Download kaggle.json dari Kaggle Account Settings
- [ ] Akun Google (untuk Colab)
- [ ] GPU enabled di Colab (Runtime → Change runtime → T4 GPU)

## ⚡ Quick Commands

### Training di Google Colab (RECOMMENDED)
```
1. Open colab.research.google.com
2. Upload training_colab.py atau copy-paste training.py
3. Runtime → Change runtime type → T4 GPU → Save
4. Upload kaggle.json saat diminta
5. Runtime → Run all (Ctrl+F9)
6. Wait ~1-2 hours
7. Download 4 files yang dihasilkan
```

### Local Training (Optional)
```bash
# Install dependencies
pip install -r requirements.txt

# Setup Kaggle
mkdir ~/.kaggle
cp kaggle.json ~/.kaggle/
chmod 600 ~/.kaggle/kaggle.json

# Download dataset
kaggle datasets download -d dansbecker/food-101
unzip food-101.zip -d ./food101

# Run training
python training.py
```

## 📦 Output Files

| File | Size | Gunakan untuk |
|------|------|---------------|
| `food_detection_model.tflite` | ~15-20 MB | ⭐ MAIN - Copy ke Flutter assets |
| `class_names.json` | ~2 KB | ⭐ IMPORTANT - List 101 makanan |
| `model_info.json` | ~1 KB | Info metadata model |
| `training_history.png` | ~100 KB | Visualisasi training |

## 🚀 Flutter Integration (Quick)

### 1. Copy Files
```bash
project/
└── assets/
    ├── models/
    │   └── food_detection_model.tflite  ← PASTE HERE
    └── class_names.json                  ← PASTE HERE
```

### 2. Update pubspec.yaml
```yaml
dependencies:
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

### 4. Create Service File
Copy code dari `README_TRAINING.md` section "Buat Service untuk AI Detection"
→ File: `lib/services/food_detection_service.dart`

### 5. Update Camera Modal
Copy code dari `README_TRAINING.md` section "Update camera_detection_modal.dart"
→ File: `lib/widgets/camera_detection_modal.dart`

### 6. Test
```bash
flutter run
```

## 🎯 Expected Results

| Metric | Value |
|--------|-------|
| Training Accuracy | 85-90% |
| Validation Accuracy | 75-85% |
| Top-5 Accuracy | 90-95% |
| Training Time | 1-2 hours |
| Model Size | 15-20 MB |

## 🐛 Common Issues

### "Out of Memory"
```python
# Reduce batch size in training.py
BATCH_SIZE = 16  # Instead of 32
```

### "Kaggle API error"
```bash
# Re-upload kaggle.json
# Check permissions: chmod 600 ~/.kaggle/kaggle.json
```

### "TFLite not loading in Flutter"
```yaml
# Check pubspec.yaml indentation
# Run: flutter clean && flutter pub get
# Verify file exists in assets/models/
```

### "Model accuracy low"
```python
# Increase epochs
EPOCHS = 50

# Or unfreeze some base_model layers
base_model.trainable = True
```

## 📚 Documentation

- **Full Guide**: `README_TRAINING.md`
- **Summary**: `SUMMARY.md`
- **Training Code**: `training.py` atau `training_colab.py`

## 🔗 Useful Links

- [Google Colab](https://colab.research.google.com)
- [Kaggle Food-101](https://www.kaggle.com/datasets/dansbecker/food-101)
- [TFLite Flutter](https://pub.dev/packages/tflite_flutter)
- [EfficientNet Paper](https://arxiv.org/abs/1905.11946)

## 💡 Pro Tips

1. **Always use GPU** - Training 10x faster
2. **Start with fewer epochs** - Test dengan EPOCHS=5 dulu
3. **Monitor val_accuracy** - Jika plateau, stop early
4. **Save checkpoints** - Model terbaik auto-saved
5. **Test inference** - Verify model works sebelum deploy

## 📞 Troubleshooting Steps

1. Check error message di console
2. Verify GPU is active (check icon di Colab)
3. Restart runtime jika stuck
4. Re-upload kaggle.json jika download fails
5. Check README_TRAINING.md untuk solusi detail

## ✅ Success Checklist

After training:
- [ ] Model accuracy > 75%
- [ ] Files downloaded successfully
- [ ] Files copied to Flutter assets
- [ ] pubspec.yaml updated
- [ ] FoodDetectionService created
- [ ] Camera modal updated
- [ ] flutter pub get run successfully
- [ ] App builds without errors
- [ ] Camera detection works
- [ ] AI predicts food correctly

---

**Ready to train?** → Open Google Colab dan upload `training_colab.py`!

**Need help?** → Check `README_TRAINING.md` for detailed guide!
