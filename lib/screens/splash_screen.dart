import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final Animation<double> _scale =
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  late final Animation<double> _fade = CurvedAnimation(
      parent: _ctrl, curve: const Interval(0.35, 1, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _next();
  }

  Future<void> _next() async {
    await Future.delayed(const Duration(milliseconds: 2600));
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (!mounted) return;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    Navigator.pushReplacement(
      context,
      fadeRoute(user == null ? const LoginScreen() : const MainShell()),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.brandColors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _blob(240, Colors.white.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: -90,
              left: -70,
              child: _blob(260, AppColors.sand.withValues(alpha: 0.22)),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: const AppLogo(size: 150, onDark: true),
                  ),
                  const SizedBox(height: 34),
                  FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Finance Tracker',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 46,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aplikasi untuk mencatat keuanganmu',
                          style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fade,
                child: const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
