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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          borderRadius:
              BorderRadius.circular(size.width * AppDimensions.numD04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediaThumbnailWidget(item: item, size: size),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(size.width * AppDimensions.numD02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(),
                    const Spacer(),
                    _buildStatusRow(),
                  ],
                ),
              ),
            ),
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
              fontSize: size.width * AppDimensions.numD032,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: size.width * AppDimensions.numD01),
        Image.asset(
          (item.isExclusive ?? false)
              ? "${iconsPath}ic_exclusive.png"
              : "${iconsPath}ic_share.png",
          height: size.width * AppDimensions.numD04,
          width: size.width * AppDimensions.numD04,
          color: AppColorTheme.colorTextFieldIcon,
        )
      ],
    );
  }

  Widget _buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildMetricsColumn()),
        SizedBox(width: size.width * AppDimensions.numD01),
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
          icon: "ic_offer.png", // Changed to ic_offer if available
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
          height: size.width * AppDimensions.numD03,
          width: size.width * AppDimensions.numD03,
          color: isActive ? AppColorTheme.colorThemePink : Colors.grey,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            "${iconsPath}dollar1.png",
            height: size.width * AppDimensions.numD03,
            width: size.width * AppDimensions.numD03,
            color: isActive ? AppColorTheme.colorThemePink : Colors.grey,
          ),
        ),
        SizedBox(width: size.width * AppDimensions.numD015),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD026,
              color: isActive ? AppColorTheme.colorThemePink : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
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
        padding: EdgeInsets.all(size.width * AppDimensions.numD015),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:
              BorderRadius.circular(size.width * AppDimensions.numD015),
        ),
        child: Text(
          item.status.toLowerCase() == "pending"
              ? "Under\nReview"
              : "Not\nApproved",
          textAlign: TextAlign.center,
          style: commonTextStyle(
            size: size,
            fontSize: size.width * AppDimensions.numD024,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * AppDimensions.numD02,
        vertical: size.width * AppDimensions.numD01,
      ),
      decoration: BoxDecoration(
        color: item.paidStatus == false
            ? AppColorTheme.colorThemePink
            : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD015),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
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
          FittedBox(
            child: Text(
              "${item.currencySymbol.isNotEmpty ? item.currencySymbol : getCurrencySymbol(item.currency)}${formatDouble(double.tryParse(item.paidStatus == false ? (item.price ?? '0') : item.totalSold) ?? 0.0)}",
              textAlign: TextAlign.center,
              style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD024,
                color: item.paidStatus == false ? Colors.white : Colors.black,
                fontWeight: FontWeight.w700,
              ),
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
    return AspectRatio(
      aspectRatio: 1.5, // Standard content aspect ratio
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD04),
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
            // if (item.totalMediaCount > 1)
            Positioned(
              right: size.width * AppDimensions.numD02,
              top: size.width * AppDimensions.numD02,
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
          height: size.width * AppDimensions.numD15,
          width: size.width * AppDimensions.numD15,
          fit: BoxFit.contain,
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
        width: double.infinity,
        height: double.infinity,
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
          "${item.totalMediaCount} ",
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
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      case "audio":
        return _buildPlaceholder(
          color: AppColorTheme.colorThemePink,
          child: Icon(
            Icons.play_arrow_rounded,
            size: size.width * AppDimensions.numD15,
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
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColorTheme.colorLightGrey),
      child: Center(
        child: Image.asset(
          "${commonImagePath}rabbitLogo.png",
          height: size.width * AppDimensions.numD15,
          width: size.width * AppDimensions.numD15,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
