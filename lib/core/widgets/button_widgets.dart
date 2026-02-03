import 'package:flutter/material.dart';
import 'package:presshop/core/constants/app_dimensions_new.dart';

Widget commonElevatedButton(String buttonText, Size size, TextStyle textStyle,
    ButtonStyle buttonStyle, VoidCallback fxn) {
  return ElevatedButton(
    onPressed: fxn,
    style: buttonStyle,
    child: Text(
      buttonText,
      style: textStyle,
      textAlign: TextAlign.center,
    ),
  );
}

ButtonStyle commonButtonStyle(Size size, Color color) {
  return ElevatedButton.styleFrom(
      backgroundColor: color,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * AppDimensions.numD03)));
}

TextStyle commonButtonTextStyle(Size size) {
  return TextStyle(
      color: Colors.white,
      fontSize: size.width * AppDimensions.numD037,
      fontFamily: "AirbnbCereal",
      fontWeight: FontWeight.bold);
}
