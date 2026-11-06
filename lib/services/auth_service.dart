import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Membuat akun, lalu menyimpan profil ke koleksi `users/{uid}`.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name);
    // Simpan profil ke Firestore. Future-nya baru selesai kalau server
    // membalas, jadi dibatasi 6 detik supaya tombol Daftar tidak menggantung.
    // Kalau gagal pun akun tetap jadi (nama sudah tersimpan di displayName).
    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 6), onTimeout: () {});
    } catch (_) {}
  }

  /// Masuk dengan Google. Web: popup. Android/iOS: alur provider bawaan
  /// firebase_auth (tanpa paket tambahan). Pengguna baru otomatis dibuatkan
  /// profil di `users/{uid}`, sama seperti saat register biasa.
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider()..addScope('email');
    final UserCredential cred = kIsWeb
        ? await _auth.signInWithPopup(provider)
        : await _auth.signInWithProvider(provider);

    final user = cred.user;
    if (user != null && (cred.additionalUserInfo?.isNewUser ?? false)) {
      // Jangan ditunggu: login sudah berhasil, profil disimpan di belakang
      // layar. Kalau gagal, nama tetap diambil dari displayName.
      unawaited(_db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((_) {}));
    }
  }

  Future<void> logout() => _auth.signOut();
}

String authMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Format email tidak valid.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email atau kata sandi salah.';
    case 'user-disabled':
      return 'Akun ini telah dinonaktifkan.';
    case 'email-already-in-use':
      return 'Email sudah terdaftar. Silakan masuk.';
    case 'weak-password':
      return 'Kata sandi terlalu lemah (minimal 6 karakter).';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
    case 'network-request-failed':
      return 'Tidak ada koneksi internet.';
    default:
      return e.message ?? 'Terjadi kesalahan autentikasi.';
  }
}