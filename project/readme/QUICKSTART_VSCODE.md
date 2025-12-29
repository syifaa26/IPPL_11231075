# ⚡ QUICK START - Training di VSCode

## 🚀 Super Cepat (Windows)

### 1. Setup (Sekali Saja)
```powershell
# Double-click atau run di PowerShell:
.\setup.bat
```

Atau manual:
```powershell
# Install dependencies
pip install -r requirements.txt

# Setup Kaggle (copy kaggle.json ke %USERPROFILE%\.kaggle\)
```

### 2. Run Training
```powershell
# Double-click atau run:
.\run_training.bat
```

Atau manual:
```powershell
python training.py
```

**That's it!** 🎉

---

## 🐧 Linux/Mac

### 1. Setup
```bash
# Install dependencies
pip install -r requirements.txt

# Setup Kaggle
mkdir -p ~/.kaggle
cp kaggle.json ~/.kaggle/
chmod 600 ~/.kaggle/kaggle.json
```

### 2. Run Training
```bash
python training.py
```

---

## 📋 Prerequisites

**Sebelum mulai, pastikan:**
- ✅ Python 3.8+ installed
- ✅ pip installed
- ✅ kaggle.json downloaded (dari kaggle.com/settings)
- ✅ ~10GB disk space free

**Optional (tapi recommended):**
- ✅ NVIDIA GPU with CUDA
- ✅ 16GB+ RAM

---

## ⏱️ Timeline

| Step | With GPU | Without GPU |
|------|----------|-------------|
| Setup | 5 min | 5 min |
| Download Dataset | 10 min | 10 min |
| Training (30 epochs) | 1-2 hours | 10-20 hours |
| **Total** | **~2 hours** | **~12 hours** |

---

## 📊 What Happens During Training?

```
1. ✅ Check kaggle.json
2. 📥 Download Food-101 dataset (5GB, one time only)
3. 📦 Extract dataset
4. 🔄 Prepare data
5. 🏗️  Build EfficientNetB0 model
6. 🚀 Train for 30 epochs
   ├─ Epoch 1/30 ━━━━━━━━━━ 120s - loss: 2.56 - accuracy: 0.45
   ├─ Epoch 2/30 ━━━━━━━━━━ 115s - loss: 2.12 - accuracy: 0.52
   └─ ...
7. 💾 Save models (.tflite, .h5, .keras)
8. 📈 Generate visualization
9. ✅ Done!
```

---

## 🎯 Output Files

Di folder `API/`:
```
✓ food_detection_model.tflite  ← IMPORTANT! Copy to Flutter
✓ class_names.json              ← IMPORTANT! Copy to Flutter
✓ model_info.json               ← Metadata
✓ training_history.png          ← Visualization
✓ best_food_model.keras         ← Best checkpoint
✓ food_detection_model.h5       ← H5 format
```

---

## 🐛 Common Issues

### "Python not found"
```bash
# Install Python
https://www.python.org/downloads/
```

### "kaggle.json not found"
```bash
# Get from: https://www.kaggle.com/settings/account
# Copy to: %USERPROFILE%\.kaggle\ (Windows)
# Copy to: ~/.kaggle/ (Linux/Mac)
```

### "Out of memory"
Edit training.py:
```python
BATCH_SIZE = 16  # Reduce from 32
```

### Training too slow (No GPU)
**Options:**
1. Reduce epochs: `EPOCHS = 10`
2. Use Google Colab (free GPU)
3. Wait longer (10-20 hours)

---

## 📱 Next Steps After Training

### 1. Copy Files to Flutter
```powershell
# Windows
copy food_detection_model.tflite ..\project\assets\models\
copy class_names.json ..\project\assets\
```

### 2. Update pubspec.yaml
```yaml
dependencies:
  tflite_flutter: ^0.10.4

flutter:
  assets:
    - assets/models/food_detection_model.tflite
    - assets/class_names.json
```

### 3. Run Flutter
```bash
cd ..\project
flutter pub get
flutter run
```

---

## 💡 Pro Tips

1. **First time?** Test with `EPOCHS = 3` untuk verify setup
2. **Have GPU?** Training 10x faster!
3. **Dataset downloaded once** - reuse untuk training berikutnya
4. **Monitor progress** - Check output untuk melihat accuracy meningkat
5. **Best model auto-saved** - Jika training interrupted, resume dari checkpoint

---

## ✅ Success Checklist

- [ ] Python installed & working
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] kaggle.json configured
- [ ] Run `python training.py` tanpa error
- [ ] Training selesai (~2 hours with GPU)
- [ ] Output files generated
- [ ] Files copied to Flutter project
- [ ] Flutter app running dengan AI detection

---

## 🆘 Need Help?

1. **Setup issues?** → Check `VSCODE_SETUP.md`
2. **Training issues?** → Check troubleshooting section
3. **Flutter integration?** → Check `README_TRAINING.md`
4. **Still stuck?** → Check error message dan Google it!

---

**Ready?** Run this:
```powershell
.\setup.bat        # First time only
.\run_training.bat # Start training
```

Or:
```bash
pip install -r requirements.txt  # First time only
python training.py               # Start training
```

**Good luck!** 🚀
