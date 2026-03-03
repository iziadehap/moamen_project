import 'package:flutter/material.dart';
import 'package:moamen_project/core/theme/app_theme.dart';
import 'package:moamen_project/features/orders/data/models/order_model.dart';

class OrderStatusHelper {
  static String getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'جاهز';
      case OrderStatus.accepted:
        return 'مقبول';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  static Color getStatusColor(
    OrderStatus status,
    CustomThemeExtension customTheme,
  ) {
    switch (status) {
      case OrderStatus.pending:
        return customTheme.statusCyan;
      case OrderStatus.accepted:
        return customTheme.primaryBlue;
      case OrderStatus.completed:
        return customTheme.statusGreen;
      case OrderStatus.cancelled:
        return customTheme.errorColor;
    }
  }

  static String getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'الاوردر جاهز في المتجر وبانتظار استلام المندوب';
      case OrderStatus.accepted:
        return 'قام المندوب بقبول الاوردر وهو في الطريق للمكان ';
      case OrderStatus.completed:
        return 'تم توصيل الاوردر بنجاح';
      case OrderStatus.cancelled:
        return 'تم إلغاء الاوردر';
    }
  }
}
