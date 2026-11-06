import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _pass.text,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                  child: CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buat akun baru',
                          style: GoogleFonts.poppins(
                              fontSize: 28, fontWeight: FontWeight.w700)),
                      Text('Mulai catat keuanganmu dengan lebih rapi.',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.muted)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
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
                              color:
                                  AppColors.primary.withValues(alpha: 0.24),
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
                                controller: _name,
                                label: 'Nama lengkap',
                                icon: Icons.person_outline_rounded,
                                action: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().length < 2)
                                        ? 'Nama minimal 2 karakter'
                                        : null,
                              ),
                              const SizedBox(height: 14),
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
                              const SizedBox(height: 14),
                              AppField(
                                controller: _pass,
                                label: 'Kata sandi',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                action: TextInputAction.next,
                                suffix: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Kata sandi minimal 6 karakter'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              AppField(
                                controller: _confirm,
                                label: 'Ulangi kata sandi',
                                icon: Icons.lock_reset_rounded,
                                obscure: _obscure,
                                action: TextInputAction.done,
                                validator: (v) => v != _pass.text
                                    ? 'Kata sandi tidak sama'
                                    : null,
                              ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: 'Daftar',
                                icon: Icons.person_add_alt_1_rounded,
                                loading: _loading,
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun?',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppColors.muted)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Masuk',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark)),
                          ),
                        ],
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
