import 'package:flutter/material.dart';

class AppColors {
  // Smart Logistics 2026 Palette

  // Backgrounds
  static const Color midnightNavy = Color(0xFF0B1221); // Dark Mode Background
  static const Color darkCard = Color(0xFF152033); // Dark Mode Card

  static const Color lightBg = Color(0xFFF4F7FE); // Light Mode Background
  static const Color lightCard = Color(0xFFFFFFFF); // Light Mode Card

  // Accents
  static const Color primaryBlue = Color(0xFF2E66F6); // Bright Blue
  static const Color primaryPurple = Color(0xFF8B47FA); // Purple accent
  static const Color statusGreen = Color(0xFF00E676); // Success/Connected
  static const Color statusCyan = Color(0xFF00E5FF); // Active/GPS
  static const Color statusOrange = Color(0xFFFF9100); // Warning/Pending
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF8F9BB3);
  static const Color textBlack = Color(0xFF1B254B); // Light Mode Primary Text

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E66F6), Color(0xFF8B47FA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B1221), Color(0xFF0F1B35)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 5),
    ),
  ];
}
