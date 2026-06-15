import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/core/widgets/open_phone_number.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/order_detail_screen.dart';

class OrderDetailsCard extends StatelessWidget {
  final Order order;
  final bool isPublicOnly;

  const OrderDetailsCard({
    super.key,
    required this.order,
    this.isPublicOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(order.status),
              if (order.createdAt != null)
                Text(
                  DateFormat('yyyy/MM/dd - hh:mm a').format(order.createdAt!),
                  style: GoogleFonts.cairo(
                    color: AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            order.title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Priority & Info Row
          Row(
            children: [
              _buildPriorityBadge(order.priority),
              if (order.photoUrls.isNotEmpty) ...[
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.image,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${order.photoUrls.length} صور',
                        style: GoogleFonts.cairo(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Divider
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 24),

          // Description Section
          _SectionHeader(
            title: 'التفاصيل:',
            icon: FaIcon(FontAwesomeIcons.fileText),
          ),
          const SizedBox(height: 12),
          Text(
            order.description,
            style: GoogleFonts.cairo(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // Contact Section
          if (!isPublicOnly &&
              (order.contactName != null || order.contactPhone != null)) ...[
            _SectionHeader(
              title: 'معلومات التواصل:',
              icon: FaIcon(FontAwesomeIcons.user),
            ),
            const SizedBox(height: 12),
            OpenPhoneNumber(
              phone: order.contactPhone ?? '',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.phone,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.contactName ?? 'بدون اسم',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            order.contactPhone ?? 'لا يوجد رقم',
                            style: GoogleFonts.cairo(
                              color: AppColors.primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],

          // Location Section
          _SectionHeader(
            title: 'الموقع والعنوان:',
            icon: FaIcon(FontAwesomeIcons.mapPin),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  FaIcon(FontAwesomeIcons.building),
                  'المنطقة:',
                  order.publicArea,
                  color: AppColors.statusCyan,
                ),
                if (!isPublicOnly &&
                    order.fullAddress != null &&
                    order.fullAddress!.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  _buildInfoRow(
                    FaIcon(FontAwesomeIcons.map),
                    'العنوان الكامل:',
                    order.fullAddress!,
                    color: AppColors.primaryPurple,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(order: order),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'عرض التفاصيل كاملة',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white),
                  ],
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(OrderPriority priority) {
    Color color;
    FaIcon icon;
    String text;

    switch (priority) {
      case OrderPriority.urgent:
        color = Colors.red;
        icon = FaIcon(FontAwesomeIcons.exclamationTriangle);
        text = 'عاجل جداً';
        break;
      case OrderPriority.high:
        color = Colors.deepOrange;
        icon = FaIcon(FontAwesomeIcons.exclamationTriangle);
        text = 'عاجل';
        break;
      case OrderPriority.medium:
        color = Colors.orange;
        icon = FaIcon(FontAwesomeIcons.clock);
        text = 'متوسط';
        break;
      case OrderPriority.low:
        color = AppColors.statusGreen;
        icon = FaIcon(FontAwesomeIcons.circleCheck);
        text = 'عادي';
        break;
    }

    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.cairo(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    FaIcon icon,
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: icon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final FaIcon icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            color: AppColors.textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
