import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'order_notifire.dart';
import 'order_state.dart';

final orderProvider = NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);
