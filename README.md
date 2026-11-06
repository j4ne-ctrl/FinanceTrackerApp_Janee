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
