# Fitur Baru: Kalender Catatan Harian & Sinkronisasi Notifikasi

## 📅 Kalender Catatan Harian

### Lokasi
Fitur ini ditambahkan di **Halaman Statistik** (Statistics Screen)

### Fitur Utama
1. **Kalender Interaktif**
   - Navigasi bulan menggunakan tombol panah
   - Tampilan grid tanggal dengan indikator visual
   - Highlight tanggal hari ini

2. **Indikator Visual**
   - 🟢 **Hijau**: Ada makanan yang dicatat pada hari tersebut
   - 🟡 **Kuning**: Ada catatan harian
   - 🔵 **Biru**: Hari ini (border biru)
   - 🟣 **Ungu**: Tanggal yang dipilih

3. **Catatan Harian**
   - Klik tanggal untuk melihat detail
   - Menampilkan catatan dan jumlah makanan
   - Edit catatan dengan dialog popup
   - Auto-save ke UserDataService

4. **Legend**
   - Penjelasan warna indikator di bawah kalender

### File yang Dibuat/Diubah
- ✅ `lib/widgets/daily_notes_calendar.dart` - Widget kalender baru
- ✅ `lib/services/user_data_service.dart` - Tambah fungsi untuk catatan
- ✅ `lib/screens/statistics_screen.dart` - Integrasi kalender

### Fungsi Baru di UserDataService
```dart
// Menyimpan catatan harian
void saveDailyNotes(String userId, DateTime date, String notes)

// Membaca catatan harian
String getDailyNotes(String userId, DateTime date)

// Cek apakah ada catatan
bool hasNotesOnDate(String userId, DateTime date)

// Cek apakah ada makanan
bool hasMealsOnDate(String userId, DateTime date)

// Ambil makanan untuk tanggal tertentu
List<Meal> getMealsForDate(String userId, DateTime date)
```

---

## 🔄 Sinkronisasi Notifikasi Antar Perangkat

### Lokasi
- Akses dari **Settings > Notification Settings > Sinkronisasi Antar Perangkat**
- Screen baru: `NotificationSyncScreen`

### Fitur Utama

1. **Auto-Sync**
   - Sinkronisasi otomatis setiap kali ada perubahan pengaturan
   - Menyimpan ke SharedPreferences dengan ID user
   - Real-time update status sinkronisasi

2. **Status Card**
   - Menampilkan status: Aktif/Nonaktif
   - Timestamp terakhir sinkronisasi
   - Loading indicator saat syncing
   - Visual gradient untuk status aktif

3. **Pengaturan Sync**
   - Toggle on/off sinkronisasi
   - Tombol "Sinkronkan Sekarang" untuk force sync
   - Tombol "Hapus Data Sinkronisasi" dengan konfirmasi

4. **Data yang Disinkronkan**
   - ✅ Pengaturan notifikasi (on/off)
   - ✅ Reminder sarapan, makan siang, makan malam
   - ✅ Reminder minum air
   - ✅ Waktu reminder untuk setiap makanan
   - ✅ Device ID dan timestamp

5. **Daftar Perangkat**
   - Menampilkan perangkat yang tersinkronisasi
   - Status aktif/tidak aktif
   - Info terakhir sinkronisasi
   - Device ID unik

### File yang Dibuat/Diubah
- ✅ `lib/services/notification_sync_service.dart` - Service sinkronisasi baru
- ✅ `lib/services/notification_service.dart` - Integrasi dengan sync service
- ✅ `lib/screens/notification_sync_screen.dart` - UI untuk sync settings
- ✅ `lib/screens/notification_settings_screen.dart` - Tambah tombol ke sync screen

### Cara Kerja Sinkronisasi

1. **Inisialisasi**
   ```dart
   final syncService = NotificationSyncService();
   await syncService.initialize();
   ```

2. **Set User ID**
   ```dart
   notificationService.setCurrentUser(userId);
   ```

3. **Auto-Sync**
   - Setiap perubahan pengaturan otomatis trigger sync
   - Data disimpan dengan format: `notification_sync_{userId}_settings`
   - Timestamp disimpan untuk tracking

4. **Load Synced Data**
   - Saat login, data sync dimuat otomatis
   - Preferences di-merge dengan data lokal
   - Prioritas: Data sync > Data lokal default

### API NotificationSyncService

```dart
// Enable/disable sync
Future<void> setSyncEnabled(bool enabled)

// Sync pengaturan notifikasi
Future<void> syncNotificationPreferences(
  String userId, {
  required bool isEnabled,
  required bool breakfastReminder,
  required bool lunchReminder,
  required bool dinnerReminder,
  required bool waterReminder,
})

// Sync waktu reminder
Future<void> syncReminderTimes(String userId, Map<String, TimeOfDay> times)

// Load synced settings
Future<Map<String, dynamic>?> loadSyncedSettings(String userId)

// Force sync now
Future<void> syncNow()

// Get sync status
String getSyncStatusMessage()

// Get synced devices
Future<List<Map<String, dynamic>>> getSyncedDevices(String userId)

// Clear sync data
Future<void> clearSyncData(String userId)
```

---

## 📦 Dependensi Baru

### pubspec.yaml
```yaml
dependencies:
  intl: ^0.19.0  # Untuk formatting tanggal di kalender
```

**Install dengan:**
```bash
flutter pub get
```

---

## 🎨 UI/UX

### Kalender Catatan Harian
- Card dengan shadow elevation
- Grid 7x6 untuk tanggal
- Responsive touch untuk pilih tanggal
- Dialog untuk edit catatan dengan TextField multiline
- Legend dengan icon berwarna

### Sinkronisasi Notifikasi
- Gradient card untuk status
- Icon cloud_done/cloud_off
- Progress indicator untuk loading state
- Device list dengan badge "Aktif"
- Info section dengan border dan background

---

## 🚀 Cara Menggunakan

### Kalender Catatan Harian

1. Buka app, pergi ke tab **Statistik**
2. Scroll ke bawah untuk melihat **Kalender Catatan Harian**
3. Klik tanggal untuk melihat detail
4. Klik icon edit untuk menambah/ubah catatan
5. Catatan disimpan otomatis per user dan tanggal

### Sinkronisasi Notifikasi

1. Buka **Settings** dari profil
2. Pilih **Notification Settings**
3. Klik tombol **"Sinkronisasi Antar Perangkat"**
4. Toggle **Sinkronisasi Otomatis** untuk enable/disable
5. Klik **"Sinkronkan Sekarang"** untuk force sync
6. Pengaturan notifikasi akan disinkronkan ke semua perangkat

---

## 🔧 Technical Details

### Data Structure

**Daily Notes Storage:**
```dart
Map<String, Map<String, String>> _dailyNotes = {
  'userId': {
    'yyyy-mm-dd': 'catatan hari ini',
  }
}
```

**Sync Settings Storage:**
```json
{
  "settings": {
    "type": "preferences",
    "isEnabled": true,
    "breakfastReminder": true,
    ...
  },
  "syncTime": "2025-12-28T10:00:00.000Z",
  "deviceId": "device_1234567890"
}
```

### State Management
- `ChangeNotifier` untuk reactive updates
- `setState()` untuk UI updates
- `SharedPreferences` untuk persistence

---

## 📝 Testing Checklist

### Kalender
- [ ] Navigasi bulan berhasil
- [ ] Klik tanggal menampilkan detail
- [ ] Edit catatan tersimpan
- [ ] Indikator muncul setelah ada data
- [ ] Legend tampil dengan benar

### Sinkronisasi
- [ ] Toggle sync enable/disable
- [ ] Status card update real-time
- [ ] Force sync berfungsi
- [ ] Data tersimpan per user
- [ ] Clear sync data berhasil
- [ ] Tombol navigasi ke sync screen

---

## 🐛 Known Issues & Future Improvements

### Kalender
- ✅ Sudah implement semua fitur dasar
- 🔜 Bisa ditambahkan: Export catatan ke PDF
- 🔜 Bisa ditambahkan: Search catatan

### Sinkronisasi
- ⚠️ Saat ini menggunakan SharedPreferences (lokal)
- 🔜 Future: Integrate dengan Firebase Cloud Messaging
- 🔜 Future: Real-time sync antar perangkat
- 🔜 Future: Conflict resolution untuk edit bersamaan

---

## 💡 Tips untuk Developer

1. **Kalender**
   - Gunakan `intl` package untuk formatting tanggal
   - Date key format: `yyyy-mm-dd` untuk konsistensi
   - Always check null untuk data user

2. **Sinkronisasi**
   - Initialize sync service di startup
   - Set user ID setelah login
   - Handle error dengan try-catch
   - Show feedback ke user (SnackBar)

---

## 📱 Screenshots

### Kalender Catatan Harian
```
┌────────────────────────────────┐
│  Catatan Harian    ← Dec 2025 →│
├────────────────────────────────┤
│ Min Sen Sel Rab Kam Jum Sab   │
│  1🟢  2   3   4   5   6   7   │
│  8   9  10🟡 11  12  13  14   │
│ 15  16  17  18  19  20  21   │
│ 22  23  24  25  26  27 [28]🔵│
│ 29  30  31                     │
├────────────────────────────────┤
│ 📝 28 December 2025            │
│ Catatan: Makan teratur hari ini│
│ Makanan yang dicatat: 3 item  │
└────────────────────────────────┘
```

### Sinkronisasi Notifikasi
```
┌────────────────────────────────┐
│  ☁️ Sinkronisasi Aktif         │
│  Baru saja disinkronkan        │
├────────────────────────────────┤
│ 🔄 Sinkronisasi Otomatis   [✓] │
├────────────────────────────────┤
│ [🔄 Sinkronkan Sekarang]       │
│ [🗑️  Hapus Data Sinkronisasi]  │
├────────────────────────────────┤
│ Perangkat Tersinkronisasi      │
│ 📱 This Device         [Aktif] │
└────────────────────────────────┘
```

---

## ✅ Summary

Kedua fitur telah berhasil diimplementasikan:

1. ✅ **Kalender Catatan Harian** di halaman Statistik
   - Interaktif, dengan indikator visual
   - Edit dan save catatan per tanggal
   - Terintegrasi dengan UserDataService

2. ✅ **Sinkronisasi Notifikasi** antar perangkat
   - Auto-sync setiap perubahan
   - UI untuk manage sync
   - Device tracking
   - Status real-time

Semua fitur ready untuk testing dan bisa dikembangkan lebih lanjut!
