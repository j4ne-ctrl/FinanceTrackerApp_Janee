import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  bool _navigated = false;
  StreamSubscription<User?>? _authSub;

  @override
  void dispose() {
    _authSub?.cancel();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.login(_email.text.trim(), _pass.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context, fadeRoute(const MainShell()), (_) => false);
    } on FirebaseAuthException catch (e) {
      if (mounted) showSnack(context, authMessage(e), error: true);
    } catch (e) {
      if (mounted) showSnack(context, 'Terjadi kesalahan: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushAndRemoveUntil(
        context, fadeRoute(const MainShell()), (_) => false);
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    setState(() => _googleLoading = true);

    // Cadangan: kalau popup sudah sukses tapi hasilnya telat/tidak kembali ke
    // app, pindah halaman begitu Firebase mencatat ada user yang login.
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      if (u != null) _goHome();
    });

    try {
      await AuthService.instance.signInWithGoogle();
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (mounted && !_navigated) {
        final closed = e.code == 'popup-closed-by-user' ||
            e.code == 'cancelled-popup-request' ||
            e.code == 'canceled' ||
            e.code == 'web-context-canceled';
        showSnack(
            context,
            closed
                ? 'Login Google dibatalkan / popup tertutup sebelum selesai. [${e.code}]'
                : '${authMessage(e)} [${e.code}]',
            error: true);
      }
    } catch (e) {
      if (mounted && !_navigated) {
        showSnack(context, 'Terjadi kesalahan: $e', error: true);
      }
    } finally {
      _authSub?.cancel();
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  const AppLogo(size: 116),
                  const SizedBox(height: 28),
                  Text('Selamat datang kembali',
                      style: GoogleFonts.poppins(
                          fontSize: 32, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Masuk untuk melanjutkan mencatat keuanganmu.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 15, color: AppColors.muted)),
                  const SizedBox(height: 34),
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.glossColors,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.24),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppField(
                            controller: _email,
                            label: 'Email',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            action: TextInputAction.next,
                            validator: (v) {
                              final t = v?.trim() ?? '';
                              if (t.isEmpty) return 'Email wajib diisi';
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(t)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          AppField(
                            controller: _pass,
                            label: 'Kata sandi',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            action: TextInputAction.done,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Kata sandi wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 28),
                          PrimaryButton(
                            label: 'Masuk',
                            icon: Icons.login_rounded,
                            loading: _loading,
                            onPressed: _googleLoading ? null : _submit,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('atau',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.muted)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _GoogleButton(
                            loading: _googleLoading,
                            onPressed: _loading ? null : _google,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun?',
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: AppColors.muted)),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        child: Text('Daftar',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// Tombol "Masuk dengan Google" (putih, outline) di bawah tombol Masuk.
class _GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const _GoogleButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.ink,
          side: BorderSide(color: AppColors.ink.withValues(alpha: 0.15)),
          shape: const StadiumBorder(),
          textStyle:
              GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleLogo(size: 22),
                  const SizedBox(width: 12),
                  const Text('Masuk dengan Google'),
                ],
              ),
      ),
    );
  }
}


/// Logo "G" Google empat warna, digambar langsung (tanpa aset gambar).
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _GoogleLogoPainter());
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  double _rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final w = s * 0.2; // tebal garis
    final rect = Rect.fromLTWH(w / 2, w / 2, s - w, s - w);

    void arc(Color c, double startDeg, double sweepDeg) {
      canvas.drawArc(
        rect,
        _rad(startDeg),
        _rad(sweepDeg),
        false,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = w
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Sudut: 0 = jam 3, searah jarum jam.
    arc(_red, 190, 125); // kiri-atas sampai kanan-atas
    arc(_yellow, 130, 60); // kiri-bawah
    arc(_green, 50, 80); // bawah
    arc(_blue, 0, 50); // kanan-bawah

    // Garis horizontal biru di tengah ("lidah" huruf G)
    canvas.drawRect(
      Rect.fromLTRB(s / 2, s / 2 - w / 2, s, s / 2 + w / 2),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}