import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';
import 'package:moamen_project/features/orders/data/order_impl.dart';
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
          .from(SupabaseTables.ordersWithWorker)
          .select()
          .order(SupabaseOrdersCulomns.createdAt, ascending: false);

      print(response);

      final List<Order> orders = (response as List<dynamic>)
          .map((order) => Order.fromJson(order as Map<String, dynamic>))
          .toList();

      

      state = state.copyWith(
        orders: orders,
        isLoading: false,
        hasFetched: true,
      );
    } catch (e) {
      print(e);
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
      final response = await _supabase
          .from(SupabaseTables.orders)
          .update({
            SupabaseOrdersCulomns.workerId: _supabase.auth.currentUser!.id,
            SupabaseOrdersCulomns.status: OrderStatus.accepted.name,
            SupabaseOrdersCulomns.acceptedAt: DateTime.now(),
          })
          .eq(SupabaseOrdersCulomns.id, orderId);

      print(response);

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

      final jsonPayload = orderData.toJson();
      print('DEBUG: Insert Payload: $jsonPayload');

      final response = await _supabase
          .from(SupabaseTables.orders) // تأكد هنا جدول orders الأصلي
          .insert(jsonPayload)
          .select(); // ترجع الصف الجديد

      print('DEBUG: admin_create_order success, response: $response');

      state = state.copyWith(isLoading: false);
      fetchOrders();

      if (response != null && response.isNotEmpty) {
        final insertedId = response[0]['id'] as String;
        return insertedId;
      }

      return null;
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
      final response = await _supabase
          .from('orders')
          .update(orderData.toJson())
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

  Future<void> pickLocalPhoto() async {
    final picker = ImagePicker();
    final pickedXFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedXFile == null) return;

    final pickedFile = File(pickedXFile.path);
    state = state.copyWith(localPhotos: [...state.localPhotos, pickedFile]);
  }

  void removeLocalPhoto(int index) {
    final newLocalPhotos = List<File>.from(state.localPhotos);
    newLocalPhotos.removeAt(index);
    state = state.copyWith(localPhotos: newLocalPhotos);
  }

  Future<List<String>> uploadAllPhotos() async {
    if (state.localPhotos.isEmpty) return [];

    state = state.copyWith(isLoading: true, isError: false);
    final List<String> uploadedUrls = [];

    try {
      for (var file in state.localPhotos) {
        final compressedFile = await _compressImage(file);
        final url = await OrderRepository(
          _supabase,
        ).uploadPhoto(compressedFile);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }
      state = state.copyWith(isLoading: false);
      return uploadedUrls;
    } catch (e) {
      print('Error uploading photos: $e');
      state = state.copyWith(isLoading: false, isError: true);
      return [];
    }
  }

  // دالة ضغط الصورة
  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;

    // Create a target path in the same directory but with a .webp extension
    final extension = filePath.split('.').last;
    final outPath = filePath.replaceAll('.$extension', '_compressed.webp');

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      outPath,
      quality: 70,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    if (result == null) return file;
    return File(result.path);
  }

  void setPhotoUrls(List<String> urls) {
    state = state.copyWith(photoUrls: urls);
  }

  void removePhoto(int index) {
    final newUrls = List<String>.from(state.photoUrls);
    newUrls.removeAt(index);
    state = state.copyWith(photoUrls: newUrls);
  }

  void resetPhotos() {
    state = state.copyWith(photoUrls: [], localPhotos: []);
  }

  Future<bool> deleteOrder({
    required String orderId,
    required String userId,
  }) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final response = await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId);

      print(response); // "تم حذف الاوردر بنجاح" أو "غير مصرح لك بحذف الاوردر‏"

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
