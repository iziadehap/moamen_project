import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:moamen_project/core/services/connectivity/connectivity_service.dart';
import 'package:moamen_project/core/services/location/location_service.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/login_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import 'riverpod/splash_state.dart';
import 'riverpod/splash_notifier.dart';

/// ==================== UI ====================
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(splashProvider);
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    // Listen for navigation only
    ref.listen<SplashState>(splashProvider, (previous, next) {
      if (next.progress == 1.0 && next.error == null) {
        if (!context.mounted) return;

        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          ref.read(connectivityProvider.notifier).enable();
          ref.read(locationProvider.notifier).enable();

          ref.read(splashProvider.notifier).getUserProfile().then((value) {
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          });
        } else {
          ref.read(connectivityProvider.notifier).enable();
          ref.read(locationProvider.notifier).enable();

          if (!context.mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                  ),
                  itemBuilder: (context, index) =>
                      Icon(Icons.add, color: customTheme.textPrimary),
                  itemCount: 100,
                ),
              ),
            ),

            Center(
              child: state.error != null
                  ? _buildErrorState(ref, state, customTheme)
                  : _buildLoadingState(state, customTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(
    SplashState state,
    CustomThemeExtension customTheme,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: customTheme.cardBackground,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: customTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: AnimationWidget.hiAnimation(50),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scrapekia',
              style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: customTheme.textPrimary,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        // Status Cards
        Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: customTheme.cardBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: customTheme.textPrimary.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: [
              _buildStatusRow(
                'الاتصال بالإنترنت',
                'Network Check...',
                Icons.wifi,
                state.internetChecked,
                customTheme.statusGreen,
                customTheme,
              ),
              Divider(
                color: customTheme.textPrimary.withOpacity(0.05),
                height: 32,
              ),
              _buildStatusRow(
                'صلاحية الموقع (GPS)',
                'Location Access...',
                Icons.navigation,
                state.gpsChecked,
                customTheme.primaryBlue,
                customTheme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(state.progress * 100).toInt()}%',
                    style: TextStyle(color: customTheme.primaryBlue),
                  ),
                  Text(
                    'جاري التحقق...',
                    style: GoogleFonts.cairo(color: customTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: state.progress),
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: customTheme.cardBackground,
                      color: customTheme.primaryBlue,
                      minHeight: 6,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    WidgetRef ref,
    SplashState state,
    CustomThemeExtension customTheme,
  ) {
    final error = state.error ?? '';
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: customTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: customTheme.errorColor,
              size: 80,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'عذراً، هناك مشكلة',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: customTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 48),

          // Retry Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => ref.read(splashProvider.notifier).retry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: customTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Solve Error Button (Open Settings)
          if (state.solveError != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (state.solveError == 'permission') {
                    Geolocator.openAppSettings();
                  } else if (state.solveError == 'gps') {
                    Geolocator.openLocationSettings();
                  }
                },
                icon: const Icon(Icons.settings_outlined),
                label: Text(
                  state.solveError == 'permission'
                      ? 'فتح إعدادات التطبيق'
                      : 'فتح إعدادات الموقع',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: customTheme.primaryBlue,
                  side: BorderSide(color: customTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            if (state.solveError == 'permission') ...[
              const SizedBox(height: 24),
              _buildPermissionGuide(customTheme),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionGuide(CustomThemeExtension customTheme) {
    final steps = [
      'اضغط على زر (فتح إعدادات التطبيق) أعلاه',
      'اختر قسم (الأذونات / Permissions)',
      'ابحث عن (الموقع / Location)',
      'قم بتفعيل الخيار إلى (عند استخدام التطبيق فقط)',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: customTheme.textPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: customTheme.textPrimary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'كيفية تفعيل الصلاحية؟',
                style: GoogleFonts.cairo(
                  color: customTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.info_outline,
                color: customTheme.primaryBlue,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.value,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        color: customTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: customTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    String title,
    String subtitle,
    IconData icon,
    bool checked,
    Color activeColor,
    CustomThemeExtension customTheme,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: checked
                ? activeColor
                : customTheme.textPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: checked
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                color: customTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: customTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: customTheme.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: customTheme.textPrimary.withOpacity(0.05),
            ),
          ),
          child: Icon(icon, color: customTheme.textPrimary, size: 20),
        ),
      ],
    );
  }
}
