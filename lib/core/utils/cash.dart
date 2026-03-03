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
