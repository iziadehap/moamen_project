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
          .eq(SupabaseCulomns.phone, phone)
          .maybeSingle();

      if (response == null) {
        state = AppAuthState(error: 'رقم الهاتف غير موجود');
        return;
      }

      // Verify password
      final passwordHash = response[SupabaseCulomns.password] as String;
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
      // Check if phone already exists
      final existing = await _supabase
          .from(SupabaseTables.accounts)
          .select()
          .eq(SupabaseCulomns.phone, phone)
          .maybeSingle();

      if (existing != null) {
        state = AppAuthState(error: 'رقم الهاتف مسجل بالفعل');
        return;
      }

      // Hash password
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      // Insert new user
      final response = await _supabase
          .from(SupabaseTables.accounts)
          .insert({
            SupabaseCulomns.phone: phone,
            SupabaseCulomns.password: passwordHash,
            SupabaseCulomns.name: name,
            SupabaseCulomns.role: SupabaseAccountTyps.user,
            SupabaseCulomns.maxOrders: 5,
            SupabaseCulomns.createdAt: DateTime.now(),
            SupabaseCulomns.isActive: true,
          })
          .select()
          .single();

      // Create user model
      final user = UserModel.fromMap(response);
      state = AppAuthState(user: user);
    } catch (e) {
      state = AppAuthState(error: 'فشل إنشاء الحساب: ${e.toString()}');
    }
  }

  void logout() {
    state = state.clearUser();
  }

  void clearError() {
    state = state.clearError();
  }
}
