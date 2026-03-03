// class SupabaseProfileCulomns {
//   static const String id = "id";
//   static const String phone = "phone";
//   static const String password = "password";
//   static const String name = "name";
//   static const String role = "role";
//   static const String isActive = "is_active";
//   static const String imageUrl = "image_url";
//   static const String maxOrders = "max_orders";
//   static const String createdAt = "created_at";
// }

// create table public.app_config (
//   id integer not null default 1,
//   min_version text not null,
//   latest_version text not null,
//   force_update boolean null default false,
//   the_big_boss_password_hash text null,
//   priority_change smallint null,
//   constraint app_config_pkey primary key (id)
// ) TABLESPACE pg_default;

class SupabaseAppConfigCulomns {
  static const String id = "id";
  static const String minVersion = "min_version";
  static const String latestVersion = "latest_version";
  static const String forceUpdate = "force_update";
  static const String theBigBossPasswordHash = "the_big_boss_password_hash";
  static const String priorityChange = "priority_change";
}

class SupabaseProfileCulomns {
  static const String id = "id";
  static const String name = "name";
  static const String phone = "phone";
  static const String role = "role";
  static const String isActive = "is_active";
  static const String maxOrders = "max_orders";
  static const String imageUrl = "image_url";
  static const String createdAt = "created_at";
}

class SupabasePricelistCulomns {
  static const String id = "id";
  static const String title = "title";
  static const String price = "price";
  static const String description = "description";
  static const String isActive = "is_active";
  static const String photoUrls = "photo_urls";
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

class TransactionType {
  static const String purchase = "purchase";
  static const String adminAdd = "admin_add";
  static const String adminRemove = "admin_remove";
  static const String usage = "usage";
}

class SupabaseOrderTransactionsCulomns {
  //  ARRAY[
  //     'purchase',
  //     'admin_add',
  //     'admin_remove',
  //     'usage'
  //   ]
  static const String id = "id";
  static const String orderId = "order_id";
  static const String userId = "user_id";
  static const String amount = "amount";
  static const String balanceBefore = "balance_before";
  static const String balanceAfter = "balance_after";
  static const String idempotencyKey = "idempotency_key";
  static const String type = "type";
  static const String createdAt = "created_at";
}

class SupabaseTables {
  static const String ordersWithWorker = "orders_with_worker";
  static const String accounts = "accounts";
  static const String profiles = "profiles";
  static const String pricelist = "price_list";
  static const String orders = "orders";
  static const String orderTransactions = "order_transactions";
  static const String PhotosBucket = "orders-photos";
  static const String orderTracking = "order_tracking";
  static const String appConfig = "app_config";
  // static const String pricelistPhotosBucket = "pricelist-photos";
}

class SupabaseAccountTyps {
  static const String user = "user";
  static const String admin = "admin";
}

class SupabaseFunctions {
  static const String acceptOrder = "accept_order";
  static const String adminAdjustMaxOrders = "admin_adjust_max_orders";
}
