# 🍃 GREEN ENERGY PALETTE - NUTRIX APP

## 🎨 PALETTE WARNA BARU!

**Tema:** Fresh, Natural, & Healthy
**Cocok untuk:** Aplikasi Nutrisi & Kesehatan

---

## 🌈 COLOR PALETTE

### Primary Colors - Fresh Green 🍃
```
🟢 Deep Turquoise    #11998E ━━━━━━━━━> #38EF7D  Bright Lime Green
   (Primary Dark)    (Primary)           (Primary Light)
```

**Penggunaan:**
- ✅ Background utama (gradien)
- ✅ Card kalori (gradien)
- ✅ Header aplikasi
- ✅ Logo & branding
- ✅ Progress bar
- ✅ Bottom navigation (selected)

---

### Secondary Colors - Sky Blue 🌊
```
🔵 Ocean Blue       #2E86DE ━━━━━━━━━> #54A0FF  Sky Blue
   (Secondary Dark) (Secondary)         (Secondary Light)
```

**Penggunaan:**
- ✅ Button "Tambah Makanan"
- ✅ Tab selector
- ✅ Accent pada card
- ✅ Icon aktif
- ✅ Link & call-to-action

---

### Accent Colors - Vibrant Orange ☀️
```
🟠 Bright Orange    #FFA502 ━━━━━━━━━> #FFD32A  Golden Yellow
   (Accent)                             (Accent Light)
```

**Penggunaan:**
- ✅ Badge "Sarapan"
- ✅ Highlight penting
- ✅ Warning messages
- ✅ Energetic elements
- ✅ Icon decorations

---

## 🎯 GRADIENTS

### 1. Primary Gradient (Main Theme)
```css
linear-gradient(
  to bottom right,
  #11998E, /* Deep Turquoise */
  #38EF7D  /* Bright Lime */
)
```
**Digunakan untuk:**
- Login/Register background
- Card kalori utama
- Header gradien
- Tab aktif

---

### 2. Secondary Gradient (Action Elements)
```css
linear-gradient(
  to bottom right,
  #2E86DE, /* Ocean Blue */
  #54A0FF  /* Sky Blue */
)
```
**Digunakan untuk:**
- Button "Tambah Makanan"
- Call-to-action buttons
- Badge "Makan Siang"

---

### 3. Accent Gradient (Highlights)
```css
linear-gradient(
  to bottom right,
  #FFA502, /* Bright Orange */
  #FFD32A  /* Golden Yellow */
)
```
**Digunakan untuk:**
- Badge "Sarapan"
- Snack badges
- Highlight cards
- Warning elements

---

### 4. Forest Gradient (Alternative)
```css
linear-gradient(
  to bottom right,
  #134E5E, /* Deep Green */
  #71B280  /* Light Green */
)
```
**Opsional untuk:**
- Dark mode variant
- Alternative sections
- Special cards

---

### 5. Sunset Gradient (Energy)
```css
linear-gradient(
  to bottom right,
  #FFA502, /* Orange */
  #FF6348  /* Coral */
)
```
**Opsional untuk:**
- Badge "Makan Malam"
- Energetic elements
- Calorie burn indicators

---

## 📊 NUTRITION COLORS

### Macro Nutrients
| Nutrisi | Warna | Hex | Icon |
|---------|-------|-----|------|
| **Protein** | 🔴 Coral Red | `#FF6348` | 🏆 Trophy |
| **Karbohidrat** | 🟡 Golden Yellow | `#FFD32A` | 💪 Fitness |
| **Lemak** | 🔵 Ocean Blue | `#2E86DE` | 🍞 Bakery |
| **Kalori** | 🟢 Lime Green | `#38EF7D` | 🔥 Fire |

---

## 🎨 UI ELEMENT MAPPING

### Halaman Login/Register
```
┌─────────────────────────────────────┐
│  🍃 GRADIEN GREEN ENERGY            │  ← Primary Gradient
│     (Turquoise → Lime Green)        │
│                                     │
│     ┌─────────────────┐             │
│     │   Logo Nutrix   │             │  ← White + Shadow
│     │   🥗 Green Icon  │             │
│     └─────────────────┘             │
│                                     │
│         NUTRIX                      │  ← White Bold
│   Tracking Kalori AI                │  ← White 90% opacity
│                                     │
│  ┌──────────────────────────────┐  │
│  │ [MASUK] │ Daftar             │  │  ← Tab with gradient
│  └──────────────────────────────┘  │
│                                     │
│  📧 Email Input                     │
│  🔒 Password Input                  │
│                                     │
│  [🍃 BUTTON LOGIN - GRADIEN]       │  ← Primary Gradient
│                                     │
└─────────────────────────────────────┘
```

---

### Card Kalori (Home)
```
┌─────────────────────────────────────┐
│  🍃 GRADIEN HIJAU SEGAR             │  ← Primary Gradient
│     #11998E → #38EF7D               │
│                                     │
│      Kalori Hari Ini                │  ← White text
│                                     │
│          1500                       │  ← White 56px bold
│        / 2000 kkal                  │  ← White 80%
│                                     │
│   ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░                │  ← White progress bar
│                                     │
│   🔴 120g    🟡 150g    🔵 45g      │
│   Protein    Karbo      Lemak       │
│                                     │
└─────────────────────────────────────┘
```

---

### Button Tambah Makanan
```
┌─────────────────────────────────────┐
│                                     │
│   🌊 GRADIEN BIRU LANGIT            │
│   ┌──────────────────────────────┐ │
│   │  📦  Tambah Makanan          │ │  ← Secondary Gradient
│   └──────────────────────────────┘ │  ← Shadow tebal
│          ▼▼▼ shadow                 │
│                                     │
└─────────────────────────────────────┘
```

---

### Meal List Items
```
┌─────────────────────────────────────┐
│  Makanan Hari Ini    [🟢 3 item]   │
│                                     │
│  ┌────────────────────────────────┐│
│  │ ☀️ Nasi Goreng            🍃   ││
│  │    [🟠 Sarapan] 🕐 08:00  450  ││  ← Orange gradient badge
│  │                           kkal ││  ← Green gradient badge
│  └────────────────────────────────┘│
│                                     │
│  ┌────────────────────────────────┐│
│  │ 🍴 Ayam Bakar             🍃   ││
│  │    [🔵 Makan Siang] 🕐   620   ││  ← Blue gradient badge
│  │                           kkal ││
│  └────────────────────────────────┘│
│                                     │
│  ┌────────────────────────────────┐│
│  │ 🌙 Salad Sayur            🍃   ││
│  │    [🌲 Makan Malam] 🕐   380   ││  ← Forest gradient
│  │                           kkal ││
│  └────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

---

## 💡 DESIGN PRINCIPLES

### 1. **Natural & Fresh** 🍃
- Hijau dominan = kesehatan & nutrisi
- Lime green cerah = energi & vitalitas
- Turquoise = segar & bersih

### 2. **Energetic & Positive** ⚡
- Orange accent = energi & semangat
- Gradien cerah = dinamis & modern
- Sky blue = tenang tapi ceria

### 3. **Professional** 💼
- Kombinasi warna harmonis
- Tidak terlalu terang/menyilaukan
- Cocok untuk aplikasi kesehatan

### 4. **Eye-Friendly** 👁️
- Green = warna paling nyaman untuk mata
- Blue = menenangkan
- Orange = accent yang tidak dominan

---

## 🆚 PERBANDINGAN DENGAN DESAIN LAMA

| Aspek | ❌ LAMA | ✅ BARU (Green Energy) |
|-------|---------|------------------------|
| **Primary** | 🟢 #2ECC71 Flat green | 🍃 #11998E→#38EF7D Gradient |
| **Secondary** | Tidak ada | 🌊 #2E86DE→#54A0FF Blue gradient |
| **Accent** | Tidak ada | ☀️ #FFA502→#FFD32A Orange gradient |
| **Background** | Putih polos | Gradien hijau segar |
| **Visual Depth** | Flat, 2D | Gradien + shadow 3D |
| **Vibe** | Sederhana | Fresh, natural, energetic |

---

## ✅ KEUNGGULAN GREEN ENERGY THEME

1. ✅ **Perfect untuk aplikasi nutrisi** - hijau = sehat
2. ✅ **Eye-friendly** - tidak menyilaukan
3. ✅ **Energetic** - kombinasi lime + orange
4. ✅ **Professional** - terlihat modern & kredibel
5. ✅ **Memorable** - kombinasi warna unik
6. ✅ **Balanced** - tidak terlalu ramai atau polos

---

## 🎯 NEXT STEPS

Setelah aplikasi build selesai, cek:
- [ ] Login screen = Gradien hijau segar
- [ ] Card kalori = Gradien turquoise → lime
- [ ] Button tambah = Gradien biru langit
- [ ] Meal badges = Orange, blue, forest green
- [ ] Bottom nav = Hijau ketika aktif
- [ ] Overall feel = Fresh, natural, healthy

---

**Palette:** Green Energy 🍃
**Created:** 2024
**Theme:** Fresh, Natural, Healthy
**Perfect for:** Nutrition & Health Apps
