import 'package:flutter/material.dart';

/// MediSync design-system color tokens.
///
/// Dark medical theme with cyan/teal accent — optimised for clinical
/// environments and maximum readability on OLED screens.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color brandCyan = Color(0xFF00E5CC);
  static const Color brandTeal = Color(0xFF0EA5E9);
  static const Color brandGradientStart = Color(0xFF00E5CC);
  static const Color brandGradientEnd = Color(0xFF0EA5E9);

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF060D1F);
  static const Color scaffoldBg = Color(0xFF0A1628);
  static const Color cardDark = Color(0xFF112240);
  static const Color cardDarker = Color(0xFF0D1B36);
  static const Color surface = Color(0xFF172B4D);
  static const Color surfaceVariant = Color(0xFF1E3A5F);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8899BB);
  static const Color textHint = Color(0xFF546080);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF5F72);
  static const Color errorContainer = Color(0xFF3D0016);
  static const Color success = Color(0xFF00E5A0);
  static const Color successContainer = Color(0xFF003822);
  static const Color warning = Color(0xFFFFB547);
  static const Color warningContainer = Color(0xFF3D2600);

  // ── Role colors ─────────────────────────────────────────────────────────────
  static const Color roleDoctor = Color(0xFF00E5CC);
  static const Color roleCompounder = Color(0xFF7C5CFC);
  static const Color roleReceptionist = Color(0xFFFF8C61);

  // ── Borders & Dividers ─────────────────────────────────────────────────────
  static const Color border = Color(0xFF1E3A5F);
  static const Color borderHighlight = Color(0xFF00E5CC);
  static const Color divider = Color(0xFF172B4D);

  // ── Glassmorphism overlay ──────────────────────────────────────────────────
  static const Color glassOverlay = Color(0x1A00E5CC);
  static const Color glassBorder = Color(0x3300E5CC);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandGradientStart, brandGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, scaffoldBg, cardDarker],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardDark, cardDarker],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
