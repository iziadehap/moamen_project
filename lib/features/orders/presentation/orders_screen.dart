// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../map/presentation/map_screen.dart';
// import 'orders_controller.dart';
// import 'widgets/order_card.dart';

// class OrdersScreen extends GetView<OrdersController> {
//   const OrdersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Get.put(OrdersController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Available Orders'),
//         actions: [
//           Obx(() {
//             final count = controller.selectedOrderIds.length;
//             return Padding(
//               padding: const EdgeInsets.only(right: 16.0),
//               child: Center(
//                 child: Text(
//                   '$count Selected',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.orders.isEmpty) {
//           return const Center(child: Text('No orders found nearby.'));
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: controller.orders.length,
//           itemBuilder: (context, index) {
//             final order = controller.orders[index];
//             return Obx(
//               () => OrderCard(
//                 order: order,
//                 isSelected: controller.isSelected(order.id),
//                 onToggle: () => controller.toggleSelection(order),
//               ),
//             );
//           },
//         );
//       }),
//       floatingActionButton: Obx(
//         () => controller.selectedOrders.isNotEmpty
//             ? FloatingActionButton.extended(
//                 onPressed: () {
//                   // Navigate to Map with selected orders
//                   Get.to(() => MapScreen(orders: controller.selectedOrders));
//                 },
//                 label: const Text('View on Map'),
//                 icon: const Icon(Icons.map),
//               )
//             : const SizedBox.shrink(),
//       ),
//     );
//   }
// }
