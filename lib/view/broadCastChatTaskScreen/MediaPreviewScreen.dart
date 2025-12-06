import 'dart:io';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/VideoWidget.dart';
import 'package:presshop/view/broadCastChatTaskScreen/broadCastChatTaskScreen.dart';
import 'package:presshop/view/cameraScreen/CameraScreen.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/commonEnums.dart';
import 'package:presshop/view/cameraScreen/AudioWaveFormWidgetScreen.dart';
import 'package:presshop/view/cameraScreen/PreviewScreen.dart';

class MediaPreviewScreen extends StatefulWidget {
  final List<MediaData> mediaList;
  final Function(List<MediaData>) onMediaUpdated;

  const MediaPreviewScreen({
    Key? key,
    required this.mediaList,
    required this.onMediaUpdated,
  }) : super(key: key);

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      onPageChanged: (value) {
                        setState(() {
                          currentPage = value;
                        });
                      },
                      itemBuilder: (context, index) {
                        var item = widget.mediaList[index];
                        debugPrint("type:::${item.mimeType}");
                        debugPrint("file:::${item.mediaPath}");
                        if (item.mimeType.startsWith('image')) {
                          return Container(
                            color: Colors.black,
                            child: Image.file(
                              File(item.mediaPath),
                              fit: item.isFromGallery
                                  ? BoxFit.contain
                                  : BoxFit.fill,
                              gaplessPlayback: true,
                            ),
                          );
                        } else if (item.mimeType.startsWith('video')) {
                          return VideoWidget(mediaData: item);
                        } else if (item.mimeType.startsWith('audio')) {
                          return AudioWaveFormWidgetScreen(
                              mediaPath: item.mediaPath);
                        }
                        return Container();
                      },
                      itemCount: widget.mediaList.length,
                    ),
                    widget.mediaList.isNotEmpty && widget.mediaList.length > 1
                        ? Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: DotsIndicator(
                              dotsCount: widget.mediaList.length,
                              position: currentPage,
                              decorator: const DotsDecorator(
                                color: Colors.grey, // Inactive color
                                activeColor: Colors.redAccent,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD04,
                                vertical: size.width * numD02),
                            height: size.width * numD18,
                            child: commonElevatedButton(
                                "Add more",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, Colors.black), () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CameraScreen(
                                            picAgain: true,
                                            previousScreen:
                                                ScreenNameEnum.manageTaskScreen,
                                          ))).then((value) {
                                if (value != null) {
                                  debugPrint(
                                      "value:::::$value::::::::${value.first.path}");
                                  List<CameraData> temData = value;
                                  temData.forEach((element) {
                                    widget.mediaList.insert(
                                      0,
                                      MediaData(
                                        isFromGallery: element.fromGallary,
                                        dateTime: "",
                                        latitude: "",
                                        location: "",
                                        longitude: "",
                                        mediaPath: element.path,
                                        mimeType: element.mimeType,
                                        thumbnail: "",
                                      ),
                                    );
                                  });
                                  widget.onMediaUpdated(widget.mediaList);
                                  setState(() {});
                                }
                              });
                            }),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD04,
                                vertical: size.width * numD02),
                            height: size.width * numD18,
                            child: commonElevatedButton(
                                "Next",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink), () {
                              Navigator.pop(context, "upload");
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * numD015,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              top: size.width * numD1,
              right: size.width * numD02,
              child: IconButton(
                  onPressed: () {
                    widget.mediaList.removeAt(currentPage);
                    widget.onMediaUpdated(widget.mediaList);
                    if (widget.mediaList.isEmpty) {
                      Navigator.pop(context);
                    } else {
                      if (currentPage >= widget.mediaList.length) {
                        currentPage = widget.mediaList.length - 1;
                      }
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    Icons.highlight_remove,
                    color: Colors.white,
                    size: size.width * numD07,
                  ))),
          Positioned(
              top: size.width * numD1,
              left: size.width * numD02,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: size.width * numD06,
                  ))),
        ],
      ),
    );
  }
}
