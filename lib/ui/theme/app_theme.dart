import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Dark theme (login / start screen) ──
  static const Color backgroundDark = Color(0xFF081442);
  static const Color backgroundMid = Color(0xFF0B1A5C);
  static const Color backgroundLight = Color(0xFF1B3A8A);
  static const Color primary = Color(0xFF2962FF);
  static const Color primaryLight = Color(0xFF448AFF);
  static const Color accent = Color(0xFFFFD54F);
  static const Color accentDark = Color(0xFFFFC107);
  static const Color xColor = Color(0xFFFF6B6B);
  static const Color oColor = Color(0xFF4ECDC4);
  static const Color surface = Color(0x1AFFFFFF);
  static const Color surfaceLight = Color(0x29FFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF69F0AE);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D47A1), Color(0xFF0B1A5C), Color(0xFF081442)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
  );

  // ── Vivid theme (game screens) ──
  static const Color pBg = Color(0xFFF0EDFF);
  static const Color pSurface = Colors.white;
  static const Color pPurple = Color(0xFF9C7CF4);
  static const Color pPurpleDeep = Color(0xFF7C4DFF);
  static const Color pBlue = Color(0xFF42A5F5);
  static const Color pBlueBg = Color(0xFFBBDEFB);
  static const Color pGreen = Color(0xFF66BB6A);
  static const Color pGreenBg = Color(0xFFC8E6C9);
  static const Color pPink = Color(0xFFEC407A);
  static const Color pPinkBg = Color(0xFFF8BBD0);
  static const Color pYellow = Color(0xFFFFCA28);
  static const Color pYellowBg = Color(0xFFFFECB3);
  static const Color pCoral = Color(0xFFFF6B6B);
  static const Color pTeal = Color(0xFF26A69A);
  static const Color pTealBg = Color(0xFFB2DFDB);
  static const Color pLavender = Color(0xFFD1C4E9);
  static const Color pTextDark = Color(0xFF2D3436);
  static const Color pTextMid = Color(0xFF636E72);
  static const Color pTextLight = Color(0xFFB2BEC3);

  static const LinearGradient pGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8E0FF), Color(0xFFF0EDFF), Color(0xFFFFF3E0)],
  );

  static const LinearGradient pAccentGradient = LinearGradient(
    colors: [Color(0xFF9C7CF4), Color(0xFF7C4DFF)],
  );
}

class AppTheme {
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  static BoxDecoration get glassCard => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceLight, width: 1),
      );

  static BoxDecoration get accentButton => BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ── Vivid decorations ──

  static BoxDecoration pastelCard([Color? bg]) => BoxDecoration(
        color: bg ?? AppColors.pSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (bg ?? AppColors.pPurple).withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  static BoxDecoration get pastelButton => BoxDecoration(
        gradient: AppColors.pAccentGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.pPurpleDeep.withAlpha(80),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );

  static BoxDecoration get circleButton => BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0x1AFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: GoogleFonts.inter(fontSize: 11),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static InputDecoration pastelInput({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: AppColors.pTextMid, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.pPurpleDeep, size: 20),
      filled: true,
      fillColor: Colors.white.withAlpha(180),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: AppColors.pPurpleDeep, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
