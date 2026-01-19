import 'package:flutter/foundation.dart';

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
        "dev-presshope.s3.eu-west-2.amazonaws.com");
  } else if (url.contains("s3.eu-west-2.amazonaws.com/presshop3.0")) {
    return url.replaceFirst("s3.eu-west-2.amazonaws.com/presshop3.0",
        "dev-presshope.s3.eu-west-2.amazonaws.com/public");
  }
  return url;
}
