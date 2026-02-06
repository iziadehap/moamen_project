import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AppAuthState> {
  late final SupabaseClient _supabase;

  @override
  AppAuthState build() {
    _supabase = ref.read(supabaseClientProvider);
    return const AppAuthState();
  }

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Query user by phone
      final response = await _supabase
          .from(SupabaseTables.accounts)
          .select()
          .eq(SupabaseAccountsCulomns.phone, phone)
          .maybeSingle();

      if (response == null) {
        state = AppAuthState(error: 'رقم الهاتف غير موجود');
        return;
      }

      // Verify password
      final passwordHash = response[SupabaseAccountsCulomns.password] as String;
      final isValid = BCrypt.checkpw(password, passwordHash);

      if (!isValid) {
        state = AppAuthState(error: 'كلمة المرور غير صحيحة');
        return;
      }

      // Create user model
      final user = UserModel.fromMap(response);
      state = AppAuthState(user: user);
    } catch (e) {
      state = AppAuthState(error: 'حدث خطأ: ${e.toString()}');
    }
  }

  Future<void> register(String phone, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Hash password
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      // Insert + return the new row (now safe because of the SELECT policy above)
      final inserted = await _supabase
          .from(SupabaseTables.accounts)
          .insert({
            SupabaseAccountsCulomns.phone: phone,
            SupabaseAccountsCulomns.password: passwordHash,
            SupabaseAccountsCulomns.name: name,
            SupabaseAccountsCulomns.role: 'user',
            SupabaseAccountsCulomns.isActive: false,
          })
          .select()
          .single();

      print('✅ Account created: $inserted');

      // Create user model
      final user = UserModel.fromMap(inserted);
      print('✅ User created: $user');
      print('user id = ${user.id}');
      print('user name = ${user.name}');
      print('user phone = ${user.phone}');
      print('user role = ${user.role}');
      print('user is active = ${user.isActive}');

      // Success → put the user in state
      state = state.copyWith(user: user, error: null);
    } on PostgrestException catch (error) {
      print('❌ Postgrest error: ${error.message} (code: ${error.code})');

      if (error.code == '23505') {
        state = state.copyWith(error: 'رقم الهاتف مسجل بالفعل');
      } else if (error.code == '42501') {
        state = state.copyWith(error: 'خطأ في الصلاحيات، حاول مرة أخرى');
      } else {
        state = state.copyWith(error: 'فشل إنشاء الحساب: ${error.message}');
      }
    } catch (e) {
      print('Unexpected error: $e');
      state = state.copyWith(error: 'فشل إنشاء الحساب: ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void logout() {
    state = state.clearUser();
  }

  void clearError() {
    state = state.clearError();
  }
}
