import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/map/data/map_model.dart';
import 'package:moamen_project/features/map/presentation/controller/map_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:intl/intl.dart' as intl;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(mapProvider.notifier).getOrders());
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);

    return Scaffold(
      backgroundColor: AppColors.midnightNavy,
      body: Stack(
        children: [
          _buildMap(mapState.mapModel),
          _buildHeader(),
          if (mapState.isLoding)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
          if (mapState.errorMassage.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mapState.errorMassage,
                  style: GoogleFonts.cairo(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkCard.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                'خريطة التوصيل',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(MapModel mapModel) {
    // Determine center
    // Determine center
    LatLng center = const LatLng(30.0444, 31.2357); // Cairo default

    if (mapModel.userPoints.isNotEmpty &&
        mapModel.userPoints.first.latitude != null) {
      center = LatLng(
        mapModel.userPoints.first.latitude!,
        mapModel.userPoints.first.longitude!,
      );
    } else if (mapModel.publicPoints.isNotEmpty) {
      center = mapModel.publicPoints.first.points;
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.moamen.project',
        ),
        // Public Points Circles (1km Radius)
        CircleLayer(
          circles: mapModel.publicPoints.map((circleOrder) {
            return CircleMarker(
              point: circleOrder.points,
              color: AppColors.primaryPurple.withOpacity(0.2),
              borderColor: AppColors.primaryPurple,
              borderStrokeWidth: 2,
              useRadiusInMeter: true,
              radius: 1000, // 1km
            );
          }).toList(),
        ),
        // Markers for User Points & Public Counts
        MarkerLayer(
          markers: [
            // Public Cluster Counts
            ...mapModel.publicPoints.map((circleOrder) {
              return Marker(
                point: circleOrder.points,
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => _showPublicOrdersSheet(circleOrder),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${circleOrder.orders.length}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            // User Points (Numbered)
            ...mapModel.userPoints.asMap().entries.map((entry) {
              final index = entry.key;
              final order = entry.value;
              if (order.latitude == null || order.longitude == null) {
                return const Marker(
                  point: LatLng(0, 0),
                  child: SizedBox.shrink(),
                );
              }
              return Marker(
                point: LatLng(order.latitude!, order.longitude!),
                width: 60,
                height: 60,
                // Alignment.topCenter means the top center of the widget is placed at the point.
                // We want the BOTTOM of our graphical pin to be at the point.
                // However, without being sure of standard Marker alignment behavior compatibility,
                // we'll center it for now and it will look like a pin over the area.
                child: GestureDetector(
                  onTap: () => _showOrderDetailsSheet(order),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(0), // Sharp corner
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      // Rotate -45 degrees (in radians) to make the sharp corner point down
                      transform: Matrix4.rotationZ(-0.785398163),
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        // Rotate text back +45 degrees
                        angle: 0.785398163,
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  void _showOrderDetailsSheet(Order order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGlassBottomSheet(
        title: 'تفاصيل الطلب',
        content: Column(children: [_buildOrderDetailsCard(order)]),
      ),
    );
  }

  void _showPublicOrdersSheet(CircleOrder circleOrder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGlassBottomSheet(
        title: 'الطلبات المتاحة (${circleOrder.orders.length})',
        content: Column(
          children: circleOrder.orders
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOrderDetailsCard(order),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildGlassBottomSheet({
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.midnightNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(child: SingleChildScrollView(child: content)),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(Order order) {
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
                if (order.workerId != null) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _buildInfoRow(
                    Icons.badge_rounded,
                    'معرف المندوب:',
                    order.workerId!,
                    color: Colors.orange,
                  ),
                ],
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
                    color: AppColors.statusGreen,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textGrey),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(color: AppColors.textGrey, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
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
        color = AppColors.statusCyan;
        text = 'مقبول';
        break;
      case OrderStatus.inProgress: // Assuming inProgress exists
        color = AppColors.primaryBlue;
        text = 'جاري التنفيذ';
        break;
      case OrderStatus.completed:
        color = AppColors.statusGreen;
        text = 'مكتمل';
        break;
      case OrderStatus.cancelled:
        color = Colors.redAccent;
        text = 'ملغي';
        break;
      default:
        color = AppColors.textGrey;
        text = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildPriorityBadge(OrderPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case OrderPriority.urgent:
        color = Colors.redAccent;
        text = 'عاجل جداً';
        break;
      case OrderPriority.high:
        color = Colors.orange;
        text = 'مرتفع';
        break;
      case OrderPriority.medium:
        color = AppColors.statusCyan;
        text = 'متوسط';
        break;
      case OrderPriority.low:
        color = AppColors.statusGreen;
        text = 'منخفض';
        break;
      default:
        color = AppColors.textGrey;
        text = 'عادي';
    }

    return Row(
      children: [
        Icon(Icons.flag_rounded, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.cairo(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
