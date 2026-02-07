import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/utils/app_text.dart';
import 'package:moamen_project/core/utils/privcy_cash.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import 'package:permission_handler/permission_handler.dart';

/// ==================== STATE ====================
class SplashState {
  final bool internetChecked;
  final bool gpsChecked;
  final double progress;
  final String? error;

  const SplashState({
    this.internetChecked = false,
    this.gpsChecked = false,
    this.progress = 0.0,
    this.error,
  });

  SplashState copyWith({
    bool? internetChecked,
    bool? gpsChecked,
    double? progress,
    String? error,
  }) {
    return SplashState(
      internetChecked: internetChecked ?? this.internetChecked,
      gpsChecked: gpsChecked ?? this.gpsChecked,
      progress: progress ?? this.progress,
      error: error,
    );
  }
}

/// ==================== NOTIFIER ====================
class SplashNotifier extends Notifier<SplashState> {
  late final PermissionService permissionService;

  @override
  SplashState build() {
    permissionService = ref.read(permissionServiceProvider);
    Future.microtask(() => _startSystemCheck());
    return const SplashState();
  }

  Future<void> _startSystemCheck() async {
    state = state.copyWith(progress: 0.1, error: null);
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Internet check
    state = state.copyWith(progress: 0.2);
    final connectivityState = ref.read(connectivityProvider);
    if (connectivityState.isChecking) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    if (!ref.read(connectivityProvider).isConnected) {
      state = state.copyWith(
        error: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
      );
      return;
    }
    state = state.copyWith(internetChecked: true, progress: 0.5);
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Location Permission check
    state = state.copyWith(progress: 0.6);
    final hasPermission = await permissionService
        .checkAndRequestLocationPermission();
    if (!hasPermission) {
      state = state.copyWith(error: 'صلاحية الوصول للموقع مطلوبة للمتابعة.');
      return;
    }

    // 3. GPS Service check
    state = state.copyWith(progress: 0.8);
    final isGpsEnabled = await permissionService.isLocationServiceEnabled();
    if (!isGpsEnabled) {
      state = state.copyWith(
        error: 'خدمات الموقع (GPS) معطلة. يرجى تفعيلها من الإعدادات.',
      );
      return;
    }

    // 4. Login check
    state = state.copyWith(progress: 0.9);
    try {
      final credentials = await PrivcyCash.readCredentials();
      if (credentials[CashHelper.phoneKey] != null &&
          credentials[CashHelper.passwordKey] != null) {
        await ref
            .read(authProvider.notifier)
            .login(
              credentials[CashHelper.phoneKey]!,
              credentials[CashHelper.passwordKey]!,
              isFromCash: true,
            );

        // Check if login failed
        final authResult = ref.read(authProvider);
        if (authResult.error != null) {
          state = state.copyWith(error: authResult.error);
          return;
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'فشل تسجيل الدخول: ${e.toString()}');
      return;
    }

    state = state.copyWith(gpsChecked: true, progress: 1.0);
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void retry() {
    _startSystemCheck();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// ==================== PROVIDER ====================
// Import service providers from their respective files
// These are now defined in the service files themselves
final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);

/// ==================== UI ====================
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(splashProvider);

    // Listen for navigation only
    ref.listen<SplashState>(splashProvider, (previous, next) {
      if (next.progress == 1.0 && next.error == null) {
        final user = ref.read(authProvider).user;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                user != null ? const DashboardScreen() : const LoginScreen(),
          ),
        );
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

            // Content
            Center(
              child: state.error != null
                  ? _buildErrorState(ref, state.error!)
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

  Widget _buildErrorState(WidgetRef ref, String error) {
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

          const SizedBox(height: 16),

          // Secondary button for settings if it's location related
          if (error.contains('الموقع') || error.contains('GPS'))
            TextButton(
              onPressed: () => openAppSettings(),
              child: Text(
                'فتح الإعدادات',
                style: GoogleFonts.cairo(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
