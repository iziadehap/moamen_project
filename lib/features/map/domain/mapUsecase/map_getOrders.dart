import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:moamen_project/core/error/failure.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:moamen_project/features/map/data/map_model.dart';
import 'package:moamen_project/features/map/domain/map_rebo.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class GetOrders {
  final MapRebo mapRebo;
  GetOrders({required this.mapRebo});

  Future<Either<Failure, MapModel>> call(UserModel user) async {
    try {
      final orders = await mapRebo.getOrders();
      MapModel mapModel = MapModel(userPoints: [], publicPoints: []);

      // Clustering list
      List<CircleOrder> circles = [];

      for (var order in orders) {
        // 1. User's own orders -> Add directly to userPoints
        // 2. order is panding
        if (order.workerId == user.id && order.status == OrderStatus.pending) {
          mapModel.userPoints.add(order);
          continue;
        }

        // 2. Public orders -> Clustering logic
        // Skip if location is missing
        if (order.latitude == null || order.longitude == null) continue;

        bool addedToCircle = false;

        for (var circle in circles) {
          // Use the first point in the cluster as the center reference
          // (Or could calculate centroid, but simple greedy is fine for now)
          if (circle.orders.isNotEmpty) {
            final center = circle.orders.first;
            double distance = Geolocator.distanceBetween(
              order.latitude!,
              order.longitude!,
              center.latitude!,
              center.longitude!,
            );

            // If within 1km (1000 meters), add to this cluster
            if (distance <= 1000) {
              circle.orders.add(order);
              addedToCircle = true;
              break;
            }
          }
        }

        // If not added to any existing cluster, create a new one
        if (!addedToCircle) {
          circles.add(
            CircleOrder(
              points: LatLng(order.latitude!, order.longitude!),
              orders: [order], // Representative order
            ),
          );
        }
      }

      mapModel.publicPoints = circles;
      return right(mapModel);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
