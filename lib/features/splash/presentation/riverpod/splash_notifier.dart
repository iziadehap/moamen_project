import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/utils/app_text.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../../auth/presentation/controller/auth_provider.dart';
import '../../domain/repositories/splash_repository.dart';
import '../../data/repositories/splash_repository_impl.dart';
import 'splash_state.dart';

class SplashNotifier extends Notifier<SplashState> {
  late final SplashRepository _repository;

  @override
  SplashState build() {
    _repository = ref.read(splashRepositoryProvider);
    Future.microtask(() => _startSystemCheck());
    return const SplashState();
  }

  Future<void> _startSystemCheck() async {
    state = state.copyWith(progress: 0.1, error: null);
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Internet check
    state = state.copyWith(progress: 0.2);

    // Wait for connectivity check to stabilize if needed
    // In strict clean arch, this waiting logic might belong in a UseCase,
    // but for Splash flow it's often View-related timing.
    // We'll trust the repository's current state but add a small delay if it's checking.
    // However, repository just returns bool. Checks should be fast.
    // The original code waited if checking.
    // Let's check the provider state directly for "isChecking" to replicate the delay logic
    // or just assume we can retry if false.

    // final connectivityState = ref.read(connectivityProvider);
    // if (connectivityState.isChecking) {
    //   await Future.delayed(const Duration(milliseconds: 1000));
    // }

    final isConnected = await _repository.checkConnectivity();
    if (!isConnected) {
      state = state.copyWith(
        error: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.',
      );
      return;
    }
    state = state.copyWith(internetChecked: true, progress: 0.5);
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Location Permission check
    state = state.copyWith(progress: 0.6);
    final hasPermission = await _repository.checkLocationPermission();
    if (!hasPermission) {
      state = state.copyWith(
        error: 'صلاحية الوصول للموقع مطلوبة للمتابعة.',
        solveError: 'permission',
      );
      return;
    }

    // 3. GPS Service check
    state = state.copyWith(progress: 0.8);
    final isGpsEnabled = await _repository.checkLocationService();
    if (!isGpsEnabled) {
      state = state.copyWith(
        error: 'خدمات الموقع (GPS) معطلة. يرجى تفعيلها من الإعدادات.',
        solveError: 'gps',
      );
      return;
    }

    // 4. Login check
    state = state.copyWith(progress: 0.9);
    try {} catch (e) {
      print(e);
      state = state.copyWith(error: 'فشل تسجيل الدخول: ${e.toString()}');
      return;
    }

    state = state.copyWith(gpsChecked: true, progress: 1.0);
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> getUserProfile() async {
    try {
      final SupabaseClient supabase = Supabase.instance.client;
      final response = await supabase
          .from(SupabaseTables.profiles)
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      final user = UserModel.fromMap(response);
      ref.read(authProvider.notifier).setUser(user);
    } catch (e) {
      print(e);
      ref.read(authProvider.notifier).logout();
      state = state.copyWith(error: 'فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  void retry() {
    _startSystemCheck();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);
