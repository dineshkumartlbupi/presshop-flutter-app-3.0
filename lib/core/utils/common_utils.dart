
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
