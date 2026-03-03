import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:moamen_project/core/error/failure.dart';
import 'package:moamen_project/core/utils/check_hashed.dart';
import 'package:moamen_project/core/utils/supabase_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfigData {
  final supabase = Supabase.instance.client;

  Future<Either<Failure, AppConfigModel>> getAppConfig() async {
    final cachedConfig = await getFromCache();
    if (cachedConfig != null) {
      return Right(cachedConfig);
    }
    final config = await getFromSupabase();
    if (config != null) {
      return Right(config);
    }
    return Left(Failure(message: 'No config found', code: 'no_config'));
  }

  Future<bool> verifyBigBossPassword(String password) async {
    final config = await getAppConfig();

    return config.fold(
      (failure) => false,
      (configModel) =>
          compareHash(password, configModel.theBigBossPasswordHash),
    );
  }

  Future<AppConfigModel?> getFromSupabase() async {
    try {
      final config = await supabase
          .from(SupabaseTables.appConfig)
          .select()
          .eq(SupabaseAppConfigCulomns.id, 1)
          .single();

      final appConfigModel = AppConfigModel.fromJson(config);
      await saveToCache(appConfigModel);

      return appConfigModel;
    } catch (e) {
      return null;
    }
  }

  Future<AppConfigModel?> getFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final config = prefs.getString(SupabaseTables.appConfig);
    if (config != null) {
      return AppConfigModel.fromJson(jsonDecode(config));
    }
    return null;
  }

  Future<bool> saveToCache(AppConfigModel appConfigModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        SupabaseTables.appConfig,
        jsonEncode(appConfigModel.toJson()),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SupabaseTables.appConfig);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class AppConfigModel {
  final String minVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String theBigBossPasswordHash;
  final int priorityChange;

  AppConfigModel({
    required this.minVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.theBigBossPasswordHash,
    required this.priorityChange,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      minVersion: json[SupabaseAppConfigCulomns.minVersion],
      latestVersion: json[SupabaseAppConfigCulomns.latestVersion],
      forceUpdate: json[SupabaseAppConfigCulomns.forceUpdate],
      theBigBossPasswordHash:
          json[SupabaseAppConfigCulomns.theBigBossPasswordHash],
      priorityChange: json[SupabaseAppConfigCulomns.priorityChange],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SupabaseAppConfigCulomns.minVersion: minVersion,
      SupabaseAppConfigCulomns.latestVersion: latestVersion,
      SupabaseAppConfigCulomns.forceUpdate: forceUpdate,
      SupabaseAppConfigCulomns.theBigBossPasswordHash: theBigBossPasswordHash,
      SupabaseAppConfigCulomns.priorityChange: priorityChange,
    };
  }
}
