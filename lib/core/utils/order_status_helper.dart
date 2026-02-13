import 'package:flutter/material.dart';
import 'package:moamen_project/core/theme/app_colors.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class OrderStatusHelper {
  static String getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'جاهز';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.inProgress:
        return 'قيد التنفيذ';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  static Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.green;
      case OrderStatus.accepted:
        return AppColors.primaryBlue;
      case OrderStatus.inProgress:
        return AppColors.primaryPurple;
      case OrderStatus.completed:
        return Colors.brown;
      case OrderStatus.cancelled:
        return Colors.redAccent;
    }
  }

  static String getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'الطلب جاهز في المتجر وبانتظار استلام المندوب';
      case OrderStatus.accepted:
        return 'قام المندوب بقبول الطلب وهو في الطريق للمتجر';
      case OrderStatus.inProgress:
        return 'قام المندوب باستلام الطلب وهو في الطريق إليك';
      case OrderStatus.completed:
        return 'تم توصيل الطلب بنجاح';
      case OrderStatus.cancelled:
        return 'تم إلغاء الطلب ولن يتم توصيله';
    }
  }
}
