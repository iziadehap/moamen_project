import 'dart:io';

import 'package:moamen_project/features/orders/data/models/order_model.dart';

class OrderState {
  final List<Order> orders;
  final bool isLoading;
  final bool isError;
  final String errorMessage;
  final bool hasFetched;
  final List<String> photoUrls;
  final List<File> localPhotos;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.isError = false,
    this.errorMessage = '',
    this.hasFetched = false,
    this.photoUrls = const [],
    this.localPhotos = const [],
  });

  OrderState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    bool? hasFetched,
    List<String>? photoUrls,
    List<File>? localPhotos,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasFetched: hasFetched ?? this.hasFetched,
      photoUrls: photoUrls ?? this.photoUrls,
      localPhotos: localPhotos ?? this.localPhotos,
    );
  }
}
