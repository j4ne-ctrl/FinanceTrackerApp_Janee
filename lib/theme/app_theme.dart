import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF7C8CF5);
  static const primaryDark = Color(0xFF5B63D6);
  static const ink = Color(0xFF2A2742);
  static const sand = Color(0xFFFFD6B0);
  static const income = Color(0xFF2FBF8A);
  static const expense = Color(0xFFFF6B8A);
  static const muted = Color(0xFF85829C);
  static const bgTop = Color(0xFFD9EAFF);
  static const bgMid = Color(0xFFEFE2FF);
  static const bgBottom = Color(0xFFE3F5D8);

  /// Latar pastel berlapis: biru bayi -> lilac -> pink -> peach -> mint
  static const bgColors = <Color>[
    Color(0xFFD9EAFF),
    Color(0xFFEFE2FF),
    Color(0xFFFFE1EE),
    Color(0xFFFFEBD8),
    Color(0xFFE3F5D8),
  ];

  /// Kilau kaca: putih terang di sudut kiri atas, memudar ke bawah
  static const glossColors = <Color>[
    Color(0xE6FFFFFF),
    Color(0x66FFFFFF),
  ];

  /// Gradasi kartu (soft): biru -> lilac -> pink -> coral
  static const brandColors = <Color>[
    Color(0xFF6C9BF2),
    Color(0xFF9B7CF0),
    Color(0xFFEE7FC0),
    Color(0xFFFF9F7A),
  ];
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.bgTop,
    );

    OutlineInputBorder border(Color c, [double w = 0]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: w == 0 ? BorderSide.none : BorderSide(color: c, width: w),
        );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.65),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: GoogleFonts.poppins(color: AppColors.muted, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: AppColors.muted, fontSize: 14),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        border: border(Colors.transparent),
        enabledBorder: border(const Color(0xFFFFFFFF), 1.2),
        focusedBorder: border(AppColors.primary, 1.8),
        errorBorder: border(AppColors.expense, 1.2),
        focusedErrorBorder: border(AppColors.expense, 1.8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Colors.white, width: 1.2),
        ),
      ),
    );
  }
}
