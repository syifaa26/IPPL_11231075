# 📱 Panduan Deploy ke Google Play Store

Panduan lengkap untuk mendeploy aplikasi Flutter ke Google Play Store.

## 📋 Prerequisites

- [x] Akun Google Play Console Developer ($25 one-time fee)
- [x] Aplikasi Flutter yang sudah siap
- [x] Java JDK terinstall (minimal Java 8)
- [x] Android Studio atau Android SDK

## 1️⃣ Persiapan Awal

### A. Cek dan Update Versi Aplikasi

Edit file `pubspec.yaml`:

```yaml
version: 1.0.0+1
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
# Contoh: 1.0.0+1, 1.0.1+2, 1.1.0+3
```

**Penting:** 
- Angka sebelum `+` adalah version name (yang dilihat user)
- Angka setelah `+` adalah version code (harus selalu naik setiap upload)

### B. Update App Information

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.yourapp">
    
    <application
        android:label="Nama App Anda"
        android:icon="@mipmap/ic_launcher">
```

Edit `android/app/build.gradle.kts` untuk app ID:

```kotlin
android {
    namespace = "com.example.yourapp"
    defaultConfig {
        applicationId = "com.example.yourapp"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

## 2️⃣ Buat Signing Key (Keystore)

### A. Generate Keystore

Buka terminal dan jalankan:

```powershell
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Isi informasi yang diminta:**
- Password keystore (INGAT INI!)
- Password key (INGAT INI!)
- Nama, Organisasi, Kota, dll.

**⚠️ PENTING:** Simpan file `upload-keystore.jks` dan password dengan aman!

### B. Buat key.properties

Buat file `android/key.properties`:

```properties
storePassword=password_keystore_anda
keyPassword=password_key_anda
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ Jangan commit file ini ke Git!**

Tambahkan ke `.gitignore`:

```
android/key.properties
android/app/upload-keystore.jks
```

### C. Konfigurasi build.gradle.kts

Edit `android/app/build.gradle.kts`:

```kotlin
// Tambahkan di atas android block
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... konfigurasi existing

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Untuk ProGuard (optional):
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

## 3️⃣ Build Release

### A. Clean & Build

```powershell
# Bersihkan build sebelumnya
flutter clean

# Get dependencies
flutter pub get

# Build App Bundle (Recommended untuk Play Store)
flutter build appbundle --release

# ATAU build APK (alternative)
flutter build apk --release --split-per-abi
```

**Output:**
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`

### B. Verify Build

```powershell
# Cek size
ls build/app/outputs/bundle/release/

# Test install APK di device
flutter install
```

## 4️⃣ Persiapan Assets untuk Play Store

Siapkan material berikut:

### A. App Icon
- **512x512 px** - High-res icon (PNG, 32-bit)
- **1024x500 px** - Feature graphic

### B. Screenshots (Minimal 2, maksimal 8)
- **Phone:** 16:9 atau 9:16 ratio
- **Tablet (optional):** 16:9 atau 9:16 ratio
- **Format:** PNG atau JPG
- **Dimensi:** 320px - 3840px

### C. Descriptions
- **Short description:** Max 80 karakter
- **Full description:** Max 4000 karakter
- **What's new:** Max 500 karakter (untuk update)

### D. Privacy Policy
- URL ke privacy policy (wajib jika ada sensitive permissions)

## 5️⃣ Upload ke Google Play Console

### A. Buat Aplikasi Baru

1. Buka [Google Play Console](https://play.google.com/console)
2. Klik **"Create app"**
3. Isi detail:
   - App name
   - Default language
   - App type (Game/App)
   - Free/Paid
   - Accept developer program policies

### B. Setup Store Listing

1. Masuk ke **Store listing**
2. Isi:
   - App name
   - Short description
   - Full description
   - App icon (512x512)
   - Feature graphic (1024x500)
   - Screenshots
   - Categorization
   - Contact details
   - Privacy policy

### C. Content Rating

1. Masuk ke **Content rating**
2. Isi questionnaire
3. Submit untuk mendapat rating

### D. App Content

1. Masuk ke **App content**
2. Lengkapi:
   - Privacy policy
   - Ads declaration
   - Target audience
   - News apps (jika applicable)
   - COVID-19 contact tracing/status apps (jika applicable)
   - Data safety

### E. Select Countries

1. Masuk ke **Countries/regions**
2. Pilih negara tempat app akan tersedia
3. Atau pilih "Available in all countries"

### F. Pricing

1. Masuk ke **Pricing**
2. Pilih:
   - Free
   - Paid (set harga)

## 6️⃣ Upload Build

### A. Create Release

1. Masuk ke **Production** (atau **Internal testing**/**Closed testing** untuk testing)
2. Klik **"Create new release"**
3. Upload **app-release.aab**
4. Isi **"Release name"** (contoh: "1.0.0")
5. Isi **"Release notes"** (what's new)
6. Review release
7. Klik **"Start rollout to Production"**

### B. Review dan Submit

1. Cek semua section di dashboard (harus semua hijau ✓)
2. Jika ada yang merah, lengkapi dulu
3. Klik **"Send for review"**

## 7️⃣ Proses Review

- **Waktu review:** 1-7 hari (biasanya 24-48 jam)
- **Status:** Cek di dashboard Play Console
- **Email notification:** Google akan kirim email jika ada masalah atau approved

## 8️⃣ Update Aplikasi (Versi Baru)

### A. Update Version

Edit `pubspec.yaml`:

```yaml
version: 1.0.1+2  # Naikkan version name dan WAJIB naikkan version code
```

### B. Build Release Baru

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

### C. Upload Update

1. Masuk ke **Production** > **Create new release**
2. Upload AAB baru
3. Isi release notes
4. Submit for review

## 🔧 Troubleshooting

### Error: "Upload failed: You need to use a different version code"

**Solusi:** Naikkan `version code` di `pubspec.yaml`

```yaml
version: 1.0.0+2  # Ubah angka setelah +
```

### Error: "App not signed"

**Solusi:** Pastikan `key.properties` dan konfigurasi signing sudah benar

### Error: "Unoptimized APK"

**Solusi:** Gunakan App Bundle (AAB) bukan APK:

```powershell
flutter build appbundle --release
```

### Error: "minSdkVersion too low"

**Solusi:** Update `minSdk` di `android/app/build.gradle.kts`:

```kotlin
minSdk = 21  # Minimal 21 untuk Play Store
```

### App ditolak: "Privacy Policy required"

**Solusi:** Tambahkan URL privacy policy di Store Listing

## 📝 Checklist Sebelum Upload

- [ ] Version code naik dari release sebelumnya
- [ ] App tested di real device
- [ ] All permissions explained di privacy policy
- [ ] Signing key configured
- [ ] Store listing lengkap (icon, screenshots, descriptions)
- [ ] Content rating completed
- [ ] Privacy policy URL added (jika required)
- [ ] Target audience selected
- [ ] Data safety form completed
- [ ] Countries/regions selected
- [ ] Build size optimal (<150MB untuk initial download)

## 🔐 Keamanan

**⚠️ JANGAN PERNAH:**
- Commit `key.properties` ke Git
- Share keystore file di public
- Lupa password keystore (tidak bisa di-reset!)

**💾 BACKUP:**
- Simpan `upload-keystore.jks` di tempat aman
- Simpan password di password manager
- Buat backup keystore di cloud storage pribadi

## 📊 Post-Launch

### Monitor Aplikasi

1. **Play Console Dashboard:**
   - Downloads
   - Ratings & reviews
   - Crashes & ANRs
   - Pre-launch reports

2. **Firebase (Optional):**
   - Analytics
   - Crashlytics
   - Performance monitoring

### Respond to Reviews

- Balas review user (terutama yang negatif)
- Fix bugs yang dilaporkan
- Release update reguler

## 🚀 Best Practices

1. **Testing:**
   - Gunakan Internal/Closed testing dulu sebelum Production
   - Test di berbagai device dan Android versions

2. **Release Strategy:**
   - Staged rollout (mulai dari 20% users, lalu naikkan bertahap)
   - Monitor crash reports setelah release

3. **Updates:**
   - Release update reguler (1-2 bulan sekali)
   - Fix critical bugs segera

4. **Store Optimization:**
   - Screenshot berkualitas tinggi
   - Description jelas dan menarik
   - Keywords relevant di title/description
   - Update icon & screenshots berkala

## 📚 Resources

- [Flutter: Build and release Android app](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- [App Signing Best Practices](https://developer.android.com/studio/publish/app-signing)

---

**Good luck dengan launch aplikasi Anda! 🎉**

Jika ada pertanyaan atau masalah, refer ke [Flutter documentation](https://docs.flutter.dev) atau [Play Console support](https://support.google.com/googleplay/android-developer).
