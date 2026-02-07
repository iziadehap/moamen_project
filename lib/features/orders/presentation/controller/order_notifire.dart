import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/presentation/controller/order_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() {
    return OrderState();
  }

  final _supabase = Supabase.instance.client;

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final response = await _supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      final List<Order> orders = (response as List<dynamic>)
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        orders: orders,
        isLoading: false,
        hasFetched: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
        hasFetched: true,
      );
    }
  }

  Future<void> acceptOrder(String orderId) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      // TODO: Replace with your actual API call (e.g., updating order status)
      // await _supabase.from('orders').update({'status': 'accepted'}).eq('id', orderId);

      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<String?> createOrderByAdmin({
    required String adminId,
    required Order orderData,
  }) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      print('DEBUG: createOrderByAdmin starting');
      print('DEBUG: Order Type: ${orderData.orderType.name}');

      final result = await _supabase.rpc(
        'admin_create_order',
        params: {
          'p_admin_id': adminId,
          'p_title': orderData.title,
          'p_description': orderData.description,
          'p_order_type': orderData.orderType.name,
          'p_public_area': orderData.publicArea,
          'p_public_landmark': orderData.publicLandmark,
          'p_availability': orderData.availability,
          'p_full_address': orderData.fullAddress,
          'p_latitude': orderData.latitude,
          'p_longitude': orderData.longitude,
          'p_contact_name': orderData.contactName,
          'p_contact_phone': orderData.contactPhone,
        },
      );

      print('DEBUG: admin_create_order success, ID: $result');

      state = state.copyWith(isLoading: false);
      fetchOrders();
      return result as String;
    } catch (e) {
      print('DEBUG: createOrderByAdmin ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<bool> updateOrder({
    required String orderId,
    required Order orderData,
  }) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      print('DEBUG: updateOrder starting for $orderId');

      await _supabase
          .from('orders')
          .update({
            'title': orderData.title,
            'description': orderData.description,
            'order_type': orderData.orderType.name,
            'public_area': orderData.publicArea,
            'public_landmark': orderData.publicLandmark,
            'availability': orderData.availability,
            'full_address': orderData.fullAddress,
            'latitude': orderData.latitude,
            'longitude': orderData.longitude,
            'contact_name': orderData.contactName,
            'contact_phone': orderData.contactPhone,
            'priority': orderData.priority.name,
          })
          .eq('id', orderId);

      print('DEBUG: updateOrder success');

      state = state.copyWith(isLoading: false);
      fetchOrders(); // Refresh the list
      return true;
    } catch (e) {
      print('DEBUG: updateOrder ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteOrder({
    required String orderId,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final result = await _supabase.rpc(
        'admin_delete_order',
        params: {'p_admin_id': userId, 'p_order_id': orderId},
      );

      print(result); // "تم حذف الطلب بنجاح" أو "غير مصرح لك بحذف الطلب"

      state = state.copyWith(isLoading: false);
      fetchOrders(); // Refresh the list
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}
