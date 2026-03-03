import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/core/widgets/custom_snackbar.dart';
import 'package:moamen_project/features/auth/presentation/AccountNotActiveScreen.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
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
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        showCustomSnackBar(
          context,
          customTheme: customTheme,
          message: next.error!,
          icon: Icons.error,
          isError: true,
          color: customTheme.errorColor,
        );
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(gradient: customTheme.scaffoldGradient),
          child: Stack(
            children: [
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
                            color: customTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'مرحباً بك',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 48,
                            color: customTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'نظام توصيل المستقبل بين يديك',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: customTheme.textSecondary,
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
                                  color: customTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController,
                                style: TextStyle(
                                  color: customTheme.textPrimary,
                                ),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: '01xxxxxxxx',
                                  prefixIcon: Icon(
                                    Icons.phone_android,
                                    color: customTheme.textSecondary,
                                  ),
                                  prefixStyle: TextStyle(
                                    color: customTheme.textPrimary,
                                    fontSize: 16,
                                  ),
                                  hintStyle: TextStyle(
                                    color: customTheme.textSecondary
                                        .withOpacity(0.3),
                                  ),
                                  filled: true,
                                  fillColor: customTheme.cardBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: customTheme.textPrimary
                                          .withOpacity(0.05),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: customTheme.primaryBlue,
                                      width: 2,
                                    ),
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
                                  color: customTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                style: TextStyle(
                                  color: customTheme.textPrimary,
                                ),
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: TextStyle(
                                    color: customTheme.textSecondary
                                        .withOpacity(0.3),
                                  ),
                                  filled: true,
                                  fillColor: customTheme.cardBackground,
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: customTheme.textSecondary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: customTheme.textPrimary
                                          .withOpacity(0.05),
                                    ),
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
                                    color:
                                        customTheme.primaryGradient.colors[0],
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
                            gradient: customTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: customTheme.primaryGradient.colors[0]
                                    .withOpacity(0.4),
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
                                    child: AnimationWidget.loadingAnimation(24),
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
                              color: customTheme.primaryGradient.colors[0],
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
      ),
    );
  }
}
