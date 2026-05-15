import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String changeDateFormat(String inputFormat, String input, String outputFormat) {
  try {
    debugPrint("InpoutDate: $input");
    var inputDF = DateFormat(inputFormat);
    var inputDate = inputDF.parse(input, true);
    var outputDF = DateFormat(outputFormat);
    var outputDate = outputDF.format(inputDate);
    debugPrint("outputDate: $outputDate");
    return outputDate;
  } catch (e) {
    debugPrint("changeDateFormat error: $e for input: $input");
    return input;
  }
}

String dateTimeFormatter(
    {required String dateTime,
    String format = "d MMM yyyy",
    bool time = false,
    bool utc = false}) {
  if (dateTime.isEmpty || dateTime == "null") return "-";
  try {
    DateTime currentDateTime =
        utc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    DateTime? parseDateTime;

    if (dateTimeFormatCheck(dateTime)) {
      parseDateTime = DateTime.tryParse(dateTime);
    }

    if (parseDateTime == null) {
      if (time) {
        try {
          String dateStr = DateFormat('yyyy-MM-dd').format(currentDateTime);
          parseDateTime = DateTime.tryParse("$dateStr $dateTime");
        } catch (_) {}
      } else {
        try {
          String timeStr = DateFormat('HH:mm:ss').format(currentDateTime);
          parseDateTime = DateTime.tryParse("$dateTime $timeStr");
        } catch (_) {}
      }
    }

    if (parseDateTime == null) {
      return dateTime;
    }

    return DateFormat(format)
        .format(utc ? parseDateTime.toUtc() : parseDateTime.toLocal());
  } catch (e) {
    debugPrint("dateTimeFormatter error: $e for input: $dateTime");
    return dateTime;
  }
}

bool dateTimeFormatCheck(String date) {
  if (date.isEmpty) return false;
  try {
    DateTime? convertValue = DateTime.tryParse(date);
    return convertValue != null;
  } catch (_) {
    return false;
  }
}

String formatDuration(Duration d) {
  var seconds = d.inSeconds;
  final days = seconds ~/ Duration.secondsPerDay;
  seconds -= days * Duration.secondsPerDay;
  final hours = seconds ~/ Duration.secondsPerHour;
  seconds -= hours * Duration.secondsPerHour;
  final minutes = seconds ~/ Duration.secondsPerMinute;
  seconds -= minutes * Duration.secondsPerMinute;

  final List<String> tokens = [];
  if (days != 0) {
    tokens.add('${days}d ');
  }
  if (tokens.isNotEmpty || hours != 0) {
    tokens.add('${hours}h');
  }
  if (tokens.isNotEmpty || minutes != 0) {
    tokens.add('${minutes}m');
  }
  tokens.add('${seconds}s');

  return tokens.join(':');
}
