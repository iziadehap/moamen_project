import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/auth/presentation/login_screen.dart';

class NotActiveScreen extends ConsumerWidget {
  const NotActiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container with Glow
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 60,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 40),

            // Title
            Text(
              'الحساب قيد المراجعة',
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'شكراً لتسجيلك في النظام. حسابك حالياً قيد المراجعة من قبل الإدارة وسيتم تفعيله قريباً.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: AppColors.textGrey,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // Contact Support Button (Optional placeholder)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                      color: AppColors.darkCard.withOpacity(0.5),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('سيتم التواصل معك قريباً'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                        // TODO: Implement contact support
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'تواصل مع الدعم',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout Button
                  TextButton.icon(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                    label: Text(
                      'تسجيل خروج',
                      style: GoogleFonts.cairo(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
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
}
