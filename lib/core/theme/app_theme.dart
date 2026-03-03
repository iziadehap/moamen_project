import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.lightBg,
      fontFamily: GoogleFonts.cairo().fontFamily,
      extensions: [
        CustomThemeExtension(
          primaryGradient: AppColors.primaryGradient,
          cardBackground: AppColors.lightCard,
          textPrimary: AppColors.textBlack,
          textSecondary: AppColors.textGrey,
          accentGradient: const LinearGradient(
            colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF)],
          ),
          scaffoldGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
          background: AppColors.lightBg,
          successColor: AppColors.statusGreen,
          errorColor: Colors.redAccent,
          primaryBlue: AppColors.primaryBlue,
          statusGreen: AppColors.statusGreen,
          statusCyan: AppColors.statusCyan,
          primaryPurple: AppColors.primaryPurple,
          statusOrange: AppColors.statusOrange,
        ),
      ],
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.statusCyan,
        surface: AppColors.lightCard,
        background: AppColors.lightBg,
        onSurface: AppColors.textBlack,
      ),
      // ... rest of lightTheme textTheme and inputDecorationTheme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: AppColors.textBlack),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: AppColors.textGrey),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIconColor: AppColors.textGrey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.midnightNavy,
      fontFamily: GoogleFonts.cairo().fontFamily,
      extensions: [
        CustomThemeExtension(
          primaryGradient: AppColors.primaryGradient,
          cardBackground: AppColors.darkCard,
          textPrimary: AppColors.textWhite,
          textSecondary: AppColors.textGrey,
          accentGradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
          scaffoldGradient: AppColors.backgroundGradient,
          background: AppColors.midnightNavy,
          successColor: AppColors.statusGreen,
          errorColor: Colors.redAccent,
          primaryBlue: AppColors.primaryBlue,
          statusGreen: AppColors.statusGreen,
          statusCyan: AppColors.statusCyan,
          primaryPurple: AppColors.primaryPurple,
          statusOrange: AppColors.statusOrange,
        ),
      ],
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.statusCyan,
        surface: AppColors.darkCard,
        background: AppColors.midnightNavy,
        onSurface: AppColors.textWhite,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: AppColors.textWhite),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: AppColors.textGrey),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIconColor: AppColors.textGrey,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue, // Fallback
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}

class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final LinearGradient primaryGradient;
  final Color cardBackground;
  final Color textPrimary;
  final Color textSecondary;
  final LinearGradient accentGradient;
  final LinearGradient scaffoldGradient;
  final Color background;
  final Color successColor;
  final Color errorColor;
  final Color primaryBlue;
  final Color statusGreen;
  final Color statusCyan;
  final Color primaryPurple;
  final Color statusOrange;

  CustomThemeExtension({
    required this.primaryGradient,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentGradient,
    required this.scaffoldGradient,
    required this.background,
    required this.successColor,
    required this.errorColor,
    required this.primaryBlue,
    required this.statusGreen,
    required this.statusCyan,
    required this.primaryPurple,
    required this.statusOrange,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({
    LinearGradient? primaryGradient,
    Color? cardBackground,
    Color? textPrimary,
    Color? textSecondary,
    LinearGradient? accentGradient,
    LinearGradient? scaffoldGradient,
    Color? background,
    Color? successColor,
    Color? errorColor,
    Color? primaryBlue,
    Color? statusGreen,
    Color? statusCyan,
    Color? primaryPurple,
    Color? statusOrange,
  }) {
    return CustomThemeExtension(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      cardBackground: cardBackground ?? this.cardBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accentGradient: accentGradient ?? this.accentGradient,
      scaffoldGradient: scaffoldGradient ?? this.scaffoldGradient,
      background: background ?? this.background,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      primaryBlue: primaryBlue ?? this.primaryBlue,
      statusGreen: statusGreen ?? this.statusGreen,
      statusCyan: statusCyan ?? this.statusCyan,
      primaryPurple: primaryPurple ?? this.primaryPurple,
      statusOrange: statusOrange ?? this.statusOrange,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) return this;
    return CustomThemeExtension(
      primaryGradient: LinearGradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accentGradient: LinearGradient.lerp(
        accentGradient,
        other.accentGradient,
        t,
      )!,
      scaffoldGradient: LinearGradient.lerp(
        scaffoldGradient,
        other.scaffoldGradient,
        t,
      )!,
      background: Color.lerp(background, other.background, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      primaryBlue: Color.lerp(primaryBlue, other.primaryBlue, t)!,
      statusGreen: Color.lerp(statusGreen, other.statusGreen, t)!,
      statusCyan: Color.lerp(statusCyan, other.statusCyan, t)!,
      primaryPurple: Color.lerp(primaryPurple, other.primaryPurple, t)!,
      statusOrange: Color.lerp(statusOrange, other.statusOrange, t)!,
    );
  }
}
