import 'dart:convert';
import 'dart:typed_data';

/// Profil pengguna dari dokumen `users/{uid}`.
class UserProfile {
  final String name;

  /// Warna avatar (nilai ARGB). null = gradasi bawaan.
  final int? avatarColor;

  /// Foto profil (JPEG kecil) dalam base64. null = tidak ada foto.
  final String? photoBase64;

  UserProfile({required this.name, this.avatarColor, this.photoBase64});

  factory UserProfile.fromMap(Map<String, dynamic>? m,
      {required String fallbackName}) {
    final n = (m?['name'] as String?)?.trim() ?? '';
    final c = m?['avatarColor'];
    final p = m?['photoBase64'];
    return UserProfile(
      name: n.isNotEmpty ? n : fallbackName,
      avatarColor: c is num ? c.toInt() : null,
      photoBase64: p is String && p.isNotEmpty ? p : null,
    );
  }

  /// Di-decode sekali per instance supaya gambar tidak berkedip saat rebuild.
  late final Uint8List? photoBytes = _decode();

  Uint8List? _decode() {
    final p = photoBase64;
    if (p == null) return null;
    try {
      return base64Decode(p);
    } catch (_) {
      return null;
    }
  }
}