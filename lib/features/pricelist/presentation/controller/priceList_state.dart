import 'package:moamen_project/features/pricelist/data/priceList_model.dart';

class PricelistState {
  final List<PriceListModel> pricelist;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  PricelistState({
    required this.pricelist,
    required this.isLoading,
    this.error,
    this.isSuccess = false,
  });

  PricelistState copyWith({
    List<PriceListModel>? pricelist,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return PricelistState(
      pricelist: pricelist ?? this.pricelist,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  PricelistState clearError() {
    return copyWith(error: null);
  }

  PricelistState resetAction() {
    return copyWith(isSuccess: false, error: null, isLoading: false);
  }

  PricelistState clearPricelist() {
    return copyWith(pricelist: []);
  }
}
