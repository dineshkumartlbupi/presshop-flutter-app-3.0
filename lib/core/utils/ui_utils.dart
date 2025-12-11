
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/theme/app_colors.dart';

/// Share
Future<void> shareLink(
    {required String title,
    required String description,
    required String taskName}) async {
  await Share.share("Please check out $taskName \n $title \n $description"
      "Post\n$appUrl");
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
    backgroundColor: lightGrey,
    textColor: Colors.black,
    fontSize: 16.0,
  );
}

bool get isIpad => sharedPreferences?.getBool("isIpad") ?? false;
