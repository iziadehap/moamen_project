import 'package:latlong2/latlong.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class MapModel {
  List<Order> userPoints;
  List<CircleOrder> publicPoints;

  MapModel({required this.userPoints, required this.publicPoints});
}

class CircleOrder {
  LatLng points; //center circle
  List<Order> orders; // the orders in circle

  CircleOrder({
    required this.points,
    required this.orders,
  });
}
