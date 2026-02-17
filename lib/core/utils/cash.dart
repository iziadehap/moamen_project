import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class Cash {
  final box = Hive.box('cash');

  Future<bool> save(dynamic data, String key) async {
    try {
      await box.put(key, data);
      print('cash saved');
      return true;
    } catch (e) {
      print('cash save failed');
      return false;
    }
  }

  Future<dynamic> get(String key) async {
    try {
      final data = box.get(key);
      print('cash get failed');
      return data;
    } catch (e) {
      print('cash get failed');
      return null;
    }
  }

  Future<bool> delete(String key) async {
    try {
      await box.delete(key);
      print('cash deleted');
      return true;
    } catch (e) {
      print('cash delete failed');
      return false;
    }
  }
}

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

  static Future<bool> comparePassword(String password) async {
    String? storedPassword = await storage.read(key: CashHelper.passwordKey);
    if (storedPassword == null) {
      return false;
    }
    if (BCrypt.checkpw(password, storedPassword)) {
      return true;
    }
    return false;
  }

  static Future<String> hashPassword(String password) async {
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    return passwordHash;
  }
}

class CashHelper {
  static const String passwordKey = "PasswordKey";
  static const String phoneKey = "PhoneKey";
  static const String userKey = "UserKey";
}
