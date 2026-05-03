class SafeParser {
  static String parseString(dynamic value, {String defaultValue = ""}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) return value == 1;
    return defaultValue;
  }

  static DateTime parseDateTime(dynamic value, {DateTime? defaultValue}) {
    final defaultVal = defaultValue ?? DateTime.now();
    if (value == null) return defaultVal;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return defaultVal;
      }
    }
    return defaultVal;
  }

  static List<T> parseList<T>(dynamic value, T Function(dynamic) mapper) {
    if (value == null || value is! List) return [];
    try {
      return value.map((e) => mapper(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
