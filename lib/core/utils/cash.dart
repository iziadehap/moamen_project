
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class Cash {
  final box = Hive.box('cash');

  Future<bool> save(dynamic data, String key) async {
    try {
      await box.put(key, data);
      debugPrint('cash saved');
      return true;
    } catch (e) {
      debugPrint('cash save failed');
      return false;
    }
  }

  Future<dynamic> get(String key) async {
    try {
      final data = box.get(key);
      debugPrint('cash get failed');
      return data;
    } catch (e) {
      debugPrint('cash get failed');
      return null;
    }
  }

  Future<bool> delete(String key) async {
    try {
      await box.delete(key);
      debugPrint('cash deleted');
      return true;
    } catch (e) {
      debugPrint('cash delete failed');
      return false;
    }
  }
}
