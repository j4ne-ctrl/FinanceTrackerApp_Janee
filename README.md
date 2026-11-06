# Finance Tracker

Aplikasi pencatat keuangan pribadi berbasis **Flutter** dengan **Firebase Authentication** dan **Cloud Firestore**. Catat pemasukan dan pengeluaran, lihat riwayatnya, dan pantau ke mana uangmu pergi lewat statistik bulanan. Data tersimpan di cloud dan tersinkron secara real-time.

## 🎬 Demo

📺 **[Tonton video demo di Google Drive](https://drive.google.com/file/d/1QrMFrSq3cwEp8UP0zyezy-Q4y7brNgy_/view?usp=sharing)**


<img width="200" alt="Screenshot 2026-11-06 141752" src="https://github.com/user-attachments/assets/e80ea4ba-8b49-4f96-a07a-c6825a3071d5" />
<img width="200" alt="Screenshot 2026-11-06 141756" src="https://github.com/user-attachments/assets/7f3c4a82-8e6e-4644-a3a3-87ebcd15e7ba" />
<img width="200" alt="Screenshot 2026-11-06 141822" src="https://github.com/user-attachments/assets/592d5ed8-a7ea-42c0-b62f-e524389ae9c5" />
<img width="200" alt="Screenshot 2026-11-06 141825" src="https://github.com/user-attachments/assets/16bf51d5-cc22-4ad4-b4cd-9762c5fa021a" />
<img width="200" alt="Screenshot 2026-11-06 141830" src="https://github.com/user-attachments/assets/f387cd2c-18b6-4f54-ba0a-1fb24ce53e8a" />
<img width="200" alt="Screenshot 2026-11-06 141833" src="https://github.com/user-attachments/assets/d07fbca6-315b-435c-af24-fe6273bd8cc9" />
<img width="200" alt="Screenshot 2026-11-06 141837" src="https://github.com/user-attachments/assets/ec529757-dcf2-4c26-b1a9-1bfb79400a27" />
<img width="200" alt="Screenshot 2026-11-06 141840" src="https://github.com/user-attachments/assets/19eda984-c632-450a-9be9-ca43ed0f201d" />


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

**Janeeta Samahat Nowa**: XI RPL 7
