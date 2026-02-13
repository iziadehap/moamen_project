import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/map/data/map_model.dart';
import 'package:moamen_project/features/map/presentation/controller/map_provider.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/map/presentation/widgets/draggable_orders_sheet.dart';
import 'package:moamen_project/features/map/presentation/widgets/glass_bottom_sheet.dart';
import 'package:moamen_project/features/map/presentation/widgets/map_header.dart';
import 'package:moamen_project/features/map/presentation/widgets/order_details_card.dart';
import 'package:moamen_project/features/map/presentation/widgets/toggle_public_circles_button.dart';
import 'package:moamen_project/features/map/presentation/widgets/user_location_button.dart';
import 'package:moamen_project/features/orders/presentation/orders_screen.dart';

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
    Future.microtask(() {
      ref.read(mapProvider.notifier).getOrders();
      ref.read(mapProvider.notifier).initLocationService();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.midnightNavy,
        body: Stack(
          children: [
            _buildMap(
              mapState.mapModel,
              mapState.userLocation,
              mapState.showPublicCircles,
            ),
            const MapHeader(),
            Align(
              alignment: AlignmentGeometry.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserLocationButton(
                      onTap: () => _goToUserLocation(mapState.userLocation),
                    ),
                    const SizedBox(height: 12),
                    TogglePublicCirclesButton(
                      showPublicCircles: mapState.showPublicCircles,
                      onToggle: () {
                        ref.read(mapProvider.notifier).togglePublicCircles();
                      },
                    ),

                    DraggableOrdersSheet(
                      userOrdersCount: mapState.mapModel.userPoints.length,
                      onTap: () => _navigateToOrdersScreen(),
                    ),
                  ],
                ),
              ),
            ),
            // Buttons (User Location & Toggle Public Circles)
            if (mapState.isLoding)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
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
      ),
    );
  }

  void _goToUserLocation(LatLng? userLocation) {
    if (userLocation != null) {
      if (!_mapController.mapEventStream.isBroadcast) {
        // This is a proxy check, but flutter_map controller doesn't have "isReady".
        // However, since this is triggered by UI tap, the map should be built.
        // A safer way is to wrap in try-catch just in case.
        try {
          final currentZoom = _mapController.camera.zoom;
          _mapController.move(userLocation, currentZoom);
        } catch (e) {
          debugPrint("Map move error: $e");
        }
      } else {
        try {
          final currentZoom = _mapController.camera.zoom;
          _mapController.move(userLocation, currentZoom);
        } catch (e) {
          debugPrint("Map move error: $e");
        }
      }
    }
  }

  Widget _buildMap(
    MapModel mapModel,
    LatLng? userLocation,
    bool showPublicCircles,
  ) {
    // Determine center
    LatLng center = const LatLng(30.0444, 31.2357); // Cairo default

    if (userLocation != null) {
      center = userLocation;
    } else if (mapModel.userPoints.isNotEmpty &&
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
        if (showPublicCircles)
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
            // User Location Marker
            if (userLocation != null)
              Marker(
                point: userLocation,
                width: 50,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.statusGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.statusGreen.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.my_location_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            // Public Cluster Counts
            if (showPublicCircles)
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
                      // Rotate -45 degrees (in radians)
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
      builder: (context) => GlassBottomSheet(
        title: 'تفاصيل الطلب',
        content: Column(children: [OrderDetailsCard(order: order)]),
      ),
    );
  }

  void _showPublicOrdersSheet(CircleOrder circleOrder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassBottomSheet(
        title: 'الطلبات المتاحة (${circleOrder.orders.length})',
        content: Column(
          children: circleOrder.orders
              .map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderDetailsCard(order: order),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _navigateToOrdersScreen() async {
    final selectedOrder = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrdersScreen(isSelectionMode: true),
      ),
    );

    if (selectedOrder is Order &&
        selectedOrder.latitude != null &&
        selectedOrder.longitude != null) {
      // Delay slightly to allow the map to render if needed
      await Future.delayed(const Duration(milliseconds: 300));

      final location = LatLng(
        selectedOrder.latitude!,
        selectedOrder.longitude!,
      );

      try {
        _mapController.move(location, 16.0);
        _showOrderDetailsSheet(selectedOrder);
      } catch (e) {
        debugPrint("Navigation map move error: $e");
      }
    }
  }
}
