// data/repositories/order_repository_impl.dart
import 'dart:io';

import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final SupabaseClient supabase;
  OrderRepository(this.supabase);

  Future<String?> uploadPhoto(File file) async {
    print('Uploading photo: ${file.path}');
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      // Upload returns the path if successful
      await supabase.storage
          .from(SupabaseTables.ordersPhotosBucket)
          .upload(fileName, file);

      final url = supabase.storage
          .from(SupabaseTables.ordersPhotosBucket)
          .getPublicUrl(fileName);
      return url;
    } catch (e) {
      print('❌ Error uploading photo: $e');
      return null;
    }
  }
}
