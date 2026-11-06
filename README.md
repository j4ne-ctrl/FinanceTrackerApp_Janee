<<<<<<< HEAD
# Dompetku - Personal Finance Tracker (Flutter + Firebase)

## Cara menjalankan

1. Buat project Flutter kosong, lalu salin file dari folder ini:
   ```bash
   flutter create dompetku
   cd dompetku
   ```
   - Ganti `pubspec.yaml` dengan yang ada di sini
   - Hapus isi `lib/` bawaan, salin folder `lib/` dari sini
   - Jalankan `flutter pub get`

2. Buat project di [Firebase Console](https://console.firebase.google.com):
   - **Authentication** -> Sign-in method -> aktifkan **Email/Password**
   - **Firestore Database** -> Create database (mulai dengan test mode), lalu tempel isi `firestore.rules` di tab *Rules*

3. Hubungkan app ke Firebase (pilih salah satu):
   - **Cara mudah (disarankan):**
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
     lalu di `lib/main.dart` ganti `Firebase.initializeApp()` menjadi
     `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
     dan tambahkan `import 'firebase_options.dart';`
   - **Manual Android:** letakkan `google-services.json` di `android/app/`
     dan tambahkan plugin `com.google.gms.google-services`.

4. Android: pastikan `minSdkVersion` minimal **23** di `android/app/build.gradle`.

5. `flutter run`

## Struktur Firestore (hirarki)

```
users (collection)
 └── {uid} (document)           name, email, uid, createdAt
      └── transactions (sub-collection)
           └── {transactionId}  title, amount, type, category, note, date, createdAt
```

## Struktur kode

```
lib/
 ├── main.dart
 ├── theme/app_theme.dart
 ├── utils/format.dart
 ├── models/         categories.dart, transaction_model.dart
 ├── services/       auth_service.dart, firestore_service.dart
 ├── widgets/        common.dart, transaction_tile.dart
 └── screens/        splash, login, register, main_shell (navbar),
                     home, history, stats, profile,
                     add_transaction (tambah + edit), transaction_detail
```
=======
# Finance Tracker

Aplikasi pencatat keuangan pribadi berbasis **Flutter** dengan **Firebase Authentication** dan **Cloud Firestore**. Catat pemasukan dan pengeluaran, lihat riwayatnya, dan pantau ke mana uangmu pergi lewat statistik bulanan. Data tersimpan di cloud dan tersinkron secara real-time.

## 🎬 Demo

📺 **[Tonton video demo di Google Drive](https://drive.google.com/file/d/1QrMFrSq3cwEp8UP0zyezy-Q4y7brNgy_/view?usp=sharing)**


## ✨ Fitur

**Akun**
- Daftar dan masuk dengan email dan kata sandi
- Masuk dengan akun Google
- Edit profil: nama pengguna, foto dari galeri, atau warna avatar

**Transaksi**
- Tambah, ubah, dan hapus transaksi (pemasukan / pengeluaran)
- Kategori terpisah untuk pemasukan dan pengeluaran
- Input nominal otomatis berformat (`1.000.000`) dan tombol nominal cepat
- Pilih tanggal transaksi dan tambahkan catatan

**Ringkasan**
- Beranda: total saldo, total pemasukan, dan pengeluaran
- Riwayat: dikelompokkan per hari, dengan pencarian dan filter pemasukan / pengeluaran
- Statistik: pengeluaran per bulan, perbandingan dengan bulan lalu, grafik 6 bulan, dan kategori terbesar

## 🛠️ Teknologi

| Bagian | Yang dipakai |
|---|---|
| Framework | Flutter (Dart `>=3.3.0`) |
| Autentikasi | Firebase Authentication (Email/Password dan Google) |
| Database | Cloud Firestore |
| Paket | `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_fonts`, `intl`, `image_picker` |

## 🗂️ Struktur Proyek

```
lib/
├── main.dart
├── firebase_options.dart
├── theme/app_theme.dart
├── utils/format.dart
├── models/
│   ├── categories.dart
│   ├── transaction_model.dart
│   └── user_profile.dart
├── services/
│   ├── auth_service.dart
│   └── firestore_service.dart
├── widgets/
│   ├── common.dart
│   ├── transaction_tile.dart
│   └── user_avatar.dart
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── main_shell.dart            # navigasi bawah
    ├── home_screen.dart
    ├── history_screen.dart
    ├── stats_screen.dart
    ├── profile_screen.dart
    ├── edit_profile_screen.dart
    ├── add_transaction_screen.dart  # tambah + edit transaksi
    └── transaction_detail_screen.dart
```

## 🗄️ Struktur Firestore

```
users (collection)
 └── {uid} (document)
      │   uid, name, email, avatarColor, photoBase64, createdAt, updatedAt
      └── transactions (sub-collection)
           └── {transactionId}
                title, amount, type, category, note, date, createdAt, updatedAt
```

- `type` bernilai `income` atau `expense`
- `photoBase64` berisi foto profil yang sudah dikecilkan (±256 px), disimpan sebagai teks sehingga tidak membutuhkan Firebase Storage

### Aturan keamanan (Firestore Rules)

Setiap pengguna hanya bisa membaca dan menulis datanya sendiri:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 🚀 Cara Menjalankan

### 1. Persiapan

- Flutter SDK terpasang (`flutter doctor` tidak ada masalah)
- Akun Google untuk Firebase

### 2. Ambil dependensi

```bash
git clone <URL_REPOSITORY_KAMU>
cd finance_tracker
flutter pub get
```

### 3. Siapkan Firebase

1. Buat project di [Firebase Console](https://console.firebase.google.com).
2. **Authentication → Sign-in method**: aktifkan **Email/Password** dan **Google**.
3. **Firestore Database → Create database**, lalu buka tab **Rules**, tempel aturan di atas, dan klik **Publish**.
4. Hubungkan app ke project Firebase kamu:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Perintah ini membuat ulang `lib/firebase_options.dart` sesuai project kamu.

### 4. Jalankan

```bash
# Web (disarankan port tetap supaya sesi login tidak hilang tiap run)
flutter run -d chrome --web-port=5000

# Android / iOS
flutter run
```

> **Android:** untuk Masuk dengan Google, tambahkan sidik jari **SHA-1** debug key di Firebase Console → Project settings → app Android, lalu unduh ulang `google-services.json`.
>
> **iOS:** tambahkan `NSPhotoLibraryUsageDescription` di `ios/Runner/Info.plist` agar bisa memilih foto profil.

## 📝 Catatan

- Simpan, ubah, dan hapus data menunggu konfirmasi dari server Firestore. Jika koneksi bermasalah, aplikasi menampilkan pesan gagal dan tidak berpura-pura berhasil.
- Di versi web, Firestore tidak menyimpan cache lokal, jadi koneksi internet dibutuhkan untuk menyimpan data.

## 👤 Pembuat

**[Nama kamu]**: [NIM / kelas / kontak, jika perlu]
>>>>>>> 90b21982d3e94920c594fcdf7afefdda5394dae8
