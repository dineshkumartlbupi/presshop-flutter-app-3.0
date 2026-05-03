import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_constant.dart';

dynamic numberFormatting(dynamic number) {
  if (number == null) return 0;
  String value = number.toString().trim();
  if (value.isEmpty) return 0;
  try {
    if (value.length == 1) {
      return int.tryParse(value) ?? 0;
    } else {
      double? parseValue = double.tryParse(value);
      if (parseValue == null) return 0;

      String decimalFormatting = parseValue
          .toStringAsFixed(parseValue.truncateToDouble() == parseValue ? 0 : 2);

      debugPrint("numberFormatting:::: $decimalFormatting");

      return double.parse(decimalFormatting);
    }
  } catch (e) {
    debugPrint("Number Exception============>$e");
    return 0;
  }
}

bool isKeyEmptyMap(Map<String, dynamic> data, String key) {
  if (data[key] == null) return true;
  return data[key] is Map && data[key].isEmpty;
}

String fixS3Url(String url) {
  try {
    Uri uri = Uri.parse(url);
    String host = uri.host;

    if (host.contains(".s3.") && host.contains("amazonaws.com")) {
      final hostParts = host.split(".s3.");
      if (hostParts.length == 2) {
        final bucketName = hostParts[0];
        final regionAndDomain = hostParts[1];

        if (bucketName.contains('.')) {
          String newHost = "s3.$regionAndDomain";
          String newPath = "/$bucketName${uri.path}";
          return uri.replace(host: newHost, path: newPath).toString();
        }
      }
    }
  } catch (e) {
    debugPrint("Error in fixS3Url: $e");
  }

  if (url.contains("presshop3.0.s3.eu-west-2.amazonaws.com")) {
    return url.replaceFirst("presshop3.0.s3.eu-west-2.amazonaws.com",
        "s3.eu-west-2.amazonaws.com/presshop3.0");
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

  // If it's a relative path/filename, prefix it with the base upload URL
  // Base URL: https://funnellike-subangular-sulema.ngrok-free.dev/api/
  // Upload URL: https://funnellike-subangular-sulema.ngrok-free.dev/uploads/
  final String baseUploadUrl =
      ApiConstantsNew.config.baseUrl.replaceAll('api/', 'uploads/');

  return fixS3Url("$baseUploadUrl$trimmedUrl");
}

String getCurrencySymbol(String? currencyCode) {
  if (currencyCode == null || currencyCode.isEmpty) return "";
  switch (currencyCode.toUpperCase()) {
    case 'GBP':
      return '£';
    case 'USD':
    case 'AUD':
    case 'CAD':
      return '\$';
    case 'EUR':
      return '€';
    case 'INR':
      return '₹';
    default:
      return currencyCode;
  }
}
