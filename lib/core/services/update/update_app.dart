// update_app.dart
import 'dart:convert';
import 'dart:io';

import 'package:apk_sideload/install_apk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UpdateDecisionType { none, optional, forced }

class UpdateDecision {
  final UpdateDecisionType type;
  final String currentVersion;
  final String latestVersion;
  final String minVersion;
  final bool forceUpdate;

  const UpdateDecision({
    required this.type,
    required this.currentVersion,
    required this.latestVersion,
    required this.minVersion,
    required this.forceUpdate,
  });

  bool get hasUpdate => type != UpdateDecisionType.none;
}

/// compares: "1.2.3"
int compareVersions(String a, String b) {
  final aParts = a.trim().split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final bParts = b.trim().split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final maxLen = aParts.length > bParts.length ? aParts.length : bParts.length;
  while (aParts.length < maxLen) aParts.add(0);
  while (bParts.length < maxLen) bParts.add(0);

  for (int i = 0; i < maxLen; i++) {
    if (aParts[i] < bParts[i]) return -1;
    if (aParts[i] > bParts[i]) return 1;
  }
  return 0;
}

class AppUpdateService {
  final SupabaseClient supabase;
  AppUpdateService(this.supabase);

  Future<UpdateDecision> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version.trim();

    final config = await supabase
        .from('app_config')
        .select('min_version, latest_version, force_update')
        .eq('id', 1)
        .single();

    final minVersion = (config['min_version'] as String).trim();
    final latestVersion = (config['latest_version'] as String).trim();
    final forceUpdate = (config['force_update'] as bool?) ?? false;

    if (compareVersions(currentVersion, minVersion) < 0) {
      return UpdateDecision(
        type: UpdateDecisionType.forced,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        minVersion: minVersion,
        forceUpdate: true,
      );
    }

    if (compareVersions(currentVersion, latestVersion) < 0) {
      return UpdateDecision(
        type: forceUpdate
            ? UpdateDecisionType.forced
            : UpdateDecisionType.optional,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        minVersion: minVersion,
        forceUpdate: forceUpdate,
      );
    }

    return UpdateDecision(
      type: UpdateDecisionType.none,
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      minVersion: minVersion,
      forceUpdate: forceUpdate,
    );
  }
}

class GithubReleaseUpdater {
  GithubReleaseUpdater();

  final String owner = "moamen303";
  final String repo = "myProject";
  final String apkAssetName = "app-release.apk";

  /// ✅ بدل /latest استخدم list releases (أضمن)
  Future<Map<String, dynamic>> _getLatestRelease(String token) async {
    final uri = Uri.parse(
      'https://api.github.com/repos/$owner/$repo/releases?per_page=1',
    );

    final headers = <String, String>{
      'Accept': 'application/vnd.github+json',
      'Authorization': 'Bearer ${token.trim()}',
    };

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('GitHub releases failed: ${res.statusCode} ${res.body}');
    }

    final list = jsonDecode(res.body) as List;
    if (list.isEmpty) throw Exception('No releases found');

    return list.first as Map<String, dynamic>;
  }

  /// ✅ يرجع asset API URL (مش browser_download_url)
  Future<String> fetchLatestApkAssetApiUrl(String token) async {
    final release = await _getLatestRelease(token);
    final assets = (release['assets'] as List?) ?? [];

    Map<String, dynamic>? picked;

    // اختار بالاسم الأول (أضمن)
    for (final a in assets) {
      final m = a as Map<String, dynamic>;
      final name = (m['name'] as String?) ?? '';
      if (name == apkAssetName) {
        picked = m;
        break;
      }
    }

    // fallback: أول APK
    picked ??= assets.cast<Map<String, dynamic>>().firstWhere(
      (m) => ((m['name'] as String?) ?? '').toLowerCase().endsWith('.apk'),
      orElse: () => {},
    );

    if (picked.isEmpty) throw Exception('No APK asset found in release');

    final assetUrl = (picked['url'] as String?) ?? '';
    if (assetUrl.isEmpty) throw Exception('Asset API url missing');

    return assetUrl;
  }

  /// ✅ تنزيل صحيح لـ private release asset مع تتبع التقدم ومنع التكرار
  Future<String> downloadApkFromAssetApiUrl(
    String assetApiUrl,
    String token, {
    required String versionName,
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final fileName = 'update_$versionName.apk';
    final file = File('${dir.path}/$fileName');

    // إذا الملف موجود وحجمه منطقي، نستخدمه فوراً
    if (await file.exists()) {
      final size = await file.length();
      if (size > 0) {
        if (onProgress != null) onProgress(1.0);
        return file.path;
      }
    }

    final req = http.Request('GET', Uri.parse(assetApiUrl))
      ..headers['Authorization'] = 'Bearer ${token.trim()}'
      ..headers['Accept'] = 'application/octet-stream';

    final streamed = await req.send();

    if (streamed.statusCode != 200) {
      final body = await streamed.stream.bytesToString();
      throw Exception('APK download failed: ${streamed.statusCode} $body');
    }

    final totalBytes = streamed.contentLength ?? 0;
    int receivedBytes = 0;
    final List<int> bytes = [];

    await for (final chunk in streamed.stream) {
      bytes.addAll(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0 && onProgress != null) {
        onProgress(receivedBytes / totalBytes);
      }
    }

    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> installApkFromUrl({
    required String latestVersion,
    void Function(double progress)? onProgress,
  }) async {
    final token = dotenv.env['GITHUB_TOKEN'];
    if (token == null || token.trim().isEmpty) {
      throw Exception('GITHUB_TOKEN is missing');
    }

    final assetApiUrl = await fetchLatestApkAssetApiUrl(token);
    final apkPath = await downloadApkFromAssetApiUrl(
      assetApiUrl,
      token,
      versionName: latestVersion,
      onProgress: onProgress,
    );

    // يفتح شاشة التثبيت
    await InstallApk().installApk(apkPath);
  }
}
