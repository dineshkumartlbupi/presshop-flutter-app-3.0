import 'dart:io';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:presshop/utils/commonEnums.dart';

import '../../utils/Common.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/VideoWidget.dart';
import '../cameraScreen/AudioWaveFormWidgetScreen.dart';
import '../cameraScreen/CameraScreen.dart';
import '../cameraScreen/PreviewScreen.dart';
import 'package:path/path.dart' as path;

class ManageTaskPreviewScreen extends StatefulWidget {
  final List<CameraData> cameraListData;
  const ManageTaskPreviewScreen({super.key, required this.cameraListData});

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
                                          height: size.width * numD60,
                                          width: size.width * numD55,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                "${dummyImagePath}doc_black_icon.png",
                                                fit: BoxFit.contain,
                                                height: size.width * numD45,
                                              ),
                                              SizedBox(
                                                height: size.width * numD04,
                                              ),
                                              Text(
                                                path.basename(
                                                    mediaList[index].mediaPath),
                                                textAlign: TextAlign.center,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD03,
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
                                              height: size.width * numD60,
                                              width: size.width * numD55,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    "${dummyImagePath}pngImage.png",
                                                    fit: BoxFit.contain,
                                                    height: size.width * numD45,
                                                  ),
                                                  SizedBox(
                                                    height: size.width * numD04,
                                                  ),
                                                  Text(
                                                    path.basename(
                                                        mediaList[index]
                                                            .mediaPath),
                                                    textAlign: TextAlign.center,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize:
                                                            size.width * numD03,
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
                                    ? size.width * numD08
                                    : 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD06,
                                vertical: size.width * numD04),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      alignment: Alignment.center,
                                      height: size.width * numD11,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_clock.png",
                                            width: size.width * numD04,
                                            height: size.width * numD04,
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Text(
                                            mediaList[index].dateTime,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD025,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          )
                                        ],
                                      )),
                                ),
                                SizedBox(
                                  width: size.width * numD04,
                                ),
                                Expanded(
                                  child: Container(
                                      height: size.width * numD11,
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_location.png",
                                            width: size.width * numD04,
                                            height: size.width * numD04,
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          SizedBox(
                                            width: size.width * numD25,
                                            child: Text(
                                              mediaList[index].location,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD025,
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
                                        ? size.width * numD08
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
                          top: size.width * numD1,
                          right: size.width * numD04,
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              padding: EdgeInsets.all(size.width * numD01),
                              child: Icon(
                                Icons.close,
                                color: Colors.black,
                                size: size.width * numD05,
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
                    position: currentPage.toDouble(),
                    decorator: const DotsDecorator(
                      color: Colors.grey, // Inactive color
                      activeColor: Colors.redAccent,
                    ),
                  )
                : Container(),
            SizedBox(
              height: size.width * numD02,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: size.width * numD14,
                      child: commonElevatedButton(
                          "Add More",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, Colors.black), () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => CameraScreen(
                                      picAgain: true,
                                      previousScreen: ScreenNameEnum
                                          .manageTaskPreviewScreen,
                                    )))
                            .then((value) {
                          debugPrint(
                              ":::: Inside Picked Again Image :::: $value");
                          if (value != null) {
                            addMediaDataList(value);
                          }
                        });
                      }),
                    ),
                  ),
                  SizedBox(width: size.width * numD04),
                  Expanded(
                    child: SizedBox(
                      height: size.width * numD14,
                      child: commonElevatedButton(
                          "Next",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        //  getImageMetaData();
                      }),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.width * numD04,
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
            longitude: element.longitude));
        debugPrint(" path ======> : ${element.path}");
        debugPrint("MedListSize: ${mediaList.length}");
        setState(() {});
      }
    }
  }
}
