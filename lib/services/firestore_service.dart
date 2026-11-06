import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../models/user_profile.dart';

/// Struktur hirarki Firestore:
///
/// users (collection)
///  └── {uid} (document)            -> name, email, createdAt
///       └── transactions (sub-collection)
///            └── {transactionId}    -> title, amount, type, category, note, date, createdAt
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _tx =>
      _userDoc.collection('transactions');

  static String fallbackName() {
    final u = FirebaseAuth.instance.currentUser;
    if (u?.displayName != null && u!.displayName!.trim().isNotEmpty) {
      return u.displayName!;
    }
    final email = u?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Pengguna';
  }

  /// Nama pemilik akun dari dokumen users/{uid}.
  Stream<String?> streamProfileName() =>
      _userDoc.snapshots().map((d) => d.data()?['name'] as String?);

  /// Profil lengkap (nama, warna avatar, foto) real-time.
  Stream<UserProfile> streamProfile() => _userDoc.snapshots().map((d) =>
      UserProfile.fromMap(d.data(), fallbackName: fallbackName()));

  /// Menyimpan profil. [photoBase64] / [avatarColor] null = hapus field-nya.
  /// Memakai merge supaya tetap jalan walau dokumen profil belum ada
  /// (mis. akun lama atau akun Google yang profilnya belum sempat tersimpan).
  Future<void> saveProfile({
    required String name,
    int? avatarColor,
    String? photoBase64,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    await _userDoc.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'name': name,
      'avatarColor': avatarColor ?? FieldValue.delete(),
      'photoBase64': photoBase64 ?? FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // Samakan juga displayName di Firebase Auth supaya nama fallback konsisten.
    await user.updateDisplayName(name);
  }

  /// Riwayat transaksi real-time, diurutkan dari tanggal terbaru.
  Stream<List<TransactionModel>> streamTransactions() => _tx
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(TransactionModel.fromDoc).toList());

  Stream<TransactionModel?> streamTransaction(String id) => _tx
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? TransactionModel.fromDoc(d) : null);

  /// ID dibuat di sisi klien (tanpa menyentuh jaringan) supaya menyimpan ulang
  /// transaksi yang sama bersifat idempotent: tekan "Simpan" dua kali / coba
  /// lagi setelah timeout tidak membuat dokumen ganda.
  String newId() => _tx.doc().id;

  /// Menyimpan transaksi baru. [t.id] harus berasal dari [newId].
  Future<void> add(TransactionModel t) => _tx.doc(t.id).set({
        ...t.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> update(TransactionModel t) => _tx.doc(t.id).update({
        ...t.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> delete(String id) => _tx.doc(id).delete();
}