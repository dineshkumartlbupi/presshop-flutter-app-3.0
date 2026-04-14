



import 'package:flutter/material.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';

class LogoWidget {
  static Widget buildLogo(Size size) {
    return Image.asset(
      "${commonImagePath}rabbitLogo.png",
      height: size.width * AppDimensions.numD15,
      width: size.width * AppDimensions.numD15,
    );
  }
}