import 'package:moamen_project/features/orders/data/models/order_model.dart';

abstract class MapRebo {
  Future<List<Order>> getOrders();
}