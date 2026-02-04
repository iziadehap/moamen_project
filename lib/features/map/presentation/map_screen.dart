// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
// import 'package:get/get.dart';
// import 'package:latlong2/latlong.dart';
// import '../../orders/data/models/order_model.dart';
// import 'map_controller.dart';

// class MapScreen extends StatelessWidget {
//   final List<OrderModel> orders;

//   const MapScreen({super.key, this.orders = const []});

//   @override
//   Widget build(BuildContext context) {
//     // Pass orders to controller
//     final controller = Get.put(DeliveryMapController(passedOrders: orders));

//     return Scaffold(
//       appBar: AppBar(title: const Text('Delivery Route')),
//       body: Stack(
//         children: [
//           Obx(
//             () => FlutterMap(
//               options: MapOptions(
//                 initialCenter: controller.orders.isNotEmpty
//                     ? controller.orders.first.location
//                     : const LatLng(30.0444, 31.2357), // Cairo Default
//                 initialZoom: 13.0,
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                   userAgentPackageName: 'com.example.app',
//                   // Dark mode tiles filter could be applied via ColorFiltered if desired
//                 ),

//                 // Route Polyline
//                 if (controller.routePoints.isNotEmpty)
//                   PolylineLayer(
//                     polylines: [
//                       Polyline(
//                         points: controller.routePoints.toList(),
//                         strokeWidth: 5.0,
//                         color: Colors.blueAccent,
//                         borderColor: Colors.blue[900]!,
//                         borderStrokeWidth: 2.0,
//                       ),
//                     ],
//                   ),

//                 // Marker Cluster
//                 MarkerClusterLayerWidget(
//                   options: MarkerClusterLayerOptions(
//                     maxClusterRadius: 120,
//                     size: const Size(40, 40),
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.all(50),
//                     maxZoom: 15,
//                     markers: controller.orders.map((order) {
//                       return Marker(
//                         point: order.location,
//                         width: 80,
//                         height: 80,
//                         child: GestureDetector(
//                           onTap: () =>
//                               _showOrderDetails(context, controller, order),
//                           child: Icon(
//                             Icons.location_on,
//                             color: order.status == 'delivered'
//                                 ? Colors.green
//                                 : Colors.red,
//                             size: 40,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                     builder: (context, markers) {
//                       return Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.blue,
//                         ),
//                         child: Center(
//                           child: Text(
//                             markers.length.toString(),
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Loading Indicator
//           Obx(
//             () => controller.isLoadingRoute.value
//                 ? Positioned(
//                     top: 20,
//                     left: 20,
//                     right: 20,
//                     child: Center(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black54,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               'Calculating optimal route...',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showOrderDetails(
//     BuildContext context,
//     DeliveryMapController controller,
//     OrderModel order,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Order Details',
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const SizedBox(height: 10),
//               Text('Address: ${order.address}'),
//               const SizedBox(height: 10),
//               Text('Status: ${order.status}'),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Get.back(); // Close modal
//                     controller.markAsDelivered(order);
//                   },
//                   icon: const Icon(Icons.check_circle),
//                   label: const Text('Mark as Delivered'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
