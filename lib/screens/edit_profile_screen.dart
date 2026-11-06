import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/user_avatar.dart';

/// Edit nama pengguna + foto profil (dari galeri) atau warna avatar.
class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _maxPhotoBytes = 200 * 1024; // batas aman (dokumen Firestore maks 1 MB)

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name);
  late int? _color = widget.profile.avatarColor;
  late Uint8List? _photo = widget.profile.photoBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Supaya inisial di avatar ikut berubah saat nama diketik.
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      // Diperkecil saat memilih: ~256 px, JPEG kualitas 75 (puluhan KB saja).
      final x = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 75,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      if (bytes.length > _maxPhotoBytes) {
        showSnack(context, 'Foto terlalu besar, pilih foto lain.', error: true);
        return;
      }
      setState(() => _photo = bytes);
    } catch (e) {
      if (mounted) showSnack(context, 'Gagal memilih foto: $e', error: true);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _saving = true);

    try {
      await FirestoreService.instance
          .saveProfile(
            name: _name.text.trim(),
            avatarColor: _color,
            photoBase64: _photo == null ? null : base64Encode(_photo!),
          )
          .timeout(const Duration(seconds: 10));
      messenger.showSnackBar(appSnack('Profil diperbarui'));
      nav.pop();
    } on TimeoutException {
      messenger.showSnackBar(appSnack(
          'Belum terkonfirmasi server. Periksa koneksi lalu coba simpan lagi.',
          error: true));
      if (mounted) setState(() => _saving = false);
    } on FirebaseException catch (e) {
      messenger.showSnackBar(
          appSnack('Gagal menyimpan [${e.code}]: ${e.message}', error: true));
      if (mounted) setState(() => _saving = false);
    } catch (e) {
      messenger.showSnackBar(appSnack('Gagal menyimpan: $e', error: true));
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _colorDot(int? value) {
    final selected = _color == value;
    return GestureDetector(
      onTap: () => setState(() => _color = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: value == null ? null : Color(value),
          gradient: value == null
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.brandColors,
                )
              : null,
          border: Border.all(
            color: selected ? AppColors.ink : Colors.white,
            width: selected ? 2.6 : 1.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text('Edit Profil',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 46),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    children: [
                      Center(
                        child: UserAvatar(
                          name: _name.text,
                          photoBytes: _photo,
                          colorValue: _color,
                          size: 112,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _saving ? null : _pickPhoto,
                            icon: const Icon(Icons.photo_library_rounded,
                                size: 18),
                            label: const Text('Pilih dari galeri'),
                          ),
                          if (_photo != null) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () => setState(() => _photo = null),
                              child: const Text('Hapus foto'),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text('Warna avatar',
                          style: GoogleFonts.poppins(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Dipakai kalau kamu tidak memakai foto.',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: AppColors.muted)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _colorDot(null),
                          for (final c in AvatarPalette.colors) _colorDot(c),
                        ],
                      ),
                      const SizedBox(height: 26),
                      AppField(
                        controller: _name,
                        label: 'Nama pengguna',
                        icon: Icons.person_outline_rounded,
                        action: TextInputAction.done,
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Nama wajib diisi';
                          if (t.length < 2) return 'Nama minimal 2 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Simpan Perubahan',
                        icon: Icons.check_rounded,
                        loading: _saving,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}