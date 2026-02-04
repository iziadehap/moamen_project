import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';

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
    state = state.copyWith(progress: 0.1);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(progress: 0.3);

    // Internet check - wait for connectivity check to complete
    final connectivityState = ref.read(connectivityProvider);

    // If still checking, wait a bit more
    if (connectivityState.isChecking) {
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    final finalConnectivityState = ref.read(connectivityProvider);
    if (!finalConnectivityState.isConnected) {
      state = state.copyWith(error: 'Internet Connection Required');
      return;
    }
    state = state.copyWith(internetChecked: true, progress: 0.6);
    await Future.delayed(const Duration(milliseconds: 800));

    // GPS permission check
    final hasLocation = await permissionService
        .checkAndRequestLocationPermission();
    if (!hasLocation) {
      state = state.copyWith(error: 'Location Permission Required');
      return;
    }
    state = state.copyWith(gpsChecked: true, progress: 1.0);
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void retry() {
    state = const SplashState();
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

    // Listen for errors and navigation
    ref.listen<SplashState>(splashProvider, (previous, next) {
      if (next.error != null) {
        _showErrorDialog(context, next.error!, () {
          Navigator.of(context).pop();
          ref.read(splashProvider.notifier).retry();
        });
      }

      if (next.progress == 1.0 && next.error == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
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
              child: Column(
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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
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
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                              ),
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
                          child: LinearProgressIndicator(
                            value: state.progress,
                            backgroundColor: AppColors.darkCard,
                            color: AppColors.primaryBlue,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showErrorDialog(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
