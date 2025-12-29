# 🚀 SETUP & TRAINING DI VSCODE - Step by Step

## 📋 Prerequisites

### 1. Python Installation
```bash
# Check Python version (harus 3.8 atau lebih baru)
python --version

# Jika belum ada, download dari: https://www.python.org/downloads/
```

### 2. GPU Setup (Optional tapi Recommended)
**Jika punya NVIDIA GPU:**
```bash
# Install CUDA Toolkit 11.8
# Download dari: https://developer.nvidia.com/cuda-11-8-0-download-archive

# Install cuDNN 8.6
# Download dari: https://developer.nvidia.com/cudnn

# Verify GPU
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

**Jika tidak punya GPU:**
- Training akan lebih lambat (~10-20x)
- Bisa reduce EPOCHS atau gunakan Google Colab

## 🛠️ Setup Instructions

### Step 1: Setup Virtual Environment (Recommended)

**Windows:**
```powershell
# Navigate ke folder API
cd d:\VSCODE\IPPL\API

# Create virtual environment
python -m venv venv

# Activate
.\venv\Scripts\Activate.ps1

# Jika error "execution policy", run:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Linux/Mac:**
```bash
cd /path/to/IPPL/API

# Create virtual environment
python3 -m venv venv

# Activate
source venv/bin/activate
```

### Step 2: Install Dependencies

```bash
# Upgrade pip first
pip install --upgrade pip

# Install all dependencies
pip install -r requirements.txt

# Verify TensorFlow installation
python -c "import tensorflow as tf; print(f'TensorFlow version: {tf.__version__}')"
```

**Jika ada error TensorFlow:**
```bash
# For CPU only
pip install tensorflow-cpu

# For GPU (Windows/Linux)
pip install tensorflow[and-cuda]
```

### Step 3: Setup Kaggle API

**Windows:**
```powershell
# Buat folder .kaggle di home directory
mkdir $env:USERPROFILE\.kaggle

# Copy kaggle.json (download dari kaggle.com/settings/account)
copy kaggle.json $env:USERPROFILE\.kaggle\kaggle.json
```

**Linux/Mac:**
```bash
# Buat folder .kaggle
mkdir -p ~/.kaggle

# Copy kaggle.json
cp kaggle.json ~/.kaggle/kaggle.json

# Set permissions
chmod 600 ~/.kaggle/kaggle.json
```

**Get kaggle.json:**
1. Login ke https://www.kaggle.com
2. Go to Account Settings (https://www.kaggle.com/settings/account)
3. Scroll ke section "API"
4. Click "Create New API Token"
5. File kaggle.json akan ter-download

### Step 4: Verify Setup

```bash
# Test Kaggle API
kaggle datasets list

# Test TensorFlow
python -c "import tensorflow as tf; print('TensorFlow OK')"

# Test imports
python -c "from tensorflow.keras.applications import EfficientNetB0; print('Keras OK')"
```

## ▶️ Running Training

### Option 1: Direct Run (Full Training)

```bash
# Make sure virtual environment is activated
# Windows: .\venv\Scripts\Activate.ps1
# Linux/Mac: source venv/bin/activate

# Run training script
python training.py
```

**Training akan:**
1. ✅ Check kaggle.json
2. ✅ Download Food-101 dataset (~5GB, sekali saja)
3. ✅ Extract dataset
4. ✅ Load and prepare data
5. ✅ Build model
6. ✅ Train for 30 epochs (~1-2 hours dengan GPU, 10-20 hours tanpa GPU)
7. ✅ Save models (.tflite, .h5, .keras)
8. ✅ Generate visualizations

### Option 2: Test Run (Quick Test)

Edit `training.py` baris 142:
```python
# Change from:
EPOCHS = 30

# To:
EPOCHS = 3  # Just for testing
```

Lalu run:
```bash
python training.py
```

### Option 3: Run in VS Code Debugger

1. Open `training.py` di VSCode
2. Press `F5` atau click "Run and Debug"
3. Select "Python File"
4. Monitor progress di Debug Console

## 📊 Monitoring Training

### Real-time Monitoring

Training akan show:
```
Epoch 1/30
250/250 [==============================] - 120s 480ms/step
  loss: 2.5634 - accuracy: 0.4521 - val_loss: 2.1234 - val_accuracy: 0.5123
Epoch 2/30
250/250 [==============================] - 115s 460ms/step
  loss: 2.1245 - accuracy: 0.5234 - val_loss: 1.9876 - val_accuracy: 0.5678
...
```

### TensorBoard (Optional)

Edit training.py, tambahkan callback:
```python
from tensorflow.keras.callbacks import TensorBoard

callbacks = [
    TensorBoard(log_dir='./logs'),  # Add this
    ModelCheckpoint(...),
    EarlyStopping(...),
    ReduceLROnPlateau(...)
]
```

Lalu run TensorBoard:
```bash
tensorboard --logdir=./logs
```

Open browser: http://localhost:6006

## 🐛 Troubleshooting

### Error: "No module named 'tensorflow'"
```bash
pip install tensorflow
# atau untuk GPU:
pip install tensorflow[and-cuda]
```

### Error: "kaggle.json not found"
```bash
# Check lokasi file
# Windows:
dir %USERPROFILE%\.kaggle\kaggle.json

# Linux/Mac:
ls -la ~/.kaggle/kaggle.json

# Jika tidak ada, copy dari folder API
```

### Error: "Out of Memory"
Edit training.py:
```python
# Reduce batch size
BATCH_SIZE = 16  # dari 32
# atau
BATCH_SIZE = 8   # kalau masih error
```

### Error: "Dataset download failed"
**Manual download:**
1. Go to: https://www.kaggle.com/datasets/dansbecker/food-101
2. Click "Download" (perlu login)
3. Extract ke: `API/food101/images/`
4. Run training.py lagi

### Training sangat lambat (No GPU)
**Options:**
1. Reduce epochs: `EPOCHS = 10`
2. Use smaller model: Comment EfficientNetB0, use simple CNN
3. Use Google Colab (Free GPU)
4. Use subset of data

### GPU not detected
```bash
# Install CUDA-enabled TensorFlow
pip uninstall tensorflow
pip install tensorflow[and-cuda]

# Verify
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"
```

## 📁 Output Files

Setelah training selesai, di folder `API/` akan ada:

```
API/
├── food_detection_model.tflite     ← Copy ke Flutter
├── class_names.json                ← Copy ke Flutter
├── model_info.json                 ← Info metadata
├── training_history.png            ← Grafik hasil
├── best_food_model.keras           ← Best checkpoint
├── food_detection_model.h5         ← H5 format
└── food101/                        ← Dataset (bisa dihapus setelah training)
```

## 📱 Copy to Flutter

**Windows:**
```powershell
# Buat folder assets di project
mkdir ..\project\assets\models -Force

# Copy files
copy food_detection_model.tflite ..\project\assets\models\
copy class_names.json ..\project\assets\
```

**Linux/Mac:**
```bash
# Buat folder assets
mkdir -p ../project/assets/models

# Copy files
cp food_detection_model.tflite ../project/assets/models/
cp class_names.json ../project/assets/
```

## ⚡ Performance Tips

### 1. Reduce Training Time
```python
EPOCHS = 15          # Instead of 30
BATCH_SIZE = 64      # If you have enough GPU memory
```

### 2. Use Mixed Precision (GPU only)
```python
# Add at top of training.py after imports
from tensorflow.keras import mixed_precision
mixed_precision.set_global_policy('mixed_float16')
```

### 3. Data Caching
Already implemented! Dataset di-cache ke memory untuk faster epochs.

### 4. Early Stopping
Already implemented! Training stops jika tidak ada improvement.

## 📈 Expected Timeline

### With GPU (NVIDIA 3060 or better):
- Dataset download: 10-15 minutes (one time)
- Training 30 epochs: 1-2 hours
- Total: ~2 hours

### Without GPU (CPU only):
- Dataset download: 10-15 minutes (one time)
- Training 30 epochs: 10-20 hours
- Recommendation: Use fewer epochs (5-10) or use Colab

## ✅ Success Checklist

- [ ] Python 3.8+ installed
- [ ] Virtual environment created
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Kaggle API configured (kaggle.json in correct location)
- [ ] Can run `kaggle datasets list` successfully
- [ ] TensorFlow imports working
- [ ] GPU detected (optional)
- [ ] Run `python training.py` without errors
- [ ] Training completes successfully
- [ ] Output files generated
- [ ] Files copied to Flutter project

## 📞 Need Help?

1. Check error message carefully
2. Google the specific error
3. Check TensorFlow/Keras documentation
4. Verify all setup steps completed
5. Try reducing batch size or epochs

## 🔗 Useful Commands

```bash
# Check Python packages
pip list

# Check TensorFlow version
python -c "import tensorflow as tf; print(tf.__version__)"

# Check GPU
python -c "import tensorflow as tf; print(tf.config.list_physical_devices('GPU'))"

# Test Kaggle
kaggle datasets list

# Monitor GPU (Windows - Task Manager)
# Monitor GPU (Linux)
nvidia-smi

# Kill Python process if stuck (Windows)
taskkill /F /IM python.exe

# Kill Python process (Linux/Mac)
killall python
```

---

**Ready to train?** Follow the steps above and run:
```bash
python training.py
```

**Questions?** Check troubleshooting section or README_TRAINING.md!
