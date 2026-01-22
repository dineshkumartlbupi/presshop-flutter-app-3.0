import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_constant.dart';

dynamic numberFormatting(dynamic number) {
  String value = number.toString();
  try {
    if (value.length == 1) {
      return int.parse(value);
    } else {
      double parseValue = double.parse(value);

      String decimalFormatting = parseValue
          .toStringAsFixed(parseValue.truncateToDouble() == parseValue ? 0 : 2);

      debugPrint("numberFormatting:::: $decimalFormatting");

      if (decimalFormatting.contains(".")) {
        return double.parse(decimalFormatting);
      } else {
        return double.parse(decimalFormatting);
      }
    }
  } on FormatException catch (e) {
    debugPrint("Number Exception============>$e");
    return 0;
  }
}

bool isKeyEmptyMap(Map<String, dynamic> data, String key) {
  if (data[key] == null) return true;
  return data[key] is Map && data[key].isEmpty;
}

String fixS3Url(String url) {
  if (url.contains("presshop3.0.s3.eu-west-2.amazonaws.com")) {
    return url.replaceFirst("presshop3.0.s3.eu-west-2.amazonaws.com",
        "s3.eu-west-2.amazonaws.com/presshop3.0");
  } else if (url.contains("s3.eu-west-2.amazonaws.com/presshop3.0")) {
    return url;
  }
  return url;
}

String getMediaImageUrl(String? url,
    {bool isVideo = false, bool isTask = false}) {
  if (url == null || url.isEmpty) return "";

  String trimmedUrl = url.trim();

  if (trimmedUrl.contains("http://") || trimmedUrl.contains("https://")) {
    return fixS3Url(trimmedUrl);
  }

  String baseUrl = isTask
      ? taskMediaUrl
      : isVideo
          ? mediaThumbnailUrl
          : contentImageUrl;

  return fixS3Url("$baseUrl$trimmedUrl");
}
