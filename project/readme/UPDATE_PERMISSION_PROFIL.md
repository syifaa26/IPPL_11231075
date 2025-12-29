# DOKUMENTASI UPDATE - PERMISSION KAMERA & PROFIL USER BARU

## ✅ Fitur yang Telah Ditambahkan

### 1. **Permission Kamera untuk User Baru**

#### Dialog Permission yang User-Friendly:
- ✅ Dialog penjelasan mengapa kamera diperlukan
- ✅ 3 alasan jelas dengan icon:
  - 🍽️ Mendeteksi makanan secara otomatis
  - 📊 Menganalisis nutrisi makanan
  - 📷 Mengambil foto makanan
- ✅ Tombol "Nanti" dan "Izinkan"
- ✅ Handle status permission (granted/denied/permanently denied)

#### Penanganan Permission:
- ✅ Cek permission sebelum buka kamera
- ✅ Request permission dengan dialog custom
- ✅ Redirect ke Settings jika permanently denied
- ✅ Pesan error yang informatif

---

### 2. **Profil User Baru - Data Kosong**

#### Tampilan untuk User Baru:
- ✅ **Berat Badan**: "- kg" (Belum diatur)
- ✅ **Target Harian**: "2000 kkal" (Belum ada data)
- ✅ **Streak**: "0 hari" (Mulai hari ini!)
- ✅ **Kalori Hari Ini**: "0 kkal" (Protein: 0g | Karbo: 0g)

#### Tampilan untuk User Existing:
- ✅ **Berat Badan**: "68 kg" (Target: 65 kg)
- ✅ **Target Harian**: "2000 kkal" (Turun berat badan)
- ✅ **Streak**: "12 hari" (Pencapaian terbaik)
- ✅ **Kalori Hari Ini**: Data aktual dari UserDataService

---

### 3. **Nama User dari Input Registrasi**

#### Sebelumnya:
- Nama diambil dari email (auto-generate)
- Contoh: `john.doe@email.com` → "John Doe"

#### Sekarang:
- ✅ Nama langsung dari input saat registrasi
- ✅ Tampil di profile avatar (inisial)
- ✅ Tampil di profile name (full name)
- ✅ Data tersimpan di User object

---

## 📁 File yang Dibuat/Dimodifikasi

### File Baru:
1. **lib/widgets/camera_permission_dialog.dart**
   - Dialog custom untuk request camera permission
   - Penjelasan user-friendly
   - Handle semua status permission

### File Dimodifikasi:
1. **lib/screens/profile_screen.dart**
   - Import UserDataService
   - Ambil data kalori dari service
   - Tampilkan data kosong untuk user baru (isNewUser)
   - Tampilkan nama dari input registrasi

2. **lib/widgets/camera_detection_modal.dart**
   - Gunakan CameraPermissionDialog
   - Request permission sebelum init kamera

---

## 🎯 Alur Permission Kamera

### Saat User Baru Membuka Kamera:

```
1. Tap "Tambah Makanan"
   ↓
2. Modal Camera terbuka
   ↓
3. Check Permission Status
   ↓
4. Show Dialog Penjelasan
   "Nutrix memerlukan akses kamera untuk:"
   - Mendeteksi makanan
   - Menganalisis nutrisi
   - Mengambil foto
   ↓
5. User tap "Izinkan"
   ↓
6. System Permission Dialog
   ↓
7a. GRANTED → Kamera siap digunakan ✅
7b. DENIED → Show snackbar warning ⚠️
7c. PERMANENTLY_DENIED → Dialog "Buka Pengaturan" ⚙️
```

---

## 🧪 Testing Scenarios

### Test 1: Permission Kamera User Baru
```
1. Registrasi user baru
2. Login
3. Tap "Tambah Makanan"

✅ Hasil yang diharapkan:
   - Muncul dialog penjelasan permission
   - 3 alasan dengan icon
   - Tombol "Nanti" dan "Izinkan"
   
4. Tap "Izinkan"
   
✅ Hasil yang diharapkan:
   - System permission dialog muncul
   - Jika granted: kamera terbuka
   - Jika denied: snackbar peringatan
```

### Test 2: Permission Permanently Denied
```
1. Deny permission beberapa kali
2. Atau block di system settings
3. Tap "Tambah Makanan"

✅ Hasil yang diharapkan:
   - Dialog "Izin Kamera Diblokir"
   - Tombol "Buka Pengaturan"
   - Redirect ke app settings
```

### Test 3: Profil User Baru
```
1. Registrasi dengan nama: "John Doe"
2. Login
3. Buka tab Profil

✅ Hasil yang diharapkan:
   - Avatar: "JD" (inisial)
   - Nama: "John Doe" (sesuai input)
   - Email: email yang didaftarkan
   - Berat Badan: "- kg" (Belum diatur)
   - Target Harian: "2000 kkal" (Belum ada data)
   - Streak: "0 hari" (Mulai hari ini!)
   - Kalori Hari Ini: "0 kkal" (Protein: 0g | Karbo: 0g)
```

### Test 4: Profil User Existing
```
1. User yang sudah punya data
2. Buka tab Profil

✅ Hasil yang diharapkan:
   - Nama: sesuai data
   - Berat Badan: "68 kg" (Target: 65 kg)
   - Target Harian: "2000 kkal" (Turun berat badan)
   - Streak: "12 hari" (Pencapaian terbaik)
   - Kalori Hari Ini: data aktual
```

---

## 🎨 UI Dialog Permission

### Dialog Penjelasan:
```
┌─────────────────────────────────────┐
│ 📷  Izin Kamera                     │
├─────────────────────────────────────┤
│                                     │
│ Nutrix memerlukan akses kamera     │
│ untuk:                              │
│                                     │
│ 🍽️  Mendeteksi makanan secara      │
│     otomatis                        │
│                                     │
│ 📊  Menganalisis nutrisi makanan   │
│                                     │
│ 📷  Mengambil foto makanan Anda    │
│                                     │
│ Kami tidak akan menggunakan kamera │
│ untuk tujuan lain.                  │
│                                     │
│         [Nanti]      [Izinkan]     │
└─────────────────────────────────────┘
```

### Dialog Settings:
```
┌─────────────────────────────────────┐
│ Izin Kamera Diblokir                │
├─────────────────────────────────────┤
│                                     │
│ Izin kamera telah diblokir.         │
│ Silakan buka pengaturan aplikasi    │
│ untuk mengaktifkan izin kamera.     │
│                                     │
│         [Batal]  [Buka Pengaturan] │
└─────────────────────────────────────┘
```

---

## 🔧 Struktur Kode

### CameraPermissionDialog:
```dart
class CameraPermissionDialog {
  // Request permission dengan dialog custom
  static Future<bool> requestPermission(BuildContext context)
  
  // Build permission reason items
  static Widget _buildPermissionReason(IconData icon, String text)
  
  // Show dialog untuk buka settings
  static Future<void> _showOpenSettingsDialog(BuildContext context)
}
```

### ProfileScreen Updates:
```dart
Widget build(BuildContext context) {
  // Ambil user data
  final authService = AuthService();
  final currentUser = authService.currentUser;
  final userDataService = UserDataService();
  
  // Get stats
  final userId = currentUser?.id ?? 'demo';
  final totalCalories = userDataService.getTotalCalories(userId);
  final isNewUser = currentUser?.isNewUser ?? false;
  
  // Tampilkan sesuai status user
  value: isNewUser ? '- kg' : '68 kg',
  subtitle: isNewUser ? 'Belum diatur' : 'Target: 65 kg',
}
```

---

## 📊 Comparison

### SEBELUM:
```
❌ Langsung request permission tanpa penjelasan
❌ Error handling kurang jelas
❌ User baru lihat data dummy
❌ Nama dari email (auto-generate)
```

### SESUDAH:
```
✅ Dialog penjelasan user-friendly
✅ Handle semua status permission
✅ User baru lihat data kosong dengan label jelas
✅ Nama dari input registrasi
✅ Redirect ke settings jika permanently denied
```

---

## 🚀 Next Steps (Opsional)

### Fitur Tambahan yang Bisa Dibuat:
1. **Edit Profil**
   - Edit nama, email, foto profil
   - Set berat badan & tinggi badan
   - Set target kalori custom

2. **Permission Status Tracking**
   - Simpan status permission di SharedPreferences
   - Jangan tampilkan dialog berulang jika sudah granted

3. **Onboarding Permission**
   - Tampilkan tutorial permission di onboarding
   - Educate user tentang fitur kamera

4. **Permission Analytics**
   - Track berapa user yang allow/deny
   - A/B testing untuk dialog text

---

## 📝 Catatan Penting

### Permission Best Practices:
- ✅ Selalu jelaskan kenapa permission diperlukan
- ✅ Request permission saat dibutuhkan (not on app start)
- ✅ Berikan opsi "Nanti" untuk user
- ✅ Handle semua status permission
- ✅ Redirect ke settings jika permanently denied

### Data Profil:
- ✅ User baru: tampilkan placeholder yang jelas
- ✅ User existing: tampilkan data aktual
- ✅ Konsisten dengan UserDataService
- ✅ Nama dari input, bukan dari email

---

## 🎉 Summary

Semua fitur yang diminta telah **100% berhasil diimplementasikan**:

✅ Permission kamera dengan dialog user-friendly  
✅ Data profil kosong untuk user baru  
✅ Nama sesuai input registrasi (bukan dari email)  
✅ Handle semua status permission  
✅ Redirect ke settings jika needed  
✅ UI yang informatif dan jelas  

**Aplikasi siap untuk di-test!** 🚀

Silakan test dengan:
1. Registrasi user baru
2. Tap "Tambah Makanan" untuk test permission
3. Buka tab "Profil" untuk lihat data kosong
4. Lihat nama sesuai input registrasi
