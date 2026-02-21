import 'package:chewie/chewie.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/feed.dart';
import 'package:presshop/features/feed/presentation/pages/feed_description.dart';

import 'package:presshop/features/feed/presentation/widgets/feed_audio_player.dart';
import 'package:presshop/features/feed/presentation/widgets/feed_video_player.dart';

class FeedItemWidget extends StatefulWidget {
  const FeedItemWidget({
    super.key,
    required this.feed,
    required this.size,
    required this.pageController,
    required this.initialController,
    required this.openUrl,
    required this.onFavouriteToggle,
    required this.onLikeToggle,
    required this.onEmojiToggle,
  });
  final Feed feed;
  final Size size;
  final PageController pageController;
  final Function(Feed, int) initialController;
  final Function(String) openUrl;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onLikeToggle;
  final VoidCallback onEmojiToggle;

  @override
  State<FeedItemWidget> createState() => _FeedItemWidgetState();
}

class _FeedItemWidgetState extends State<FeedItemWidget> {
  int _currentMediaIndex = 0;
  String _userCurrencySymbol = '';

  @override
  void initState() {
    super.initState();
    _loadUserCurrency();
  }

  Future<void> _loadUserCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final symbol =
        prefs.getString(SharedPreferencesKeys.currencySymbolKey) ?? '';
    if (mounted) {
      setState(() {
        _userCurrencySymbol = symbol;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final feed = widget.feed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: size.width * AppDimensions.numD50,
          child: PageView.builder(
              controller: widget.pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (value) {
                setState(() {
                  _currentMediaIndex = value;
                });
              },
              itemCount: feed.contentList.length,
              itemBuilder: (context, idx) {
                var item = feed.contentList[idx];
                ChewieController? chewieController =
                    widget.initialController(feed, idx);
                return ClipRRect(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD04),
                  child: InkWell(
                    onTap: () {
                      if (item.mediaType == "pdf" || item.mediaType == "doc") {
                        widget.openUrl(getMediaImageUrl(item.mediaUrl));
                      } else if (item.mediaType == "video" &&
                          chewieController != null) {
                        if (chewieController
                            .videoPlayerController.value.isPlaying) {
                          chewieController.pause();
                        } else {
                          chewieController.play();
                        }
                      }
                    },
                    child: Stack(
                      children: [
                        item.mediaType == "audio"
                            ? FeedAudioPlayer(
                                audioUrl: getMediaImageUrl(item.mediaUrl),
                                size: size)
                            : item.mediaType == "video"
                                ? FeedVideoPlayer(
                                    videoKey: Key("${feed.id}_$idx"),
                                    chewieController: chewieController)
                                : item.mediaType == "pdf"
                                    ? Padding(
                                        padding: EdgeInsets.all(
                                            size.width * AppDimensions.numD04),
                                        child: Image.asset(
                                          "${dummyImagePath}pngImage.png",
                                          fit: BoxFit.contain,
                                          height:
                                              size.width * AppDimensions.numD35,
                                          width: size.width,
                                        ),
                                      )
                                    : item.mediaType == "doc"
                                        ? Padding(
                                            padding: EdgeInsets.all(size.width *
                                                AppDimensions.numD04),
                                            child: Image.asset(
                                              "${dummyImagePath}doc_black_icon.png",
                                              fit: BoxFit.contain,
                                              height: size.width *
                                                  AppDimensions.numD35,
                                              width: size.width,
                                            ),
                                          )
                                        : Image.network(
                                            getMediaImageUrl(
                                                item.mediaType == "video"
                                                    ? item.thumbnail
                                                    : item.mediaUrl,
                                                isVideo:
                                                    item.mediaType == "video"),
                                            width: size.width,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                "${commonImagePath}rabbitLogo.png",
                                                width: size.width,
                                                fit: BoxFit.contain,
                                              );
                                            },
                                          ),
                        Positioned(
                          right: size.width * AppDimensions.numD02,
                          top: size.width * AppDimensions.numD02,
                          child: Column(
                            children: getMediaCount2(feed.contentList, size),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        feed.contentList.length > 1
            ? Align(
                alignment: Alignment.bottomCenter,
                child: DotsIndicator(
                  dotsCount: feed.contentList.length,
                  position: _currentMediaIndex,
                  decorator: const DotsDecorator(
                    color: Colors.grey, // Inactive color
                    activeColor: Colors.redAccent,
                  ),
                ),
              )
            : Container(),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        Row(
          children: [
            Container(
              width: size.width * AppDimensions.numD09,
              height: size.width * AppDimensions.numD09,
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, spreadRadius: 3)
                  ]),
              child: ClipOval(
                child: feed.categoryImage.isNotEmpty
                    ? Image.network(
                        feed.categoryImage,
                        width: size.width * AppDimensions.numD09,
                        height: size.width * AppDimensions.numD09,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "${commonImagePath}rabbitLogo.png",
                            width: size.width * AppDimensions.numD09,
                            height: size.width * AppDimensions.numD09,
                            fit: BoxFit.contain,
                          );
                        },
                      )
                    : Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        width: size.width * AppDimensions.numD09,
                        height: size.width * AppDimensions.numD09,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD02,
            ),
            Text(
              feed.categoryName.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD033,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            Image.asset(
              "${iconsPath}ic_newspaper.png",
              height: size.width * AppDimensions.numD035,
            ),
            SizedBox(
              width: size.width * AppDimensions.numD02,
            ),
            Text(
              feed.status.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD033,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        Text(
          feed.heading.toCapitalized(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD04,
              color: Colors.black,
              lineHeight: 1.5,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        ExpandableText(
          text: feed.description.toCapitalizeText(),
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            "${iconsPath}dollar1.png",
                            color: feed.viewCount == 0
                                ? Colors.grey
                                : AppColorTheme.colorThemePink,
                            height: size.width * AppDimensions.numD04,
                            width: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            width: size.width * AppDimensions.numD014,
                          ),
                          Text(
                            '${feed.offerCount.toString()} ${AppStrings.soldText.toLowerCase()}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD029,
                                color: AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            "${iconsPath}ic_view.png",
                            color: feed.viewCount == 0
                                ? Colors.grey
                                : AppColorTheme.colorThemePink,
                            height: size.width * AppDimensions.numD05,
                            width: size.width * AppDimensions.numD05,
                          ),
                          SizedBox(
                            width: size.width * AppDimensions.numD012,
                          ),
                          Text(
                            '${feed.viewCount.toString()} ${feed.viewCount > 1 ? '${AppStrings.viewsText}s' : AppStrings.viewsText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD029,
                                color: AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_clock.png",
                        height: size.width * AppDimensions.numD04,
                        color: AppColorTheme.colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD02,
                      ),
                      Text(
                        dateTimeFormatter(
                            dateTime: feed.createdAt, format: "hh:mm a"),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD028,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD02,
                      ),
                      Image.asset(
                        "${iconsPath}ic_yearly_calendar.png",
                        height: size.width * AppDimensions.numD04,
                        color: AppColorTheme.colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD018,
                      ),
                      Text(
                        dateTimeFormatter(
                            dateTime: feed.createdAt, format: "dd MMM yyyy"),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD028,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD03,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_location.png",
                        height: size.width * AppDimensions.numD045,
                        color: AppColorTheme.colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD02,
                      ),
                      Expanded(
                        child: Text(
                          feed.location,
                          overflow: TextOverflow.ellipsis,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD028,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD03,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: size.width * AppDimensions.numD002),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: size.width * AppDimensions.numD01,
                              top: size.width * AppDimensions.numD005),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: widget.onFavouriteToggle,
                            child: feed.isFavourite
                                ? Image.asset(
                                    "${iconsPath}heart_icon.png",
                                    color: AppColorTheme.colorThemePink,
                                    height: size.width * AppDimensions.numD0575,
                                  )
                                : Image.asset(
                                    "${iconsPath}heart_icon.png",
                                    height: size.width * AppDimensions.numD0575,
                                  ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * AppDimensions.numD1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: size.width * AppDimensions.numD002),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: widget.onLikeToggle,
                              child: feed.isLiked
                                  ? Image.asset(
                                      "${iconsPath}like_icon_fill.png",
                                      height:
                                          size.width * AppDimensions.numD057,
                                    )
                                  : Image.asset(
                                      "${iconsPath}like_grey.png",
                                      height:
                                          size.width * AppDimensions.numD057,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * AppDimensions.numD1,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: size.width * AppDimensions.numD003),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: widget.onEmojiToggle,
                              child: feed.isEmoji
                                  ? Image.asset(
                                      "${iconsPath}sad.png",
                                      height:
                                          size.width * AppDimensions.numD058,
                                    )
                                  : Image.asset(
                                      "${iconsPath}ic_grey_sad_emoji.png",
                                      height:
                                          size.width * AppDimensions.numD058,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD075,
            ),
            Container(
              width: size.width * AppDimensions.numD30,
              padding: EdgeInsets.symmetric(
                  vertical: size.width * AppDimensions.numD025,
                  horizontal: size.width * AppDimensions.numD02),
              decoration: BoxDecoration(
                  color: AppColorTheme.colorThemePink,
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD03)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.soldText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD03,
                        color: Colors.white,
                        fontWeight: FontWeight.normal),
                  ),
                  FittedBox(
                    child: Text(
                      "${_userCurrencySymbol.isNotEmpty ? _userCurrencySymbol : (feed.displayCurrency.isNotEmpty ? feed.displayCurrency : '£')}${amountFormat(feed.displayPrice)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD055,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
