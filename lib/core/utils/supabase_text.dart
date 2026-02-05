class SupabaseAccountsCulomns {
  static const String id = "id";
  static const String phone = "phone";
  static const String password = "password";
  static const String name = "name";
  static const String role = "role";
  static const String isActive = "is_active";
  static const String maxOrders = "max_orders";
  static const String createdAt = "created_at";
}

class SupabasePricelistCulomns {
  static const String id = "id";
  static const String title = "title";
  static const String price = "price";
  static const String description = "description";
  static const String isActive = "is_active";
  static const String createdAt = "created_at";
}

class SupabaseTables {
  static const String accounts = "accounts";
  static const String pricelist = "price_list";
}

class SupabaseAccountTyps {
  static const String user = "user";
  static const String admin = "admin";
}
