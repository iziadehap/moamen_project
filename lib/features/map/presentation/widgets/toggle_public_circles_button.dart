import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';

class TogglePublicCirclesButton extends StatelessWidget {
  final bool showPublicCircles;
  final VoidCallback onToggle;

  const TogglePublicCirclesButton({
    super.key,
    required this.showPublicCircles,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showPublicCircles
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: showPublicCircles
                    ? AppColors.primaryPurple
                    : AppColors.textGrey,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'الطلبات العامة',
                style: GoogleFonts.cairo(
                  color: showPublicCircles ? Colors.white : AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
