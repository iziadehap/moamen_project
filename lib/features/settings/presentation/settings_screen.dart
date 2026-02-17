import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/core/utils/cash.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/auth/presentation/login_screen.dart';
import 'package:moamen_project/features/settings/data/settings_provider.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale == 'ar';

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        isArabic
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isArabic ? 'الإعدادات' : 'Settings',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings List
              Expanded(
                child: Directionality(
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      // Theme Section
                      Text(
                        isArabic ? 'المظهر' : 'Appearance',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SettingsTile(
                        title: isArabic ? 'الوضع الداكن' : 'Dark Mode',
                        subtitle: isArabic
                            ? 'تبديل بين الوضع الداكن والفاتح'
                            : 'Toggle between dark and light mode',
                        icon: isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primaryPurple,
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (value) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                          activeColor: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Language Section
                      Text(
                        isArabic ? 'اللغة' : 'Language',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SettingsTile(
                        title: isArabic ? 'اللغة العربية' : 'Arabic Language',
                        subtitle: isArabic
                            ? 'التبديل بين العربية والإنجليزية'
                            : 'Switch between Arabic and English',
                        icon: Icons.language_rounded,
                        color: AppColors.primaryBlue,
                        trailing: Switch(
                          value: isArabic,
                          onChanged: (value) {
                            ref.read(localeProvider.notifier).toggleLocale();
                          },
                          activeColor: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Account Section
                      Text(
                        isArabic ? 'الحساب' : 'Account',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SettingsTile(
                        title: isArabic ? 'تسجيل الخروج' : 'Logout',
                        subtitle: isArabic
                            ? 'تسجيل الخروج من الحساب'
                            : 'Sign out from your account',
                        icon: Icons.logout_rounded,
                        color: Colors.redAccent,
                        onTap: () async {
                          ref.read(authProvider.notifier).logout();
                          await PrivcyCash.deleteCredentials();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
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
