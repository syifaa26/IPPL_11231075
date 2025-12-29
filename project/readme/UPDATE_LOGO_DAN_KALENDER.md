# Update UI: Logo Nutrix & Kalender Minimalis

## ✅ Perubahan yang Dilakukan

### 🎨 1. Logo Nutrix Baru

**Widget Custom:** `NutrixLogo`
- Logo custom dengan huruf "N" dan garis horizontal
- Menggunakan `CustomPainter` untuk menggambar logo
- Gradient background sesuai brand color
- Dapat digunakan dengan/tanpa teks "NUTRIX"

**File Baru:**
- [lib/widgets/nutrix_logo.dart](lib/widgets/nutrix_logo.dart)

**Implementasi:**
```dart
const NutrixLogo(
  size: 80,
  showText: true,
)
```

**Diterapkan di:**
- ✅ Landing Page ([lib/screens/landing_page.dart](lib/screens/landing_page.dart))
- ✅ Auth Screen ([lib/screens/auth_screen.dart](lib/screens/auth_screen.dart))

---

### 📅 2. Kalender Minimalis dengan Bubble Preview

**Desain Baru:**
- **Collapsed (Default):** Menampilkan 7 hari terakhir dalam bentuk bubble
- **Expanded:** Kalender bulan penuh dengan grid tanggal
- Tombol expand/collapse di header
- Indikator lebih jelas dengan dot kecil

**Fitur Bubble Preview:**
```
┌────────────────────────────┐
│ Catatan Harian       [▼]  │
├────────────────────────────┤
│ 7 Hari Terakhir            │
│                            │
│ ╭─╮ ╭─╮ ╭─╮ ╭─╮ ╭─╮ ╭─╮ ╭─╮│
│ │S│ │S│ │R│ │K│ │J│ │S│ │M││
│ │21││22││23││24││25││26││27││
│ │•│ │ │ │••││ │ │•│ │ │ │ ││
│ ╰─╯ ╰─╯ ╰─╯ ╰─╯ ╰─╯ ╰─╯ ╰─╯│
│                            │
│ Ketuk untuk detail...      │
└────────────────────────────┘
```

**Bubble Features:**
- Width: 40px, Height: 56px
- Border radius: 20px (very rounded)
- Hari ini: Gradient background
- Ada data: Light primary color
- Indikator: Dot 4x4px untuk meals (hijau) dan notes (kuning)
- Huruf hari: 1 karakter (S, S, R, K, J, S, M)

**Expanded View:**
- Grid kalender penuh 7x6
- Navigasi bulan dengan chevron
- Legend untuk indikator
- Section untuk edit catatan

**Keuntungan Desain Baru:**
- ✅ Lebih minimalis dan clean
- ✅ Hemat space - tidak memakan banyak ruang di halaman statistik
- ✅ Quick overview 7 hari terakhir
- ✅ Easy access - tap untuk expand
- ✅ Modern bubble UI pattern

---

## 📁 File yang Diubah

### Dibuat Baru:
1. `lib/widgets/nutrix_logo.dart` - Custom logo widget
2. `lib/widgets/daily_notes_calendar.dart` - Rebuilt dengan expand/collapse

### Dimodifikasi:
1. `lib/screens/landing_page.dart` - Gunakan NutrixLogo
2. `lib/screens/auth_screen.dart` - Gunakan NutrixLogo
3. `lib/screens/statistics_screen.dart` - (sudah terintegrasi sebelumnya)

---

## 🎯 Cara Menggunakan

### Logo Nutrix

**Basic:**
```dart
const NutrixLogo()
```

**Custom size:**
```dart
const NutrixLogo(
  size: 100,
  showText: true,
)
```

**Tanpa teks:**
```dart
const NutrixLogo(
  size: 60,
  showText: false,
)
```

### Kalender Bubble

**Default (Collapsed):**
- Menampilkan 7 bubble untuk 7 hari terakhir
- Hari ini dengan gradient
- Tap bubble → expand kalender & pilih tanggal

**Expand:**
- Tap icon ▼ di header
- Kalender bulan penuh muncul
- Navigasi bulan dengan ← →
- Tap tanggal untuk lihat detail

**Edit Catatan:**
1. Expand kalender
2. Tap tanggal
3. Tap icon ✏️ di section catatan
4. Edit & simpan

---

## 🎨 Design Specs

### Logo Nutrix
- **Container:** Gradient primary → secondary
- **Border radius:** 22% dari size
- **White circle:** 75% dari size
- **N letter:** 50% dari size dengan stroke width 12%
- **Horizontal line:** 60% thickness, full width
- **Dot:** 40% dari stroke width
- **Text:** 35% dari size, bold, letter-spacing 2

### Kalender Bubble (Collapsed)
- **Container:** Card dengan shadow
- **Padding:** 20px all sides
- **Bubble width:** 40px
- **Bubble height:** 56px
- **Border radius:** 20px
- **Spacing:** SpaceAround
- **Dot size:** 4x4px
- **Text size:** 
  - Day letter: 10px
  - Day number: 16px bold
  - Helper text: 11px italic

### Kalender Full (Expanded)
- **Grid:** 7 columns
- **Cell aspect ratio:** 1:1
- **Cell border radius:** 8px
- **Indicator dot:** 6x6px
- **Month text:** 16px semibold
- **Day label:** 12px bold
- **Date number:** 14px

---

## 💡 Technical Details

### NutrixLogoPainter
- Extends `CustomPainter`
- Menggambar 3 komponen:
  1. Left vertical bar (N)
  2. Right vertical bar (N)
  3. Diagonal connecting bar
  4. Horizontal line through middle
  5. Bottom dot

### Calendar State Management
```dart
bool _isExpanded = false;  // Track collapse/expand
DateTime _focusedMonth;     // Current month
DateTime? _selectedDate;    // Selected date for notes
```

### Bubble Preview Logic
```dart
List.generate(7, (index) {
  return today.subtract(Duration(days: 6 - index));
});
```
- Generate 7 hari dari 6 hari lalu sampai hari ini
- Check data untuk setiap hari
- Render bubble dengan styling conditional

---

## 🚀 Testing

### Logo Nutrix
1. ✅ Landing page - logo muncul dengan teks
2. ✅ Auth screen - logo muncul dengan teks
3. ✅ Gradient background applied
4. ✅ N letter dengan horizontal line terlihat jelas
5. ✅ Responsive terhadap size parameter

### Kalender Bubble
1. ✅ Collapsed view menampilkan 7 bubble
2. ✅ Hari ini dengan gradient
3. ✅ Indikator dot muncul jika ada data
4. ✅ Tap bubble → expand & select date
5. ✅ Tap header icon → expand/collapse
6. ✅ Full calendar navigation berfungsi
7. ✅ Edit notes dialog berfungsi
8. ✅ Legend tampil di expanded view

---

## 📸 Preview

### Logo Nutrix
```
┌──────────┐
│          │
│  ╭────╮  │  ← Gradient background
│  │ ⚊N │  │  ← White circle dengan N dan garis
│  ╰────╯  │
│          │
│  NUTRIX  │  ← Bold text
└──────────┘
```

### Kalender Before vs After

**Before (Always Full):**
- Selalu menampilkan grid 7x5 atau 7x6
- Memakan banyak space
- Sulit untuk quick view

**After (Collapsible):**
- Default: 7 bubble horizontal
- Minimal space usage
- Quick overview aktivitas
- Expand on demand

---

## 🎉 Summary

✅ **Logo Nutrix custom** diterapkan di landing & auth
✅ **Kalender minimalis** dengan bubble preview 7 hari
✅ **Expand/collapse** untuk hemat space
✅ **Indikator visual** lebih jelas dengan dots
✅ **Better UX** - fokus pada data recent
✅ **Responsive** dan smooth animation ready

Semua perubahan sudah diterapkan dan siap digunakan!
