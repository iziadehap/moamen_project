import 'package:moamen_project/features/orders/data/models/order_model.dart';

enum OrderFilter {
  myOrders('اوردري', null),
  all('الكل', null),
  // active('نشط', null), // Pending + Accepted + InProgress
  pending('جاهز', OrderStatus.pending),
  accepted('مقبول', OrderStatus.accepted),
  // inProgress('قيد التنفيذ', OrderStatus.inProgress),
  completed('مكتمل', OrderStatus.completed),
  cancelled('ملغي', OrderStatus.cancelled);

  final String label;
  final OrderStatus? status;

  const OrderFilter(this.label, this.status);
}
