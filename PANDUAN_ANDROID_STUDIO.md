# Panduan Menjalankan SIMWAR Warung Azzam di Android Studio

Proyek ini dibuat menggunakan **Flutter 3.x** dengan backend **Supabase** dan gateway verifikasi OTP **WhatsApp (Fonnte)** yang sudah aktif dan terkonfigurasi.

---

## 📋 Prasyarat di Laptop Teman
1. **Android Studio** (Koala / Ladybug / Iguana / Jellyfish / Hedgehog) dengan plugin **Flutter** dan **Dart** terpasang.
2. **Flutter SDK** versi 3.20 ke atas.
3. Emulator Android (AVD) atau HP Android fisik (dengan USB Debugging aktif).

---

## 🚀 Langkah Menjalankan Proyek

### 1. Ekstrak File ZIP
* Ekstrak file `SIMWAR_Warung_Azzam_AndroidStudio.zip` ke lokasi folder yang diinginkan di laptop.

### 2. Buka di Android Studio
1. Buka aplikasi **Android Studio**.
2. Pilih menu **File** -> **Open...** (atau klik **Open** pada layar pembuka).
3. Arahkan dan pilih folder hasil ekstrak: `simwar_warung_azzam`.
4. Tunggu beberapa saat hingga Android Studio selesai membaca struktur file.

### 3. Install Dependensi (Pub Get)
* Saat file `pubspec.yaml` terbuka, klik tombol **'Flutter pub get'** di barisan atas editor.
* Atau buka tab **Terminal** di bagian bawah Android Studio dan jalankan:
  ```bash
  flutter pub get
  ```

### 4. Pilih Perangkat Target
* Pada menu dropdown pilihan perangkat di toolbar atas, pilih:
  - Salah satu **Android Emulator (AVD)**, atau
  - **HP Android Anda** yang sudah dicolokkan ke laptop.

### 5. Jalankan Aplikasi (Run)
* Klik tombol hijau **Run ▶** (atau tekan shortcut `Shift + F10`).
* Gradle akan melakukan proses build pertama kali dan aplikasi **SIMWAR Warung Azzam** akan langsung terpasang dan terbuka di layar HP/Emulator!

---

## 🔑 Data Uji Coba (Demo)
Aplikasi sudah terhubung langsung ke database Supabase:
- **Role Pemilik (Demo Login):**
  - Nomor HP: `081234567890`
  - Kata Sandi: `12345678`
- **Pendaftaran Akun Baru (OTP WhatsApp Live):**
  - Bisa klik "Buat profil pemilik" pada halaman login.
  - Masukkan nomor HP, sistem akan mengirimkan OTP via WhatsApp gateway.

---

## 📁 Struktur File Utama
- `lib/main.dart` : Titik awal aplikasi & inisialisasi koneksi Supabase.
- `lib/screens/login_screen.dart` : Layar 01 (Login Pemilik & Penjaga).
- `lib/screens/register_screen_1.dart` : Layar 04 (Buat Profil Pemilik 1 dari 2).
- `lib/screens/register_otp_screen.dart` : Layar 03/Verifikasi OTP WhatsApp 6-digit.
- `lib/screens/register_screen_2.dart` : Layar 05 (Atur Peringatan Warung 2 dari 2).
- `lib/screens/home_screen.dart` : Layar 06 (Beranda Lengkap Pemilik).
- `lib/services/otp_service.dart` : Layanan pengiriman OTP via API Fonnte.
- `lib/services/auth_service.dart` : Layanan autentikasi login Supabase.
