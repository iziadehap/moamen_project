import 'dart:io';

import 'package:moamen_project/features/orders/data/models/order_model.dart';

class OrderState {
  final List<Order> orders;
  final HintError? hintError;
  final bool isLoading;
  final bool isError;
  final String errorMessage;
  final bool hasFetched;
  final List<String> photoUrls;
  final List<File> localPhotos;

  OrderState({
    this.orders = const [],
    this.hintError,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage = '',
    this.hasFetched = false,
    this.photoUrls = const [],
    this.localPhotos = const [],
  });

  OrderState copyWith({
    List<Order>? orders,
    HintError? hintError,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    bool? hasFetched,
    List<String>? photoUrls,
    List<File>? localPhotos,
    bool clearHintError = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      hintError: clearHintError ? null : (hintError ?? this.hintError),
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasFetched: hasFetched ?? this.hasFetched,
      photoUrls: photoUrls ?? this.photoUrls,
      localPhotos: localPhotos ?? this.localPhotos,
    );
  }
}

class HintError {
  final String message;
  final String description;

  HintError({required this.message, required this.description});
}
