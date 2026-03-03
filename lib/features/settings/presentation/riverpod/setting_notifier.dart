import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/services/supabase_service.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/core/utils/images.dart';
import 'package:moamen_project/features/auth/presentation/controller/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'setting_state.dart';

class SettingNotifier extends Notifier<SettingState> {
  late final SupabaseClient _supabase;

  @override
  SettingState build() {
    _supabase = ref.read(supabaseClientProvider);
    return const SettingState();
  }

  Future<void> updateProfile({String? name, File? imageFile}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final user = ref.read(authProvider).user;
      if (user == null) throw Exception('User not logged in');

      String? imageUrl = user.imageUrl;

      // 1. Compress and Upload image if provided
      if (imageFile != null) {
        final compressedFile = await ImageUtils.compressImage(imageFile);
        imageUrl = await ImageUtils.uploadPhoto(
          supabase: _supabase,
          file: compressedFile,
          bucket: SupabaseTables.PhotosBucket,
        );

        if (imageUrl == null) throw Exception('فشل رفع الصورة');
      }

      // 2. Update profile in database
      final updates = {
        if (name != null) SupabaseProfileCulomns.name: name,
        SupabaseProfileCulomns.imageUrl: imageUrl,
        // SupabaseProfileCulomns.updatedAt: DateTime.now().toIso8601String(),
      };

      await _supabase
          .from(SupabaseTables.profiles)
          .update(updates)
          .eq(SupabaseProfileCulomns.id, user.id);

      // 3. Update local auth state
      final updatedUser = user.copyWith(
        name: name ?? user.name,
        imageUrl: imageUrl,
      );
      ref.read(authProvider.notifier).setUser(updatedUser);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      print('error while updating profile $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() {
    state = const SettingState();
  }
}
