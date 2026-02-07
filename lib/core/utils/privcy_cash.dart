import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moamen_project/core/utils/app_text.dart';

class PrivcyCash {
  // Create instance
  static final storage = FlutterSecureStorage();

  // Save Credentials
  static Future<void> saveCredentials({
    required String phone,
    required String password,
  }) async {
    await storage.write(key: CashHelper.phoneKey, value: phone);
    await storage.write(key: CashHelper.passwordKey, value: password);
    print('privecy saved');
  }

  // Read Credentials
  static Future<Map<String, String?>> readCredentials() async {
    String? phone = await storage.read(key: CashHelper.phoneKey);
    String? password = await storage.read(key: CashHelper.passwordKey);
    print('privecy read');
    return {CashHelper.phoneKey: phone, CashHelper.passwordKey: password};
  }

  // Delete Credentials
  static Future<void> deleteCredentials() async {
    await storage.delete(key: CashHelper.phoneKey);
    await storage.delete(key: CashHelper.passwordKey);
    print('privecy deleted');
  }
}
