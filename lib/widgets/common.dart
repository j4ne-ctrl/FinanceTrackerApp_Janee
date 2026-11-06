import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';

// ---------------------------------------------------------------- background
class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.bgColors,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
              top: -90, right: -70, child: _Glow(280, Color(0xB3FFFFFF))),
          const Positioned(
              top: 260, left: -110, child: _Glow(320, Color(0x66FFB3DE))),
          const Positioned(
              bottom: -80, right: -50, child: _Glow(300, Color(0x80BDEBC9))),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Lingkaran cahaya buram untuk efek latar ala kaca.
class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow(this.size, this.color);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------- logo
class AppLogo extends StatelessWidget {
  final double size;
  final bool onDark;
  const AppLogo({super.key, this.size = 88, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        color: onDark ? Colors.white : null,
        gradient: onDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.brandColors,
              ),
        boxShadow: [
          BoxShadow(
            color: (onDark ? Colors.white : AppColors.primary)
                .withValues(alpha: onDark ? 0.5 : 0.6),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        size: size * 0.5,
        color: onDark ? AppColors.primaryDark : Colors.white,
      ),
    );
  }
}

// ------------------------------------------------------------------- buttons
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color color;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.7),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle:
              GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const CircleIconButton(
      {super.key, required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.7),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, size: 21, color: iconColor ?? AppColors.ink),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------- field
class AppField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final Widget? suffix;
  final String? hint;
  final TextInputAction? action;

  const AppField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.suffix,
    this.hint,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: obscure ? 1 : maxLines,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}

// ---------------------------------------------------------------- empty view
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 34, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 16),
          Text(title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- snack + routes
SnackBar appSnack(String message, {bool error = false}) => SnackBar(
      content: Row(
        children: [
          Icon(error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: error ? AppColors.expense : AppColors.income, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );

void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(appSnack(message, error: error));
}

Route<T> fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );

// ---------------------------------------------------------- stream builders
/// Membungkus StreamBuilder untuk riwayat transaksi (real-time, terbaru dulu).
class TxStreamBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, List<TransactionModel> list)
      builder;
  const TxStreamBuilder({super.key, required this.builder});

  @override
  State<TxStreamBuilder> createState() => _TxStreamBuilderState();
}

class _TxStreamBuilderState extends State<TxStreamBuilder> {
  late final Stream<List<TransactionModel>> _stream =
      FirestoreService.instance.streamTransactions();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TransactionModel>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Gagal memuat data',
              subtitle:
                  'Periksa koneksi internet dan aturan (rules) Firestore.\n${snap.error}',
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        return widget.builder(context, snap.data!);
      },
    );
  }
}

/// Menyediakan nama pemilik akun (dari koleksi users) ke builder.
class UserNameBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, String name) builder;
  const UserNameBuilder({super.key, required this.builder});

  @override
  State<UserNameBuilder> createState() => _UserNameBuilderState();
}

class _UserNameBuilderState extends State<UserNameBuilder> {
  late final Stream<String?> _stream =
      FirestoreService.instance.streamProfileName();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _stream,
      builder: (context, snap) {
        final n = snap.data?.trim() ?? '';
        return widget.builder(
            context, n.isNotEmpty ? n : FirestoreService.fallbackName());
      },
    );
  }
}

// ------------------------------------------------------------ logout dialog
Future<void> confirmLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.logout_rounded, color: AppColors.expense),
      ),
      title: Text('Keluar dari akun?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18)),
      content: Text(
        'Sesi kamu akan diakhiri dan kamu perlu masuk lagi untuk melihat catatan keuangan.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Ya, keluar'),
        ),
      ],
    ),
  );

  if (ok == true && context.mounted) {
    final nav = Navigator.of(context);
    await AuthService.instance.logout();
    nav.pushAndRemoveUntil(fadeRoute(const LoginScreen()), (_) => false);
  }
}

/// Inisial nama untuk avatar.
String initialOf(String name) =>
    name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

User? get currentUser => FirebaseAuth.instance.currentUser;
