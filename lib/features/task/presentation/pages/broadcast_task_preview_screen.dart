import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dots_indicator/dots_indicator.dart';
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

class BroadcastTaskPreviewScreen extends StatefulWidget {
  final List<MediaData> mediaList;
  final Function(List<MediaData>) onMediaUpdated;
  final EarningTransaction? transactionData;
  final String? type;
  final PageType? pageType;

  const BroadcastTaskPreviewScreen({
    super.key,
    required this.mediaList,
    required this.onMediaUpdated,
    this.transactionData,
    this.type,
    this.pageType,
  });

  @override
  State<BroadcastTaskPreviewScreen> createState() =>
      _BroadcastTaskPreviewScreenState();
}

class _BroadcastTaskPreviewScreenState
    extends State<BroadcastTaskPreviewScreen> {
  int currentPage = 0;
  late List<MediaData> _currentMediaList;

  @override
  void initState() {
    super.initState();
    _currentMediaList = List.from(widget.mediaList);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CommonBrandedAppBar(
          title: 'Preview Content', size: size, showLogo: true),
      body: Column(
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
                  itemCount: _currentMediaList.length,
                  itemBuilder: (context, index) {
                    var item = _currentMediaList[index];
                    if (item.mimeType.startsWith('image')) {
                      return InteractiveViewer(
                        child: Center(
                          child: Image.file(
                            File(item.mediaPath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    } else if (item.mimeType.startsWith('video')) {
                      return Center(child: VideoWidget(mediaData: item));
                    } else if (item.mimeType.startsWith('audio')) {
                      return Center(
                        child: AudioWaveFormWidgetScreen(
                            mediaPath: item.mediaPath),
                      );
                    }
                    return InkWell(
                      onTap: () {
                        context.pushNamed(AppRoutes.docViewerName, extra: {
                          "path": item.mediaPath,
                        });
                      },
                      child: Center(
                        child: Image.asset(
                          '${dummyImagePath}pngImage.png',
                          height: 120,
                        ),
                      ),
                    );
                  },
                ),
                if (_currentMediaList.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: DotsIndicator(
                        dotsCount: _currentMediaList.length,
                        position: currentPage,
                        decorator: DotsDecorator(
                          color: Colors.black.withOpacity(0.3),
                          activeColor: AppColorTheme.colorThemePink,
                        ),
                      ),
                    ),
                  ),
                if (_currentMediaList.isNotEmpty)
                  Positioned(
                    top: 5,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _currentMediaList.removeAt(currentPage);
                          if (_currentMediaList.isEmpty) {
                            context.pop();
                          } else if (currentPage >= _currentMediaList.length) {
                            currentPage = _currentMediaList.length - 1;
                          }
                          widget.onMediaUpdated(_currentMediaList);
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          _buildBottomButtons(context, size),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, Size size) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(size.width * AppDimensions.numD04),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          // borderRadius: BorderRadius.only(
          //   topLeft: Radius.circular(size.width * AppDimensions.numD06),
          //   topRight: Radius.circular(size.width * AppDimensions.numD06),
          // ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: size.width * AppDimensions.numD14,
                    child: commonElevatedButton(
                      "Add More",
                      size,
                      commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD04,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      commonButtonStyle(size, Colors.black),
                      () async {
                        final result = await context.pushNamed(
                          AppRoutes.broadcastTaskMediaPickerName,
                        );
                        if (result != null &&
                            result is List<CameraData> &&
                            result.isNotEmpty) {
                          setState(() {
                            for (var cameraData in result) {
                              if (_currentMediaList.any((MediaData e) =>
                                  e.mediaPath == cameraData.path)) continue;
                              _currentMediaList.add(
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
                                  mimeType: _getMimeType(cameraData),
                                  thumbnail: cameraData.videoImagePath,
                                ),
                              );
                            }
                            widget.onMediaUpdated(_currentMediaList);
                          });
                        }
                      },
                    ),
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
                        fontSize: size.width * AppDimensions.numD04,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      commonButtonStyle(size, AppColorTheme.colorThemePink),
                      () {
                        if (widget.transactionData != null) {
                          context.pushNamed(
                            AppRoutes.transactionDetailName,
                            extra: {
                              'type': widget.type ?? "received",
                              'pageType': widget.pageType ?? PageType.TASK,
                              'transactionData': widget.transactionData,
                              'shouldShowPublication': false,
                            },
                          );
                        } else {
                          context.pop("upload");
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMimeType(CameraData cameraData) {
    if (cameraData.mimeType == "image") {
      return lookupMimeType(cameraData.path) ?? "image/jpeg";
    } else if (cameraData.mimeType == "video") {
      return lookupMimeType(cameraData.path) ?? "video/mp4";
    } else if (cameraData.mimeType == "audio") {
      return lookupMimeType(cameraData.path) ?? "audio/mpeg";
    }
    return cameraData.mimeType;
  }
}
