import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/features/auth/presentation/AccountNotActiveScreen.dart';
import '../../../../core/theme/app_colors.dart';
import 'controller/auth_provider.dart';
import 'register_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .login(_phoneController.text, _passwordController.text);

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        if (authState.isActive) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NotActiveScreen()),
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('حسابك غير مفعل'),
          //     backgroundColor: Colors.redAccent,
          //   ),
          // );
        }
      }
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (value.length < 9) {
      return 'رقم الهاتف قصير جداً';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Close Button
            // Positioned(
            //   top: 50,
            //   right: 20,
            //   child: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.white.withValues(alpha: 0.1),
            //       shape: BoxShape.circle,
            //     ),
            //     child: const Icon(Icons.close, color: Colors.white),
            //   ),
            // ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Text (Arabic)
                      Text(
                        'تسجيل الدخول',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'مرحباً بك',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 48,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'نظام توصيل المستقبل بين يديك',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Phone Field
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'رقم الهاتف',
                              style: GoogleFonts.cairo(
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: '01xxxxxxxx',
                                prefixIcon: const Icon(
                                  Icons.phone_android,
                                  color: AppColors.textGrey,
                                ),
                                // prefixText: '+20 ',
                                prefixStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                filled: true,
                                fillColor: AppColors.darkCard,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: _validatePhone,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'كلمة المرور',
                              style: GoogleFonts.cairo(
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                filled: true,
                                fillColor: AppColors.darkCard,
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: AppColors.textGrey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: GoogleFonts.cairo(
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Login Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E66F6), Color(0xFF8B47FA)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2E66F6,
                              ).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: authState.isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                    ), // RTL Arrow
                                    const SizedBox(width: 10),
                                    Text(
                                      'دخول',
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Footer - Create Account
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'ليس لديك حساب؟ إنشاء حساب جديد',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
