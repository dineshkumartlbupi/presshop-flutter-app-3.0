import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:presshop/features/content/presentation/pages/my_draft_screen.dart';
import 'package:presshop/core/core_export.dart';
export 'package:presshop/core/core_export.dart';

Size globalSize = MediaQuery.of(navigatorKey.currentContext!).size;

///:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
///:::::::::::::::::::::::: BROAD CAST DIALOG ::::::::::::::::::::::::::::::::

/// common amountFormater

/// Show Text If No Data Found
Widget errorMessageWidget(message) {
  return Center(
    child: Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 30),
      child: Text(
        message,
        style: commonTextStyle(
          size: globalSize,
          fontSize: globalSize.width * numD04,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}

/// Smart Refresh

Widget commonRefresherFooter(context, mode) {
  Widget body;
  if (mode == LoadStatus.idle) {
    body = const Text("pull up load");
  } else if (mode == LoadStatus.loading) {
    body = const CircularProgressIndicator(
      color: colorThemePink,
    );
  } else if (mode == LoadStatus.failed) {
    body = const Text("Load Failed!Click retry!");
  } else if (mode == LoadStatus.canLoading) {
    body = const Text("release to load more");
  } else {
    body = const Text("No more Data");
  }
  return SizedBox(
    height: 55.0,
    child: Center(child: body),
  );
}

/// Show Loader
Widget showLoader({bool isForLocation = false}) {
  var size = MediaQuery.of(navigatorKey.currentContext!).size;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.max,
    children: [
      Center(
        child: Lottie.asset("assets/lottieFiles/loader_new.json",
            height: size.width * numD28, width: size.width * numD28),
      ),
      if (isForLocation) ...[
        SizedBox(height: size.width * numD005),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Text(
            "Please wait while we tring to fetch your location. Be with us.",
            textAlign: TextAlign.center,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * numD04,
                color: Colors.black,
                fontWeight: FontWeight.w500),
          ),
        ),
      ]
    ],
  );
}

Widget showAnimatedLoader(var size) {
  return Center(
      child: Lottie.asset("assets/lottieFiles/loader_new.json",
          height: size.width * numD25, width: size.width * numD25));
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
            colorScheme:
                const ColorScheme.light().copyWith(primary: colorThemePink)),
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
commonFilterIcon(Size size) {
  return Container(
      padding: EdgeInsets.all(size.width * (isIpad ? numD008 : numD043)),
      child: Image.asset(
        "assets/icons/newfilter.png",
        fit: BoxFit.fill,
      ));
}

/// aditya

/// aditya

/// aditya

Widget getMediaCountCard(String mediaType, int count, Size size) {
  return Container(
    width: size.width * numD11,
    padding: EdgeInsets.symmetric(vertical: size.width * numD01),
    decoration: BoxDecoration(
        color: colorLightGreen.withOpacity(0.8),
        borderRadius: BorderRadius.circular(size.width * numD021)),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.005,
        vertical: size.width * 0.005,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count ",
            style: commonTextStyle(
                size: size,
                fontSize: size.width * numD038,
                color: Colors.white,
                fontWeight: FontWeight.w600),
          ),
          const Padding(padding: EdgeInsets.only(left: 1.5)),
          Container(
            child: Image.asset(
              alignment: Alignment.center,
              mediaType == "image"
                  ? "${iconsPath}ic_camera_publish.png"
                  : mediaType == "video"
                      ? "${iconsPath}ic_v_cam.png"
                      : mediaType == "audio"
                          ? "${iconsPath}new_audio.png"
                          : "${iconsPath}doc_icon.png",
              color: Colors.white,
              height: mediaType == "image"
                  ? size.width * 0.029
                  : mediaType == "video"
                      ? size.width * 0.041
                      : mediaType == "audio"
                          ? size.width * 0.04
                          : size.width * 0.04,
            ),
          ),
        ],
      ),
    ),
  );
}

List<Widget> getMediaCount(List<ContentMediaData> contentMediaList, Size size) {
  final imageCount =
      contentMediaList.where((item) => item.mediaType == "image").length;
  final videoCount =
      contentMediaList.where((item) => item.mediaType == "video").length;
  final audioCount =
      contentMediaList.where((item) => item.mediaType == "audio").length;
  debugPrint("MediaCount $imageCount, $videoCount, $audioCount");
  final widgetList = <Widget>[];
  if (imageCount > 0) {
    widgetList.add(getMediaCountCard("image", imageCount, size));
    widgetList.add(SizedBox(height: 6));
  }
  if (videoCount > 0) {
    widgetList.add(getMediaCountCard("video", videoCount, size));
    widgetList.add(SizedBox(height: 6));
  }
  if (audioCount > 0) {
    widgetList.add(getMediaCountCard("audio", audioCount, size));
    widgetList.add(SizedBox(height: 6));
  }
  return widgetList;
}

List<Widget> getMediaCount2(List<dynamic> contentMediaList, Size size) {
  final imageCount =
      contentMediaList.where((item) => item.mediaType == "image").length;
  final videoCount =
      contentMediaList.where((item) => item.mediaType == "video").length;
  final audioCount =
      contentMediaList.where((item) => item.mediaType == "audio").length;
  debugPrint("MediaCount $imageCount, $videoCount, $audioCount");
  final widgetList = <Widget>[];
  if (imageCount > 0) {
    widgetList.add(getMediaCountCard("image", imageCount, size));
    widgetList.add(SizedBox(height: 6));
  }
  if (videoCount > 0) {
    widgetList.add(getMediaCountCard("video", videoCount, size));
    widgetList.add(SizedBox(height: 6));
  }
  if (audioCount > 0) {
    widgetList.add(getMediaCountCard("audio", audioCount, size));
    widgetList.add(SizedBox(height: 6));
  }
  return widgetList;
}
