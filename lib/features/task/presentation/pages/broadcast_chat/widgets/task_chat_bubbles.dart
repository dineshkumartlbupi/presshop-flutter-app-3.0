import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/core/services/media_upload_service.dart';
import 'package:presshop/main.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/features/chat/presentation/pages/FullVideoView.dart';

class MediaUploadProgress {
  final double progress;
  final String status;

  MediaUploadProgress({required this.progress, required this.status});
}

class MediaHouseAvatar extends StatelessWidget {
  const MediaHouseAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          "${commonImagePath}rabbitLogo.png",
          height: size.width * AppDimensions.numD10,
          width: size.width * AppDimensions.numD10,
        ),
      ),
    );
  }
}

class HopperAvatar extends StatelessWidget {
  const HopperAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    String avatarUrl =
        sharedPreferences?.getString(SharedPreferencesKeys.avatarKey) ?? "";
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                height: size.width * AppDimensions.numD10,
                width: size.width * AppDimensions.numD10,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * AppDimensions.numD10,
                    width: size.width * AppDimensions.numD10,
                  );
                },
              )
            : Image.asset(
                "${commonImagePath}rabbitLogo.png",
                height: size.width * AppDimensions.numD10,
                width: size.width * AppDimensions.numD10,
              ),
      ),
    );
  }
}

class LeftTextChatBubble extends StatelessWidget {
  final ManageTaskChatModel item;

  const LeftTextChatBubble({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MediaHouseAvatar(),
        SizedBox(width: size.width * AppDimensions.numD04),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(size.width * AppDimensions.numD04),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              ),
            ),
            child: Text(
              item.message,
              style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD036,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RightMediaChatBubble extends StatelessWidget {
  final ManageTaskChatModel item;
  final String address;
  final String? currentUploadingLocalTaskId;

  const RightMediaChatBubble({
    super.key,
    required this.item,
    required this.address,
    this.currentUploadingLocalTaskId,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                  ),
                  child: Stack(
                    children: [
                      _buildMediaContent(context, size),
                      _buildUploadOverlay(
                          size,
                          BorderRadius.circular(
                              size.width * AppDimensions.numD04)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.width * AppDimensions.numD02),
              _buildMediaInfo(size),
            ],
          ),
        ),
        SizedBox(width: size.width * AppDimensions.numD04),
        const HopperAvatar(),
      ],
    );
  }

  Widget _buildMediaContent(BuildContext context, Size size) {
    if (item.media?.type.contains("video") ?? false) {
      return rightVideoChatWidget(item, size, context);
    } else if (item.media?.type.contains("audio") ?? false) {
      return rightAudioChatWidget(item, size, context);
    } else {
      return rightImageChatWidget(item, size);
    }
  }

  Widget _buildUploadOverlay(Size size, BorderRadius radius) {
    if (!item.isLocalUpload) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: radius,
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(size.width * AppDimensions.numD02),
            child: ValueListenableBuilder(
              valueListenable: MediaUploadService.uploadStatus,
              builder: (context, status, child) {
                bool isCurrentUpload =
                    currentUploadingLocalTaskId == item.id && status != null;
                double progress = isCurrentUpload
                    ? (status['progress'] as num).toDouble()
                    : item.uploadProgress.toDouble();

                String uploadStatus = isCurrentUpload
                    ? (status['status'] as String)
                    : item.uploadStatus;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD02,
                    vertical: size.width * AppDimensions.numD015,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(
                      size.width * AppDimensions.numD05,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        color: Colors.white,
                        size: size.width * AppDimensions.numD04,
                      ),
                      SizedBox(width: size.width * AppDimensions.numD02),
                      SizedBox(
                        width: size.width * AppDimensions.numD04,
                        height: size.width * AppDimensions.numD04,
                        child: CircularProgressIndicator(
                          value: uploadStatus == 'processing'
                              ? null
                              : progress / 100,
                          strokeWidth: 2,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * AppDimensions.numD02),
                      Text(
                        uploadStatus == 'processing'
                            ? 'Processing'
                            : '${progress.toInt()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * AppDimensions.numD035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaInfo(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          dateTimeFormatter(dateTime: item.createdAtTime, format: "hh:mm a"),
          style: commonTextStyle(
            size: size,
            fontSize: size.width * AppDimensions.numD028,
            color: AppColorTheme.colorHint,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(width: size.width * AppDimensions.numD018),
        Image.asset("${iconsPath}ic_location.png",
            height: size.width * AppDimensions.numD035, color: Colors.black),
        SizedBox(width: size.width * AppDimensions.numD01),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(right: size.width * AppDimensions.numD13),
            child: Text(
              address.isNotEmpty ? address : "N/A",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD028,
                color: AppColorTheme.colorHint,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget rightVideoChatWidget(
      ManageTaskChatModel item, Size size, BuildContext context) {
    var mediaItem = item.mediaList.isNotEmpty ? item.mediaList.first : null;
    if (mediaItem == null) return Container();

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        context.pushNamed(
          AppRoutes.fullVideoViewName,
          extra: {
            'mediaFile': mediaItem.imageVideoUrl,
            'type': MediaTypeEnum.video,
          },
        );
      },
      child: Container(
        height: size.height / 3,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                mediaItem.thumbnail.isNotEmpty
                    ? mediaItem.thumbnail
                    : getMediaImageUrl(
                        mediaItem.imageVideoUrl,
                        isVideo: true,
                        isTask: true,
                      ),
                height: size.height / 3,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, s, o) => Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.height / 3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: size.width * AppDimensions.numD02,
                left: size.width * AppDimensions.numD02,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD006,
                    vertical: size.width * AppDimensions.numD002,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorTheme.colorLightGreen.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(
                      size.width * AppDimensions.numD01,
                    ),
                  ),
                  child: const Icon(
                    Icons.videocam_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.play_circle,
                color: Colors.white,
                size: size.width * AppDimensions.numD09,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget rightImageChatWidget(ManageTaskChatModel item, Size size) {
    var mediaItem = item.mediaList.isNotEmpty ? item.mediaList.first : null;
    if (mediaItem == null) return Container();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorTheme.colorGreyChat,
        borderRadius: BorderRadius.circular(
          size.width * AppDimensions.numD04,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          size.width * AppDimensions.numD04,
        ),
        child: Stack(
          children: [
            Image.network(
              getMediaImageUrl(mediaItem.imageVideoUrl, isTask: true),
              height: size.height / 3,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, exception, stackTrace) => Center(
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.height / 3,
                  width: size.width / 1.7,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: size.width * AppDimensions.numD02,
              left: size.width * AppDimensions.numD02,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD01,
                ),
                decoration: BoxDecoration(
                  color: AppColorTheme.colorLightGreen.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(
                    size.width * AppDimensions.numD01,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
              ),
            ),
            Image.asset(
              "${commonImagePath}watermark1.png",
              height: size.height / 3,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  Widget rightAudioChatWidget(
      ManageTaskChatModel item, Size size, BuildContext context) {
    var mediaItem = item.mediaList.isNotEmpty ? item.mediaList.first : null;
    if (mediaItem == null) return Container();

    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoutes.fullVideoViewName,
          extra: {
            'mediaFile': mediaItem.imageVideoUrl,
            'type': MediaTypeEnum.audio
          },
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              size.width * AppDimensions.numD04,
            ),
            child: Container(
              color: AppColorTheme.colorThemePink,
              height: size.height / 3,
              width: double.infinity,
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: size.width * AppDimensions.numD18,
              ),
            ),
          ),
          Positioned(
            top: size.width * AppDimensions.numD02,
            left: size.width * AppDimensions.numD02,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD008,
                vertical: size.width * AppDimensions.numD005,
              ),
              decoration: BoxDecoration(
                color: AppColorTheme.colorLightGreen.withOpacity(0.8),
                borderRadius: BorderRadius.circular(
                  size.width * AppDimensions.numD01,
                ),
              ),
              child: Image.asset(
                "${iconsPath}ic_mic1.png",
                fit: BoxFit.cover,
                height: size.width * AppDimensions.numD05,
                width: size.width * AppDimensions.numD05,
              ),
            ),
          ),
          Image.asset(
            "${commonImagePath}watermark1.png",
            height: size.height / 3,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

class UploadingCircleWithPercentageWidget extends StatelessWidget {
  final double progress;
  final Size size;

  const UploadingCircleWithPercentageWidget({
    super.key,
    required this.progress,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: size.width * AppDimensions.numD15,
          width: size.width * AppDimensions.numD15,
          child: CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: 6,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        Text(
          "${progress.toInt()}%",
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * AppDimensions.numD035,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
