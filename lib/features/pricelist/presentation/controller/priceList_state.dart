import 'dart:io';
import 'package:moamen_project/features/pricelist/data/priceList_model.dart';

class PricelistState {
  final List<PriceListModel> pricelist;
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final List<File> localPhotos;
  final List<String> photoUrls;

  PricelistState({
    required this.pricelist,
    required this.isLoading,
    this.error,
    this.isSuccess = false,
    this.localPhotos = const [],
    this.photoUrls = const [],
  });

  PricelistState copyWith({
    List<PriceListModel>? pricelist,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    List<File>? localPhotos,
    List<String>? photoUrls,
  }) {
    return PricelistState(
      pricelist: pricelist ?? this.pricelist,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      localPhotos: localPhotos ?? this.localPhotos,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  PricelistState clearError() {
    return copyWith(error: null);
  }

  PricelistState resetAction() {
    return copyWith(
      isSuccess: false,
      error: null,
      isLoading: false,
      localPhotos: [],
      photoUrls: [],
    );
  }

  PricelistState clearPricelist() {
    return copyWith(pricelist: []);
  }
}
