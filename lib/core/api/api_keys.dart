import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

String get googleMapAPiKey {
  try {
    return dotenv.get('GOOGLE_MAP_API_KEY',
        fallback: "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI");
  } catch (_) {
    return "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI";
  }
}

String get appleMapAPiKey {
  try {
    return dotenv.get('APPLE_MAP_API_KEY',
        fallback: "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw");
  } catch (_) {
    return "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw";
  }
}

final String appUrl = Platform.isAndroid
    ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
    : 'https://apps.apple.com/in/app/presshop/id6744651614';
