import 'package:flutter/material.dart';
import 'package:moamen_project/core/theme/app_colors.dart';

class UserLocationButton extends StatelessWidget {
  final VoidCallback onTap;

  const UserLocationButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.my_location_rounded,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
