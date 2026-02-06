import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:moamen_project/features/pricelist/data/priceList_model.dart';
import 'package:moamen_project/features/pricelist/presentation/controller/priceList_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PricelistNotifier extends Notifier<PricelistState> {
  late final SupabaseClient _supabase;

  @override
  PricelistState build() {
    _supabase = Supabase.instance.client;
    return PricelistState(pricelist: [], isLoading: false, error: null);
  }

  Future<void> getPricelist() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _supabase
          .from(SupabaseTables.pricelist)
          .select()
          .order(SupabasePricelistCulomns.createdAt, ascending: false);

      final pricelist = List<PriceListModel>.from(
        data.map((e) => PriceListModel.fromJson(e)),
      );

      state = state.copyWith(pricelist: pricelist, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Administrative Operations (Add, Update, Delete)

  Future<void> addPriceItem({
    required String adminId,
    required String title,
    required double price,
    String? description,
    bool isActive = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final res = await _supabase.rpc(
        'admin_manage_price_list',
        params: {
          'p_admin_id': adminId,
          'p_operation': 'insert',
          'p_title': title,
          'p_price': price,
          'p_description': description,
          'p_is_active': isActive,
        },
      );

      final result = res as Map<String, dynamic>;
      if (result['success'] == true) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        await getPricelist(); // Refresh list on success
      } else {
        state = state.copyWith(isLoading: false, error: result['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePriceItem({
    required String adminId,
    required String priceId,
    String? title,
    double? price,
    String? description,
    bool? isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final res = await _supabase.rpc(
        'admin_manage_price_list',
        params: {
          'p_admin_id': adminId,
          'p_operation': 'update',
          'p_id': priceId,
          'p_title': title,
          'p_price': price,
          'p_description': description,
          'p_is_active': isActive,
        },
      );

      final result = res as Map<String, dynamic>;
      if (result['success'] == true) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        await getPricelist();
      } else {
        state = state.copyWith(isLoading: false, error: result['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deletePriceItem({
    required String adminId,
    required String priceId,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final res = await _supabase.rpc(
        'admin_manage_price_list',
        params: {
          'p_admin_id': adminId,
          'p_operation': 'delete',
          'p_id': priceId,
        },
      );

      final result = res as Map<String, dynamic>;
      if (result['success'] == true) {
        state = state.copyWith(isLoading: false, isSuccess: true);
        await getPricelist();
      } else {
        state = state.copyWith(isLoading: false, error: result['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetActionState() {
    state = state.resetAction();
  }
}
