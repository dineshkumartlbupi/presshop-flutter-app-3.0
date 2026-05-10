import 'package:flutter/material.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/utils/ui_utils.dart';

class LogoWidget {
  static Widget buildLogo(Size size) {
    return Builder(builder: (context) {
      final double scalingWidth = isIpad ? 650 : size.width;
      return Image.asset(
        "${commonImagePath}rabbitLogo.png",
        height: scalingWidth * AppDimensions.numD13,
        width: scalingWidth * AppDimensions.numD13,
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
      );
    });
  }
}
