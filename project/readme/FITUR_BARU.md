# DOKUMENTASI FITUR BARU - NUTRIX APP

## ✅ Fitur yang Telah Ditambahkan

### 1. **Kalori Kosong untuk User Baru** 
- ✅ User baru akan memiliki kalori 0 / 2000 kkal
- ✅ List makanan kosong dengan pesan "Belum ada makanan hari ini"
- ✅ Protein, Karbohidrat, dan Kalori sisa semuanya 0

### 2. **Onboarding/Tutorial untuk User Baru**
- ✅ 5 halaman panduan interaktif
- ✅ Tampil otomatis setelah registrasi
- ✅ Bisa di-skip atau dilanjutkan
- ✅ Elegant design dengan icon dan warna berbeda

### 3. **Validasi Password**
- ✅ Password disimpan saat registrasi
- ✅ Validasi password saat login
- ✅ Pesan error spesifik untuk password salah

### 4. **Deteksi Email Duplikat**
- ✅ Cek email sudah terdaftar
- ✅ Redirect ke login dengan email terisi otomatis
- ✅ Pesan warning yang jelas

---

## 📁 File yang Dibuat/Dimodifikasi

### File Baru:
1. **lib/services/user_data_service.dart**
   - Service untuk mengelola data kalori per user
   - Menyimpan meals, target kalori, dan statistik

2. **lib/screens/onboarding_screen.dart**
   - Screen panduan untuk user baru
   - 5 halaman tutorial interaktif

### File Dimodifikasi:
1. **lib/services/auth_service.dart**
   - Tambah field `isNewUser` dan `password` di class User
   - Tambah tracking onboarding status
   - Validasi password saat login

2. **lib/screens/auth_screen.dart**
   - Redirect ke onboarding setelah registrasi
   - Handle password validation errors

3. **lib/main.dart**
   - Import services baru
   - Tambah route `/onboarding`
   - Update home content untuk data dinamis
   - Tampilkan UI kosong jika belum ada data

---

## 🎯 Alur User Baru

### Registrasi:
1. User mengisi form registrasi
2. Sistem menyimpan data user dengan password
3. Mark user sebagai `isNewUser = true`
4. Arahkan ke **Onboarding Screen**

### Onboarding:
1. Tampilkan 5 halaman tutorial:
   - Selamat datang di Nutrix
   - Deteksi makanan otomatis
   - Pantau kalori harian
   - Statistik & progress
   - Siap memulai?
2. User bisa "Lewati" atau "Lanjut"
3. Setelah selesai → arahkan ke **Home Screen**

### Home Screen (User Baru):
- Kalori: **0 / 2000 kkal**
- Sisa: **2000**
- Protein: **0g**
- Karbo: **0g**
- List makanan: **"Belum ada makanan hari ini"**

---

## 🧪 Testing Fitur

### Test 1: Registrasi User Baru
```
1. Buka aplikasi
2. Tab "Daftar"
3. Isi:
   - Nama: John Doe
   - Email: john@test.com
   - Password: test123
   - Konfirmasi: test123
4. Tap "Daftar"

✅ Hasil yang diharapkan:
   - Muncul pesan "Akun berhasil dibuat!"
   - Arahkan ke Onboarding Screen (5 halaman)
   - Bisa skip atau lanjut
   - Setelah selesai masuk ke Home
   - Kalori 0, list makanan kosong
```

### Test 2: Validasi Password
```
1. Setelah registrasi dengan password: test123
2. Logout (jika perlu)
3. Login dengan:
   - Email: john@test.com
   - Password: salah123

✅ Hasil yang diharapkan:
   - Muncul pesan "Password yang Anda masukkan salah"
   - Tidak bisa masuk

4. Login dengan password benar: test123
   ✅ Berhasil masuk ke Home
```

### Test 3: Email Sudah Terdaftar
```
1. Register dengan email: john@test.com
2. Coba register lagi dengan email sama

✅ Hasil yang diharapkan:
   - Pesan "Email sudah terdaftar!"
   - Otomatis pindah ke tab Login
   - Email terisi otomatis di form login
```

### Test 4: Data Kalori Kosong
```
1. Login sebagai user baru
2. Lihat Home Screen

✅ Hasil yang diharapkan:
   - Kalori: 0 / 2000 kkal
   - Progress bar kosong (0%)
   - Sisa: 2000
   - Protein: 0g
   - Karbo: 0g
   - List makanan menampilkan:
     "Belum ada makanan hari ini"
     "Tap 'Tambah Makanan' untuk memulai"
```

---

## 🎨 UI Onboarding Screen

### Halaman 1 - Selamat Datang
- Icon: 🍽️ Restaurant Menu (hijau)
- Judul: "Selamat Datang di Nutrix!"
- Deskripsi: "Aplikasi pelacak nutrisi..."

### Halaman 2 - Deteksi Makanan
- Icon: 📷 Camera (biru)
- Judul: "Deteksi Makanan Otomatis"
- Deskripsi: "Gunakan kamera..."

### Halaman 3 - Pantau Kalori
- Icon: 📊 Bar Chart (orange)
- Judul: "Pantau Kalori Harian"
- Deskripsi: "Lacak asupan kalori..."

### Halaman 4 - Statistik
- Icon: 📈 Trending Up (ungu)
- Judul: "Statistik & Progress"
- Deskripsi: "Lihat perkembangan..."

### Halaman 5 - Siap Memulai
- Icon: 🎉 Celebration (hijau)
- Judul: "Siap Memulai?"
- Deskripsi: "Mari mulai perjalanan..."

---

## 🔧 Struktur Data

### UserDataService
```dart
class UserDataService {
  Map<String, UserCalorieData> _userCalorieData;
  
  - getCalorieData(userId)
  - addMeal(userId, meal)
  - getMeals(userId)
  - getTotalCalories(userId)
  - setCalorieTarget(userId, target)
  - getRemainingCalories(userId)
}
```

### UserCalorieData
```dart
class UserCalorieData {
  List<Meal> meals = [];
  int targetCalories = 2000;
  
  - totalCalories (computed)
  - totalProtein (computed)
  - totalCarbs (computed)
  - totalFat (computed)
}
```

### Meal
```dart
class Meal {
  String name;
  String type; // Sarapan, Makan Siang, Makan Malam, Camilan
  String time;
  int calories;
  int protein;
  int carbs;
  int fat;
}
```

---

## 🚀 Next Steps (Opsional)

### Fitur yang Bisa Ditambahkan:
1. **Simpan onboarding status** di SharedPreferences
2. **Set target kalori** berdasarkan profil user (tinggi, berat, aktivitas)
3. **Animasi transisi** antar halaman onboarding
4. **Tutorial interaktif** di dalam aplikasi (tooltips)
5. **Reset password** functionality
6. **Persistent storage** untuk data kalori (database/API)

---

## 📝 Catatan Penting

⚠️ **Untuk Production:**
- Hash password (gunakan bcrypt/argon2)
- Simpan data di database/API
- Implementasi JWT/token authentication
- Validasi email dengan OTP
- HTTPS untuk semua request

✅ **Saat ini untuk Development:**
- Password plaintext (OK untuk testing)
- Data di memory (hilang saat restart)
- Singleton pattern untuk services

---

## 🎉 Summary

Semua fitur yang diminta telah berhasil diimplementasikan:

✅ Kalori kosong untuk user baru
✅ Onboarding/tutorial untuk user baru  
✅ Validasi password
✅ Deteksi email duplikat
✅ UI yang clean dan user-friendly

Silakan test aplikasi dan lihat hasilnya! 🚀
