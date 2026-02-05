import 'package:moamen_project/features/pricelist/data/priceList_model.dart';

class PricelistState {
  final List<PriceListModel> pricelist;
  final bool isLoading;
  final String? error;

  PricelistState({
    required this.pricelist,
    required this.isLoading,
    required this.error,
  });

  PricelistState copyWith({
    List<PriceListModel>? pricelist,
    bool? isLoading,
    String? error,
  }) {
    return PricelistState(
      pricelist: pricelist ?? this.pricelist,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  PricelistState clearError() {
    return copyWith(error: null);
  }

  PricelistState clearPricelist() {
    return copyWith(pricelist: []);
  }
}
