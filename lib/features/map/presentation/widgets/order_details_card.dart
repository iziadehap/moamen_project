import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class OrderDetailsCard extends StatelessWidget {
  final Order order;

  const OrderDetailsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status & Priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(order.status),
              _buildPriorityBadge(order.priority),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'التفاصيل:',
            style: GoogleFonts.cairo(
              color: AppColors.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.description,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Info Grid (Order Type, Worker, Location)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.category_rounded,
                  'نوع الطلب:',
                  order.orderType.name,
                  color: AppColors.primaryBlue,
                ),
                // if (order.workerId != null) ...[
                //   const Divider(color: Colors.white10, height: 16),
                //   _buildInfoRow(
                //     Icons.badge_rounded,
                //     'معرف المندوب:',
                //     order.workerId!,
                //     color: Colors.orange,
                //   ),
                // ],
                const Divider(color: Colors.white10, height: 16),
                _buildInfoRow(
                  Icons.location_city_rounded,
                  'المنطقة:',
                  order.publicArea,
                  color: AppColors.statusCyan,
                ),
                if (order.publicLandmark != null &&
                    order.publicLandmark!.isNotEmpty) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _buildInfoRow(
                    Icons.flag_rounded,
                    'علامة مميزة:',
                    order.publicLandmark!,
                    color: AppColors.primaryPurple,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'قيد الانتظار';
        break;
      case OrderStatus.accepted:
        color = AppColors.primaryBlue;
        text = 'تم القبول';
        break;
      case OrderStatus.inProgress:
        color = AppColors.primaryBlue;
        text = 'جاري التنفيذ';
        break;
      case OrderStatus.completed:
        color = AppColors.statusGreen;
        text = 'مكتمل';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'ملغي';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 6,
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(OrderPriority priority) {
    Color color;
    IconData icon;
    String text;

    switch (priority) {
      case OrderPriority.urgent:
        color = Colors.red;
        icon = Icons.campaign_rounded;
        text = 'عاجل جداً';
        break;
      case OrderPriority.high:
        color = Colors.deepOrange;
        icon = Icons.priority_high_rounded;
        text = 'عاجل';
        break;
      case OrderPriority.medium:
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        text = 'متوسط';
        break;
      case OrderPriority.low:
        color = AppColors.statusGreen;
        icon = Icons.low_priority_rounded;
        text = 'عادي';
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.cairo(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 10),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
