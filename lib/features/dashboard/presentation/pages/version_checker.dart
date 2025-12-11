import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  /// --- ANDROID: Fetch Play Store version ---
  static Future<String?> fetchPlayStoreVersion(String packageName) async {
    try {
      final response = await _dio.get(
        'https://play.google.com/store/apps/details?id=$packageName&hl=en&gl=US',
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118 Safari/537.36',
            'Cache-Control': 'no-cache',
          },
          responseType: ResponseType.plain,
        ),
      );

      final html = response.data.toString();

      // Primary regex
      final regex =
          RegExp(r'\[\[\["([0-9]+(?:\.[0-9]+)+)"\]\]', caseSensitive: false);
      final match = regex.firstMatch(html);
      if (match != null) return match.group(1);

      // Fallback regex
      final altRegex = RegExp(r'version.*?>([\d\.]+)<', caseSensitive: false);
      final altMatch = altRegex.firstMatch(html);
      return altMatch?.group(1);
    } catch (e) {
      print('Error fetching Play Store version: $e');
      return null;
    }
  }

  static Future<String?> fetchAppStoreVersion(String appleId) async {
    try {
      final response = await _dio.get(
        'https://itunes.apple.com/lookup?id=$appleId',
        options: Options(responseType: ResponseType.plain),
      );

      final jsonData = jsonDecode(response.data);
      final results = jsonData['results'] as List;

      if (results.isNotEmpty) {
        final version = results.first['version']?.toString();
        print("✅ Fetched iOS version: $version");
        return version;
      } else {
        print("⚠️ No results found in App Store response.");
      }
    } catch (e) {
      print('❌ Error fetching App Store version: $e');
    }
    return null;
  }

  /// --- Unified: Fetch latest version based on platform ---
  static Future<String?> fetchLatestVersion({
    required String androidPackage,
    required String iosAppId,
  }) async {
    if (Platform.isAndroid) {
      return await fetchPlayStoreVersion(androidPackage);
    } else if (Platform.isIOS) {
      return await fetchAppStoreVersion(iosAppId);
    }
    return null;
  }

  /// --- Compare versions and determine if update is available ---
  static Future<bool> isUpdateAvailable({
    required String androidPackage,
    required String iosAppId,
  }) async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;
    final latestVersion = await fetchLatestVersion(
      androidPackage: androidPackage,
      iosAppId: iosAppId,
    );

    print('Current Version: $currentVersion');
    print('Latest Store Version: $latestVersion');

    if (latestVersion == null) return false;
    return _compareVersions(latestVersion, currentVersion);
  }

  static bool _compareVersions(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
