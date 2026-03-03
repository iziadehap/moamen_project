import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/core/utils/order_status_helper.dart';
import 'package:moamen_project/core/widgets/build_buttons.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/add_order_screen.dart';
import 'package:moamen_project/features/orders/presentation/widgets/order_filter.dart';

Widget contant_widget(
  Order order,
  CustomThemeExtension customTheme, {
  bool isAuthorized = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PriorityBadge(priority: order.priority),
          Text(
            order.createdAt != null
                ? _formatDate(order.createdAt!)
                : 'جاري التحميل...',
            style: GoogleFonts.cairo(
              color: customTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        order.title,
        style: GoogleFonts.cairo(
          color: customTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      if (isAuthorized) ...[
        const SizedBox(height: 4),
        Text(
          order.description,
          style: GoogleFonts.cairo(
            color: customTheme.textSecondary.withOpacity(0.9),
            fontSize: 13,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _buildMetaDataItem(
              icon: Icons.location_on_rounded,
              label: order.publicArea,
              color: customTheme.primaryBlue,
              customTheme: customTheme,
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(status: order.status),
        ],
      ),
    ],
  );
}

Widget _buildMetaDataItem({
  required IconData icon,
  required String label,
  required Color color,
  required CustomThemeExtension customTheme,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: customTheme.textPrimary.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 60) {
    return 'منذ ${diff.inMinutes} دقيقة';
  } else if (diff.inHours < 24) {
    return 'منذ ${diff.inHours} ساعة';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class StatusChip extends StatelessWidget {
  final OrderStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    Color color = OrderStatusHelper.getStatusColor(status, customTheme);
    String text = OrderStatusHelper.getStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final OrderPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    Color color;
    String text;
    switch (priority) {
      case OrderPriority.low:
        color = Colors.greenAccent;
        text = 'منخفضة';
        break;
      case OrderPriority.medium:
        color = customTheme.primaryBlue;
        text = 'متوسطة';
        break;
      case OrderPriority.high:
        color = Colors.orangeAccent;
        text = 'عالية';
        break;
      case OrderPriority.urgent:
        color = Colors.redAccent;
        text = 'عاجل جداً';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderHeader extends StatelessWidget {
  final bool isSelectionMode;
  final VoidCallback onRefresh;
  final bool isAdmin;
  final VoidCallback onAdd;
  final VoidCallback onInfoPressed;

  const OrderHeader({
    super.key,
    required this.isSelectionMode,
    required this.onRefresh,
    required this.isAdmin,
    required this.onAdd,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            customTheme.background,
            customTheme.background.withOpacity(0.0),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (isSelectionMode)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: customTheme.textPrimary,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: customTheme.textPrimary.withOpacity(
                        0.05,
                      ),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: customTheme.textPrimary.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                if (isSelectionMode) const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              isSelectionMode ? 'إختر أوردر' : 'أوردراتك ',
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: customTheme.textPrimary,
                                letterSpacing: -1,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onInfoPressed,
                            icon: Icon(
                              Icons.info_outline_rounded,
                              color: customTheme.textSecondary,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(20, 20),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إدارة الأوردرات',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: customTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isAdmin) ...[
            BuildButtons(ontap: onAdd, icon: Icons.add),
            // IconButton(
            //   onPressed: onAdd,
            //   icon: const Icon(Icons.add, color: Colors.white),
            //   style: IconButton.styleFrom(
            //     backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            //     padding: const EdgeInsets.all(12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(16),
            //       side: BorderSide(
            //         color: AppColors.primaryBlue.withOpacity(0.2),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(width: 12),
          ],
          // BuildButtons(ontap: onRefresh, icon: Icons.refresh_rounded),
          // IconButton(
          //   onPressed: onRefresh,
          //   icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          //   style: IconButton.styleFrom(
          //     backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          //     padding: const EdgeInsets.all(12),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(16),
          //       side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.2)),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class OrderFilterBar extends StatelessWidget {
  final OrderFilter selectedFilter;
  final ValueChanged<OrderFilter> onFilterSelected;

  const OrderFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = OrderFilter.values;
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          final status = filters[index].status;

          Color chipColor;
          if (filter == OrderFilter.myOrders) {
            chipColor = customTheme.statusOrange;
          } else if (filter == OrderFilter.all) {
            chipColor = customTheme.textPrimary;
          } else {
            chipColor = OrderStatusHelper.getStatusColor(status!, customTheme);
          }

          return ChoiceChip(
            label: Text(
              filter.label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (chipColor.computeLuminance() > 0.5
                          ? Colors.black87
                          : Colors.white)
                    : customTheme.textSecondary,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) onFilterSelected(filter);
            },
            backgroundColor: customTheme.textPrimary.withOpacity(0.05),
            selectedColor: isSelected ? chipColor : null,
            checkmarkColor: isSelected
                ? (chipColor.computeLuminance() > 0.5
                      ? Colors.black87
                      : Colors.white)
                : null,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }
}

class AddOrderButton extends StatelessWidget {
  const AddOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: customTheme.background.withOpacity(0.8),
        border: Border(
          top: BorderSide(color: customTheme.textPrimary.withOpacity(0.1)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            gradient: customTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddOrderScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'إضافة اوردر جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

class StatusInfoDialog extends StatelessWidget {
  const StatusInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>()!;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: customTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: customTheme.textPrimary.withOpacity(0.1)),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: customTheme.primaryBlue),
            const SizedBox(width: 12),
            Text(
              'حالات الاوردر‏',
              style: GoogleFonts.cairo(
                color: customTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: OrderStatus.values.map((status) {
            final color = OrderStatusHelper.getStatusColor(status, customTheme);
            final label = OrderStatusHelper.getStatusLabel(status);
            final description = OrderStatusHelper.getStatusDescription(status);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.cairo(
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.cairo(
                            color: customTheme.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                color: customTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
