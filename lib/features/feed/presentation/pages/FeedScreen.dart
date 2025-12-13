import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/utils/extensions.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/api/network_class.dart';
import 'package:presshop/features/feed/presentation/pages/feed_description.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:presshop/core/api/network_response.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../../domain/entities/feed.dart';


class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return FeedScreenState();
  }
}

class FeedScreenState extends State<FeedScreen> {
  PageController pageController = PageController();
  ScrollController listController = ScrollController();
  PlayerController controller = PlayerController();

  int _currentMediaIndex = 0;
  int feedIndex = 0;
  String contentId = "";
  String selectedSellType = sharedText;

  bool isLoading = false;
  bool audioPlaying = false;

  late FeedBloc _feedBloc;
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    debugPrint("class ====> $runtimeType");
    super.initState();
    _feedBloc = sl<FeedBloc>();
    _feedBloc.add(const FetchFeeds(isRefresh: true));
    initializeFilter();
  }

  @override
  void dispose() {
    //flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: true,
        title: Padding(
          padding: EdgeInsets.only(left: true ? size.width * numD04 : 0),
          child: Text(
            "Feed",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * appBarHeadingFontSize),
          ),
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
            child: commonFilterIcon(size),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD07,
              width: size.width * numD07,
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          )
        ],
      ),
      // appBar: CommonAppBar(
      //   elevation: 0,
      //   hideLeading: true,
      //   title: Text(
      //     feedText.toTitleCase(),
      //     style: TextStyle(
      //         color: Colors.black,
      //         fontWeight: FontWeight.bold,
      //         fontSize: size.width * appBarHeadingFontSize),
      //   ),
      //   centerTitle: false,
      //   titleSpacing: 0,
      //   size: size,
      //   showActions: true,
      //   leadingFxn: () {
      //     Navigator.pop(context);
      //   },
      //   actionWidget: [
      //     InkWell(
      //         onTap: () {
      //           showBottomSheet(size);
      //         },
      //         child: commonFilterIcon(size)),
      //     SizedBox(
      //       width: size.width * numD02,
      //     ),
      //     Container(
      //       margin: EdgeInsets.only(
      //           bottom: size.width * numD02, right: size.width * numD016),
      //       child: InkWell(
      //         onTap: () {
      //           Navigator.of(context).pushAndRemoveUntil(
      //               MaterialPageRoute(
      //                   builder: (context) => Dashboard(initialPosition: 2)),
      //               (route) => false);
      //         },
      //         child: Image.asset(
      //           "${commonImagePath}rabbitLogo.png",
      //           height: size.width * numD07,
      //           width: size.width * numD07,
      //         ),
      //       ),
      //     ),
      //     SizedBox(
      //       width: size.width * numD02,
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: BlocConsumer<FeedBloc, FeedState>(
          listener: (context, state) {
            if (state.status == FeedStatus.failure) {
              _refreshController.refreshFailed();
               // showSnackBar(state.errorMessage); // Assuming showSnackBar exists
            } else if (state.status == FeedStatus.success) {
               _refreshController.refreshCompleted();
               if (state.hasReachedMax) {
                  _refreshController.loadNoData();
               } else {
                  _refreshController.loadComplete();
               }
            }
          },
          builder: (context, state) {
            if (state.status == FeedStatus.initial || (state.status == FeedStatus.loading && state.feeds.isEmpty)) {
               return showLoader();
            }
            
            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: !state.hasReachedMax,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              footer: const CustomFooter(builder: commonRefresherFooter),
              child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                          vertical: size.width * numD04),
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
                                  },
                                  itemCount: state.feeds[index]
                                      .contentList
                                      .length,
                                  itemBuilder: (context, idx) {
                                    var item = state.feeds[index]
                                        .contentList[idx];
                                    var flickManager =
                                        initialController(state.feeds[index], idx);
                                    return VisibilityDetector(
                                      key:
                                          Key("${state.feeds[index].id}_$idx"),
                                      onVisibilityChanged: (visibility) {
                                        if (visibility.visibleFraction < 0.6) {
                                          flickManager?.flickControlManager
                                              ?.autoPause();
                                        } else if (visibility.visibleFraction ==
                                            1) {
                                          flickManager?.flickControlManager
                                              ?.autoResume();
                                        }
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                        child: InkWell(
                                          onTap: () {
                                            if (item.mediaType == "pdf" ||
                                                item.mediaType == "doc") {
                                              openUrl(
                                                  contentImageUrl + item.mediaUrl);
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              item.mediaType == "audio"
                                                  ? playAudioWidget(size)
                                                  : item.mediaType == "video"
                                                      ? videoWidget(
                                                          Key(
                                                              "${state.feeds[index].id}_$idx"),
                                                          flickManager)
                                                      : item.mediaType == "pdf"
                                                          ? Padding(
                                                              padding: EdgeInsets
                                                                  .all(size
                                                                          .width *
                                                                      numD04),
                                                              child:
                                                                  Image.asset(
                                                                "${dummyImagePath}pngImage.png",
                                                                fit: BoxFit
                                                                    .contain,
                                                                height:
                                                                    size.width *
                                                                        numD35,
                                                                width:
                                                                    size.width,
                                                              ),
                                                            )
                                                          : item.mediaType ==
                                                                  "doc"
                                                              ? Padding(
                                                                  padding: EdgeInsets
                                                                      .all(size
                                                                              .width *
                                                                          numD04),
                                                                  child: Image
                                                                      .asset(
                                                                    "${dummyImagePath}doc_black_icon.png",
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    height: size
                                                                            .width *
                                                                        numD35,
                                                                    width: size
                                                                        .width,
                                                                  ),
                                                                )
                                                              : Image.network(
                                                                  item.mediaType ==
                                                                          "video"
                                                                      ? "$contentImageUrl${item.thumbnail}"
                                                                      : "$contentImageUrl${item.mediaUrl}",
                                                                  width: size
                                                                      .width,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                              //  state.feeds[index].contentList
                                              Positioned(
                                                right: size.width * numD02,
                                                top: size.width * numD02,
                                                child: Column(
                                                  children: getMediaCount2(
                                                      state.feeds[index]
                                                          .contentList,
                                                      size),
                                                ),
                                              ),
                                              /*     Positioned(
                                              right: size.width * numD02,
                                              bottom: size.width * numD02,
                                              child: Visibility(
                                                visible: state.feeds[index]
                                                        .contentList
                                                        .length >
                                                    1,
                                                child: Text(
                                                  "+${state.feeds[index].contentList.length}",
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
                                              // state.feeds[index].viewCount > 2
                                              //     ? Positioned(
                                              //         bottom: size.width * numD02,
                                              //         left: size.width * numD02,
                                              //         child: Container(
                                              //           padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD02),
                                              //           decoration: BoxDecoration(
                                              //               color: colorThemePink,
                                              //               borderRadius: BorderRadius.circular(size.width * numD04),
                                              //             border: Border.all(color: Colors.white)
                                              //           ),
                                              //           child: Text(
                                              //             mostViewedText,
                                              //             overflow: TextOverflow.ellipsis,
                                              //             style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.white, fontWeight: FontWeight.w600),
                                              //           ),
                                              //         ),
                                              //       )
                                              //     : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            state.feeds[index].contentList.length > 1
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: DotsIndicator(
                                      dotsCount: state.feeds[index]
                                          .contentList
                                          .length,
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
                                  width: size.width * numD09,
                                  height: size.width * numD09,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 1, vertical: 1),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade200,
                                            spreadRadius: 3)
                                      ]),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD06),
                                      child: Image.network(
                                        state.feeds[index].feedImage,
                                        height: size.width * numD06,
                                        fit: BoxFit.fill,
                                      )),
                                ),
                                SizedBox(
                                  width: size.width * numD02,
                                ),
                                Text(
                                  state.feeds[index]
                                      .categoryName
                                      .toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
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
                                  state.feeds[index].status.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            Text(
                              state.feeds[index].heading.toCapitalized(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD04,
                                  color: Colors.black,
                                  lineHeight: 1.5,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            ExpandableText(
                              text: state.feeds[index]
                                  .description
                                  .toCapitalizeText(),
                            ),
                            // Text(
                            //   state.feeds[index].description,
                            //   maxLines: 4,
                            //   textAlign: TextAlign.justify,
                            //   style: commonTextStyle(
                            //       size: size,
                            //       fontSize: size.width * numD03,
                            //       color: Colors.black,
                            //       lineHeight: 2,
                            //       fontWeight: FontWeight.normal),
                            // ),
                            SizedBox(
                              height: size.width * numD02,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                "${iconsPath}dollar1.png",
                                                color: state.feeds[index]
                                                            .viewCount ==
                                                        0
                                                    ? Colors.grey
                                                    : colorThemePink,
                                                height: size.width * numD04,
                                                width: size.width * numD04,
                                              ),
                                              SizedBox(
                                                width: size.width * numD014,
                                              ),
                                              Text(
                                                '${state.feeds[index].offerCount.toString()} ${soldText.toLowerCase()}',
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD029,
                                                    color: colorThemePink,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                "${iconsPath}ic_view.png",
                                                color: state.feeds[index]
                                                            .viewCount ==
                                                        0
                                                    ? Colors.grey
                                                    : colorThemePink,
                                                height: size.width * numD05,
                                                width: size.width * numD05,
                                              ),
                                              SizedBox(
                                                width: size.width * numD012,
                                              ),
                                              Text(
                                                '${state.feeds[index].viewCount.toString()} ${state.feeds[index].viewCount > 1 ? '${viewsText}s' : viewsText}',
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD029,
                                                    color: colorThemePink,
                                                    fontWeight:
                                                        FontWeight.normal),
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
                                            dateTimeFormatter(
                                                dateTime: state.feeds[index]
                                                    .createdAt,
                                                format: "hh:mm a"),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD028,
                                                color: colorHint,
                                                fontWeight: FontWeight.normal),
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
                                            dateTimeFormatter(
                                                dateTime: state.feeds[index]
                                                    .createdAt,
                                                format: "dd MMM yyyy"),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD028,
                                                color: colorHint,
                                                fontWeight: FontWeight.normal),
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
                                              state.feeds[index].location,
                                              overflow: TextOverflow.ellipsis,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD028,
                                                  color: colorHint,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: size.width * numD03,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: size.width * numD002),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: size.width * numD01,
                                                  top: size.width * numD005),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  _feedBloc.add(ToggleFavouriteFeed(
                                                      id: state.feeds[index].id,
                                                      isFavourite: !state
                                                          .feeds[index]
                                                          .isFavourite));
                                                },
                                                child: state.feeds[index]
                                                        .isFavourite
                                                    ? Image.asset(
                                                        "${iconsPath}heart_icon.png",
                                                        color: colorThemePink,
                                                        height: size.width *
                                                            numD0575,
                                                      )
                                                    : Image.asset(
                                                        "${iconsPath}heart_icon.png",
                                                        height: size.width *
                                                            numD0575,
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD1,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        size.width * numD002),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    _feedBloc.add(
                                                        ToggleLikeFeed(
                                                            id: state
                                                                .feeds[index]
                                                                .id,
                                                            isLiked: !state
                                                                .feeds[index]
                                                                .isLiked));
                                                  },
                                                  child: state
                                                          .feeds[index].isLiked
                                                      ? Image.asset(
                                                          "${iconsPath}like_icon_fill.png",
                                                          height: size.width *
                                                              numD057,
                                                        )
                                                      : Image.asset(
                                                          "${iconsPath}like_grey.png",
                                                          height: size.width *
                                                              numD057,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD1,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: size.width * numD003),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    _feedBloc.add(
                                                        ToggleEmojiFeed(
                                                            id: state
                                                                .feeds[index]
                                                                .id,
                                                            isEmoji: !state
                                                                .feeds[index]
                                                                .isEmoji));
                                                  },
                                                  //splashRadius: size.width * numD05,
                                                  child: state
                                                          .feeds[index].isEmoji
                                                      ? Image.asset(
                                                          "${iconsPath}sad.png",
                                                          height: size.width *
                                                              numD058,
                                                        )
                                                      : Image.asset(
                                                          "${iconsPath}ic_grey_sad_emoji.png",
                                                          height: size.width *
                                                              numD058,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            /* SizedBox(
                                                  width: size.width * numD1,
                                                  child: InkWell(
                                                    onTap: () {
                                                      state.feeds[index]
                                                              .isClap =
                                                          !state.feeds[index]
                                                              .isClap;
                                                      if (state.feeds[index]
                                                          .isClap) {
                                                        state.feeds[index]
                                                            .isLiked = false;
                                                        state.feeds[index]
                                                            .isEmoji = false;
                                                        state.feeds[index]
                                                                .isFavourite =
                                                            false;
                                                        callAddLikeFavAPI(
                                                            state.feeds[index]
                                                                .id,
                                                            state.feeds[index]
                                                                .isFavourite,
                                                            state.feeds[index]
                                                                .isLiked,
                                                            state.feeds[index]
                                                                .isEmoji,
                                                            state.feeds[index]
                                                                .isClap);
                                                      }
                                                      setState(() {});
                                                    },
                                                    // splashRadius: size.width * numD05,
                                                    child: state.feeds[index]
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
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * numD012),
                                  decoration: BoxDecoration(
                                      color: state.feeds[index].paidStatus ==
                                              unPaidText
                                          ? colorThemePink
                                          : colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD03)),
                                  child: Column(
                                    children: [
                                      Text(
                                        state.feeds[index].saleStatus == "sold"
                                            ? "Sold"
                                            : "Sold",
                                        // state.feeds[index].saleStatus,

                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD035,
                                            color: state.feeds[index]
                                                        .paidStatus ==
                                                    "paid"
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      FittedBox(
                                        child: Text(
                                          // "$currencySymbol${amountFormat(state.feeds[index].displayPrice)}",
                                          "$currencySymbol${amountFormat(state.feeds[index].displayPrice)}",

                                          // "${state.feeds[index].displayCurrency} ${amountFormat(state.feeds[index].displayPrice)}",

                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD055,
                                              color: state.feeds[index]
                                                          .paidStatus ==
                                                      "paid"
                                                  ? Colors.black
                                                  : Colors.white,
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
                      },
                      separatorBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: size.width * numD04),
                          child: const Divider(
                            color: colorTextFieldIcon,
                          ),
                        );
                      },
                      itemCount: state.feeds.length),
            );
          },
        ),
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

  Widget videoWidget(Key key, flickManager) {
    return flickManager != null
        ? FlickVideoPlayer(
            key: key,
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
        : Container();
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
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * appBarHeadingFontSizeNew,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                                color: colorThemePink,
                                fontWeight: FontWeight.w400,
                                fontSize: size.width * numD035),
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
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),

                    /// New Sort::

                    filterListWidget(
                        context, sortList, stateSetter, size, true),

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
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * numD04),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: commonElevatedButton(
                          applyText,
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        Navigator.pop(context);
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

  void _onRefresh() {
    _feedBloc.add(const FetchFeeds(isRefresh: true));
  }

  void _onLoading() {
    _feedBloc.add(LoadMoreFeeds());
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
      FilterModel(
          name: "Latest content",
          value: "desc",
          icon: "ic_monthly_calendar.png",
          isSelected: true),
      FilterModel(
          name: "Oldest content ",
          value: "asc",
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: "Highest earning content",
          value: "highest_earning",
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: "Lowest earning content",
          icon: "ic_eye_outlined.png",
          value: "lowest_earning",
          isSelected: false),
      FilterModel(
          name: "Most views",
          value: "most_views",
          icon: "ic_eye_outlined.png",
          isSelected: false),
      FilterModel(
          name: "Least views",
          value: "least_views",
          icon: "ic_eye_outlined.png",
          isSelected: false),
    ]);

    filterList.addAll([
      /*   FilterModel(
          name: allContentsText, icon: "ic_square_play.png", isSelected: true),
      FilterModel(name: allTasksText, icon: "ic_task.png", isSelected: false),*/
      FilterModel(
          name: allExclusiveContentText,
          icon: "ic_exclusive.png",
          isSelected: false),
      FilterModel(
          name: allSharedContentText, icon: "ic_share.png", isSelected: false),
      FilterModel(
          name: paymentsReceivedText,
          icon: "ic_payment_reviced.png",
          isSelected: false),
      FilterModel(
          name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
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

  Widget filterListWidget(BuildContext context, List<FilterModel> list,
      StateSetter stateSetter, Size size, bool isSort) {
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
              top: list[index].name == filterDateText
                  ? size.width * 0
                  : size.width * numD025,
              bottom: list[index].name == filterDateText
                  ? size.width * 0
                  : size.width * numD025,
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
                              int pos = list
                                  .indexWhere((element) => element.isSelected);
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
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                border: Border.all(
                                    width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.fromDate != null
                                        ? dateTimeFormatter(
                                            dateTime: item.fromDate.toString())
                                        : fromText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
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

                                DateTime parseFromDate =
                                    DateTime.parse(item.fromDate!);
                                DateTime parseToDate =
                                    DateTime.parse(pickedDate!);

                                debugPrint("parseFromDate : $parseFromDate");
                                debugPrint("parseToDate : $parseToDate");

                                if (parseToDate.isAfter(parseFromDate) ||
                                    parseToDate
                                        .isAtSameMomentAs(parseFromDate)) {
                                  item.toDate = pickedDate;
                                } else {
                                  showSnackBar(
                                      "Date Error",
                                      "Please select to date above from date",
                                      Colors.red);
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
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                border: Border.all(
                                    width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.toDate != null
                                        ? dateTimeFormatter(
                                            dateTime: item.toDate.toString())
                                        : toText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
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
                    : Text(list[index].name,
                        style: TextStyle(
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: "AirbnbCereal_W_Bk"))
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

  FlickManager? initialController(Feed feed, int currentMediaIndex) {
    FlickManager? flickManager;
    var content = feed.contentList[currentMediaIndex];
    
    if (content.mediaType == "audio") {
      initWaveData(contentImageUrl + content.mediaUrl);
    } else if (content.mediaType == "video") {
      debugPrint("videoLink=====> ${content.mediaUrl}");
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(contentImageUrl + content.mediaUrl),
        ),
        autoPlay: false,
      );
    }
    return flickManager;
  }

  /// Filter List API
  void callFilterListAPI() {
    Map<String, dynamic> map = {"limit": "10", "offset": "0"};

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos >= 0) {
      map["sort"] = sortList[pos].value!;
    }

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

    _feedBloc.add(FetchFeeds(isRefresh: true, newFilters: map));
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }






}
