import 'package:moamen_project/features/map/data/datasources/map_datasources.dart';
import 'package:moamen_project/features/map/domain/map_rebo.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class MapReboImp implements MapRebo {
  final MapDatasources mapDatasources;
  MapReboImp({required this.mapDatasources});
  @override
  Future<List<Order>> getOrders() async {
    return await mapDatasources.getPandingOrders();
  }
}
