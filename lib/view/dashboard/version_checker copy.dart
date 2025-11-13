// import 'package:dio/dio.dart';
// import 'dart:io';

// class VersionService {
//   static final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(seconds: 8),
//     receiveTimeout: const Duration(seconds: 8),
//   ));

//   static Future<String?> fetchPlayStoreVersion(String packageName) async {
//     try {
//       final response = await _dio.get(
//         'https://play.google.com/store/apps/details?id=$packageName&hl=en',
//         options: Options(
//           headers: {
//             'User-Agent':
//                 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118 Safari/537.36',
//             'Cache-Control': 'no-cache',
//           },
//         ),
//       );

//       final html = response.data.toString();
//       final regex =
//           RegExp(r'\[\[\["([0-9]+(?:\.[0-9]+)+)"\]\]', caseSensitive: false);
//       final match = regex.firstMatch(html);
//       if (match != null) {
//         return match.group(1);
//       }

//       // fallback if HTML changes
//       final altRegex = RegExp(r'version.*?>([\d\.]+)<', caseSensitive: false);
//       final altMatch = altRegex.firstMatch(html);
//       return altMatch?.group(1);
//     } catch (e) {
//       print('Error fetching Play Store version: $e');
//       return null;
//     }
//   }

//   /// Fetch latest version from iOS App Store using Dio
//   static Future<String?> fetchAppStoreVersion(String appleId) async {
//     try {
//       final response = await _dio.get(
//         'https://itunes.apple.com/lookup?id=$appleId',
//       );
//       final results = response.data['results'] as List;
//       if (results.isNotEmpty) {
//         return results.first['version'];
//       }
//     } catch (e) {
//       print('Error fetching App Store version: $e');
//     }
//     return null;
//   }

//   /// Get the latest version depending on the platform
//   static Future<String?> fetchLatestVersion({
//     required String androidPackage,
//     required String iosAppId,
//   }) async {
//     if (Platform.isAndroid) {
//       return await fetchPlayStoreVersion(androidPackage);
//     } else if (Platform.isIOS) {
//       return await fetchAppStoreVersion(iosAppId);
//     }
//     return null;
//   }
// }
