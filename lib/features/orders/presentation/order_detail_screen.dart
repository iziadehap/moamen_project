import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/add_order_screen.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_provider.dart';
import 'location_picker_screen.dart';

class OrderDetailScreen extends ConsumerWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.user?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isAdmin, ref),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBatch(order.status),
                        const SizedBox(height: 16),
                        Text(
                          order.title,
                          style: GoogleFonts.cairo(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.description,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppColors.textGrey,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildSectionTitle('المعلومات العامة'),
                        const SizedBox(height: 16),
                        _buildInfoCard([
                          _buildInfoRow(
                            Icons.category_rounded,
                            'نوع الطلب',
                            _orderTypeArabic(order.orderType),
                          ),
                          _buildInfoRow(
                            Icons.priority_high_rounded,
                            'الأولوية',
                            _priorityArabic(order.priority),
                          ),
                          _buildInfoRow(
                            Icons.location_city_rounded,
                            'المنطقة',
                            order.publicArea,
                          ),
                          if (order.publicLandmark != null)
                            _buildInfoRow(
                              Icons.assistant_navigation,
                              'معلم شهير',
                              order.publicLandmark!,
                            ),
                        ]),

                        const SizedBox(height: 32),
                        _buildSectionTitle('التوافر والوقت'),
                        const SizedBox(height: 16),
                        _buildAvailabilityCard(order.availability),

                        if (isAdmin) ...[
                          const SizedBox(height: 32),
                          _buildSectionTitle(
                            'بيانات التواصل والتوصيل (خاصة بالمسؤول)',
                          ),
                          const SizedBox(height: 16),
                          if (order.latitude != null && order.longitude != null)
                            _buildMapPreview(context),
                          const SizedBox(height: 16),
                          _buildInfoCard([
                            if (order.fullAddress != null)
                              _buildInfoRow(
                                Icons.home_work_rounded,
                                'العنوان الكامل',
                                order.fullAddress!,
                              ),
                            if (order.latitude != null &&
                                order.longitude != null)
                              _buildInfoRow(
                                Icons.location_on_rounded,
                                'الإحداثيات',
                                '${order.latitude}, ${order.longitude}',
                              ),
                            if (order.contactName != null)
                              _buildInfoRow(
                                Icons.person_rounded,
                                'اسم المستلم',
                                order.contactName!,
                              ),
                            if (order.contactPhone != null)
                              _buildInfoRow(
                                Icons.phone_android_rounded,
                                'رقم التواصل',
                                order.contactPhone!,
                              ),
                          ]),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isAdmin ? _buildEditButton(context) : null,
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    if (order.latitude == null || order.longitude == null) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Center(
          child: Text(
            'الموقع غير متوفر',
            style: GoogleFonts.cairo(color: AppColors.textGrey),
          ),
        ),
      );
    }
    final location = LatLng(order.latitude!, order.longitude!);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationPickerScreen(
              initialLocation: location,
              isReadOnly: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.moamen_project',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.redAccent,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Overlay gradient for a more 'interactable' look
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),
            // Tapping hint
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.midnightNavy.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'عرض الخريطة بالكامل',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.midnightNavy.withOpacity(0.8),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.glowShadow,
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOrderScreen(order: order),
                ),
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
                const Icon(Icons.edit_note_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'تعديل تفاصيل الطلب',
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

  Widget _buildHeader(BuildContext context, bool isAdmin, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'تفاصيل الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (isAdmin)
            IconButton(
              onPressed: () => _showDeleteConfirmation(context, ref),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
                size: 22,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10),
          ),
          title: Text(
            'حذف الطلب',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف هذا الطلب؟ لا يمكن التراجع عن هذا الإجراء.',
            style: GoogleFonts.cairo(color: AppColors.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final userId = ref.read(authProvider).user?.id ?? '';
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                // Close dialog
                navigator.pop();

                final success = await ref
                    .read(orderProvider.notifier)
                    .deleteOrder(orderId: order.id, userId: userId);

                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم حذف الطلب بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Return to orders screen
                  navigator.pop();
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'فشل حذف الطلب',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'حذف',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBatch(OrderStatus status) {
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
        color = Colors.purple;
        text = 'قيد التنفيذ';
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: children
            .expand(
              (w) => [w, if (children.last != w) const SizedBox(height: 16)],
            )
            .toList(),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBlue.withOpacity(0.5), size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityCard(List<Map<String, dynamic>> availability) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: availability.map((avail) {
          final range = avail['timeRange'] as Map<String, dynamic>;
          final fromHour = range['fromHour'].toString().padLeft(2, '0');
          final fromMin = range['fromMinute'].toString().padLeft(2, '0');
          final toHour = range['toHour'].toString().padLeft(2, '0');
          final toMin = range['toMinute'].toString().padLeft(2, '0');

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  _dayArabic(avail['day']),
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  '$fromHour:$fromMin - $toHour:$toMin',
                  style: GoogleFonts.cairo(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _dayArabic(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday':
        return 'الاثنين';
      case 'tuesday':
        return 'الثلاثاء';
      case 'wednesday':
        return 'الأربعاء';
      case 'thursday':
        return 'الخميس';
      case 'friday':
        return 'الجمعة';
      case 'saturday':
        return 'السبت';
      case 'sunday':
        return 'الأحد';
      default:
        return dayName;
    }
  }

  String _orderTypeArabic(OrderType type) {
    switch (type) {
      case OrderType.pickup:
        return 'استلام';
      case OrderType.delivery:
        return 'توصيل';
      case OrderType.pickupAndReturn:
        return 'استلام وعودة';
    }
  }

  String _priorityArabic(OrderPriority priority) {
    switch (priority) {
      case OrderPriority.low:
        return 'منخفضة';
      case OrderPriority.medium:
        return 'متوسطة';
      case OrderPriority.high:
        return 'عالية';
      case OrderPriority.urgent:
        return 'عاجل جداً';
    }
  }
}
