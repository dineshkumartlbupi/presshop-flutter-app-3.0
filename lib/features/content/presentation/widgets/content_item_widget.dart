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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: size.width * AppDimensions.numD03,
          right: size.width * AppDimensions.numD03,
          top: size.width * AppDimensions.numD03,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              spreadRadius: 2,
              blurRadius: 1,
            )
          ],
          borderRadius:
              BorderRadius.circular(size.width * AppDimensions.numD04),
        ),
        child: Column(
          children: [
            MediaThumbnailWidget(item: item, size: size),
            SizedBox(height: size.width * AppDimensions.numD02),
            _buildInfoRow(),
            const Spacer(),
            _buildStatusRow(),
            SizedBox(height: size.width * AppDimensions.numD02),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
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
              fontSize: size.width * AppDimensions.numD03,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: size.width * AppDimensions.numD01),
        Image.asset(
          (item.isExclusive ?? false)
              ? "${iconsPath}ic_exclusive.png"
              : "${iconsPath}ic_share.png",
          height: (item.isExclusive ?? false)
              ? size.width * AppDimensions.numD03
              : size.width * AppDimensions.numD04,
          color: AppColorTheme.colorTextFieldIcon,
        )
      ],
    );
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricsColumn(),
        _buildPriceBadge(),
      ],
    );
  }

  Widget _buildMetricsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricItem(
          icon: "dollar1.png",
          value: "${item.purchasedMediahouseCount} ${AppStrings.soldText}",
          isActive: item.purchasedMediahouseCount > 0,
        ),
        SizedBox(height: size.width * AppDimensions.numD01),
        _buildMetricItem(
          icon: "dollar1.png",
          value:
              "${item.totalOffer} ${item.totalOffer > 1 ? '${AppStrings.offerText}s' : AppStrings.offerText}",
          isActive: item.totalOffer > 0,
        ),
        SizedBox(height: size.width * AppDimensions.numD01),
        _buildMetricItem(
          icon: "ic_view.png",
          value:
              "${item.totalView} ${item.totalView > 1 ? '${AppStrings.viewsText}s' : AppStrings.viewsText}",
          isActive: item.totalView > 0,
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String icon,
    required String value,
    required bool isActive,
  }) {
    return Row(
      children: [
        Image.asset(
          "$iconsPath$icon",
          height: size.width * AppDimensions.numD025,
          width: size.width * AppDimensions.numD025,
          color: isActive ? AppColorTheme.colorThemePink : Colors.grey,
        ),
        SizedBox(width: size.width * AppDimensions.numD014),
        Text(
          value,
          style: commonTextStyle(
            size: size,
            fontSize: size.width * AppDimensions.numD026,
            color: isActive ? AppColorTheme.colorThemePink : Colors.grey,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBadge() {
    bool isPendingOrRejected = item.status.toLowerCase() == "pending" ||
        item.status.toLowerCase() == "rejected";

    if (isPendingOrRejected) {
      return Container(
        height: size.height * AppDimensions.numD036,
        width: size.width * AppDimensions.numD17,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:
              BorderRadius.circular(size.width * AppDimensions.numD015),
        ),
        child: Center(
          child: Text(
            item.status.toLowerCase() == "pending"
                ? "Under\nReview"
                : "Not\nApproved",
            textAlign: TextAlign.center,
            style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD024,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Container(
      height: size.width * AppDimensions.numD08,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * AppDimensions.numD015,
        vertical: size.width * AppDimensions.numD01,
      ),
      decoration: BoxDecoration(
        color: item.paidStatus == false
            ? AppColorTheme.colorThemePink
            : AppColorTheme.colorLightGrey,
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD015),
      ),
      child: Column(
        children: [
          Padding(
            padding: item.paidStatus && !item.isPaidStatusToHopper
                ? EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD028)
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
                fontSize: size.width * AppDimensions.numD022,
                color: item.paidStatus == false ? Colors.white : Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            "${item.currencySymbol.isNotEmpty ? item.currencySymbol : getCurrencySymbol(item.currency)}${formatDouble(double.tryParse(item.paidStatus == false ? (item.price ?? '0') : item.totalSold) ?? 0.0)}",
            textAlign: TextAlign.center,
            style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD022,
              color: item.paidStatus == false ? Colors.white : Colors.black,
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
  });
  final ContentItem item;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.width * AppDimensions.numD04),
      child: Stack(
        children: [
          _buildMediaContent(),
          if (item.mediaUrls.isNotEmpty)
            Image.asset(
              "${commonImagePath}watermark1.png",
              height: size.width * AppDimensions.numD29,
              width: size.width,
              fit: BoxFit.cover,
              // Cache the watermark image for better performance
              cacheWidth: (size.width * 2).toInt(),
              cacheHeight: (size.width * AppDimensions.numD29 * 2).toInt(),
            ),
          if (item.mediaUrls.length > 1)
            Positioned(
              right: size.width * AppDimensions.numD02,
              top: size.width * AppDimensions.numD02,
              child: _buildCountBadge(),
            ),
          Positioned(
            right: size.width * AppDimensions.numD02,
            top: size.width * AppDimensions.numD02,
            child: _buildCountBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaContent() {
    if (item.mediaUrls.isEmpty) {
      return Container(
        height: size.width * AppDimensions.numD30,
        width: size.width,
        decoration: const BoxDecoration(color: AppColorTheme.colorLightGrey),
        padding: EdgeInsets.all(size.width * AppDimensions.numD06),
        child: Image.asset(
          "${commonImagePath}rabbitLogo.png",
          height: size.width * AppDimensions.numD07,
          width: size.width * AppDimensions.numD07,
        ),
      );
    }

    final isVideo = item.mediaType == 'video' ||
        (item.mediaList.isNotEmpty &&
            item.mediaList.first.mediaType == 'video');

    if (isVideo) {
      return VideoThumbnailWidget(
        videoUrl: getMediaImageUrl(item.mediaUrls.first, isVideo: true),
        thumbnailUrl: item.mediaList.isNotEmpty &&
                item.mediaList.first.thumbnailUrl.isNotEmpty
            ? fixS3Url(item.mediaList.first.thumbnailUrl)
            : null,
        width: size.width,
        height: size.width * AppDimensions.numD30,
        fit: BoxFit.cover,
      );
    }

    return _showImage(item.mediaType ?? 'photo', item.mediaUrls.first);
  }

  Widget _buildCountBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * AppDimensions.numD015,
        vertical: size.width * 0.005,
      ),
      decoration: BoxDecoration(
        color: AppColorTheme.colorLightGreen.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD015),
      ),
      child: Center(
        child: Text(
          "${item.mediaUrls.length} ",
          textAlign: TextAlign.center,
          style: commonTextStyle(
            size: size,
            fontSize: size.width * AppDimensions.numD038,
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
          width: size.width,
          height: size.height * AppDimensions.numD30,
          fit: BoxFit.cover,
        );
      case "audio":
        return _buildPlaceholder(
          color: AppColorTheme.colorThemePink,
          child: Icon(
            Icons.play_arrow_rounded,
            size: size.width * AppDimensions.numD18,
            color: Colors.white,
          ),
        );
      case "pdf":
        return _buildPlaceholder(
          child: Image.asset(
            "${dummyImagePath}pngImage.png",
            width: size.width * AppDimensions.numD03,
            height: size.height * AppDimensions.numD03,
          ),
        );
      case "doc":
        return _buildPlaceholder(
          child: Image.asset(
            "${dummyImagePath}doc_black_icon.png",
            width: size.width * AppDimensions.numD03,
            height: size.height * AppDimensions.numD03,
          ),
        );
      default:
        return CachedNetworkImage(
          imageUrl: getMediaImageUrl(url, isVideo: type == 'video'),
          height: size.width * AppDimensions.numD30,
          width: size.width,
          fit: BoxFit.cover,
          // Optimize memory usage by caching at display size
          memCacheWidth: (size.width * 2).toInt(), // 2x for retina displays
          memCacheHeight: (size.width * AppDimensions.numD30 * 2).toInt(),
          // Smooth fade-in transition
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          // Lightweight placeholder for better performance
          placeholder: (_, __) => _buildLightweightPlaceholder(),
          errorWidget: (_, __, ___) => _buildLightweightPlaceholder(),
        );
    }
  }

  Widget _buildPlaceholder({Color? color, required Widget child}) {
    return Container(
      height: size.width * AppDimensions.numD30,
      width: size.width,
      padding: EdgeInsets.all(size.width * AppDimensions.numD04),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColorTheme.colorHint),
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD04),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD04),
        child: Padding(
          padding: EdgeInsets.all(size.width * AppDimensions.numD03),
          child: child,
        ),
      ),
    );
  }

  // Lightweight placeholder using simple Container instead of loading PNG asset
  Widget _buildLightweightPlaceholder() {
    return Container(
      alignment: Alignment.topCenter,
      height: size.width * AppDimensions.numD30,
      width: size.width,
      child: Center(
        child: Image.asset(
          "${commonImagePath}rabbitLogo.png",
          height: size.width * AppDimensions.numD15,
          width: size.width * AppDimensions.numD15,
        ),
      ),
    );
  }
}
