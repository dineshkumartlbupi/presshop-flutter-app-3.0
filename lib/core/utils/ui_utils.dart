import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/api/api_constant_new.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/constants/app_dimensions_new.dart';

/// Share
Future<void> shareLink(
    {required String title,
    required String description,
    required String taskName}) async {
  await Share.share("Please check out $taskName \n $title \n $description"
      "Post\n${ApiConstantsNew.config.appUrl}");
}

bool isSixInchScreen(BuildContext context) {
  var mediaQuery = MediaQuery.of(context);

  double widthPx = mediaQuery.size.width * mediaQuery.devicePixelRatio;
  double heightPx = mediaQuery.size.height * mediaQuery.devicePixelRatio;
  double dpi = mediaQuery.devicePixelRatio * 160;

  // Calculate diagonal size in inches
  double diagonalSizeInches = sqrt(pow(widthPx, 2) + pow(heightPx, 2)) / dpi;

  return diagonalSizeInches >= 5.8 && diagonalSizeInches <= 6.2;
}

void showToast(String msg, [Toast toastLength = Toast.LENGTH_SHORT]) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLength,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: AppColorTheme.lightGrey,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

bool get isIpad => sharedPreferences?.getBool("isIpad") ?? false;

TextStyle commonTextStyle(
    {required Size size,
    required fontSize,
    required Color color,
    double? lineHeight,
    required FontWeight fontWeight}) {
  return TextStyle(
    fontWeight: fontWeight,
    fontSize: fontSize,
    height: lineHeight,
    color: color,
  );
}

TextStyle commonBigTitleTextStyle(Size size, Color color) {
  return TextStyle(
      fontFamily: "AirbnbCereal",
      color: color,
      fontSize: size.width * AppDimensions.numD08,
      fontWeight: FontWeight.bold);
}

Widget commonLeading(Size size) {
  return Row(
    children: [
      Icon(
        Icons.arrow_back_rounded,
        color: Colors.black,
        size: size.width * AppDimensions.numD08,
      ),
    ],
  );
}

String amountFormat(String? price) {
  if (price == null || price.isEmpty || price.toLowerCase() == "nan") {
    return "0";
  }
  try {
    var formattedNumber =
        NumberFormat("#,##0", "en_US").format(double.parse(price));
    return formattedNumber;
  } catch (e) {
    debugPrint("amountFormat error: $e");
    return "0";
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 17) {
    return 'Good afternoon';
  }
  return 'Good evening';
}

String formatDouble(double value) {
  final NumberFormat numberFormat = NumberFormat("#,##0.00");
  if (value == value.toInt()) {
    return NumberFormat("#,##0").format(value);
  } else {
    return numberFormat.format(value);
  }
}

String formatMessageTimestamp(DateTime timestamp) {
  final currentTime = DateTime.now();
  final difference = currentTime.difference(timestamp.toLocal());

  if (difference < const Duration(days: 1)) {
    return DateFormat("hh:mm a, dd MMM yyyy").format(timestamp.toLocal());
  } else {
    return DateFormat("hh:mm a, dd MMM yyyy").format(timestamp);
  }
}
