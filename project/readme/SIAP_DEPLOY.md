# ⚡ Quick Start: Siap Deploy

## ✅ Yang Sudah Diperbaiki

- ✅ Application ID: `com.nutrix.app`
- ✅ App Name: **Nutrix**
- ✅ Signing config sudah disiapkan
- ✅ ProGuard rules untuk optimasi
- ✅ Namespace dan package seragam

## 🔑 Langkah Berikutnya (WAJIB!)

### 1. Generate Keystore

Buka PowerShell di folder project, lalu jalankan:

```powershell
cd android\app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Isi informasi:**
- Masukkan password keystore (INGAT INI!)
- Ulangi password
- Masukkan password key (INGAT INI!)
- Nama lengkap: [Nama Anda]
- Nama organisasi: Nutrix atau [Nama Perusahaan]
- Kota: [Kota Anda]
- Provinsi: [Provinsi Anda]
- Kode negara: ID
- Konfirmasi: yes

### 2. Update key.properties

Edit file `android/key.properties` dan ganti dengan password yang tadi:

```properties
storePassword=password_keystore_anda
keyPassword=password_key_anda
keyAlias=upload
storeFile=upload-keystore.jks
```

### 3. Build Release

```powershell
# Kembali ke root project
cd ..\..

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build App Bundle (untuk Play Store)
flutter build appbundle --release
```

**Output:** `build\app\outputs\bundle\release\app-release.aab`

### 4. Test Dulu (Optional tapi Recommended)

Build APK untuk test di device:

```powershell
flutter build apk --release
```

Install dan test:

```powershell
flutter install --release
```

## 📦 File Output untuk Upload

Setelah build berhasil, file yang akan di-upload ke Play Store:

📍 **`build\app\outputs\bundle\release\app-release.aab`**

Size biasanya: 20-50 MB (tergantung assets)

## 🎯 Checklist Sebelum Upload

- [ ] Keystore sudah digenerate dan password disimpan aman
- [ ] key.properties sudah diisi dengan password yang benar
- [ ] Build AAB berhasil tanpa error
- [ ] Test APK di real device (tidak ada crash)
- [ ] Siapkan assets untuk Play Store:
  - [ ] Icon 512x512px
  - [ ] Feature graphic 1024x500px
  - [ ] Screenshot minimal 2 (phone)
  - [ ] Description short & full
  - [ ] Privacy policy URL (jika pakai kamera/storage)

## 🚨 PENTING: Backup!

**Simpan di tempat AMAN:**
- `android/app/upload-keystore.jks`
- Password keystore & key
- Simpan di cloud backup (Google Drive, OneDrive, dll)

**⚠️ Jangan sampai hilang! Tidak bisa di-reset!**

## 🔧 Jika Ada Error

### Error: "keytool not found"
Pastikan Java JDK terinstall:
```powershell
java -version
```

### Error: "BUILD FAILED"
Cek error message, biasanya:
- Gradle sync issue: `flutter clean && flutter pub get`
- Missing dependencies: Cek internet connection

### Error: "Signing config not found"
Pastikan:
1. File `key.properties` ada di folder `android/`
2. File `upload-keystore.jks` ada di folder `android/app/`
3. Password di `key.properties` benar

## 📱 Setelah Build Berhasil

Lanjut ke **PANDUAN_DEPLOY_PLAY_STORE.md** bagian **5️⃣ Upload ke Google Play Console**

---

**Semua sudah disiapkan! Tinggal generate keystore dan build! 🚀**
