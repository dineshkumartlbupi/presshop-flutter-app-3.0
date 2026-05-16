import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/widgets/video_widget.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/pages/audio_waveform_widget_screen.dart';
import 'package:presshop/features/camera/presentation/pages/preview_screen.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/earning/domain/entities/earning_transaction.dart';
import 'package:presshop/features/earning/presentation/pages/tansaction_detail_screen.dart';

class MediaPreviewScreen extends StatefulWidget {
  const MediaPreviewScreen({
    super.key,
    required this.mediaList,
    required this.onMediaUpdated,
    this.transactionData,
    this.type,
    this.pageType,
  });
  final List<MediaData> mediaList;
  final Function(List<MediaData>) onMediaUpdated;
  final EarningTransaction? transactionData;
  final String? type;
  final PageType? pageType;

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
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
                                horizontal: size.width * AppDimensions.numD04,
                                vertical: size.width * AppDimensions.numD02),
                            height: size.width * AppDimensions.numD18,
                            child: commonElevatedButton(
                                "Add more",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, Colors.black),
                                () async {
                              try {
                                final result = await context.pushNamed(
                                  AppRoutes.broadcastTaskMediaPickerName,
                                );
                                if (result != null &&
                                    result is List<CameraData> &&
                                    result.isNotEmpty &&
                                    mounted) {
                                  debugPrint(
                                      "Captured more from BroadcastTaskMediaPickerScreen: ${result.length} items");
                                  for (var cameraData in result) {
                                    // Avoid duplicates
                                    if (widget.mediaList.any((e) =>
                                        e.mediaPath.trim() ==
                                        cameraData.path.trim())) continue;

                                    widget.mediaList.insert(
                                      0,
                                      MediaData(
                                        isFromGallery: cameraData.fromGallary,
                                        dateTime: cameraData.dateTime,
                                        latitude: cameraData.latitude,
                                        location: cameraData.location,
                                        longitude: cameraData.longitude,
                                        country: cameraData.country,
                                        state: cameraData.state,
                                        city: cameraData.city,
                                        mediaPath: cameraData.path,
                                        mimeType: cameraData.mimeType == "image"
                                            ? (lookupMimeType(
                                                    cameraData.path) ??
                                                "image/jpeg")
                                            : cameraData.mimeType == "video"
                                                ? (lookupMimeType(
                                                        cameraData.path) ??
                                                    "video/mp4")
                                                : cameraData.mimeType == "audio"
                                                    ? (lookupMimeType(
                                                            cameraData.path) ??
                                                        "audio/mpeg")
                                                    : cameraData.mimeType,
                                        thumbnail: cameraData.videoImagePath,
                                      ),
                                    );
                                  }
                                  widget.onMediaUpdated(widget.mediaList);
                                  setState(() {});
                                }
                              } catch (e) {
                                debugPrint("Camera error: $e");
                              }
                            }),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * AppDimensions.numD04,
                                vertical: size.width * AppDimensions.numD02),
                            height: size.width * AppDimensions.numD18,
                            child: commonElevatedButton(
                                "Next",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink), () {
                              if (widget.transactionData != null) {
                                context.pushNamed(
                                  AppRoutes.transactionDetailName,
                                  extra: {
                                    'type': widget.type ?? "received",
                                    'pageType':
                                        widget.pageType ?? PageType.TASK,
                                    'transactionData': widget.transactionData,
                                    'shouldShowPublication': false,
                                  },
                                );
                              } else {
                                context.pop("upload");
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * AppDimensions.numD015,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              top: size.width * AppDimensions.numD1,
              right: size.width * AppDimensions.numD02,
              child: IconButton(
                  onPressed: () {
                    widget.mediaList.removeAt(currentPage);
                    widget.onMediaUpdated(widget.mediaList);
                    if (widget.mediaList.isEmpty) {
                      context.pop();
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
                    size: size.width * AppDimensions.numD07,
                  ))),
          Positioned(
              top: size.width * AppDimensions.numD1,
              left: size.width * AppDimensions.numD02,
              child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: size.width * AppDimensions.numD06,
                  ))),
        ],
      ),
    );
  }
}
