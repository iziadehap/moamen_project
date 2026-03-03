import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/utils/normiliz_eg_phone.dart';
import 'package:moamen_project/core/widgets/animation_widget.dart';
import 'package:moamen_project/features/auth/presentation/AccountNotActiveScreen.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'controller/auth_provider.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _name2Controller = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _name2Controller.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .register(
          _phoneController.text,
          _passwordController.text,
          _nameController.text,
          _name2Controller.text,
        );

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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    try {
      normalizeEgyptianPhone(value);
    } catch (_) {
      return 'رقم الهاتف غير صحيح';
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

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: customTheme.errorColor,
          ),
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
              // Back Button
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: customTheme.textPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: customTheme.textPrimary,
                    ),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Text(
                          'Scrapekia',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            color: customTheme.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'انضم إلى مستقبل التوصيل',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: customTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 60),

                        // Name Field
                        _buildField(
                          label: 'الاسم',
                          controller: _nameController,
                          icon: Icons.person_outline,
                          hint: 'أدخل اسمك',
                          validator: _validateName,
                          customTheme: customTheme,
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          label: 'الاسم الثاني',
                          controller: _name2Controller,
                          icon: Icons.person_outline,
                          hint: 'أدخل اسمك الثاني',
                          validator: _validateName,
                          customTheme: customTheme,
                        ),
                        const SizedBox(height: 20),

                        // Phone Field
                        _buildField(
                          label: 'رقم الهاتف',
                          controller: _phoneController,
                          icon: Icons.phone_android,
                          hint: '01xxxxxxxx',
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                          customTheme: customTheme,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        _buildField(
                          label: 'كلمة المرور',
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          hint: '••••••••',
                          obscureText: true,
                          validator: _validatePassword,
                          customTheme: customTheme,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        _buildField(
                          label: 'تأكيد كلمة المرور',
                          controller: _confirmPasswordController,
                          icon: Icons.lock_outline,
                          hint: '••••••••',
                          obscureText: true,
                          validator: _validateConfirmPassword,
                          customTheme: customTheme,
                        ),
                        const SizedBox(height: 40),

                        // Register Button
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
                            onPressed: authState.isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: authState.isLoading
                                ?  SizedBox(
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
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'إنشاء الحساب',
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required CustomThemeExtension customTheme,
    String? prefixText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(color: customTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: TextStyle(color: customTheme.textPrimary),
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: customTheme.textSecondary.withOpacity(0.3),
              ),
              prefixText: prefixText,
              prefixStyle: TextStyle(
                color: customTheme.textPrimary,
                fontSize: 16,
              ),
              filled: true,
              fillColor: customTheme.cardBackground,
              prefixIcon: Icon(icon, color: customTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: customTheme.textPrimary.withOpacity(0.05),
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
            validator: validator,
          ),
        ],
      ),
    );
  }
}
