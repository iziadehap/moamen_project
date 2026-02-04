// import 'package:get/get.dart';
// import 'package:latlong2/latlong.dart';
// import '../../../core/services/location_service.dart';
// import '../../auth/presentation/login_controller.dart';
// import '../data/models/order_model.dart';

// class OrdersController extends GetxController {
//   final LocationService _locationService = Get.find<LocationService>();
//   final LoginController _loginController = Get.find<LoginController>();

//   final RxList<OrderModel> orders = <OrderModel>[].obs;
//   final RxList<String> selectedOrderIds = <String>[].obs; // Multi-selection
//   final isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchOrders(); // Initial fetch
//   }

//   void fetchOrders() async {
//     isLoading.value = true;

//     // Simulate network delay
//     await Future.delayed(const Duration(seconds: 1));

//     // Mock Data
//     final mockOrders = [
//       OrderModel(
//         id: '1',
//         address: '123 Main St, Cairo',
//         location: const LatLng(30.0444, 31.2357),
//         status: 'pending',
//         createdAt: DateTime.now(),
//       ),
//       OrderModel(
//         id: '2',
//         address: '456 Nile Corniche, Maadi',
//         location: const LatLng(29.9602, 31.2569),
//         status: 'pending',
//         createdAt: DateTime.now(),
//       ),
//       OrderModel(
//         id: '3',
//         address: '789 Pyramids Rd, Giza',
//         location: const LatLng(29.9792, 31.1342),
//         status: 'pending',
//         createdAt: DateTime.now(),
//       ),
//       OrderModel(
//         id: '4',
//         address: 'Delivered Order Test',
//         location: const LatLng(30.0131, 31.2089),
//         status: 'delivered',
//         createdAt: DateTime.now(),
//       ),
//     ];

//     // Filter pending only (usually done on backend query)
//     var pendingOrders = mockOrders.where((o) => o.status == 'pending').toList();

//     // Calculate distances
//     final currentPos = _locationService.currentPosition.value;
//     if (currentPos != null) {
//       for (var order in pendingOrders) {
//         order.distanceInMeters = _locationService.calculateDistance(
//           currentPos.latitude,
//           currentPos.longitude,
//           order.location.latitude,
//           order.location.longitude,
//         );
//       }

//       // Sort by distance
//       pendingOrders.sort(
//         (a, b) => (a.distanceInMeters ?? 0).compareTo(b.distanceInMeters ?? 0),
//       );
//     }

//     orders.value = pendingOrders;
//     isLoading.value = false;
//   }

//   void toggleSelection(OrderModel order) {
//     if (selectedOrderIds.contains(order.id)) {
//       selectedOrderIds.remove(order.id);
//     } else {
//       // Check max orders limit from user profile
//       final user = _loginController.currentUser.value;
//       final maxOrders = user?.maxOrders ?? 5;

//       if (selectedOrderIds.length < maxOrders) {
//         selectedOrderIds.add(order.id);
//       } else {
//         Get.snackbar(
//           'Limit Reached',
//           'You can only select up to $maxOrders orders.',
//         );
//       }
//     }
//   }

//   bool isSelected(String orderId) => selectedOrderIds.contains(orderId);

//   List<OrderModel> get selectedOrders =>
//       orders.where((o) => selectedOrderIds.contains(o.id)).toList();
// }
