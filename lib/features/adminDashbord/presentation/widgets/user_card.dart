import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/core/utils/fake_email.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/widgets/open_phone_number.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:moamen_project/features/adminDashbord/presentation/user_details_screen.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCard extends ConsumerWidget {
  final UserModel user;
  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = user.role == SupabaseAccountTyps.admin;
    final color = isAdmin ? AppColors.primaryPurple : AppColors.primaryBlue;
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final isMe = user.id == Supabase.instance.client.auth.currentUser?.id;

    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: customTheme.cardBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsScreen(user: user),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Badge
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: color.withOpacity(0.1),
                      backgroundImage: user.imageUrl != null
                          ? NetworkImage(user.imageUrl!)
                          : null,
                      child: user.imageUrl == null
                          ? Icon(
                              isAdmin
                                  ? Icons.admin_panel_settings_rounded
                                  : Icons.person_rounded,
                              color: color,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? AppColors.statusGreen
                            : Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: customTheme.cardBackground,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        user.isActive
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isMe
                                ? '${user.name} (أنت)'
                                : (user.name ?? 'بدون اسم'),
                            style: GoogleFonts.cairo(
                              color: customTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildRoleBadge(isAdmin),
                      ],
                    ),
                    OpenPhoneNumber(
                      phone: user.phone,
                      child: Text(
                        PhoneToEmailConverter.reutrnPhoneFromEmailWithoutCountryCode(
                          user.phone,
                        ),
                        style: GoogleFonts.cairo(
                          color: customTheme.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: customTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: [
                        _buildSmallStat(
                          Icons.shopping_bag_rounded,
                          'الطلبات: ${user.maxOrders}',
                          customTheme,
                        ),
                        _buildSmallStat(
                          Icons.access_time_filled_rounded,
                          dateFormat.format(user.createdAt),
                          customTheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(bool isAdmin) {
    final color = isAdmin ? AppColors.primaryPurple : AppColors.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        isAdmin ? 'مدير' : 'عميل',
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSmallStat(
    IconData icon,
    String label,
    CustomThemeExtension customTheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: customTheme.textSecondary.withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
