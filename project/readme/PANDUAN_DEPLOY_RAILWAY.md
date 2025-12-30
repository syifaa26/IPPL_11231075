# Panduan Manual Deploy Backend ke Railway

Backend aplikasi Anda (Node.js) perlu di-deploy ke layanan cloud agar bisa diakses oleh aplikasi Android dari mana saja (tanpa harus satu jaringan WiFi).

## 1. Persiapan Kode (Sudah Dilakukan)
Saya sudah membantu Anda melakukan ini:
- Menambahkan script `start` di `package.json`.
- Menambahkan `.env` dan `node_modules` ke `.gitignore`.

Anda hanya perlu memastikan kode terbaru sudah ada di GitHub:
```bash
# Jalankan di terminal VS Code
git add .
git commit -m "Persiapan deploy backend"
git push
```

## 2. Setup di Railway.app

1.  Buka [Railway.app](https://railway.app) dan login (bisa pakai akun GitHub).
2.  Klik tombol **New Project** (atau "Start a New Project").
3.  Pilih **Deploy from GitHub repo**.
4.  Pilih repository project Anda `IPPL_11231075` (atau `IPPL`).
5.  Klik **Deploy Now**.
   
   > *Tunggu sebentar... Railway akan mencoba build tapi mungkin gagal atau belum sempurna karena kita perlu set Root Directory.*

## 3. Konfigurasi Root Directory (PENTING)

Karena kode backend Anda ada di dalam folder `API` (bukan langsung di luar), kita harus memberitahu Railway.

1.  Klik Project yang baru dibuat tadi.
2.  Klik kotak service (biasanya nama repo).
3.  Pergi ke tab **Settings**.
4.  Scroll ke bawah cari bagian **Build** -> **Root Directory**.
5.  Ubah nilainya menjadi: `/API`
6.  Tekan Enter atau Save.
7.  Railway akan otomatis melakukan re-deploy.

## 4. Setup Environment Variables

Kode Anda membutuhkan API Key (misal untuk Gemini AI) yang ada di file `.env`. Railway tidak membaca file `.env` lokal, jadi harus dimasukkan manual.

1.  Buka kembali file `API/.env` di VS Code Anda. Lihat isinya (misal `GEMINI_API_KEY=...`).
2.  Di dashboard Railway, buka tab **Variables**.
3.  Klik **New Variable**.
4.  Masukkan nama (KEY) dan isinya (VALUE) sesuai dengan yang ada di file `.env`.
5.  Contoh:
    - VARIABLE_NAME: `GEMINI_API_KEY`
    - VALUE: `AIzaSyD...` (copy dari file .env Anda)
6.  Klik **Add**. Railway akan re-deploy lagi.

## 5. Generate URL Publik

1.  Masih di dashboard Railway, buka tab **Settings**.
2.  Cari bagian **Networking** -> **Public Networking**.
3.  Klik tombol **Generate Domain**.
4.  Anda akan mendapatkan URL unik, contoh: `https://nutrisi-api-production.up.railway.app`.
5.  **Copy URL tersebut.**

## 6. Update Aplikasi Flutter

Terakhir, agar aplikasi Android menggunakan backend yang baru:

1.  Buka file `lib/services/nutrition_backend_service.dart`.
2.  Ganti `_baseUrl` lama dengan URL dari Railway:
    ```dart
    // Contoh
    static const String _baseUrl = 'https://nutrisi-api-production.up.railway.app'; 
    ```
    *(Jangan pakai akhiran `/` di belakang URL)*
3.  Save file.

## 7. Build Aplikasi

Sekarang aplikasi siap di-build untuk Play Store:

```bash
flutter build appbundle --release
```

Selesai! Aplikasi Anda sekarang menggunakan backend cloud yang stabil.
