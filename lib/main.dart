import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'core/services/connectivity_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      // title: 'EGX Gold',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return ConnectivityWrapper(child: child!);
      },
      home: const SplashScreen(),
    );
  }
}

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    return Stack(
      children: [
        child,
        if (!connectivityState.isConnected && !connectivityState.isChecking)
          _buildNoInternetOverlay(),
      ],
    );
  }

  Widget _buildNoInternetOverlay() {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: AppColors.glowShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.redAccent,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'انقطع الاتصال',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'يرجى التأكد من اتصالك بالإنترنت للمتابعة',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*


 
//  the code win admin need to change any tink in account of user

Future<Map<String, dynamic>> updateAccountByAdmin({
  required String adminUserId,       // uuid بتاع الإدمن
  required String targetUserId,      // uuid بتاع اليوزر اللي هيتعدل
  String? newName,
  bool? newIsActive,
  String? newRole,
  String? newPassword,
}) async {
  try {
    final response = await supabase.rpc('admin_update_account', params: {
      'p_admin_id': adminUserId,
      'p_target_id': targetUserId,
      'p_new_name': newName,
      'p_new_is_active': newIsActive,
      'p_new_role': newRole,
      'p_new_password': newPassword,
    });

    return response as Map<String, dynamic>;
  } catch (e) {
    print('خطأ في تعديل الحساب: $e');
    return {'success': false, 'message': e.toString()};
    */
