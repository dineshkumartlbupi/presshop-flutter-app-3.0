import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/video_thumbnail_widget.dart';
import 'package:presshop/features/content/domain/entities/content_item.dart';

class ContentItemWidget extends StatelessWidget {
  const ContentItemWidget({
    super.key,
    required this.item,
    required this.size,
    required this.onTap,
  });
  final ContentItem item;
  final Size size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double scalingWidth = isIpad ? 550 : size.width;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: scalingWidth * AppDimensions.numD03,
          right: scalingWidth * AppDimensions.numD03,
          top: scalingWidth * AppDimensions.numD03,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 1,
              ),
          ],
          borderRadius: BorderRadius.circular(
            scalingWidth * AppDimensions.numD04,
          ),
        ),
        child: Column(
          children: [
            MediaThumbnailWidget(
                item: item, size: size, scalingWidth: scalingWidth),
            SizedBox(height: scalingWidth * AppDimensions.numD02),
            _buildInfoRow(context, scalingWidth),
            const Spacer(),
            _buildStatusRow(context, scalingWidth),
            SizedBox(height: scalingWidth * AppDimensions.numD02),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, double scalingWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.status.toLowerCase() == "pending" ||
                    item.status.toLowerCase() == "rejected"
                ? item.description
                : item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: commonTextStyle(
              size: size,
              fontSize: scalingWidth * AppDimensions.numD03,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: scalingWidth * AppDimensions.numD01),
        Image.asset(
          (item.isExclusive ?? false)
              ? "${iconsPath}ic_exclusive.png"
              : "${iconsPath}ic_share.png",
          height: (item.isExclusive ?? false)
              ? scalingWidth * AppDimensions.numD03
              : scalingWidth * AppDimensions.numD04,
          color: AppColorTheme.colorTextFieldIcon,
        ),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, double scalingWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricsColumn(scalingWidth),
        _buildPriceBadge(context, scalingWidth)
      ],
    );
  }

  Widget _buildMetricsColumn(double scalingWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricItem(
          scalingWidth: scalingWidth,
          icon: "dollar1.png",
          value: "${item.purchasedMediahouseCount} ${AppStrings.soldText}",
          isActive: item.purchasedMediahouseCount > 0,
        ),
        SizedBox(height: scalingWidth * AppDimensions.numD01),
        _buildMetricItem(
          scalingWidth: scalingWidth,
          icon: "dollar1.png",
          value:
              "${item.totalOffer} ${item.totalOffer > 1 ? '${AppStrings.offerText}s' : AppStrings.offerText}",
          isActive: item.totalOffer > 0,
        ),
        SizedBox(height: scalingWidth * AppDimensions.numD01),
        _buildMetricItem(
          scalingWidth: scalingWidth,
          icon: "ic_view.png",
          value:
              "${item.totalView} ${item.totalView > 1 ? '${AppStrings.viewsText}s' : AppStrings.viewsText}",
          isActive: item.totalView > 0,
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required double scalingWidth,
    required String icon,
    required String value,
    required bool isActive,
  }) {
    return Row(
      children: [
        Image.asset(
          "$iconsPath$icon",
          height: scalingWidth * AppDimensions.numD025,
          width: scalingWidth * AppDimensions.numD025,
          color: isActive ? AppColorTheme.colorThemePink : Colors.grey,
        ),
        SizedBox(width: scalingWidth * AppDimensions.numD014),
        Text(
          value,
          style: commonTextStyle(
            size: size,
            fontSize: scalingWidth * AppDimensions.numD026,
            color: isActive ? AppColorTheme.colorThemePink : Colors.grey,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBadge(BuildContext context, double scalingWidth) {
    bool isPendingOrRejected = item.status.toLowerCase() == "pending" ||
        item.status.toLowerCase() == "rejected";

    if (isPendingOrRejected) {
      return Container(
        padding: EdgeInsets.all(scalingWidth * AppDimensions.numD01),
        constraints: BoxConstraints(
          minWidth: scalingWidth * AppDimensions.numD17,
        ),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
            scalingWidth * AppDimensions.numD015,
          ),
        ),
        child: Center(
          child: Text(
            item.status.toLowerCase() == "pending"
                ? "Under\nReview"
                : "Not\nApproved",
            textAlign: TextAlign.center,
            style: commonTextStyle(
              size: size,
              fontSize: scalingWidth * AppDimensions.numD024,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scalingWidth * AppDimensions.numD015,
        vertical: scalingWidth * AppDimensions.numD01,
      ),
      decoration: BoxDecoration(
        color: item.paidStatus == false
            ? AppColorTheme.colorThemePink
            : AppColorTheme.colorLightGrey,
        borderRadius:
            BorderRadius.circular(scalingWidth * AppDimensions.numD015),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: item.paidStatus && !item.isPaidStatusToHopper
                ? EdgeInsets.symmetric(
                    horizontal: scalingWidth * AppDimensions.numD028,
                  )
                : EdgeInsets.zero,
            child: Text(
              !item.paidStatus
                  ? item.status.toCapitalized()
                  : item.paidStatus && item.isPaidStatusToHopper
                      ? "Received"
                      : "Sold",
              textAlign: TextAlign.center,
              style: commonTextStyle(
                size: size,
                fontSize: scalingWidth * AppDimensions.numD022,
                color: item.paidStatus == false
                    ? Colors.white
                    : (Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            "${item.currencySymbol.isNotEmpty ? item.currencySymbol : getCurrencySymbol(item.currency)}${formatDouble(double.tryParse(item.paidStatus == false ? (item.price ?? '0') : item.totalSold) ?? 0.0)}",
            textAlign: TextAlign.center,
            style: commonTextStyle(
              size: size,
              fontSize: scalingWidth * AppDimensions.numD022,
              color: item.paidStatus == false
                  ? Colors.white
                  : (Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MediaThumbnailWidget extends StatelessWidget {
  const MediaThumbnailWidget({
    super.key,
    required this.item,
    required this.size,
    required this.scalingWidth,
  });
  final ContentItem item;
  final Size size;
  final double scalingWidth;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(scalingWidth * AppDimensions.numD04),
        child: Stack(
          children: [
            _buildMediaContent(),
            if (item.mediaUrls.isNotEmpty)
              Image.asset(
                "${commonImagePath}watermark1.png",
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                // Cache the watermark image for better performance
                cacheWidth: (size.width * 2).toInt(),
              ),
            if (item.mediaUrls.length >= 1)
              Positioned(
                right: scalingWidth * AppDimensions.numD02,
                top: scalingWidth * AppDimensions.numD02,
                child: _buildCountBadge(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (item.mediaUrls.isEmpty) {
      return Container(
        decoration: const BoxDecoration(color: AppColorTheme.colorLightGrey),
        alignment: Alignment.center,
        child: Image.asset(
          "${commonImagePath}rabbitLogo.png",
          height: scalingWidth * AppDimensions.numD15,
          width: scalingWidth * AppDimensions.numD15,
          fit: BoxFit.contain,
        ),
      );
    }

    final firstMedia = item.mediaList.isNotEmpty ? item.mediaList.first : null;
    final isVideo = item.mediaType == 'video' ||
        (firstMedia?.mediaType.toLowerCase() == 'video');
    final isAudio = item.mediaType == 'audio' ||
        (firstMedia?.mediaType.toLowerCase() == 'audio');

    if (isVideo) {
      return VideoThumbnailWidget(
        videoUrl: getMediaImageUrl(item.mediaUrls.first, isVideo: true),
        thumbnailUrl: firstMedia?.thumbnailUrl.isNotEmpty == true
            ? fixS3Url(firstMedia!.thumbnailUrl)
            : null,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    // Try to show thumbnail from metadata if it looks like a valid image
    if (firstMedia != null &&
        firstMedia.thumbnailUrl.isNotEmpty &&
        !firstMedia.thumbnailUrl.toLowerCase().endsWith('.m4a') &&
        !firstMedia.thumbnailUrl.toLowerCase().endsWith('.mp3')) {
      return CachedNetworkImage(
        imageUrl: fixS3Url(firstMedia.thumbnailUrl),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildLightweightPlaceholder(),
        errorWidget: (_, __, ___) => _showImage(
          isAudio ? 'audio' : (item.mediaType ?? 'photo'),
          item.mediaUrls.first,
        ),
      );
    }

    final effectiveType =
        isAudio ? 'audio' : (isVideo ? 'video' : (item.mediaType ?? 'photo'));

    return _showImage(effectiveType, item.mediaUrls.first);
  }

  Widget _buildCountBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scalingWidth * AppDimensions.numD015,
        vertical: scalingWidth * 0.005,
      ),
      decoration: BoxDecoration(
        color: AppColorTheme.colorLightGreen.withValues(alpha: 0.8),
        borderRadius:
            BorderRadius.circular(scalingWidth * AppDimensions.numD015),
      ),
      child: Center(
        child: Text(
          "${(item.audioCount ?? 0) + (item.videoCount ?? 0) + (item.imageCount ?? 0) + (item.otherCount ?? 0)} ",
          textAlign: TextAlign.center,
          style: commonTextStyle(
            size: size,
            fontSize: scalingWidth * AppDimensions.numD038,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _showImage(String type, String url) {
    switch (type) {
      case "video":
        return VideoThumbnailWidget(
          videoUrl: getMediaImageUrl(url, isVideo: true),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      case "audio":
        return _buildPlaceholder(
          color: AppColorTheme.colorThemePink,
          child: Icon(
            Icons.play_arrow_rounded,
            size: scalingWidth * AppDimensions.numD15,
            color: Colors.white,
          ),
        );
      case "pdf":
        return _buildPlaceholder(
          child: Image.asset(
            "${dummyImagePath}pngImage.png",
            width: scalingWidth * AppDimensions.numD03,
            height: scalingWidth * AppDimensions.numD03,
          ),
        );
      case "doc":
        return _buildPlaceholder(
          child: Image.asset(
            "${dummyImagePath}doc_black_icon.png",
            width: scalingWidth * AppDimensions.numD03,
            height: scalingWidth * AppDimensions.numD03,
          ),
        );
      default:
        return CachedNetworkImage(
          imageUrl: getMediaImageUrl(url, isVideo: type == 'video'),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          memCacheWidth: (size.width * 2).toInt(),
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          placeholder: (_, __) => _buildLightweightPlaceholder(),
          errorWidget: (_, __, ___) => _buildLightweightPlaceholder(),
        );
    }
  }

  Widget _buildPlaceholder({Color? color, required Widget child}) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColorTheme.colorHint),
        borderRadius:
            BorderRadius.circular(scalingWidth * AppDimensions.numD04),
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(scalingWidth * AppDimensions.numD04),
        child: Padding(
          padding: EdgeInsets.all(scalingWidth * AppDimensions.numD03),
          child: child,
        ),
      ),
    );
  }

  // Lightweight placeholder using simple Container instead of loading PNG asset
  Widget _buildLightweightPlaceholder() {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColorTheme.colorLightGrey),
      child: Center(
        child: Image.asset(
          "${commonImagePath}rabbitLogo.png",
          height: scalingWidth * AppDimensions.numD15,
          width: scalingWidth * AppDimensions.numD15,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
