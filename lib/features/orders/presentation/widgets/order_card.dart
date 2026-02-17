import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets.dart' show PriorityBadge, StatusChip;

class OrderCard extends StatelessWidget {
  final Order order;
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
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.15)
              : AppColors.darkCard.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue.withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: isSelected ? AppColors.glowShadow : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Photo Thumbnail
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                        image: order.photoUrls.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(order.photoUrls.first),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: order.photoUrls.isEmpty
                          ? Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white.withOpacity(0.2),
                              size: 30,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              PriorityBadge(priority: order.priority),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.publicArea,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusChip(status: order.status),
                              // Selection Indicator
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryBlue
                                        : Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
