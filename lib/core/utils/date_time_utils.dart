
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

String changeDateFormat(String inputFormat, String input, String outputFormat) {
  debugPrint("InpoutDate: $input");
  var inputDF = DateFormat(inputFormat);
  var inputDate = inputDF.parse(input, true);
  var outputDF = DateFormat(outputFormat);
  var outputDate = outputDF.format(inputDate);
  debugPrint("outputDate: $outputDate");
  return outputDate;
}

String dateTimeFormatter(
    {required String dateTime,
    String format = "d MMM yyyy",
    bool time = false,
    bool utc = false}) {
  debugPrint("dateTimeFormatter::::$dateTime");
  try {
    DateTime currentDateTime =
        utc ? DateTime.now().toUtc() : DateTime.now().toLocal();
    DateTime parseDateTime = DateTime.now();

    if (dateTimeFormatCheck(dateTime) && format.isNotEmpty) {
      parseDateTime = DateTime.parse(dateTime);
    } else if (time) {
      String date = DateFormat('d MMMM yyyy').format(currentDateTime);
      parseDateTime = DateTime.parse("$date $dateTime");
    } else {
      String time = DateFormat('hh:mm a').format(currentDateTime);
      parseDateTime = DateTime.parse("$dateTime $time");
    }

    return DateFormat(format)
        .format(utc ? parseDateTime.toUtc() : parseDateTime.toLocal());
  } on FormatException catch (e) {
    debugPrint("$e");
    return DateFormat(format).format(DateTime.now());
  }
}

bool dateTimeFormatCheck(String date) {
  try {
    DateTime covertValue = DateTime.parse(date);
    return true;
  } on FormatException {
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
