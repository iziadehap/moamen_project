import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapDatasources {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Order>> getPandingOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('status', OrderStatus.pending.name)
          .order('created_at', ascending: false);

      final List<Order> orders = (response as List<dynamic>)
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList();
      return orders;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
