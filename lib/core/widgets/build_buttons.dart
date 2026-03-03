import 'package:flutter/material.dart';
import 'package:moamen_project/core/theme/app_theme.dart';

class BuildButtons extends StatelessWidget {
  final VoidCallback ontap;
  final IconData icon;
  const BuildButtons({super.key, required this.ontap, required this.icon});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return IconButton(
      onPressed: ontap,
      icon: Icon(icon, color: customTheme.textPrimary),
      style: IconButton.styleFrom(
        backgroundColor: customTheme.primaryGradient.colors[0].withOpacity(0.1),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: customTheme.primaryBlue.withOpacity(0.2)),
        ),
      ),
    );
  }
}
