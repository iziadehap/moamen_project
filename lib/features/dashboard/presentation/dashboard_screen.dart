import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/auth/presentation/login_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../pricelist/presentation/price_list_screen.dart';
import '../../admin/addOrder/add_order_screen.dart';
import 'widgets/dashboard_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  void _logout() {
    ref.read(authProvider.notifier).logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.role == SupabaseAccountTyps.admin;

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Custom Premium Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مرحباً بك،',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppColors.textGrey,
                          ),
                        ),
                        Text(
                          user?.name ?? 'المستخدم',
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Admin/User Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? AppColors.primaryPurple.withOpacity(0.2)
                                : AppColors.primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAdmin
                                  ? AppColors.primaryPurple.withOpacity(0.3)
                                  : AppColors.primaryBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            isAdmin ? 'مدير' : 'مستخدم',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: isAdmin
                                  ? AppColors.primaryPurple
                                  : AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Logout Action
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'ماذا تريد أن تفعل اليوم؟',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                // Premium Vertical List
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        DashboardCard(
                          title: 'الطلبات',
                          subtitle: 'مشاهدة وإدارة جميع طلبات التوصيل',
                          icon: Icons.list_alt_rounded,
                          color: AppColors.primaryBlue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('قريباً: شاشة الطلبات'),
                              ),
                            );
                          },
                        ),
                        DashboardCard(
                          title: 'الخريطة',
                          subtitle: 'تتبع الشحنات والمواقع المباشرة',
                          icon: Icons.map_rounded,
                          color: AppColors.statusCyan,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('قريباً: شاشة الخريطة'),
                              ),
                            );
                          },
                        ),
                        DashboardCard(
                          title: 'قائمة الأسعار',
                          subtitle: 'أسعار خدمات التوصيل والطرود',
                          icon: Icons.attach_money_rounded,
                          color: Colors.orangeAccent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PriceListScreen(),
                              ),
                            );
                          },
                        ),
                        if (isAdmin)
                          DashboardCard(
                            title: 'إضافة طلب',
                            subtitle: 'إنشاء طلب توصيل جديد للنظام',
                            icon: Icons.add_location_alt_rounded,
                            color: AppColors.primaryPurple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddOrderScreen(),
                                ),
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
      ),
    );
  }
}
