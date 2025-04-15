import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/networkOperations/NetworkResponse.dart';
import '../../../main.dart';
import '../../../utils/CommonSharedPrefrence.dart';
import '../../dashboard/Dashboard.dart';
import '../../myEarning/MyEarningScreen.dart';
import 'feedDataModel.dart';

class FeedScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FeedScreenState();
  }
}

class FeedScreenState extends State<FeedScreen> implements NetworkResponse {
  PageController pageController = PageController();
  ScrollController listController = ScrollController();
  PlayerController controller = PlayerController();
  FlickManager? flickManager;

  int _currentMediaIndex = 0;
  int feedIndex = 0;
  String contentId = "";
  String selectedSellType = sharedText;

  bool isLoading = false;
  bool audioPlaying = false;

  List<FeedsDataModel> feedDataList = [];
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  int _offset = 0;

  @override
  void initState() {
    debugPrint("class ====> $runtimeType");
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => callFilterListAPI());
    initializeFilter();
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          feedText.toTitleCase(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: size.width * appBarHeadingFontSize),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
              onTap: () {
                showBottomSheet(size);
              },
              child: commonFilterIcon(size)),
          SizedBox(
            width: size.width * numD02,
          ),
          Container(
            margin: EdgeInsets.only(bottom: size.width * numD02, right: size.width * numD016),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
              },
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                height: size.width * numD07,
                width: size.width * numD07,
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
        ],
      ),
      body: SafeArea(
          child: isLoading
              ? SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  footer: const CustomFooter(builder: commonRefresherFooter),
                  child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD04),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * numD50,
                              child: PageView.builder(
                                  controller: pageController,
                                  scrollDirection: Axis.horizontal,
                                  onPageChanged: (value) {
                                    _currentMediaIndex = value;
                                    if (flickManager != null) {
                                      flickManager?.dispose();
                                      flickManager = null;
                                    }
                                    initialController(index, _currentMediaIndex);
                                    setState(() {});
                                  },
                                  itemCount: feedDataList[index].contentDataList.length,
                                  itemBuilder: (context, idx) {
                                    var item = feedDataList[index].contentDataList[idx];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(size.width * numD04),
                                      child: InkWell(
                                        onTap: () {
                                          if (item.mediaType == "pdf" || item.mediaType == "doc") {
                                            openUrl(contentImageUrl + item.media);
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            item.mediaType == "audio"
                                                ? playAudioWidget(size)
                                                : item.mediaType == "video"
                                                    ? videoWidget()
                                                    : item.mediaType == "pdf"
                                                        ? Padding(
                                                            padding: EdgeInsets.all(size.width * numD04),
                                                            child: Image.asset(
                                                              "${dummyImagePath}pngImage.png",
                                                              fit: BoxFit.contain,
                                                              height: size.width * numD35,
                                                              width: size.width,
                                                            ),
                                                          )
                                                        : item.mediaType == "doc"
                                                            ? Padding(
                                                                padding: EdgeInsets.all(size.width * numD04),
                                                                child: Image.asset(
                                                                  "${dummyImagePath}doc_black_icon.png",
                                                                  fit: BoxFit.contain,
                                                                  height: size.width * numD35,
                                                                  width: size.width,
                                                                ),
                                                              )
                                                            : Image.network(
                                                                item.mediaType == "video" ? "$contentImageUrl${item.thumbnail}" : "$contentImageUrl${item.media}",
                                                                width: size.width,
                                                                fit: BoxFit.cover,
                                                              ),
                                            //  feedDataList[index].contentDataList
                                            Positioned(
                                              right: size.width * numD02,
                                              top: size.width * numD02,
                                              child: Column(
                                                children: getMediaCount2(feedDataList[index].contentDataList, size),
                                              ),
                                            ),
                                            /*     Positioned(
                                            right: size.width * numD02,
                                            bottom: size.width * numD02,
                                            child: Visibility(
                                              visible: feedDataList[index]
                                                      .contentDataList
                                                      .length >
                                                  1,
                                              child: Text(
                                                "+${feedDataList[index].contentDataList.length}",
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD04,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),*/
                                            feedDataList[index].viewCount > 2
                                                ? Positioned(
                                                    bottom: size.width * numD02,
                                                    left: size.width * numD02,
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD02),
                                                      decoration: BoxDecoration(
                                                          color: colorThemePink,
                                                          borderRadius: BorderRadius.circular(size.width * numD04),
                                                        border: Border.all(color: Colors.white)
                                                      ),
                                                      child: Text(
                                                        mostViewedText,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.white, fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            feedDataList[index].contentDataList.length > 1
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: DotsIndicator(
                                      dotsCount: feedDataList[index].contentDataList.length,
                                      position: _currentMediaIndex,
                                      decorator: const DotsDecorator(
                                        color: Colors.grey, // Inactive color
                                        activeColor: Colors.redAccent,
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * numD017, vertical: size.width * numD01),
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 3)]),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(size.width * numD06),
                                      child: Image.asset(
                                        "${dummyImagePath}news.png",
                                        height: size.width * numD06,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                SizedBox(
                                  width: size.width * numD02,
                                ),
                                Text(
                                  feedDataList[index].categoryName.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(size: size, fontSize: size.width * numD033, color: Colors.black, fontWeight: FontWeight.w400),
                                ),
                                const Spacer(),
                                Image.asset(
                                  "${iconsPath}ic_newspaper.png",
                                  height: size.width * numD035,
                                ),
                                SizedBox(
                                  width: size.width * numD02,
                                ),
                                Text(
                                  feedDataList[index].status.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(size: size, fontSize: size.width * numD033, color: Colors.black, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            Text(
                              feedDataList[index].heading.toCapitalized(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: commonTextStyle(size: size, fontSize: size.width * numD04, color: Colors.black, lineHeight: 1.5, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            Text(
                              feedDataList[index].description,
                              maxLines: 4,
                              textAlign: TextAlign.justify,
                              style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, lineHeight: 2, fontWeight: FontWeight.normal),
                            ),
                            SizedBox(
                              height: size.width * numD02,
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
                                                color: feedDataList[index].viewCount == 0 ? Colors.grey : colorThemePink,
                                                height: size.width * numD04,
                                                width: size.width * numD04,
                                              ),
                                              SizedBox(
                                                width: size.width * numD014,
                                              ),
                                              Text(
                                                '${feedDataList[index].offerCount.toString()} ${soldText.toLowerCase()}',
                                                style: commonTextStyle(size: size, fontSize: size.width * numD029, color: colorThemePink, fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                "${iconsPath}ic_view.png",
                                                color: feedDataList[index].viewCount == 0 ? Colors.grey : colorThemePink,
                                                height: size.width * numD05,
                                                width: size.width * numD05,
                                              ),
                                              SizedBox(
                                                width: size.width * numD012,
                                              ),
                                              Text(
                                                '${feedDataList[index].viewCount.toString()} ${feedDataList[index].viewCount > 1 ? '${viewsText}s' : viewsText}',
                                                style: commonTextStyle(size: size, fontSize: size.width * numD029, color: colorThemePink, fontWeight: FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_clock.png",
                                            height: size.width * numD04,
                                            color: colorTextFieldIcon,
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Text(
                                            dateTimeFormatter(dateTime: feedDataList[index].createdAt, format: "hh:mm a"),
                                            style: commonTextStyle(size: size, fontSize: size.width * numD028, color: colorHint, fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Image.asset(
                                            "${iconsPath}ic_yearly_calendar.png",
                                            height: size.width * numD04,
                                            color: colorTextFieldIcon,
                                          ),
                                          SizedBox(
                                            width: size.width * numD018,
                                          ),
                                          Text(
                                            dateTimeFormatter(dateTime: feedDataList[index].createdAt, format: "dd MMM yyyy"),
                                            style: commonTextStyle(size: size, fontSize: size.width * numD028, color: colorHint, fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * numD03,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_location.png",
                                            height: size.width * numD045,
                                            color: colorTextFieldIcon,
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Expanded(
                                            child: Text(
                                              feedDataList[index].location,
                                              overflow: TextOverflow.ellipsis,
                                              style: commonTextStyle(size: size, fontSize: size.width * numD028, color: colorHint, fontWeight: FontWeight.normal),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * numD03,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: size.width * numD002),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(right: size.width * numD01, top: size.width * numD005),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor: Colors.transparent,
                                                onTap: () {
                                                  feedDataList[index].isFavourite = !feedDataList[index].isFavourite;
                                                  if (feedDataList[index].isFavourite) {
                                                    feedDataList[index].isLiked = false;
                                                    feedDataList[index].isEmoji = false;
                                                    feedDataList[index].isClap = false;
                                                    contentId = feedDataList[index].id;
                                                    callAddLikeFavAPI(feedDataList[index].id, feedDataList[index].isFavourite, feedDataList[index].isLiked, feedDataList[index].isEmoji, feedDataList[index].isClap);
                                                  }
                                                  setState(() {});
                                                },
                                                child: feedDataList[index].isFavourite
                                                    ? Image.asset(
                                                        "${iconsPath}heart_icon.png",
                                                        color: colorThemePink,
                                                        height: size.width * numD0575,
                                                      )
                                                    : Image.asset(
                                                        "${iconsPath}heart_icon.png",
                                                        height: size.width * numD0575,
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD1,
                                              child: Padding(
                                                padding: EdgeInsets.only(bottom: size.width * numD002),
                                                child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () {
                                                    feedDataList[index].isLiked = !feedDataList[index].isLiked;
                                                    if (feedDataList[index].isLiked) {
                                                      feedDataList[index].isEmoji = false;
                                                      feedDataList[index].isClap = false;
                                                      feedDataList[index].isFavourite = false;
                                                      contentId = feedDataList[index].id;
                                                      callAddLikeFavAPI(feedDataList[index].id, feedDataList[index].isFavourite, feedDataList[index].isLiked, feedDataList[index].isEmoji, feedDataList[index].isClap);
                                                    }
                                                    setState(() {});
                                                  },
                                                  child: feedDataList[index].isLiked
                                                      ? Image.asset(
                                                          "${iconsPath}like_icon_fill.png",
                                                          height: size.width * numD057,
                                                        )
                                                      : Image.asset(
                                                          "${iconsPath}like_grey.png",
                                                          height: size.width * numD057,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD1,
                                              child: Padding(
                                                padding: EdgeInsets.only(top: size.width * numD003),
                                                child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  onTap: () {
                                                    feedDataList[index].isEmoji = !feedDataList[index].isEmoji;
                                                    if (feedDataList[index].isEmoji) {
                                                      feedDataList[index].isLiked = false;
                                                      feedDataList[index].isClap = false;
                                                      feedDataList[index].isFavourite = false;
                                                      contentId = feedDataList[index].id;
                                                      callAddLikeFavAPI(feedDataList[index].id, feedDataList[index].isFavourite, feedDataList[index].isLiked, feedDataList[index].isEmoji, feedDataList[index].isClap);
                                                    }
                                                    setState(() {});
                                                  },
                                                  //splashRadius: size.width * numD05,
                                                  child: feedDataList[index].isEmoji
                                                      ? Image.asset(
                                                          "${iconsPath}sad.png",
                                                          height: size.width * numD058,
                                                        )
                                                      : Image.asset(
                                                          "${iconsPath}ic_grey_sad_emoji.png",
                                                          height: size.width * numD058,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            /* SizedBox(
                                                  width: size.width * numD1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      feedDataList[index]
                                                              .isClap =
                                                          !feedDataList[index]
                                                              .isClap;
                                                      if (feedDataList[index]
                                                          .isClap) {
                                                        feedDataList[index]
                                                            .isLiked = false;
                                                        feedDataList[index]
                                                            .isEmoji = false;
                                                        feedDataList[index]
                                                                .isFavourite =
                                                            false;
                                                        callAddLikeFavAPI(
                                                            feedDataList[index]
                                                                .id,
                                                            feedDataList[index]
                                                                .isFavourite,
                                                            feedDataList[index]
                                                                .isLiked,
                                                            feedDataList[index]
                                                                .isEmoji,
                                                            feedDataList[index]
                                                                .isClap);
                                                      }
                                                      setState(() {});
                                                    },
                                                    // splashRadius: size.width * numD05,
                                                    child: feedDataList[index]
                                                            .isClap
                                                        ? Image.asset(
                                                            "${iconsPath}handclap_icon.png",
                                                            color:
                                                                colorThemePink,
                                                            height: size.width *
                                                                numD057,
                                                          )
                                                        : Image.asset(
                                                            "${iconsPath}handclap_icon.png",
                                                            height: size.width *
                                                                numD057,
                                                          ),
                                                  ),
                                                ),*/
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * numD075,
                                ),
                                Container(
                                  width: size.width * numD30,
                                  padding: EdgeInsets.symmetric(vertical: size.width * numD012),
                                  decoration: BoxDecoration(color: feedDataList[index].paidStatus == unPaidText ? colorThemePink : colorLightGrey, borderRadius: BorderRadius.circular(size.width * numD03)),
                                  child: Column(
                                    children: [
                                      Text(
                                        feedDataList[index].saleStatus == "sold" ? "Sold" : "Un Sold",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(size: size, fontSize: size.width * numD035, color: feedDataList[index].paidStatus == "paid" ? Colors.black : Colors.white, fontWeight: FontWeight.normal),
                                      ),
                                      FittedBox(
                                        child: Text(
                                          "$euroUniqueCode${amountFormat(feedDataList[index].amountPaid)}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: commonTextStyle(size: size, fontSize: size.width * numD055, color: feedDataList[index].paidStatus == "paid" ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: size.width * numD04),
                          child: const Divider(
                            color: colorTextFieldIcon,
                          ),
                        );
                      },
                      itemCount: feedDataList.length))
              : showLoader()
          //errorMessageWidget("No Content Published")
          ),
    );
  }

/*  Widget playAudioWidget(size) {
    return Container(
      width: size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        border: Border.all(color: colorGreyNew),
        borderRadius: BorderRadius.circular(size.width * numD06),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          */ /*Image.asset(
            "${iconsPath}ic_sound.png",
            width: size.width * numD15,
            height: size.width * numD15,
          ),

          SizedBox(
            height: size.width * numD02,
          ),*/ /*

          SizedBox(
            height: size.width * numD05,
          ),
          AudioFileWaveforms(
            size: Size(size.width, size.width * numD20),
            playerController: controller,
            enableSeekGesture: true,
            waveformType: WaveformType.long,
            continuousWaveform: true,
            playerWaveStyle: PlayerWaveStyle(
              fixedWaveColor: Colors.black,
              liveWaveColor: colorThemePink,
              spacing: 6,
              liveWaveGradient: ui.Gradient.linear(
                const Offset(70, 50),
                Offset(MediaQuery.of(context).size.width / 2, 0),
                [Colors.red, Colors.green],
              ),
              fixedWaveGradient: ui.Gradient.linear(
                const Offset(70, 50),
                Offset(MediaQuery.of(context).size.width / 2, 0),
                [Colors.red, Colors.green],
              ),
              seekLineColor: colorThemePink,
              seekLineThickness: 2,
              showSeekLine: true,
              showBottom: true,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              if (!audioPlaying) {
                await controller.startPlayer(finishMode: FinishMode.pause);
              } else {
                await controller.pausePlayer(); // Start audio player
              }

              audioPlaying = !audioPlaying;
              setState(() {});
            },
            child: Icon(
              audioPlaying ? Icons.pause_circle : Icons.play_circle,
              color: colorThemePink,
              size: size.width * numD1,
            ),
          ),
        ],
      ),
    );
  }*/
  Widget playAudioWidget(Size size) {
    return Container(
      width: size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        color: colorThemePink,
        border: Border.all(color: colorGreyNew),
        borderRadius: BorderRadius.circular(size.width * numD06),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          audioPlaying
              ? Lottie.asset(
                  "assets/lottieFiles/ripple.json",
                )
              : Container(),
          InkWell(
            onTap: () {
              if (audioPlaying) {
                pauseSound();
              } else {
                playSound();
              }
              audioPlaying = !audioPlaying;
              setState(() {});
            },
            child: Icon(
              audioPlaying ? Icons.pause : Icons.play_arrow_rounded,
              color: Colors.white,
              size: size.width * numD15,
            ),
          ),
        ],
      ),
    );
  }

/*  Widget videoWidget() {
    return FlickVideoPlayer(
      flickManager: flickManager!,
      flickVideoWithControls: const FlickVideoWithControls(
        playerLoadingFallback: Center(
            child: CircularProgressIndicator(
          color: colorThemePink,
        )),
      ),
      flickVideoWithControlsFullscreen: const FlickVideoWithControls(
        playerLoadingFallback: CircularProgressIndicator(
          color: colorThemePink,
        ),
        controls: FlickLandscapeControls(),
      ),
    );
  }*/
  Future playSound() async {
    debugPrint("PlayTheSound");

    await controller.startPlayer(); // Start audio player
  }

  Future pauseSound() async {
    await controller.pausePlayer(); // Start audio player
  }

  Widget videoWidget() {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && mounted) {
          flickManager?.flickControlManager?.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager?.flickControlManager?.autoResume();
        }
      },
      child: flickManager != null
          ? FlickVideoPlayer(
              flickManager: flickManager!,
              flickVideoWithControls: const FlickVideoWithControls(
                playerLoadingFallback: Center(
                    child: CircularProgressIndicator(
                  color: colorThemePink,
                )),
                closedCaptionTextStyle: TextStyle(fontSize: 8),
                controls: FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                playerLoadingFallback: Center(
                    child: CircularProgressIndicator(
                  color: colorThemePink,
                )),
                controls: FlickLandscapeControls(),
              ),
            )
          : Container(),
    );
  }

  Future<void> showBottomSheet(Size size) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD085),
          topRight: Radius.circular(size.width * numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter stateSetter) {
            return Padding(
              padding: EdgeInsets.only(
                top: size.width * numD06,
                left: size.width * numD05,
                right: size.width * numD05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          splashRadius: size.width * numD07,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: size.width * numD07,
                          ),
                        ),
                        Text(
                          "Sort and Filter",
                          style: commonTextStyle(size: size, fontSize: size.width * appBarHeadingFontSizeNew, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            filterList.clear();
                            sortList.clear();
                            initializeFilter();
                            stateSetter(() {});
                          },
                          child: Text(
                            "Clear all",
                            style: TextStyle(color: colorThemePink, fontWeight: FontWeight.w400, fontSize: size.width * numD035),
                          ),
                        ),
                      ],
                    ),

                    /// Sort
                    SizedBox(
                      height: size.width * numD085,
                    ),

                    /// Sort Heading
                    Text(
                      sortText,
                      style: commonTextStyle(size: size, fontSize: size.width * numD05, color: Colors.black, fontWeight: FontWeight.w500),
                    ),

                    /// New Sort::

                    filterListWidget(context, sortList, stateSetter, size, true),

                    /// Filter
                    SizedBox(
                      height: size.width * numD05,
                    ),

                    /// Filter Heading
                    /*Text(
                      filterText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),*/

                    /*filterListWidget(
                        context, filterList, stateSetter, size, false),*/

                    SizedBox(
                      height: size.width * numD06,
                    ),

                    Container(
                      width: size.width,
                      height: size.width * numD13,
                      margin: EdgeInsets.symmetric(horizontal: size.width * numD04),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: commonElevatedButton(applyText, size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () {
                        Navigator.pop(context);
                        _offset = 0;
                        callFilterListAPI();
                      }),
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset = 0;
      callFilterListAPI();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset += 10;
      callFilterListAPI();
    });
    _refreshController.loadComplete();
  }

  /// Load Filter And Sort
  void initializeFilter() {
    /* sortList.addAll([
      FilterModel(
          name: viewWeeklyText,
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: viewMonthlyText,
          icon: "ic_monthly_calendar.png",
          isSelected: true),
      FilterModel(
          name: viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
    ]);*/

    sortList.addAll([
      FilterModel(name: "Latest content", value: "desc", icon: "ic_monthly_calendar.png", isSelected: true),
      FilterModel(name: "Oldest content ", value: "asc", icon: "ic_weekly_calendar.png", isSelected: false),
      FilterModel(name: "Highest earning content", value: "highest_earning", icon: "ic_yearly_calendar.png", isSelected: false),
      FilterModel(name: "Lowest earning content", icon: "ic_eye_outlined.png", value: "lowest_earning", isSelected: false),
      FilterModel(name: "Most views", value: "most_views", icon: "ic_eye_outlined.png", isSelected: false),
      FilterModel(name: "Least views", value: "least_views", icon: "ic_eye_outlined.png", isSelected: false),
    ]);

    filterList.addAll([
      /*   FilterModel(
          name: allContentsText, icon: "ic_square_play.png", isSelected: true),
      FilterModel(name: allTasksText, icon: "ic_task.png", isSelected: false),*/
      FilterModel(name: allExclusiveContentText, icon: "ic_exclusive.png", isSelected: false),
      FilterModel(name: allSharedContentText, icon: "ic_share.png", isSelected: false),
      FilterModel(name: paymentsReceivedText, icon: "ic_payment_reviced.png", isSelected: false),
      FilterModel(name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
    ]);
  }

  Future initWaveData(String url) async {
    var dio = Dio();
    dio.interceptors.add(LogInterceptor(responseBody: false));

    Directory appFolder = await getApplicationDocumentsDirectory();
    bool appFolderExists = await appFolder.exists();
    if (!appFolderExists) {
      final created = await appFolder.create(recursive: true);
      debugPrint(created.path);
    }

    final filepath = '${appFolder.path}/dummyFileRecordFile.m4a';
    debugPrint("Audio FilePath : $filepath");

    File(filepath).createSync();

    await dio.download(url, filepath);

    await controller.preparePlayer(
      path: filepath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );

    controller.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        audioPlaying = false;
        if (mounted) {
          setState(() {});
        }
      }
    });
    setState(() {});
  }

  Widget filterListWidget(BuildContext context, List<FilterModel> list, StateSetter stateSetter, Size size, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: size.width * numD02),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return InkWell(
          onTap: () {
            if (isSort) {
              int pos = list.indexWhere((element) => element.isSelected);
              if (pos != -1) {
                list[pos].isSelected = false;
                list[pos].fromDate = null;
                list[pos].toDate = null;
              } else {
                int pos = list.indexWhere((element) => element.isSelected);
                if (pos != -1) {
                  list[pos].isSelected = false;
                }
              }
              filterList.indexWhere((element) => element.isSelected = false);
            }
            sortList.indexWhere((element) => element.isSelected = false);

            list[index].isSelected = !list[index].isSelected;

            stateSetter(() {});
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.only(
              top: list[index].name == filterDateText ? size.width * 0 : size.width * numD025,
              bottom: list[index].name == filterDateText ? size.width * 0 : size.width * numD025,
              left: size.width * numD02,
              right: size.width * numD02,
            ),
            color: list[index].isSelected ? Colors.grey.shade400 : null,
            child: Row(
              children: [
                /*Image.asset(
                  "$iconsPath${list[index].icon}",
                  color: Colors.black,
                  height: list[index].name == soldContentText
                      ? size.width * numD06
                      : size.width * numD05,
                  width: list[index].name == soldContentText
                      ? size.width * numD06
                      : size.width * numD05,
                ),*/
                /* SizedBox(
                  width: size.width * numD03,
                ),*/
                list[index].name == filterDateText
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              item.fromDate = await commonDatePicker();
                              item.toDate = null;
                              int pos = list.indexWhere((element) => element.isSelected);
                              if (pos != -1) {
                                list[pos].isSelected = false;
                              }
                              item.isSelected = !item.isSelected;
                              stateSetter(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size.width * numD04),
                                border: Border.all(width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.fromDate != null ? dateTimeFormatter(dateTime: item.fromDate.toString()) : fromText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD015,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD03,
                          ),
                          InkWell(
                            onTap: () async {
                              if (item.fromDate != null) {
                                String? pickedDate = await commonDatePicker();

                                if (pickedDate != null) {
                                  DateTime parseFromDate = DateTime.parse(item.fromDate!);
                                  DateTime parseToDate = DateTime.parse(pickedDate);

                                  debugPrint("parseFromDate : $parseFromDate");
                                  debugPrint("parseToDate : $parseToDate");

                                  if (parseToDate.isAfter(parseFromDate) || parseToDate.isAtSameMomentAs(parseFromDate)) {
                                    item.toDate = pickedDate;
                                  } else {
                                    showSnackBar("Date Error", "Please select to date above from date", Colors.red);
                                  }
                                }
                              }
                              stateSetter(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size.width * numD04),
                                border: Border.all(width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.toDate != null ? dateTimeFormatter(dateTime: item.toDate.toString()) : toText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD02,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(list[index].name, style: TextStyle(fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400, fontFamily: "AirbnbCereal_W_Bk"))
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: size.width * numD01,
        );
      },
    );
  }

  void initialController(feedIndex, currentMediaIndex) {
    if (feedDataList[feedIndex].contentDataList[currentMediaIndex].mediaType == "audio") {
      initWaveData(contentImageUrl + feedDataList[feedIndex].contentDataList[currentMediaIndex].media);
    } else if (feedDataList[feedIndex].contentDataList[currentMediaIndex].mediaType == "video") {
      debugPrint("videoLink=====> ${feedDataList[feedIndex].contentDataList[currentMediaIndex].media}");
      flickManager = FlickManager(
        videoPlayerController: /*VideoPlayerController.network(contentImageUrl +
            feedDataList[feedIndex].contentDataList[currentMediaIndex].media),*/

            VideoPlayerController.networkUrl(
          Uri.parse(feedDataList[feedIndex].contentDataList[currentMediaIndex].media),
        ),
        autoPlay: false,
      );
    }
    setState(() {});
  }

  /// Filter List API
  callFilterListAPI() {
    Map<String, String> map = {"limit": "10", "offset": _offset.toString()};

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos >= 0) {
      map["sort"] = sortList[pos].value!;
    }

    /// Commented by Rajan @ 31 JAN
    /*if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        map["startdate"] = sortList[pos].fromDate!;
        map["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == viewMonthlyText) {
        map["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        map["posted_date"] = "365";
      } else if (sortList[pos].name == viewWeeklyText) {
        map["posted_date"] = "7";
      }
    }*/

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case allExclusiveContentText:
            map["type"] = 'exclusive';
            break;

          case allSharedContentText:
            map["sharedtype"] = "shared";
            break;

          case paymentsReceivedText:
            map["paid_status"] = "paid";
            break;

          case pendingPaymentsText:
            map["paid_status"] = "un_paid";
            break;
        }
      }
    }

    NetworkClass(getFeedListAPI, this, reqFeedList).callRequestServiceHeader(false, "get", map);
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }

  /// Add Like
  callAddLikeFavAPI(String contentId, bool isFav, bool isLike, bool isEmoji, bool isClap) {
    Map<String, String> map = {
      "is_favourite": isFav.toString(),
      "is_liked": isLike.toString(),
      "is_emoji": isEmoji.toString(),
      "is_clap": isClap.toString(),
      "content_id": contentId,
    };
    debugPrint("map value====> $map");
    NetworkClass.fromNetworkClassRow(likeFavFeedAPI, this, reqLikeFavFeedAPI, map).callPatchServiceHeaderRow(context, false);
  }

  /// ADD Count
  callAddFeedContentCount() {
    Map<String, String> map = {"type": "feed_content", "content_id": contentId, "user_id": sharedPreferences!.getString(hopperIdKey).toString() ?? ''};
    debugPrint("map add value====> $map");

    NetworkClass.fromNetworkClass(addViewCountAPI, this, reqAddViewCountAPI, map).callRequestServiceHeader(false, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqFeedList:
          debugPrint("reqFeedList errorResponse ==> ${jsonDecode(response)}");
          isLoading = false;
          setState(() {});
          break;

        case reqLikeFavFeedAPI:
          debugPrint("reqLikeFavFeedAPI_error===> ${jsonDecode(response)}");
          break;

        case reqAddViewCountAPI:
          debugPrint("reqAddViewCountAPI====> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("exception error ==> $e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqFeedList:
          debugPrint("reqFeedList successResponse ==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          /*  var dataList = data['response'] as List;
          if (dataList.isNotEmpty) {
            feedDataList =
                dataList.map((e) => FeedsDataModel.fromJson(e)).toList();
            debugPrint("Feed Data length ==> ${feedDataList.length}");
            initialController(0, 0);
          } else {
            feedDataList.clear();
          }
          showData = true;
          setState(() {});*/

          if (data["code"] == 200) {
            var listModel = data["response"] as List;
            var list = listModel.map((e) => FeedsDataModel.fromJson(e)).toList();

            if (list.isNotEmpty) {
              _refreshController.loadComplete();
            } else if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadFailed();
            }

            if (_offset == 0) {
              feedDataList.clear();
            }

            feedDataList.addAll(list);
            if (feedDataList.isNotEmpty) {
              initialController(0, 0);
            }
          }
          isLoading = true;
          debugPrint("feedDataList length:::::::::${feedDataList.length}");
          setState(() {});
          break;
        case reqLikeFavFeedAPI:
          debugPrint("reqLikeFavFeedAPI_success===> ${jsonDecode(response)}");
          break;
        case reqAddViewCountAPI:
          debugPrint("reqAddViewCountAPI====> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("exception error ==> $e");
    }
  }
}
