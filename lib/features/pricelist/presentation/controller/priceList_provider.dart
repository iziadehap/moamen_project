import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moamen_project/features/pricelist/presentation/controller/priceList_notifier.dart';
import 'package:moamen_project/features/pricelist/presentation/controller/priceList_state.dart';

final priceProvider = NotifierProvider<PricelistNotifier, PricelistState>(
  PricelistNotifier.new,
);
