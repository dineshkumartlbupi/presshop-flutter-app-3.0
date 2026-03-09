import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/widgets/video_widget.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/pages/AudioWaveFormWidgetScreen.dart';

import 'package:path/path.dart' as path;
import 'package:presshop/features/camera/presentation/pages/PreviewScreen.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';

class ManageTaskPreviewScreen extends StatefulWidget {
  const ManageTaskPreviewScreen({super.key, required this.cameraListData});
  final List<CameraData> cameraListData;

  @override
  State<ManageTaskPreviewScreen> createState() =>
      _ManageTaskPreviewScreenState();
}

class _ManageTaskPreviewScreenState extends State<ManageTaskPreviewScreen> {
  int currentPage = 0;
  List<MediaData> mediaList = [];
  @override
  void initState() {
    addMediaDataList(widget.cameraListData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: PageView.builder(
                onPageChanged: (value) {
                  currentPage = value;
                  setState(() {});
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 2,
                    scaleEnabled:
                        mediaList[index].mimeType == "image" ? true : false,
                    child: Stack(
                      children: [
                        mediaList[index].mimeType.contains("video")
                            ? Align(
                                alignment: Alignment.center,
                                child: VideoWidget(mediaData: mediaList[index]),
                              )
                            : mediaList[index].mimeType.contains("audio")
                                ? AudioWaveFormWidgetScreen(
                                    mediaPath: mediaList[index].mediaPath,
                                  )
                                : mediaList[index].mimeType.contains("doc")
                                    ? Center(
                                        child: SizedBox(
                                          height:
                                              size.width * AppDimensions.numD60,
                                          width:
                                              size.width * AppDimensions.numD55,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                "${dummyImagePath}doc_black_icon.png",
                                                fit: BoxFit.contain,
                                                height: size.width *
                                                    AppDimensions.numD45,
                                              ),
                                              SizedBox(
                                                height: size.width *
                                                    AppDimensions.numD04,
                                              ),
                                              Text(
                                                path.basename(
                                                    mediaList[index].mediaPath),
                                                textAlign: TextAlign.center,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD03,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                maxLines: 2,
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    : mediaList[index].mimeType.contains("pdf")
                                        ? Center(
                                            child: SizedBox(
                                              height: size.width *
                                                  AppDimensions.numD60,
                                              width: size.width *
                                                  AppDimensions.numD55,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "${dummyImagePath}pngImage.png",
                                                    fit: BoxFit.contain,
                                                    height: size.width *
                                                        AppDimensions.numD45,
                                                  ),
                                                  SizedBox(
                                                    height: size.width *
                                                        AppDimensions.numD04,
                                                  ),
                                                  Text(
                                                    path.basename(
                                                        mediaList[index]
                                                            .mediaPath),
                                                    textAlign: TextAlign.center,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            AppDimensions
                                                                .numD03,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                    maxLines: 2,
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: size.height,
                                            width: size.width,
                                            child: Image.file(
                                              File(mediaList[index].mediaPath),
                                              fit: BoxFit.cover,
                                              gaplessPlayback: true,
                                            ),
                                          ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(
                                bottom: mediaList[index].mimeType == "video"
                                    ? size.width * AppDimensions.numD08
                                    : 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * AppDimensions.numD06,
                                vertical: size.width * AppDimensions.numD04),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.center,
                                      height: size.width * AppDimensions.numD11,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_clock.png",
                                            width: size.width *
                                                AppDimensions.numD04,
                                            height: size.width *
                                                AppDimensions.numD04,
                                          ),
                                          SizedBox(
                                            width: size.width *
                                                AppDimensions.numD02,
                                          ),
                                          Text(
                                            mediaList[index].dateTime,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD025,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          )
                                        ],
                                      )),
                                ),
                                SizedBox(
                                  width: size.width * AppDimensions.numD04,
                                ),
                                Expanded(
                                  child: Container(
                                      height: size.width * AppDimensions.numD11,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_location.png",
                                            width: size.width *
                                                AppDimensions.numD04,
                                            height: size.width *
                                                AppDimensions.numD04,
                                          ),
                                          SizedBox(
                                            width: size.width *
                                                AppDimensions.numD02,
                                          ),
                                          SizedBox(
                                            width: size.width *
                                                AppDimensions.numD25,
                                            child: Text(
                                              mediaList[index].location,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width *
                                                      AppDimensions.numD025,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                        !mediaList[index].mimeType.contains("audio")
                            ? Positioned(
                                top: 0,
                                bottom:
                                    mediaList[index].mimeType.contains("video")
                                        ? size.width * AppDimensions.numD08
                                        : 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                    child: Image.asset(
                                      "${commonImagePath}watermark1.png",
                                      fit: BoxFit.cover,
                                    )))
                            : Container(),
                        Positioned(
                          top: size.width * AppDimensions.numD1,
                          right: size.width * AppDimensions.numD04,
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD01),
                              child: Icon(
                                Icons.close,
                                color: Colors.black,
                                size: size.width * AppDimensions.numD05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: mediaList.length,
              ),
            ),
            mediaList.isNotEmpty && mediaList.length > 1
                ? DotsIndicator(
                    dotsCount: mediaList.length,
                    position: currentPage,
                    decorator: const DotsDecorator(
                      color: Colors.grey, // Inactive color
                      activeColor: Colors.redAccent,
                    ),
                  )
                : Container(),
            SizedBox(
              height: size.width * AppDimensions.numD02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: size.width * AppDimensions.numD14,
                      child: commonElevatedButton(
                          "Add More",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, Colors.black), () {
                        context.pushNamed(AppRoutes.cameraName, extra: {
                          'picAgain': true,
                          'previousScreen':
                              ScreenNameEnum.manageTaskPreviewScreen,
                        }).then((value) {
                          debugPrint(
                              ":::: Inside Picked Again Image :::: $value");
                          if (value != null) {
                            addMediaDataList(value as List<CameraData>);
                          }
                        });
                      }),
                    ),
                  ),
                  SizedBox(width: size.width * AppDimensions.numD04),
                  Expanded(
                    child: SizedBox(
                      height: size.width * AppDimensions.numD14,
                      child: commonElevatedButton(
                          "Next",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, AppColorTheme.colorThemePink),
                          () {
                        //  getImageMetaData();
                      }),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.width * AppDimensions.numD04,
            ),
          ],
        ),
      ),
    );
  }

  Future addMediaDataList(List<CameraData> cDataList) async {
    if (cDataList.isNotEmpty) {
      for (var element in cDataList) {
        mediaList.add(MediaData(
            mediaPath: element.path,
            mimeType: element.mimeType,
            thumbnail: element.videoImagePath,
            location: element.location,
            dateTime: element.dateTime.toString(),
            latitude: element.latitude,
            longitude: element.longitude,
            country: element.country,
            state: element.state,
            city: element.city,
            isFromGallery: element.fromGallary,
            isLocalMedia: true));
        debugPrint(" path ======> : ${element.path}");
        debugPrint("MedListSize: ${mediaList.length}");
        setState(() {});
      }
    }
  }
}
