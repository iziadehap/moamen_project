import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isSelected;
  final VoidCallback onToggle;

  const OrderCard({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.2)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: AppColors.glowShadow,
        ),
        child: Row(
          children: [
            // Checkbox with custom style
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.address,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(order.distanceInMeters ?? 0) ~/ 1000} km away', // Approx km
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
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
