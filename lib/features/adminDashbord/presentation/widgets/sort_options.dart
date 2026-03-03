import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/features/adminDashbord/presentation/controller/admin_provider.dart';

void showSortOptions(BuildContext context, WidgetRef ref) {
  final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
  showModalBottomSheet(
    context: context,
    backgroundColor: customTheme.cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ترتيب حسب',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: customTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildSortItem(
            context: context,
            ref: ref,
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ الإنشاء',
            value: 'created_at',
            customTheme: customTheme,
          ),
          _buildSortItem(
            context: context,
            ref: ref,
            icon: Icons.person_rounded,
            label: 'الاسم',
            value: 'name',
            customTheme: customTheme,
          ),
        ],
      ),
    ),
  );
}

Widget _buildSortItem({
  required BuildContext context,
  required WidgetRef ref,
  required IconData icon,
  required String label,
  required String value,
  required CustomThemeExtension customTheme,
}) {
  final currentSort = ref.watch(adminProvider).sortBy;
  final isSelected = currentSort == value;

  return ListTile(
    leading: Icon(
      icon,
      color: isSelected ? customTheme.primaryBlue : customTheme.textSecondary,
    ),
    title: Text(
      label,
      style: GoogleFonts.cairo(
        color: isSelected ? customTheme.textPrimary : customTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    ),
    trailing: isSelected
        ? Icon(Icons.check_circle_rounded, color: customTheme.primaryBlue)
        : null,
    onTap: () {
      ref.read(adminProvider.notifier).setSortBy(value);
      Navigator.pop(context);
    },
  );
}
