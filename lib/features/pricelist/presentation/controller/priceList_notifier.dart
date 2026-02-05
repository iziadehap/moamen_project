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

  void getPricelist() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _supabase.from(SupabaseTables.pricelist).select();
      final pricelist = response
          .map((e) => PriceListModel.fromJson(e))
          .toList();
      print(pricelist);
      print(pricelist.length);

      state = state.copyWith(pricelist: pricelist, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
