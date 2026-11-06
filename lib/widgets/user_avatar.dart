import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
/// Pilihan warna avatar (nilai ARGB). Pilihan pertama di editor = gradasi bawaan.
class AvatarPalette {
  static const colors = <int>[
    0xFF6C9BF2, // biru
    0xFF9B7CF0, // ungu
    0xFFEE7FC0, // pink
    0xFFFF9F7A, // coral
    0xFF2FBF8A, // hijau
    0xFFF5A623, // kuning
    0xFF4DA3FF, // biru langit
    0xFF8A8A99, // abu
  ];
}

/// Avatar bulat: foto kalau ada, kalau tidak inisial di atas warna pilihan.
class UserAvatar extends StatelessWidget {
  final String name;
  final Uint8List? photoBytes;
  final int? colorValue;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    required this.size,
    this.photoBytes,
    this.colorValue,
  });

  UserAvatar.fromProfile(UserProfile p, {super.key, required this.size})
      : name = p.name,
        photoBytes = p.photoBytes,
        colorValue = p.avatarColor;

  @override
  Widget build(BuildContext context) {
    final bytes = photoBytes;
    if (bytes != null) {
      return ClipOval(
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _initial(),
        ),
      );
    }
    return _initial();
  }

  Widget _initial() {
    final c = colorValue;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c == null ? null : Color(c),
        gradient: c == null
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.brandColors,
              )
            : null,
      ),
      child: Text(
        initialOf(name),
        style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Menyediakan profil pengguna (nama, warna, foto) secara real-time.
class UserProfileBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, UserProfile profile) builder;
  const UserProfileBuilder({super.key, required this.builder});

  @override
  State<UserProfileBuilder> createState() => _UserProfileBuilderState();
}

class _UserProfileBuilderState extends State<UserProfileBuilder> {
  late final Stream<UserProfile> _stream =
      FirestoreService.instance.streamProfile();
  // Dipakai selama data belum datang / kalau gagal dimuat.
  late final UserProfile _fallback =
      UserProfile(name: FirestoreService.fallbackName());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile>(
      stream: _stream,
      builder: (context, snap) => widget.builder(context, snap.data ?? _fallback),
    );
  }
}