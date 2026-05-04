import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/features/content/data/models/my_content_data_model.dart';
import 'package:presshop/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:presshop/core/core_export.dart';
export 'package:presshop/core/core_export.dart';

Size globalSize = MediaQuery.of(navigatorKey.currentContext!).size;

// Reusable widget for Price Image and Button
Widget priceImageWithButton(Size size, String amount, String hour,
    {String? localCurrencySymbol}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: Image.asset(
          "assets/illustrations/priceimage2.png",
          width: size.width * AppDimensions.numD60,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                "Error loading image: $error",
                style: const TextStyle(color: Colors.red),
              ),
            );
          },
        ),
      ),
      SizedBox(height: size.width * AppDimensions.numD02),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  "${localCurrencySymbol ?? currencySymbol}${formatDouble(double.tryParse(amount) ?? 0.0)} ",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD08,
                  color: Theme.of(navigatorKey.currentContext!)
                      .textTheme
                      .bodyLarge
                      ?.color,
                  fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: "for $hour hours",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD04,
                  color: Theme.of(navigatorKey.currentContext!)
                      .textTheme
                      .bodyMedium
                      ?.color,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: size.width * AppDimensions.numD02),
    ],
  );
}

Widget errorMessageWidget(String message) {
  return Center(
    child: Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 30),
      child: Text(
        message,
        style: commonTextStyle(
          size: globalSize,
          fontSize: globalSize.width * AppDimensions.numD04,
          color: Theme.of(navigatorKey.currentContext!).hintColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}

/// Smart Refresh

Widget commonRefresherFooter(BuildContext context, LoadStatus? mode) {
  Widget body;
  if (mode == LoadStatus.idle) {
    body = const Text("pull up load");
  } else if (mode == LoadStatus.loading) {
    body = const CircularProgressIndicator(
      color: AppColorTheme.colorThemePink,
    );
  } else if (mode == LoadStatus.failed) {
    body = const Text("Load Failed!Click retry!");
  } else if (mode == LoadStatus.canLoading) {
    body = const Text("release to load more");
  } else if (mode == LoadStatus.noMore) {
    body = const Text("No item available");
  } else {
    body = const Text("");
  }
  return SizedBox(
    height: 55.0,
    child: Center(child: body),
  );
}

Widget showLoader({bool isForLocation = false}) {
  var size = MediaQuery.of(navigatorKey.currentContext!).size;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: [
      Center(
        child: Builder(builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final loaderColor = isDark ? Colors.white : Colors.black;
          return ColorFiltered(
            colorFilter: ColorFilter.mode(loaderColor, BlendMode.srcIn),
            child: Lottie.asset(
              "assets/lottieFiles/loader_new.json",
              height: size.width * AppDimensions.numD28,
              width: size.width * AppDimensions.numD28,
            ),
          );
        }),
      ),
      if (isForLocation) ...[
        SizedBox(height: size.width * AppDimensions.numD005),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Text(
            "Please wait while we tring to fetch your location. Be with us.",
            textAlign: TextAlign.center,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD04,
                color: Theme.of(navigatorKey.currentContext!)
                    .textTheme
                    .bodyLarge
                    ?.color,
                fontWeight: FontWeight.w500),
          ),
        ),
      ]
    ],
  );
}

Widget showAnimatedLoader(Size size) {
  return Center(
    child: Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final loaderColor = isDark ? Colors.white : Colors.black;
      return ColorFiltered(
        colorFilter: ColorFilter.mode(loaderColor, BlendMode.srcIn),
        child: Lottie.asset("assets/lottieFiles/loader_new.json",
            height: size.width * AppDimensions.numD25,
            width: size.width * AppDimensions.numD25),
      );
    }),
  );
}

/// Calender
Future<String?> commonDatePicker({String? date}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: navigatorKey.currentContext!,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900, 01, 01),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light()
                .copyWith(primary: AppColorTheme.colorThemePink)),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    final String formatted = pickedDate.toString();
    //dateTimeFormatter(dateTime: pickedDate.toString());
    debugPrint("formatted=======Date===Format====>$formatted");
    return formatted;
  } else {
    return date;
  }
}

/// FilterIcon
Container commonFilterIcon(BuildContext context, Size size) {
  return Container(
      padding: EdgeInsets.all(size.width * AppDimensions.numD025),
      child: Image.asset(
        "assets/icons/filter_new.png",
        width: size.width * AppDimensions.numD06,
        height: size.width * AppDimensions.numD06,
        color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.tune_rounded,
              color: Theme.of(context).iconTheme.color,
              size: size.width * AppDimensions.numD06);
        },
      ));
}

/// aditya

/// aditya

/// aditya

Widget getMediaCountCard(
    String mediaType, int count, Size size, BuildContext context) {
  return Container(
    width: size.width * AppDimensions.numD11,
    height: size.width * 0.06,
    margin: EdgeInsets.only(bottom: size.width * AppDimensions.numD01),
    decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark
                ? AppColorTheme.colorBlack
                : AppColorTheme.colorGrey5)
            .withOpacity(0.7),
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD01)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$count",
          textAlign: TextAlign.center,
          style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD03,
              color: Colors.white,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(width: size.width * 0.01),
        Image.asset(
          mediaType == "image"
              ? "${iconsPath}ic_camera_publish.png"
              : mediaType == "video"
                  ? "${iconsPath}ic_v_cam.png"
                  : mediaType == "audio"
                      ? "${iconsPath}new_audio.png"
                      : "${iconsPath}doc_icon.png",
          height: size.width * 0.035,
          color: Colors.white,
        ),
      ],
    ),
  );
}

List<Widget> getMediaCount(
    List<dynamic> contentMediaList, Size size, BuildContext context) {
  int imageCount = 0;
  int videoCount = 0;
  int audioCount = 0;
  int docCount = 0;

  for (var item in contentMediaList) {
    String type = "";
    if (item is Map) {
      type = (item['media_type'] ?? item['type'] ?? "").toString();
    } else {
      // Handle objects with mediaType or type property
      try {
        type = (item.mediaType ?? item.type ?? "").toString();
      } catch (_) {}
    }

    if (type == "image") {
      imageCount++;
    } else if (type == "video") {
      videoCount++;
    } else if (type == "audio") {
      audioCount++;
    } else if (type == "pdf" || type == "doc") {
      docCount++;
    }
  }

  final widgetList = <Widget>[];
  if (imageCount > 0) {
    widgetList.add(getMediaCountCard("image", imageCount, size, context));
    widgetList.add(const SizedBox(height: 6));
  }
  if (videoCount > 0) {
    widgetList.add(getMediaCountCard("video", videoCount, size, context));
    widgetList.add(const SizedBox(height: 6));
  }
  if (audioCount > 0) {
    widgetList.add(getMediaCountCard("audio", audioCount, size, context));
    widgetList.add(const SizedBox(height: 6));
  }
  if (docCount > 0) {
    widgetList.add(getMediaCountCard("doc", docCount, size, context));
    widgetList.add(const SizedBox(height: 6));
  }
  return widgetList;
}

List<Widget> getMediaCount2(
    List<dynamic> contentMediaList, Size size, BuildContext context) {
  return getMediaCount(contentMediaList, size, context);
}
