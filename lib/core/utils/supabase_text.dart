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

class SupabaseProfileCulomns {
  static const String id = "id";
  static const String name = "name";
  static const String phone = "phone";
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

class SupabaseOrdersCulomns {
  static const String id = "id";
  static const String title = "title";
  static const String description = "description";
  static const String status = "status";
  static const String priority = "priority";
  static const String orderType = "order_type";
  static const String workerId = "worker_id";
  static const String workerName = "worker_name";
  static const String publicArea = "public_area";
  static const String publicLandmark = "public_landmark";
  static const String availability = "availability";
  static const String fullAddress = "full_address";
  static const String latitude = "latitude";
  static const String longitude = "longitude";
  static const String contactName = "contact_name";
  static const String contactPhone = "contact_phone";
  static const String createdAt = "created_at";
  static const String updatedAt = "updated_at";
  static const String photoUrls = "photo_urls";
  static const String acceptedAt = "accepted_at";
}

class SupabaseTables {
  static const String ordersWithWorker = "orders_with_worker";
  static const String accounts = "accounts";
  static const String profiles = "profiles";
  static const String pricelist = "price_list";
  static const String orders = "orders";
  static const String ordersPhotosBucket = "orders-photos";
}

class SupabaseAccountTyps {
  static const String user = "user";
  static const String admin = "admin";
}
