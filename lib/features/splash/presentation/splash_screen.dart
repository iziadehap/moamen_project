import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart'; // Added import for openLocationSettings
import 'package:moamen_project/core/services/connectivity/connectivity_service.dart';
import 'package:moamen_project/core/services/location/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
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

    // Listen for navigation only
    ref.listen<SplashState>(splashProvider, (previous, next) {
      if (next.progress == 1.0 && next.error == null) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          // Enable connectivity and location services
          ref.read(connectivityProvider.notifier).enable();
          ref.read(locationProvider.notifier).enable();

          // get user profile from supabase
          ref.read(splashProvider.notifier).getUserProfile().then((value) {
            // User is logged in
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          });
        } else {
          // Enable connectivity and location services for Login Screen
          ref.read(connectivityProvider.notifier).enable();
          ref.read(locationProvider.notifier).enable();
          // Not logged in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
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
                      const Icon(Icons.add, color: Colors.white),
                  itemCount: 100,
                ),
              ),
            ),

            Center(
              child: state.error != null
                  ? _buildErrorState(ref, state)
                  : _buildLoadingState(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(SplashState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            boxShadow: AppColors.glowShadow,
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            size: 64,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'نظام التوصيل الذكي',
          style: GoogleFonts.cairo(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'SMART LOGISTICS 2026',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            letterSpacing: 4,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 60),
        // Status Cards
        Container(
          height: 220,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _buildStatusRow(
                'الاتصال بالإنترنت',
                'Network Check...',
                Icons.wifi,
                state.internetChecked,
                AppColors.statusGreen,
              ),
              const Divider(color: Colors.white10, height: 32),
              _buildStatusRow(
                'صلاحية الموقع (GPS)',
                'Location Access...',
                Icons.navigation,
                state.gpsChecked,
                AppColors.primaryBlue,
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
                    style: const TextStyle(color: AppColors.primaryBlue),
                  ),
                  Text(
                    'جاري التحقق...',
                    style: GoogleFonts.cairo(color: Colors.white),
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
                      backgroundColor: AppColors.darkCard,
                      color: AppColors.primaryBlue,
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

  Widget _buildErrorState(WidgetRef ref, SplashState state) {
    final error = state.error ?? '';
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 80,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'عذراً، هناك مشكلة',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textGrey),
          ),
          const SizedBox(height: 48),

          // Retry Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => ref.read(splashProvider.notifier).retry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
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
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            if (state.solveError == 'permission') ...[
              const SizedBox(height: 24),
              _buildPermissionGuide(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionGuide() {
    final steps = [
      'اضغط على زر (فتح إعدادات التطبيق) أعلاه',
      'اختر قسم (الأذونات / Permissions)',
      'ابحث عن (الموقع / Location)',
      'قم بتفعيل الخيار إلى (عند استخدام التطبيق فقط)',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
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
                        color: AppColors.textGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
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
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: checked ? activeColor : Colors.grey.shade800,
            shape: BoxShape.circle,
            boxShadow: checked
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.5),
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
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.midnightNavy,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}
