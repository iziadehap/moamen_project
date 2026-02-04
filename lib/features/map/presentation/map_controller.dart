// import 'package:get/get.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:open_route_service/open_route_service.dart';
// import '../../../core/services/location_service.dart';
// import '../../orders/data/models/order_model.dart';
// import '../../orders/presentation/orders_controller.dart';

// class DeliveryMapController extends GetxController {
//   final LocationService _locationService = Get.find<LocationService>();
//   final String openRouteServiceKey =
//       '5b3ce3597851110001cf624838e0792131234983724831274';
//   late OpenRouteService _openRouteService;

//   final RxList<OrderModel> orders = <OrderModel>[].obs;
//   final RxList<LatLng> routePoints = <LatLng>[].obs;
//   final isLoadingRoute = false.obs;
//   final MapController mapController = MapController();

//   final List<OrderModel> passedOrders;

//   DeliveryMapController({this.passedOrders = const []});

//   @override
//   void onInit() {
//     super.onInit();
//     _openRouteService = OpenRouteService(apiKey: openRouteServiceKey);

//     if (passedOrders.isNotEmpty) {
//       orders.value = passedOrders;
//       calculateOptimizedRoute();
//     } else {
//       try {
//         final ordersCtrl = Get.find<OrdersController>();
//         if (ordersCtrl.orders.isNotEmpty) {
//           orders.value = ordersCtrl.orders;
//         }
//       } catch (e) {
//         print('OrdersController not found');
//       }
//     }
//   }

//   Future<void> calculateOptimizedRoute() async {
//     final currentPos = _locationService.currentPosition.value;
//     if (currentPos == null || orders.isEmpty) return;

//     isLoadingRoute.value = true;
//     routePoints.clear();

//     try {
//       List<ORSCoordinate> waypoints = [
//         ORSCoordinate(
//           latitude: currentPos.latitude,
//           longitude: currentPos.longitude,
//         ),
//         ...orders.map(
//           (o) => ORSCoordinate(
//             latitude: o.location.latitude,
//             longitude: o.location.longitude,
//           ),
//         ),
//       ];

//       // Using start, end coordinates as per lints
//       final directionData = await _openRouteService.directionsRouteCoordsGet(
//         startCoordinate: waypoints.first,
//         endCoordinate: waypoints.last,
//         // intermediateCoordinates removed as it is not supported in this version
//       );

//       if (directionData.isNotEmpty) {
//         routePoints.value = directionData
//             .map((e) => LatLng(e.latitude, e.longitude))
//             .toList();
//       }
//     } catch (e) {
//       print('Routing Error: $e');
//       // Mock route for demo if API fails
//       routePoints.value = [
//         LatLng(currentPos.latitude, currentPos.longitude),
//         ...orders.map((o) => o.location),
//       ];
//     } finally {
//       isLoadingRoute.value = false;
//     }
//   }

//   void markAsDelivered(OrderModel order) {
//     orders.removeWhere((o) => o.id == order.id);
//     if (orders.isNotEmpty) {
//       calculateOptimizedRoute();
//     } else {
//       routePoints.clear();
//       Get.back();
//       Get.snackbar('All Delivered', 'Great job! Return to base.');
//     }
//   }
// }
