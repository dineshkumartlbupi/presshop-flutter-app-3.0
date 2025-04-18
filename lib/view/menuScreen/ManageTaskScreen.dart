import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/commonEnums.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/PermissionHandler.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../authentication/TermCheckScreen.dart';
import '../cameraScreen/CameraScreen.dart';
import '../chatScreens/FullVideoView.dart';
import '../dashboard/Dashboard.dart';
import '../myEarning/MyEarningScreen.dart';
import '../myEarning/TransactionDetailScreen.dart';
import '../myEarning/earningDataModel.dart';
import 'ContactUsScreen.dart';
import 'FAQScreen.dart';
import 'MyContentScreen.dart';

class ManageTaskScreen extends StatefulWidget {
  final TaskDetailModel? taskDetail;
  MyContentData? myContentData;
  final String roomId;
  final Widget? contentMedia;
  final Widget? contentHeader;
  final String? contentId;
  final ManageTaskChatModel? mediaHouseDetail;
  final String type;

  ManageTaskScreen(
      {super.key,
      this.mediaHouseDetail,
      this.contentId,
      this.taskDetail,
      required this.roomId,
      required this.type,
      this.contentMedia,
      this.myContentData,
      this.contentHeader});

  @override
  State<StatefulWidget> createState() {
    return ManageTaskScreenState();
  }
}

class ManageTaskScreenState extends State<ManageTaskScreen>
    implements NetworkResponse {
  late Size size;

  late IO.Socket socket;

  final String _senderId = sharedPreferences!.getString(hopperIdKey) ?? "";
  TextEditingController ratingReviewController1 = TextEditingController();
  List<ManageTaskChatModel> chatList = [];
  List<int> indexList = [];
  List<String> dataList = [];
  List<EarningTransactionDetail> earningTransactionDataList = [];
  var scrollController = ScrollController();
  List<String> intList = [
    "User experience",
    "Safe",
    "Easy to use",
    "Instant money",
    "Anonymity",
    "Secure Payment",
    "Hopper Support"
  ];
  String _chatId = "";
  double ratings = 0.0;
  bool _againUpload = false;
  bool showAcceptBtn = false;
  bool showRejectBtn = false;
  bool isRatingGiven = false;
  String imageId = "";
  String contentView = "0";
  String contentPurchased = "0";
  FlickManager? flickManager;
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerController controller = PlayerController();
  int _currentMediaIndex = 0;
  bool audioPlaying = false;
  bool isLoading = false;
  bool isRequiredVisible = false;
  bool showCelebration = false;
  bool uploadSuccess = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    debugPrint("Class name :::::: $runtimeType::::::${widget.type}");
    debugPrint("ContentId ${widget.myContentData?.id}");
    super.initState();

    // socketConnectionFunc();
    callGetManageTaskListingApi();
  }

  void onTextChanged() {
    setState(() {
      isRequiredVisible = ratingReviewController1.text.isEmpty;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    socket.disconnect();
    socket.onDisconnect(
        (_) => socket.emit('room join', {"room_id": widget.roomId}));
    super.dispose();
  }

  Widget chatBubbleSpacer() {
    return SizedBox(
      height: size.width * numD05,
    );
  }

  Widget chatDividerSpacer() {
    return widgetDivider();
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      callGetManageTaskListingApi();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoad() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      callGetManageTaskListingApi();
    });
    _refreshController.loadComplete();
  }

  Widget widgetDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
      child: const Divider(color: colorGrey1),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                widget.contentMedia != null && widget.contentHeader != null
                    ? manageContentText
                    : manageTaskText,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * appBarHeadingFontSize),
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
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(initialPosition: 2)),
                        (route) => false);
                  },
                  child: Image.asset(
                    "${commonImagePath}ic_black_rabbit.png",
                    height: size.width * numD07,
                    width: size.width * numD07,
                  ),
                ),
                SizedBox(
                  width: size.width * numD04,
                )
              ],
            ),
            body: isLoading
                ? SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SmartRefresher(
                            controller: _refreshController,
                            onRefresh: _onRefresh,
                            onLoading: _onLoad,
                            enablePullUp: false,
                            enablePullDown: true,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: Column(
                                children: [
                                  widget.contentMedia != null &&
                                          widget.contentHeader != null
                                      ? contentDetailWidget()
                                      : const SizedBox.shrink(),
                                  widget.taskDetail != null
                                      ? showTaskPriceWidget()
                                      : const SizedBox.shrink(),

                                  widget.taskDetail != null
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * numD04),
                                          child: uploadMediaInfoWidget(""),
                                        )
                                      : Container(),

                                  /// This is fab
                                  widget.type != "content"
                                      ? Container()
                                      : Column(
                                          children: [
                                            // chatBubbleSpacer(),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: size.width *
                                                            numD04),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              spreadRadius: 2)
                                                        ]),
                                                    child: ClipOval(
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            size.width *
                                                                numD01),
                                                        child: Image.asset(
                                                          "${commonImagePath}ic_black_rabbit.png",
                                                          color: Colors.white,
                                                          width: size.width *
                                                              numD07,
                                                          height: size.width *
                                                              numD07,
                                                        ),
                                                      ),
                                                    )),
                                                SizedBox(
                                                  width: size.width * numD025,
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  margin: EdgeInsets.only(
                                                      top: 0,
                                                      right:
                                                          size.width * numD04),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          size.width * numD05,
                                                      vertical:
                                                          size.width * numD02),
                                                  width: size.width,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color:
                                                              colorGoogleButtonBorder),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(
                                                                size.width *
                                                                    numD04),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                size.width *
                                                                    numD04),
                                                        bottomRight:
                                                            Radius.circular(
                                                                size.width *
                                                                    numD04),
                                                      )),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height:
                                                            size.width * numD01,
                                                      ),
                                                      contentPurchased != "0"
                                                          ? RichText(
                                                              text: TextSpan(
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: size
                                                                            .width *
                                                                        numD037,
                                                                    fontFamily:
                                                                        "AirbnbCereal",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                  TextSpan(
                                                                    text:
                                                                        "This is fab. Your content was ",
                                                                    style: commonTextStyle(
                                                                        size:
                                                                            size,
                                                                        fontSize:
                                                                            size.width *
                                                                                numD036,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  ),
                                                                  int.parse(contentView) <
                                                                          2
                                                                      ? TextSpan(
                                                                          text: int.parse(contentView) > 2
                                                                              ? 'viewed by $contentView publications'
                                                                              : 'viewed by $contentView publication',
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * numD036,
                                                                              color: colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        )
                                                                      : TextSpan(
                                                                          text: int.parse(contentView) < 10
                                                                              ? 'viewed by $contentView publications'
                                                                              : 'viewed by $contentView publications',
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * numD036,
                                                                              color: colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                  TextSpan(
                                                                    text:
                                                                        " and ",
                                                                    style: commonTextStyle(
                                                                        size:
                                                                            size,
                                                                        fontSize:
                                                                            size.width *
                                                                                numD036,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.normal),
                                                                  ),
                                                                  int.parse(contentPurchased) <
                                                                          2
                                                                      ? TextSpan(
                                                                          text: int.parse(contentPurchased) < 2
                                                                              ? 'purchased by $contentPurchased publication'
                                                                              : 'purchased by $contentPurchased publications',
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * numD036,
                                                                              color: colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        )
                                                                      : TextSpan(
                                                                          text: int.parse(contentPurchased) < 10
                                                                              ? 'purchased by $contentPurchased publications'
                                                                              : 'purchased by $contentPurchased publications',
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * numD036,
                                                                              color: colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                ]))
                                                          : int.parse(contentView) <
                                                                  1
                                                              ? RichText(
                                                                  text: TextSpan(
                                                                      children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "You’re officially a newsmaker!  Your content has been ",
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD036,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.normal),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "successfully published.",
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD036,
                                                                            color:
                                                                                colorThemePink,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "Get ready for ",
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD036,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.normal),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "offers to start rolling in!",
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD036,
                                                                            color:
                                                                                colorThemePink,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                    ]))
                                                              : RichText(
                                                                  text: TextSpan(
                                                                      children: [
                                                                      TextSpan(
                                                                        text:
                                                                            "This is fab. Your content was ",
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD036,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.normal),
                                                                      ),
                                                                      TextSpan(
                                                                        text: int.parse(contentView) >
                                                                                2
                                                                            ? 'viewed by $contentView publications'
                                                                            : 'viewed by $contentView publication',
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD036,
                                                                            color:
                                                                                colorThemePink,
                                                                            fontWeight:
                                                                                FontWeight.w600),
                                                                      ),
                                                                    ])),
                                                      SizedBox(
                                                        height:
                                                            contentPurchased !=
                                                                    "0"
                                                                ? size.width *
                                                                    numD05
                                                                : size.width *
                                                                    numD01,
                                                      ),
                                                      contentPurchased != "0"
                                                          ? SizedBox(
                                                              height:
                                                                  size.width *
                                                                      numD13,
                                                              width: size.width,
                                                              child: commonElevatedButton(
                                                                  "View My Earnings",
                                                                  size,
                                                                  commonButtonTextStyle(
                                                                      size),
                                                                  commonButtonStyle(
                                                                      size,
                                                                      colorThemePink),
                                                                  () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder: (context) => MyEarningScreen(
                                                                              openDashboard: false,
                                                                            )));
                                                              }),
                                                            )
                                                          : Container(),
                                                      SizedBox(
                                                        height: size.height *
                                                            numD01,
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.width * numD025,
                                            ),
                                            // widgetDivider()
                                            chatDividerSpacer()
                                          ],
                                        ),

                                  SizedBox(
                                    height: size.height * numD01,
                                  ),

                                  ListView.separated(
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                          height: size.height * numD02,
                                        );
                                      },
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size.width * numD04,
                                      ),
                                      itemBuilder: (context, index) {
                                        var item = chatList[index];
                                        if (item.messageType == "media") {
                                          if (item.media!.type == "video") {
                                            return Column(
                                              children: [
                                                rightVideoChatWidget(
                                                    item.media!.thumbnail,
                                                    item.media!.imageVideoUrl),
                                                SizedBox(
                                                  height: size.width * numD03,
                                                ),
                                                thanksToUploadMediaWidget(
                                                    "video"),
                                                SizedBox(
                                                  height: size.width * numD03,
                                                ),
                                              ],
                                            );
                                          } else if (item.media!.type ==
                                              "audio") {
                                            return Column(
                                              children: [
                                                rightAudioChatWidget(
                                                    item.media!.imageVideoUrl),
                                                SizedBox(
                                                  height: size.width * numD03,
                                                ),
                                                thanksToUploadMediaWidget(
                                                    "audio"),
                                                SizedBox(
                                                  height: size.width * numD03,
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              children: [
                                                rightImageChatWidget(
                                                  item.media!.type == "video"
                                                      ? item.media!.thumbnail
                                                      : item
                                                          .media!.imageVideoUrl,
                                                  item.createdAtTime,
                                                ),
                                                SizedBox(
                                                  height: size.width * numD03,
                                                ),
                                                thanksToUploadMediaWidget(
                                                    "photo"),
                                                SizedBox(
                                                  height: size.width * numD03,
                                                ),
                                              ],
                                            );
                                          }
                                        } else if (item.messageType ==
                                            "Payment") {
                                          return paymentReceivedWidget(item);
                                        } else if (item.messageType ==
                                            "request_more_content") {
                                          return moreContentReqWidget(item);
                                        } else if (item.messageType ==
                                            "contentupload") {
                                          return Column(
                                            children: [
                                              uploadMediaInfoWidget(
                                                  "request_more_content"),
                                              SizedBox(
                                                height: size.width * numD03,
                                              ),
                                            ],
                                          );
                                        } else if (item.messageType ==
                                            "NocontentUpload") {
                                          return uploadNoContentWidget();
                                        } else if (item.messageType ==
                                            "Offered") {
                                          return mediaHouseOfferWidget(
                                              item,
                                              item.messageType ==
                                                  "Mediahouse_initial_offer");
                                        } else if (item.messageType ==
                                            "hopper_counter_offer") {
                                          return counterFieldWidget(item);
                                        }
                                        // else if (item.messageType == "rating_hopper") {
                                        //   return ratingWidget(item);
                                        // }
                                        else if (item.messageType ==
                                            "MakeOverPrice") {
                                          return makeOverPriceWidget(
                                              item.hopperPrice, item.amount);
                                        } else {
                                          return SizedBox.shrink();
                                        }
                                      },
                                      itemCount: chatList.length),

                                  ///  Rating Widget
                                  widget.type != "content"
                                      ? Container()
                                      : int.parse(contentPurchased) > 0
                                          ? Column(
                                              children: [
                                                SizedBox(
                                                  height: size.height * numD01,
                                                ),
                                                chatDividerSpacer(),
                                                SizedBox(
                                                  height: size.height * numD01,
                                                ),
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            margin: EdgeInsets.only(
                                                                left:
                                                                    size.width *
                                                                        numD04),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300,
                                                                      spreadRadius:
                                                                          2)
                                                                ]),
                                                            child: ClipOval(
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .all(size
                                                                            .width *
                                                                        numD01),
                                                                child:
                                                                    Image.asset(
                                                                  "${commonImagePath}ic_black_rabbit.png",
                                                                  color: Colors
                                                                      .white,
                                                                  width: size
                                                                          .width *
                                                                      numD07,
                                                                  height: size
                                                                          .width *
                                                                      numD07,
                                                                ),
                                                              ),
                                                            )),
                                                        SizedBox(
                                                          width: size.width *
                                                              numD025,
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                          margin: EdgeInsets.only(
                                                              right:
                                                                  size.width *
                                                                      numD04),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      size.width *
                                                                          numD04,
                                                                  vertical: size
                                                                          .width *
                                                                      numD02),
                                                          width: size.width,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              colorGoogleButtonBorder),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topRight: Radius.circular(
                                                                        size.width *
                                                                            numD04),
                                                                    bottomLeft: Radius.circular(
                                                                        size.width *
                                                                            numD04),
                                                                    bottomRight:
                                                                        Radius.circular(size.width *
                                                                            numD04),
                                                                  )),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    size.height *
                                                                        numD01,
                                                              ),
                                                              RichText(
                                                                  text: TextSpan(
                                                                      children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "Rate your experience with PressHop",
                                                                      style: commonTextStyle(
                                                                          size:
                                                                              size,
                                                                          fontSize: size.width *
                                                                              numD036,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                    ),
                                                                  ])),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD04,
                                                              ),
                                                              RatingBar(
                                                                glowRadius: 0,
                                                                ratingWidget:
                                                                    RatingWidget(
                                                                  empty: Image
                                                                      .asset(
                                                                          "${iconsPath}emptystar.png"),
                                                                  full: Image.asset(
                                                                      "${iconsPath}star.png"),
                                                                  half: Image.asset(
                                                                      "${iconsPath}ic_half_star.png"),
                                                                ),
                                                                onRatingUpdate:
                                                                    (value) {
                                                                  ratings =
                                                                      value;
                                                                  setState(
                                                                      () {});
                                                                },
                                                                itemSize:
                                                                    size.width *
                                                                        numD09,
                                                                itemCount: 5,
                                                                initialRating:
                                                                    ratings,
                                                                allowHalfRating:
                                                                    true,
                                                                itemPadding: EdgeInsets.only(
                                                                    left: size
                                                                            .width *
                                                                        numD03),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        0.04,
                                                              ),
                                                              const Text(
                                                                "Tell us what you liked about the App",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD018,
                                                              ),
                                                              Wrap(
                                                                  spacing: 0.2,
                                                                  runSpacing:
                                                                      0.1,
                                                                  children: List<
                                                                          Widget>.generate(
                                                                      intList
                                                                          .length,
                                                                      (int
                                                                          index) {
                                                                    return Container(
                                                                      margin: EdgeInsets.only(
                                                                          left: size.width *
                                                                              0.012,
                                                                          right:
                                                                              size.width * 0.012),
                                                                      child:
                                                                          ChoiceChip(
                                                                        label: Text(
                                                                            intList[index]),
                                                                        labelStyle: TextStyle(
                                                                            color: dataList.contains(intList[index])
                                                                                ? Colors.white
                                                                                : colorGrey6),
                                                                        onSelected:
                                                                            (bool
                                                                                selected) {
                                                                          if (selected) {
                                                                            for (int i = 0;
                                                                                i < intList.length;
                                                                                i++) {
                                                                              if (intList[i] == intList[index] && !dataList.contains(intList[i])) {
                                                                                dataList.add(intList[i]);
                                                                                indexList.add(i);
                                                                              }
                                                                            }
                                                                          } else {
                                                                            for (int i = 0;
                                                                                i < intList.length;
                                                                                i++) {
                                                                              if (intList[i] == intList[index] && dataList.contains(intList[i])) {
                                                                                dataList.remove(intList[i]);
                                                                                indexList.remove(i);
                                                                              }
                                                                            }
                                                                          }
                                                                          setState(
                                                                              () {});
                                                                        },
                                                                        selectedColor:
                                                                            colorThemePink,
                                                                        disabledColor:
                                                                            colorGreyChat.withOpacity(.3),
                                                                        selected: dataList.contains(intList[index])
                                                                            ? true
                                                                            : false,
                                                                      ),
                                                                    );
                                                                  })),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD02,
                                                              ),
                                                              Stack(
                                                                children: [
                                                                  TextFormField(
                                                                    controller:
                                                                        ratingReviewController1,
                                                                    cursorColor:
                                                                        colorTextFieldIcon,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    maxLines: 6,
                                                                    readOnly:
                                                                        false,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD035,
                                                                    ),
                                                                    onChanged:
                                                                        (v) {
                                                                      onTextChanged();
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          textData,
                                                                      contentPadding: EdgeInsets.only(
                                                                          left: size.width *
                                                                              numD08,
                                                                          right: size.width *
                                                                              numD02,
                                                                          top: size.width *
                                                                              numD075),
                                                                      hintStyle: TextStyle(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400,
                                                                          wordSpacing:
                                                                              2,
                                                                          fontSize:
                                                                              size.width * numD035),
                                                                      disabledBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(size.width *
                                                                              0.03),
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey.shade300)),
                                                                      focusedBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(size.width *
                                                                              0.03),
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey.shade300)),
                                                                      enabledBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(size.width *
                                                                              0.03),
                                                                          borderSide: const BorderSide(
                                                                              width: 1,
                                                                              color: Colors.black)),
                                                                      errorBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(size.width *
                                                                              0.03),
                                                                          borderSide: BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey.shade300)),
                                                                      focusedErrorBorder: OutlineInputBorder(
                                                                          borderRadius: BorderRadius.circular(size.width *
                                                                              0.03),
                                                                          borderSide: const BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey)),
                                                                      alignLabelWithHint:
                                                                          false,
                                                                    ),
                                                                    autovalidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        top: size.width *
                                                                            numD038,
                                                                        left: size.width *
                                                                            numD014),
                                                                    child: Image
                                                                        .asset(
                                                                      "${iconsPath}docs.png",
                                                                      width: size
                                                                              .width *
                                                                          0.06,
                                                                      height: size
                                                                              .width *
                                                                          0.07,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade400,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: size
                                                                          .width *
                                                                      numD017),
                                                              ratingReviewController1
                                                                      .text
                                                                      .isEmpty
                                                                  ? const Text(
                                                                      "Required",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          color:
                                                                              colorThemePink,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    )
                                                                  : Container(),
                                                              SizedBox(
                                                                  height: size
                                                                          .width *
                                                                      numD04),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD13,
                                                                width:
                                                                    size.width,
                                                                child:
                                                                    commonElevatedButton(
                                                                        isRatingGiven
                                                                            ? "Thanks a Ton"
                                                                            : submitText,
                                                                        size,
                                                                        isRatingGiven
                                                                            ? TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: size.width * numD037,
                                                                                fontFamily: "AirbnbCereal",
                                                                                fontWeight: FontWeight.bold)
                                                                            : commonButtonTextStyle(size),
                                                                        commonButtonStyle(size, isRatingGiven ? Colors.grey : colorThemePink),
                                                                        !isRatingGiven
                                                                            ? () {
                                                                                if (ratingReviewController1.text.isNotEmpty) {
                                                                                  var map = {
                                                                                    // "chat_id": item.id,
                                                                                    "rating": ratings,
                                                                                    "review": ratingReviewController1.text,
                                                                                    "features": dataList,
                                                                                    "image_id": widget.type == "content" ? widget.contentId : imageId,
                                                                                    "type": "content",
                                                                                    "sender_type": "hopper"
                                                                                  };
                                                                                  debugPrint("map function $map");
                                                                                  socketEmitFunc(socketEvent: "rating", messageType: "rating_for_hopper", dataMap: map);
                                                                                  showSnackBar("Rating & Review", "Thanks for the love! Your feedback makes all the difference ❤️", Colors.green);
                                                                                  showCelebration = true;
                                                                                  Future.delayed(const Duration(seconds: 3), () {
                                                                                    showCelebration = false;
                                                                                  });
                                                                                  setState(() {});
                                                                                } else {
                                                                                  showSnackBar("Required *", "Please Enter some review for mediahouse", Colors.red);
                                                                                }
                                                                              }
                                                                            : () {
                                                                                debugPrint("already rated:::;");
                                                                              }),
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.width *
                                                                          0.02),
                                                              RichText(
                                                                  text: TextSpan(
                                                                      style: commonTextStyle(
                                                                          size:
                                                                              size,
                                                                          fontSize: size.width *
                                                                              numD03,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                      children: [
                                                                    TextSpan(
                                                                      text:
                                                                          "Please refer to our ",
                                                                      style: commonTextStyle(
                                                                          size:
                                                                              size,
                                                                          fontSize: size.width *
                                                                              numD03,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    TextSpan(
                                                                        text:
                                                                            "Terms & Conditions. ",
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD03,
                                                                            color:
                                                                                colorThemePink,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        recognizer: TapGestureRecognizer()
                                                                          ..onTap = () {
                                                                            Navigator.of(context).push(MaterialPageRoute(
                                                                                builder: (context) => TermCheckScreen(
                                                                                      type: 'legal',
                                                                                    )));
                                                                          }),
                                                                    TextSpan(
                                                                      text:
                                                                          "The price of your content can be automatically adjusted in order to increase sales. If you have any questions, please ",
                                                                      style: commonTextStyle(
                                                                          size:
                                                                              size,
                                                                          fontSize: size.width *
                                                                              numD03,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                    TextSpan(
                                                                        text:
                                                                            "contact ",
                                                                        style: commonTextStyle(
                                                                            size:
                                                                                size,
                                                                            fontSize: size.width *
                                                                                numD03,
                                                                            color:
                                                                                colorThemePink,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                        recognizer: TapGestureRecognizer()
                                                                          ..onTap = () {
                                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactUsScreen()));
                                                                          }),
                                                                    TextSpan(
                                                                      text:
                                                                          "our helpful teams who are available 24x7 to assist you. Thank you",
                                                                      style: commonTextStyle(
                                                                          size:
                                                                              size,
                                                                          fontSize: size.width *
                                                                              numD03,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.w400),
                                                                    ),
                                                                  ])),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        0.01,
                                                              ),

                                                              /*Row(
                                                                    children: [
                                                                      Expanded(
                                                                              child: SizedBox(
                                                                                height: size.width * numD13,
                                                                                width: size.width,
                                                                                child: ElevatedButton(
                                                                                  onPressed: () {
                                                                                        if (item.requestStatus.isEmpty &&
                                                !item.isMakeCounterOffer) {
                                              var map1 = {
                                                "chat_id": item.id,
                                                "status": false,
                                              };
                                                
                                              socketEmitFunc(
                                                  socketEvent: "reqstatus",
                                                  messageType: "",
                                                  dataMap: map1);
                                                
                                              socketEmitFunc(
                                                socketEvent: "chat message",
                                                messageType: "reject_mediaHouse_offer",
                                              );
                                                
                                              socketEmitFunc(
                                                socketEvent: "chat message",
                                                messageType: "rating_hopper",
                                              );
                                                
                                              socketEmitFunc(
                                                socketEvent: "chat message",
                                                messageType: "rating_mediaHouse",
                                              );
                                              showRejectBtn = true;
                                                                                        }
                                                                                        setState(() {});
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: item.requestStatus.isEmpty &&
                                                  !item.isMakeCounterOffer
                                                  ? Colors.black
                                                  : item.requestStatus == "false"
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(size.width * numD04),
                                                  side: (item.requestStatus == "false" ||
                                                      item.requestStatus.isEmpty) &&
                                                      !item.isMakeCounterOffer
                                                      ? BorderSide.none
                                                      : const BorderSide(
                                                      color: Colors.black, width: 1))),
                                                                                  child: Text(
                                                                                        rejectText,
                                                                                        style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD037,
                                                color: (item.requestStatus == "false" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? Colors.white
                                                    : colorLightGreen,
                                                fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ),
                                                                              )),
                                                                      SizedBox(
                                                                        width: size.width * numD04,
                                                                      ),
                                                                      Expanded(
                                                                              child: SizedBox(
                                                                                height: size.width * numD13,
                                                                                width: size.width,
                                                                                child: ElevatedButton(
                                                                                  onPressed: () {
                                                                                        //aditya accept btn
                                                                                        if (item.requestStatus.isEmpty &&
                                                !item.isMakeCounterOffer) {
                                              debugPrint("tapppppp:::::$showAcceptBtn");
                                              showAcceptBtn = true;
                                              var map1 = {
                                                "chat_id": item.id,
                                                "status": true,
                                              };
                                                
                                              socketEmitFunc(
                                                  socketEvent: "reqstatus",
                                                  messageType: "",
                                                  dataMap: map1);
                                                
                                              socketEmitFunc(
                                                  socketEvent: "chat message",
                                                  messageType: "accept_mediaHouse_offer",
                                                  dataMap: {
                                                    "amount": isMakeCounter
                                                        ? item.initialOfferAmount
                                                        : item.finalCounterAmount,
                                                    "image_id": widget.contentId!,
                                                  });
                                                                                        }
                                                                                        setState(() {});
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor: item.requestStatus.isEmpty &&
                                                  !item.isMakeCounterOffer
                                                  ? colorThemePink
                                                  : item.requestStatus == "true"
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(size.width * numD04),
                                                  side: (item.requestStatus == "true" ||
                                                      item.requestStatus.isEmpty) &&
                                                      !item.isMakeCounterOffer
                                                      ? BorderSide.none
                                                      : const BorderSide(
                                                      color: Colors.black, width: 1))),
                                                                                  child: Text(
                                                                                        acceptText,
                                                                                        style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD037,
                                                color: (item.requestStatus == "true" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? Colors.white
                                                    : colorLightGreen,
                                                fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ),
                                                                              )),
                                                
                                                                      */
                                                              /* Expanded(
                                                                              child: SizedBox(
                                                                                height: size.width * numD13,
                                                                                width: size.width,
                                                                                child: ElevatedButton(
                                                                                  onPressed: () {
                                                                                        if(item.requestStatus.isEmpty){
                                                
                                              var map1 = {
                                                "chat_id" : item.id,
                                                "status" : true,
                                              };
                                                
                                              socketEmitFunc(
                                                  socketEvent: "reqstatus",
                                                  messageType: "",
                                                  dataMap: map1
                                              );
                                                
                                              socketEmitFunc(
                                                  socketEvent: "chat message",
                                                  messageType: "contentupload",
                                              );
                                                                                        }
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              item.requestStatus.isEmpty
                                                  ? colorThemePink
                                                  :item.requestStatus == "true"
                                                  ?  Colors.grey
                                                  :  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    size.width * numD04),
                                                  side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                                      color: colorGrey1, width: 2)
                                              )),
                                                                                  child: Text(
                                                                                        yesText,
                                                                                        style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD04,
                                                color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : colorLightGreen,
                                                fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ),
                                                                              )),*/
                                                              /*
                                                                    ],
                                                                  ),*/
                                                            ],
                                                          ),
                                                        )),
                                                      ],
                                                    ),
                                                    showCelebration
                                                        ? Lottie.asset(
                                                            "assets/lottieFiles/celebrate.json",
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container(),

                                  widget.type == "task_content"
                                      ? (widget.taskDetail!.paidStatus == "paid"
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: size.width * numD04,
                                                  right: size.width * numD04),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: size.width *
                                                            numD013),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              spreadRadius: 2)
                                                        ]),
                                                    child: ClipOval(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            size.width *
                                                                numD01),
                                                        child: Image.asset(
                                                          "${commonImagePath}ic_black_rabbit.png",
                                                          width: size.width *
                                                              numD075,
                                                          height: size.width *
                                                              numD075,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * numD04,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                              horizontal:
                                                                  size.width *
                                                                      numD05,
                                                              vertical:
                                                                  size.width *
                                                                      numD02),
                                                      width: size.width,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade400),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                          )),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: size.width *
                                                                numD01,
                                                          ),
                                                          RichText(
                                                              text: TextSpan(
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        "AirbnbCereal",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Congratulations, ",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                ),
                                                                TextSpan(
                                                                  text: widget
                                                                      .taskDetail!
                                                                      .mediaHouseName,
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color:
                                                                          colorThemePink,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      " has purchased your content for ",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "$euroUniqueCode${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color:
                                                                          colorThemePink,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ])),
                                                          SizedBox(
                                                            height: size.width *
                                                                numD03,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD13,
                                                                width:
                                                                    size.width,
                                                                child: commonElevatedButton(
                                                                    "View Transaction Details task",
                                                                    size,
                                                                    commonButtonTextStyle(
                                                                        size),
                                                                    commonButtonStyle(
                                                                        size,
                                                                        colorThemePink),
                                                                    () {
                                                                  callDetailApi(widget
                                                                      .taskDetail!
                                                                      .mediaHouseId);
                                                                }),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD01,
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container())
                                      : Container(),

                                  SizedBox(
                                    height: size.width * numD04,
                                  ),
                                  widget.type == "task_content"
                                      ? (widget.taskDetail!.paidStatus == "paid"
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  left: size.width * numD04,
                                                  right: size.width * numD04),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: size.width *
                                                            numD013),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.grey
                                                                  .shade300,
                                                              spreadRadius: 2)
                                                        ]),
                                                    child: ClipOval(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            size.width *
                                                                numD01),
                                                        child: Image.asset(
                                                          "${commonImagePath}ic_black_rabbit.png",
                                                          width: size.width *
                                                              numD075,
                                                          height: size.width *
                                                              numD075,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: size.width * numD04,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                              horizontal:
                                                                  size.width *
                                                                      numD05,
                                                              vertical:
                                                                  size.width *
                                                                      numD02),
                                                      width: size.width,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color:
                                                                  colorGoogleButtonBorder),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                          )),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: size.width *
                                                                numD01,
                                                          ),
                                                          RichText(
                                                              text: TextSpan(
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: size
                                                                            .width *
                                                                        numD037,
                                                                    fontFamily:
                                                                        "AirbnbCereal",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Woohoo! We have paid ",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "$euroUniqueCode${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color:
                                                                          colorThemePink,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      " into your bank account. Please visit ",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      "My Earnings",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color:
                                                                          colorThemePink,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      " to view your transaction ",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal),
                                                                )
                                                              ])),
                                                          SizedBox(
                                                            height: size.width *
                                                                numD025,
                                                          ),
                                                          /*Row(
                            children: [
                              Expanded(
                                    child: SizedBox(
                                      height: size.width * numD13,
                                      width: size.width,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (item.requestStatus.isEmpty &&
                                              !item.isMakeCounterOffer) {
                                            var map1 = {
                                              "chat_id": item.id,
                                              "status": false,
                                            };
                                                
                                            socketEmitFunc(
                                                socketEvent: "reqstatus",
                                                messageType: "",
                                                dataMap: map1);
                                                
                                            socketEmitFunc(
                                              socketEvent: "chat message",
                                              messageType: "reject_mediaHouse_offer",
                                            );
                                                
                                            socketEmitFunc(
                                              socketEvent: "chat message",
                                              messageType: "rating_hopper",
                                            );
                                                
                                            socketEmitFunc(
                                              socketEvent: "chat message",
                                              messageType: "rating_mediaHouse",
                                            );
                                            showRejectBtn = true;
                                          }
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: item.requestStatus.isEmpty &&
                                                !item.isMakeCounterOffer
                                                ? Colors.black
                                                : item.requestStatus == "false"
                                                ? Colors.grey
                                                : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(size.width * numD04),
                                                side: (item.requestStatus == "false" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? BorderSide.none
                                                    : const BorderSide(
                                                    color: Colors.black, width: 1))),
                                        child: Text(
                                          rejectText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD037,
                                              color: (item.requestStatus == "false" ||
                                                  item.requestStatus.isEmpty) &&
                                                  !item.isMakeCounterOffer
                                                  ? Colors.white
                                                  : colorLightGreen,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                    child: SizedBox(
                                      height: size.width * numD13,
                                      width: size.width,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          //aditya accept btn
                                          if (item.requestStatus.isEmpty &&
                                              !item.isMakeCounterOffer) {
                                            debugPrint("tapppppp:::::$showAcceptBtn");
                                            showAcceptBtn = true;
                                            var map1 = {
                                              "chat_id": item.id,
                                              "status": true,
                                            };
                                                
                                            socketEmitFunc(
                                                socketEvent: "reqstatus",
                                                messageType: "",
                                                dataMap: map1);
                                                
                                            socketEmitFunc(
                                                socketEvent: "chat message",
                                                messageType: "accept_mediaHouse_offer",
                                                dataMap: {
                                                  "amount": isMakeCounter
                                                      ? item.initialOfferAmount
                                                      : item.finalCounterAmount,
                                                  "image_id": widget.contentId!,
                                                });
                                          }
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            backgroundColor: item.requestStatus.isEmpty &&
                                                !item.isMakeCounterOffer
                                                ? colorThemePink
                                                : item.requestStatus == "true"
                                                ? Colors.grey
                                                : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(size.width * numD04),
                                                side: (item.requestStatus == "true" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? BorderSide.none
                                                    : const BorderSide(
                                                    color: Colors.black, width: 1))),
                                        child: Text(
                                          acceptText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD037,
                                              color: (item.requestStatus == "true" ||
                                                  item.requestStatus.isEmpty) &&
                                                  !item.isMakeCounterOffer
                                                  ? Colors.white
                                                  : colorLightGreen,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )),
                                                
                              */
                                                          /* Expanded(
                                    child: SizedBox(
                                      height: size.width * numD13,
                                      width: size.width,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if(item.requestStatus.isEmpty){
                                                
                                            var map1 = {
                                              "chat_id" : item.id,
                                              "status" : true,
                                            };
                                                
                                            socketEmitFunc(
                                                socketEvent: "reqstatus",
                                                messageType: "",
                                                dataMap: map1
                                            );
                                                
                                            socketEmitFunc(
                                                socketEvent: "chat message",
                                                messageType: "contentupload",
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            item.requestStatus.isEmpty
                                                ? colorThemePink
                                                :item.requestStatus == "true"
                                                ?  Colors.grey
                                                :  Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  size.width * numD04),
                                                side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                                    color: colorGrey1, width: 2)
                                            )),
                                        child: Text(
                                          yesText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD04,
                                              color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : colorLightGreen,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )),*/ /*
                            ],
                                                    ),*/
                                                          SizedBox(
                                                            height: size.width *
                                                                numD03,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD13,
                                                                width:
                                                                    size.width,
                                                                child: commonElevatedButton(
                                                                    "View My Earnings",
                                                                    size,
                                                                    commonButtonTextStyle(
                                                                        size),
                                                                    commonButtonStyle(
                                                                        size,
                                                                        colorThemePink),
                                                                    () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(MaterialPageRoute(
                                                                          builder: (context) => MyEarningScreen(
                                                                                openDashboard: false,
                                                                              )));
                                                                }),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    size.width *
                                                                        numD01,
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          : Container())
                                      : Container(),
                                  SizedBox(
                                    height: size.width * numD04,
                                  ),

                                  widget.type == "task_content"
                                      ? (widget.taskDetail!.paidStatus == "paid"
                                          ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          left: size.width *
                                                              numD04),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                spreadRadius: 2)
                                                          ]),
                                                      child: ClipOval(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  size.width *
                                                                      numD01),
                                                          child: Image.asset(
                                                            "${commonImagePath}ic_black_rabbit.png",
                                                            width: size.width *
                                                                numD075,
                                                            height: size.width *
                                                                numD075,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          size.width * numD04,
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      margin: EdgeInsets.only(
                                                          right: size.width *
                                                              numD04,
                                                          bottom: size.width *
                                                              numD06),
                                                      padding: EdgeInsets
                                                          .symmetric(
                                                              horizontal:
                                                                  size.width *
                                                                      numD05,
                                                              vertical:
                                                                  size.width *
                                                                      numD02),
                                                      width: size.width,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade400),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    size.width *
                                                                        numD04),
                                                          )),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: size.width *
                                                                numD04,
                                                          ),
                                                          RichText(
                                                              text: TextSpan(
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        "AirbnbCereal",
                                                                  ),
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Rate your experience with PressHop",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD035,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ])),
                                                          SizedBox(
                                                            height: size.width *
                                                                numD04,
                                                          ),
                                                          RatingBar(
                                                            glowRadius: 0,
                                                            ratingWidget:
                                                                RatingWidget(
                                                              empty: Image.asset(
                                                                  "${iconsPath}emptystar.png"),
                                                              full: Image.asset(
                                                                  "${iconsPath}star.png"),
                                                              half: Image.asset(
                                                                  "${iconsPath}ic_half_star.png"),
                                                            ),
                                                            onRatingUpdate:
                                                                (value) {
                                                              ratings = value;
                                                              setState(() {});
                                                            },
                                                            itemSize:
                                                                size.width *
                                                                    numD09,
                                                            itemCount: 5,
                                                            initialRating:
                                                                ratings,
                                                            allowHalfRating:
                                                                true,
                                                            itemPadding:
                                                                EdgeInsets.only(
                                                                    left: size
                                                                            .width *
                                                                        numD03),
                                                          ),
                                                          SizedBox(
                                                            height: size.width *
                                                                0.04,
                                                          ),
                                                          Text(
                                                            "Tell us what you liked about the App",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    size.width *
                                                                        numD035,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    "AirbnbCereal",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                          SizedBox(
                                                            height: size.width *
                                                                numD018,
                                                          ),
                                                          Wrap(
                                                              children: List<
                                                                      Widget>.generate(
                                                                  intList
                                                                      .length,
                                                                  (int index) {
                                                            return Container(
                                                              margin: EdgeInsets.only(
                                                                  left:
                                                                      size.width *
                                                                          0.02,
                                                                  right:
                                                                      size.width *
                                                                          0.02),
                                                              child: ChoiceChip(
                                                                label: Text(
                                                                    intList[
                                                                        index]),
                                                                labelStyle: TextStyle(
                                                                    color: dataList.contains(intList[
                                                                            index])
                                                                        ? Colors
                                                                            .white
                                                                        : colorGrey6,
                                                                    fontFamily:
                                                                        "AirbnbCereal",
                                                                    fontSize: size
                                                                            .width *
                                                                        numD035),
                                                                onSelected: (bool
                                                                    selected) {
                                                                  if (selected) {
                                                                    for (int i =
                                                                            0;
                                                                        i < intList.length;
                                                                        i++) {
                                                                      if (intList[i] ==
                                                                              intList[index] &&
                                                                          !dataList.contains(intList[i])) {
                                                                        dataList
                                                                            .add(intList[i]);
                                                                        indexList
                                                                            .add(i);
                                                                      }
                                                                    }
                                                                  } else {
                                                                    for (int i =
                                                                            0;
                                                                        i < intList.length;
                                                                        i++) {
                                                                      if (intList[i] ==
                                                                              intList[index] &&
                                                                          dataList.contains(intList[i])) {
                                                                        dataList
                                                                            .remove(intList[i]);
                                                                        indexList
                                                                            .remove(i);
                                                                      }
                                                                    }
                                                                  }
                                                                  setState(
                                                                      () {});
                                                                },
                                                                selectedColor:
                                                                    colorThemePink,
                                                                disabledColor:
                                                                    colorGreyChat
                                                                        .withOpacity(
                                                                            .3),
                                                                selected: dataList
                                                                        .contains(
                                                                            intList[index])
                                                                    ? true
                                                                    : false,
                                                              ),
                                                            );
                                                          })),
                                                          SizedBox(
                                                            height: size.width *
                                                                numD02,
                                                          ),
                                                          Stack(
                                                            children: [
                                                              TextFormField(
                                                                controller:
                                                                    ratingReviewController1,
                                                                cursorColor:
                                                                    colorTextFieldIcon,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .multiline,
                                                                maxLines: 6,
                                                                readOnly: false,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: size
                                                                          .width *
                                                                      numD035,
                                                                ),
                                                                onChanged: (v) {
                                                                  onTextChanged();
                                                                },
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      textData,
                                                                  contentPadding: EdgeInsets.only(
                                                                      left: size
                                                                              .width *
                                                                          numD08,
                                                                      right: size
                                                                              .width *
                                                                          numD02,
                                                                      top: size
                                                                              .width *
                                                                          numD075),
                                                                  hintStyle: TextStyle(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade400,
                                                                      wordSpacing:
                                                                          2,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD035),
                                                                  disabledBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(size.width *
                                                                              0.03),
                                                                      borderSide: BorderSide(
                                                                          width:
                                                                              1,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300)),
                                                                  focusedBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(size.width *
                                                                              0.03),
                                                                      borderSide: BorderSide(
                                                                          width:
                                                                              1,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300)),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(size.width *
                                                                              0.03),
                                                                      borderSide: const BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.black)),
                                                                  errorBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(size.width *
                                                                              0.03),
                                                                      borderSide: BorderSide(
                                                                          width:
                                                                              1,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade300)),
                                                                  focusedErrorBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(size.width *
                                                                              0.03),
                                                                      borderSide: const BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.grey)),
                                                                  alignLabelWithHint:
                                                                      false,
                                                                ),
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .onUserInteraction,
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: size
                                                                            .width *
                                                                        numD038,
                                                                    left: size
                                                                            .width *
                                                                        numD014),
                                                                child:
                                                                    Image.asset(
                                                                  "${iconsPath}docs.png",
                                                                  width:
                                                                      size.width *
                                                                          0.06,
                                                                  height:
                                                                      size.width *
                                                                          0.07,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade400,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  size.width *
                                                                      numD017),
                                                          ratingReviewController1
                                                                  .text.isEmpty
                                                              ? const Text(
                                                                  "Required",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color:
                                                                          colorThemePink,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                )
                                                              : Container(),
                                                          SizedBox(
                                                              height:
                                                                  size.width *
                                                                      numD04),
                                                          SizedBox(
                                                            height: size.width *
                                                                numD13,
                                                            width: size.width,
                                                            child:
                                                                commonElevatedButton(
                                                                    isRatingGiven
                                                                        ? "Thanks a Ton"
                                                                        : submitText,
                                                                    size,
                                                                    isRatingGiven
                                                                        ? TextStyle(
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize: size.width *
                                                                                numD037,
                                                                            fontFamily:
                                                                                "AirbnbCereal",
                                                                            fontWeight: FontWeight
                                                                                .bold)
                                                                        : commonButtonTextStyle(
                                                                            size),
                                                                    commonButtonStyle(
                                                                        size,
                                                                        isRatingGiven
                                                                            ? Colors.grey
                                                                            : colorThemePink),
                                                                    !isRatingGiven
                                                                        ? () {
                                                                            if (ratingReviewController1.text.isNotEmpty) {
                                                                              var map = {
                                                                                // "chat_id": item.id,
                                                                                "rating": ratings,
                                                                                "review": ratingReviewController1.text,
                                                                                "features": dataList,
                                                                                "image_id": widget.type == "content" ? widget.contentId : imageId,
                                                                                "type": "content",
                                                                                "sender_type": "hopper"
                                                                              };
                                                                              debugPrint("map function $map");
                                                                              socketEmitFunc(socketEvent: "rating", messageType: "rating_for_hopper", dataMap: map);
                                                                              showSnackBar("Rating & Review", "Thanks for the love! Your feedback makes all the difference ❤️", Colors.green);
                                                                              showCelebration = true;
                                                                              Future.delayed(const Duration(seconds: 3), () {
                                                                                showCelebration = false;
                                                                              });
                                                                              setState(() {});
                                                                            } else {
                                                                              showSnackBar("Required *", "Please Enter some review for mediahouse", Colors.red);
                                                                            }
                                                                          }
                                                                        : () {
                                                                            debugPrint("already rated:::;");
                                                                          }),
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  size.width *
                                                                      0.01),
                                                          RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                TextSpan(
                                                                  text:
                                                                      "Please refer to our ",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      lineHeight:
                                                                          1.2,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                TextSpan(
                                                                    text:
                                                                        "Terms & Conditions. ",
                                                                    style: commonTextStyle(
                                                                        size:
                                                                            size,
                                                                        fontSize:
                                                                            size.width *
                                                                                numD036,
                                                                        color:
                                                                            colorThemePink,
                                                                        lineHeight:
                                                                            2,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600),
                                                                    recognizer:
                                                                        TapGestureRecognizer()
                                                                          ..onTap =
                                                                              () {
                                                                            Navigator.of(context).push(MaterialPageRoute(
                                                                                builder: (context) => TermCheckScreen(
                                                                                      type: 'legal',
                                                                                    )));
                                                                          }),
                                                                TextSpan(
                                                                  text:
                                                                      "If you have any questions, please ",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                TextSpan(
                                                                    text:
                                                                        "contact ",
                                                                    style: commonTextStyle(
                                                                        size:
                                                                            size,
                                                                        fontSize:
                                                                            size.width *
                                                                                numD036,
                                                                        color:
                                                                            colorThemePink,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600),
                                                                    recognizer:
                                                                        TapGestureRecognizer()
                                                                          ..onTap =
                                                                              () {
                                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ContactUsScreen()));
                                                                          }),
                                                                TextSpan(
                                                                  text:
                                                                      "our helpful teams who are available 24x7 to assist you. Thank you",
                                                                  style: commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD036,
                                                                      color: Colors
                                                                          .black,
                                                                      lineHeight:
                                                                          1.4,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                              ])),
                                                          SizedBox(
                                                            height: size.width *
                                                                0.01,
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                                showCelebration
                                                    ? Lottie.asset(
                                                        "assets/lottieFiles/celebrate.json",
                                                      )
                                                    : Container(),
                                              ],
                                            )
                                          : Container())
                                      : Container(),

                                  !showAcceptBtn || !showRejectBtn
                                      ? Container()
                                      : Padding(
                                          padding: EdgeInsets.all(
                                              size.width * numD03),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              profilePicWidget(),
                                              SizedBox(
                                                width: size.width * numD04,
                                              ),
                                              Expanded(
                                                  child: Container(
                                                padding: EdgeInsets.all(
                                                    size.width * numD02),
                                                width: size.width,
                                                decoration: BoxDecoration(
                                                    color: colorLightGrey,
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius: BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(size
                                                                    .width *
                                                                numD04),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                size.width *
                                                                    numD04),
                                                        bottomRight:
                                                            Radius.circular(
                                                                size.width *
                                                                    numD04))),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          size.width * numD04,
                                                    ),
                                                    Text(
                                                      showRejectBtn
                                                          ? " The offer is rejected by you."
                                                          : "Well done, the offer is now accepted",
                                                      style: commonTextStyle(
                                                          size: size,
                                                          fontSize: size.width *
                                                              numD035,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          size.width * numD04,
                                                    ),
                                                  ],
                                                ),
                                              ))
                                            ],
                                          ),
                                        ),
                                  widgetDivider(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: size.height * numD01),
                                    child: Text(
                                      "Please refresh to view more offers.",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.black,
                                          lineHeight: 1.2,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: (widget.type != "content"),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD04,
                                      vertical: size.width * numD02),
                                  height: size.width * numD18,
                                  child: commonElevatedButton(
                                      galleryText,
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, Colors.black),
                                      () {
                                    getImage(ImageSource.gallery);
                                  }),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD04,
                                      vertical: size.width * numD02),
                                  margin: EdgeInsets.only(bottom: 8),
                                  height: size.width * numD18,
                                  child: commonElevatedButton(
                                      cameraText,
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, colorThemePink),
                                      () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CameraScreen(
                                                  picAgain: true,
                                                  previousScreen: ScreenNameEnum
                                                      .manageTaskScreen,
                                                ))).then((value) {
                                      if (value != null) {
                                        debugPrint("value:::::$value");
                                        List<CameraData> cameraData = value;

                                        if (cameraData.first.mimeType ==
                                            "video") {
                                          generateVideoThumbnail(
                                              cameraData.first.path);
                                        } else if (cameraData.first.mimeType ==
                                            "audio") {
                                          Map<String, String> mediaMap = {
                                            "imageAndVideo":
                                                cameraData.first.path,
                                          };
                                          callUploadMediaApi(mediaMap, "audio");
                                        } else {
                                          Map<String, String> mediaMap = {
                                            "imageAndVideo":
                                                cameraData.first.path,
                                          };
                                          callUploadMediaApi(mediaMap, "image");
                                        }
                                      }
                                    });
                                  }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(child: showLoader())));
  }

  Widget contentDetailWidget() {
    return Column(
      children: [
        showMediaWidget(),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD04,
              vertical:
                  widget.myContentData!.exclusive ? size.width * numD02 : 0),
          child: headerWidget(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
          child: const Divider(
            color: colorGrey1,
          ),
        ),
        SizedBox(
          height: size.height * numD015,
        )
      ],
    );
  }

  Widget headerWidget() {
    return Column(
      children: [
        widget.myContentData!.contentMediaList.length > 1
            ? Align(
                alignment: Alignment.bottomCenter,
                child: DotsIndicator(
                  dotsCount: widget.myContentData!.contentMediaList.length,
                  position: _currentMediaIndex,
                  decorator: const DotsDecorator(
                    color: Colors.grey, // Inactive color
                    activeColor: Colors.redAccent,
                  ),
                ),
              )
            : Container(),
        SizedBox(
          height: size.width * numD03,
        ),
        Row(
          children: [
            Text(
              widget.myContentData!.exclusive ? "" : multipleText.toUpperCase(),
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD033,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            Row(
              children: [
                Image.asset(
                  widget.myContentData!.exclusive
                      ? "${iconsPath}ic_exclusive.png"
                      : "${iconsPath}ic_share.png",
                  height: size.width * numD035,
                ),
                SizedBox(
                  width: size.width * numD02,
                ),
                Text(
                  widget.myContentData!.exclusive ? exclusiveText : sharedText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: size.width * numD04,
        ),

        /// Title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD005,
                  ),
                  Text(
                    widget.myContentData!.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD04,
                        color: Colors.black,
                        lineHeight: 1.5,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),

                  /// Offers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageIcon(const AssetImage("${iconsPath}dollar1.png"),
                              color: widget.myContentData?.offerCount == 0
                                  ? Colors.grey
                                  : colorThemePink,
                              size: size.width * numD042),
                          SizedBox(width: size.width * numD018),
                          Text(
                            '${widget.myContentData?.offerCount} ${widget.myContentData!.offerCount > 1 ? '${offerText}s' : offerText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD029,
                                color: widget.myContentData?.offerCount == 0
                                    ? Colors.grey
                                    : colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: widget.myContentData!.offerCount >= 0
                              ? size.width * numD04
                              : size.width * numD02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageIcon(const AssetImage("${iconsPath}dollar1.png"),
                              color: widget.myContentData
                                          ?.purchasedMediahouseCount ==
                                      0
                                  ? Colors.grey
                                  : colorThemePink,
                              size: size.width * numD042),
                          SizedBox(width: size.width * numD018),
                          Text(
                            '${widget.myContentData?.purchasedMediahouseCount} ${widget.myContentData!.purchasedMediahouseCount > 1 ? '${sold}s' : sold}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD029,
                                color: widget.myContentData?.offerCount == 0
                                    ? Colors.grey
                                    : colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: widget.myContentData!.offerCount >= 0
                              ? size.width * numD04
                              : size.width * numD02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageIcon(const AssetImage("${iconsPath}ic_view.png"),
                              color: widget.myContentData!.contentView == 0
                                  ? Colors.grey
                                  : colorThemePink,
                              size: size.width * numD05),
                          SizedBox(width: size.width * numD018),
                          Text(
                            '${widget.myContentData!.contentView.toString()} ${widget.myContentData!.contentView > 1 ? '${viewsText}s' : viewsText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD029,
                                color: (widget.myContentData!.paidStatus ==
                                                paidText &&
                                            widget.myContentData!.contentView ==
                                                1) ||
                                        widget.myContentData!.contentView == 0
                                    ? Colors.grey
                                    : colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),

                  /// Time Date
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_clock.png",
                        height: size.width * numD04,
                        color: colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * numD018,
                      ),
                      Text(
                        DateFormat('hh:mm a').format(
                            DateTime.parse(widget.myContentData!.dateTime)),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD028,
                            color: colorHint,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: size.width * numD012,
                      ),
                      Image.asset(
                        "${iconsPath}ic_yearly_calendar.png",
                        height: size.width * numD04,
                        color: colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * numD02,
                      ),
                      Text(
                        DateFormat("dd MMM yyyy").format(
                            DateTime.parse(widget.myContentData!.dateTime)),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD028,
                            color: colorHint,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),

                  /// Location
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_location.png",
                        height: size.width * numD045,
                        color: colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * numD01,
                      ),
                      Expanded(
                        child: Text(
                          widget.myContentData!.location,
                          overflow: TextOverflow.ellipsis,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD028,
                              color: colorHint,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width * numD07,
            ),

            /// price
            Container(
              width: size.width * numD30,
              padding: EdgeInsets.symmetric(vertical: size.width * numD012),
              /*    padding: EdgeInsets.symmetric(
                  horizontal: myContentData!.paidStatus == unPaidText
                      ? size.width * numD06
                      : myContentData!.paidStatus == paidText &&
                              !myContentData!.isPaidStatusToHopper
                          ? size.width * numD04
                          : size.width * numD06,
                  vertical: size.width * numD01),*/
              decoration: BoxDecoration(
                  color: widget.myContentData!.paidStatus == unPaidText
                      ? colorThemePink
                      : /*myContentData!.paidStatus == paidText &&
                              !myContentData!.isPaidStatusToHopper
                          ? colorThemePink
                          :*/
                      colorLightGrey,
                  borderRadius: BorderRadius.circular(size.width * numD03)),
              child: Column(
                children: [
                  Text(
                    widget.myContentData!.paidStatus == unPaidText
                        ? 'Published Price'
                        : widget.myContentData!.paidStatus == paidText &&
                                widget.myContentData!.isPaidStatusToHopper
                            ? receivedText
                            : soldText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: widget.myContentData!.paidStatus == unPaidText
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                  FittedBox(
                    child: Container(
                      margin: EdgeInsets.only(
                        left: size.width * numD02,
                        right: size.width * numD02,
                      ),
                      child: Text(
                        "$euroUniqueCode${formatDouble(double.parse(widget.myContentData!.amount))}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD05,
                            color:
                                widget.myContentData!.paidStatus == unPaidText
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold),
                        /*myContentData!.paidStatus == paidText &&
                                        myContentData!.isPaidStatusToHopper
                                    ?
                        : Colors.white*/
                      ),
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

  Widget showMediaWidget() {
    return SizedBox(
      height: size.width * numD50,
      child: PageView.builder(
          onPageChanged: (value) {
            debugPrint('value:::::::$value');
            _currentMediaIndex = value;
            setState(() {});
            if (flickManager != null) {
              flickManager?.dispose();
              flickManager = null;
            }
            initialController();
            setState(() {});
          },
          itemCount: widget.myContentData!.contentMediaList.length,
          itemBuilder: (context, index) {
            var item = widget.myContentData!.contentMediaList[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: InkWell(
                  onTap: () {
                    if (item.mediaType == "pdf" || item.mediaType == "doc") {
                      openUrl(widget.myContentData!.paidStatus == paidText
                          ? contentImageUrl + item.media
                          : item.waterMark);
                    }
                  },
                  child: Stack(
                    children: [
                      item.mediaType == "audio"
                          ? playAudioWidget()
                          : item.mediaType == "video"
                              ? videoWidget()
                              : item.mediaType == "pdf"
                                  ? Padding(
                                      padding:
                                          EdgeInsets.all(size.width * numD04),
                                      child: Image.asset(
                                        "${dummyImagePath}pngImage.png",
                                        fit: BoxFit.contain,
                                        width: size.width,
                                      ),
                                    )
                                  : item.mediaType == "doc"
                                      ? Padding(
                                          padding: EdgeInsets.all(
                                              size.width * numD04),
                                          child: Image.asset(
                                            "${dummyImagePath}doc_black_icon.png",
                                            fit: BoxFit.contain,
                                            width: size.width,
                                          ),
                                        )
                                      : Image.network(
                                          widget
                                                      .myContentData!
                                                      .contentMediaList[index]
                                                      .mediaType ==
                                                  "video"
                                              ? "$contentImageUrl${widget.myContentData!.contentMediaList[index].thumbNail}"
                                              : "$contentImageUrl${widget.myContentData!.contentMediaList[index].media}",
                                          width: double.infinity,
                                          height: size.width * numD50,
                                          fit: BoxFit.cover,
                                        ),

                      /*   mediaList[index]
                          .mimeType
                          .contains("doc")
                          ? SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Image.asset(
                          "${dummyImagePath}docImage.png",
                          fit: BoxFit.contain,
                        ),
                      )
                          : mediaList[index]
                          .mimeType
                          .contains("pdf")
                          ? SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Image.asset(
                          "${dummyImagePath}pngImage.png",
                          fit: BoxFit.contain,
                        ),
                      )*/
                      Positioned(
                          right: size.width * numD02,
                          top: size.width * numD02,
                          child: Column(
                              children: getMediaCount(
                                  widget.myContentData!.contentMediaList,
                                  size))),
                      // Positioned(
                      //   right: size.width * numD02,
                      //   bottom: size.width * numD02,
                      //   child: Visibility(
                      //     visible: myContentData!.contentMediaList.length > 1,
                      //     child: Text(
                      //       "+${myContentData!.contentMediaList.length - 1}",
                      //       style: commonTextStyle(
                      //           size: size,
                      //           fontSize: size.width * numD04,
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w600),
                      //     ),
                      //   ),
                      // ),
                      item.mediaType == "image"
                          ? Image.asset(
                              "${commonImagePath}watermark1.png",
                              width: size.width,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget playAudioWidget() {
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
          /*AudioFileWaveforms(
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

          */
          Image.asset(
            "${commonImagePath}watermark1.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
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
                  ),
                ),
                closedCaptionTextStyle: TextStyle(fontSize: 8),
                controls: FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                playerLoadingFallback: Center(
                  child: CircularProgressIndicator(
                    color: colorThemePink,
                  ),
                ),
                controls: FlickLandscapeControls(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  /// Rating
  Widget ratingWidget(ManageTaskChatModel item) {
    return Container();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* profilePicWidget(),*/
        Container(
          padding: EdgeInsets.all(
            size.width * numD01,
          ),
          height: size.width * numD09,
          width: size.width * numD09,
          decoration: const BoxDecoration(
              color: colorSwitchBack, shape: BoxShape.circle),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD09,
              width: size.width * numD09,
            ),
          ),
        ),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Rate your experience with Reuters Media",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              RatingBar(
                ratingWidget: RatingWidget(
                  empty: Image.asset("${iconsPath}ic_empty_star.png"),
                  full: Image.asset("${iconsPath}ic_full_star.png"),
                  half: Image.asset("${iconsPath}ic_half_star.png"),
                ),
                onRatingUpdate: (value) {
                  item.rating = value;
                  setState(() {});
                },
                itemSize: size.width * numD09,
                itemCount: 5,
                ignoreGestures: item.isRatingGiven,
                initialRating: item.rating,
                allowHalfRating: true,
                itemPadding: EdgeInsets.only(left: size.width * numD03),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Write your review here",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              Stack(
                children: [
                  SizedBox(
                    height: size.width * numD35,
                    child: TextFormField(
                      controller: item.ratingReviewController,
                      cursorColor: colorTextFieldIcon,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      readOnly: item.isRatingGiven,
                      decoration: InputDecoration(
                        hintText:
                            "Please share your feedback on your experience"
                            " with the publication. Your feedback is very "
                            "important for improving your experience, "
                            "and our service. Thank you",
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: size.width * numD035),
                        disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        contentPadding: EdgeInsets.only(
                            left: size.width * numD08,
                            right: size.width * numD03,
                            top: size.width * numD04,
                            bottom: size.width * numD04),
                        alignLabelWithHint: true,
                      ),
                      validator: checkRequiredValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.width * numD04, left: size.width * numD01),
                    child: Icon(
                      Icons.sticky_note_2_outlined,
                      size: size.width * numD06,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              SizedBox(
                height: size.width * numD13,
                width: size.width,
                child: commonElevatedButton(
                    submitText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                      size,
                      item.isRatingGiven ? Colors.grey : colorThemePink,
                    ), () {
                  if (!item.isRatingGiven) {
                    if (item.ratingReviewController.text.isNotEmpty) {
                      var map = {
                        "chat_id": item.id,
                        "rating": item.rating,
                        "review": item.ratingReviewController.text,
                        //  "image_id": widget.taskDetail?.id ?? widget.contentId ?? "",
                        "image_id": widget.type == "content"
                            ? widget.contentId
                            : imageId,
                        //"type": ,
                      };
                      socketEmitFunc(
                          socketEvent: "rating", messageType: "", dataMap: map);
                      /*   Timer(
                          const Duration(milliseconds: 50),
                          () => scrollController.jumpTo(
                              scrollController.position.maxScrollExtent));*/
                    } else {
                      showSnackBar(
                          "Required *",
                          "Please Enter some review for mediahouse",
                          Colors.red);
                    }
                  }
                }),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
            ],
          ),
        ))
      ],
    );
  }

  /// offer From Media House
  Widget mediaHouseOfferWidget(ManageTaskChatModel item, bool isMakeCounter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                ]),
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(size.width * numD01),
                child: Image.asset(
                  "${commonImagePath}ic_black_rabbit.png",
                  color: Colors.white,
                  width: size.width * numD07,
                  height: size.width * numD07,
                ),
              ),
            )),
        SizedBox(
          width: size.width * numD02,
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: colorGoogleButtonBorder),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * numD04),
                bottomLeft: Radius.circular(size.width * numD04),
                bottomRight: Radius.circular(size.width * numD04),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD002,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width * 0.55,
                    child: RichText(
                        text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                          TextSpan(
                            text: "Well done! You've received\nan offer from",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD036,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: " ${item.mediaHouseName}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD036,
                                color: colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),

                          // TextSpan(
                          //   text: item.hopperPrice.isEmpty
                          //       ? ""
                          //       : "$euroUniqueCode${amountFormat(item.hopperPrice)} ",
                          //   style: commonTextStyle(
                          //       size: size,
                          //       fontSize: size.width * numD036,
                          //       color: colorThemePink,
                          //       fontWeight: FontWeight.w600),
                          // ),
                        ])),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: size.width * numD01),
                      width: size.width * numD13,
                      height: size.width * numD13,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(size.width * numD03),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200, spreadRadius: 1)
                          ]),
                      child: ClipOval(
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          item.mediaHouseImage,
                          fit: BoxFit.contain,
                          height: size.width * numD20,
                          width: size.width * numD20,
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Image.asset(
                              "${dummyImagePath}news.png",
                              fit: BoxFit.contain,
                              width: size.width * numD20,
                              height: size.width * numD20,
                            );
                          },
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: size.width * numD01,
              ),
              /*Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                if (item.requestStatus.isEmpty &&
                                    !item.isMakeCounterOffer) {
                                  var map1 = {
                                    "chat_id": item.id,
                                    "status": false,
                                  };

                                  socketEmitFunc(
                                      socketEvent: "reqstatus",
                                      messageType: "",
                                      dataMap: map1);

                                  socketEmitFunc(
                                    socketEvent: "chat message",
                                    messageType: "reject_mediaHouse_offer",
                                  );

                                  socketEmitFunc(
                                    socketEvent: "chat message",
                                    messageType: "rating_hopper",
                                  );

                                  socketEmitFunc(
                                    socketEvent: "chat message",
                                    messageType: "rating_mediaHouse",
                                  );
                                  showRejectBtn = true;
                                }
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: item.requestStatus.isEmpty &&
                                      !item.isMakeCounterOffer
                                      ? Colors.black
                                      : item.requestStatus == "false"
                                      ? Colors.grey
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(size.width * numD04),
                                      side: (item.requestStatus == "false" ||
                                          item.requestStatus.isEmpty) &&
                                          !item.isMakeCounterOffer
                                          ? BorderSide.none
                                          : const BorderSide(
                                          color: Colors.black, width: 1))),
                              child: Text(
                                rejectText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD037,
                                    color: (item.requestStatus == "false" ||
                                        item.requestStatus.isEmpty) &&
                                        !item.isMakeCounterOffer
                                        ? Colors.white
                                        : colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                //aditya accept btn
                                if (item.requestStatus.isEmpty &&
                                    !item.isMakeCounterOffer) {
                                  debugPrint("tapppppp:::::$showAcceptBtn");
                                  showAcceptBtn = true;
                                  var map1 = {
                                    "chat_id": item.id,
                                    "status": true,
                                  };

                                  socketEmitFunc(
                                      socketEvent: "reqstatus",
                                      messageType: "",
                                      dataMap: map1);

                                  socketEmitFunc(
                                      socketEvent: "chat message",
                                      messageType: "accept_mediaHouse_offer",
                                      dataMap: {
                                        "amount": isMakeCounter
                                            ? item.initialOfferAmount
                                            : item.finalCounterAmount,
                                        "image_id": widget.contentId!,
                                      });
                                }
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: item.requestStatus.isEmpty &&
                                      !item.isMakeCounterOffer
                                      ? colorThemePink
                                      : item.requestStatus == "true"
                                      ? Colors.grey
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(size.width * numD04),
                                      side: (item.requestStatus == "true" ||
                                          item.requestStatus.isEmpty) &&
                                          !item.isMakeCounterOffer
                                          ? BorderSide.none
                                          : const BorderSide(
                                          color: Colors.black, width: 1))),
                              child: Text(
                                acceptText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD037,
                                    color: (item.requestStatus == "true" ||
                                        item.requestStatus.isEmpty) &&
                                        !item.isMakeCounterOffer
                                        ? Colors.white
                                        : colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),

                      */
              /*
                       Expanded(
                          child: SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: ElevatedButton(
                              onPressed: () {
                                if(item.requestStatus.isEmpty){

                                  var map1 = {
                                    "chat_id" : item.id,
                                    "status" : true,
                                  };

                                  socketEmitFunc(
                                      socketEvent: "reqstatus",
                                      messageType: "",
                                      dataMap: map1
                                  );

                                  socketEmitFunc(
                                      socketEvent: "chat message",
                                      messageType: "contentupload",
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  item.requestStatus.isEmpty
                                      ? colorThemePink
                                      :item.requestStatus == "true"
                                      ?  Colors.grey
                                      :  Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                      side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                          color: colorGrey1, width: 2)
                                  )),
                              child: Text(
                                yesText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD04,
                                    color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),*/ /*
                    ],
                  ),*/
              SizedBox(
                height: size.width * numD03,
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.all(size.width * numD012),
                decoration: BoxDecoration(
                    color: colorLightGrey,
                    borderRadius: BorderRadius.circular(size.width * numD03),
                    border:
                        Border.all(color: const Color(0xFFd4dedd), width: 2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Offered Price",
                      style: TextStyle(
                          fontSize: size.width * numD035,
                          color: colorLightGreen,
                          fontFamily: 'AirbnbCereal_W_Lt Light'),
                    ),
                    Text(
                      item.amount.isEmpty
                          ? ""
                          : "$euroUniqueCode${formatDouble(double.parse(item.amount))}",
                      style: TextStyle(
                          fontSize: size.width * numD045,
                          color: colorLightGreen,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'AirbnbCereal_W_Bd'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * numD03,
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// Counter Offer
  Widget counterFieldWidget(ManageTaskChatModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        presshopPicWidget(),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Make a counter offer to ${item.mediaHouseName} Media",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD036,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              TextFormField(
                controller: item.priceController,
                readOnly: item.finalCounterAmount.isNotEmpty,
                cursorColor: colorTextFieldIcon,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    counterText: "",
                    filled: false,
                    hintText: "Enter price here...",
                    hintStyle: TextStyle(
                      color: colorHint,
                      fontSize: size.width * numD035,
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black)),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: size.width * numD02)),
                textAlignVertical: TextAlignVertical.center,
                validator: null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              SizedBox(
                height: size.width * numD13,
                width: size.width,
                child: commonElevatedButton(
                    submitText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                        size,
                        item.finalCounterAmount.isEmpty
                            ? colorThemePink
                            : Colors.grey), () {
                  var map = {
                    "finaloffer_price": item.priceController.text,
                    "content_id": widget.contentId,
                    "initial_offer_price": "",
                    "chat_id": item.id
                  };

                  socketEmitFunc(
                      socketEvent: "initialoffer",
                      messageType: "hopper_final_offer",
                      dataMap: map);
                  Timer(
                      const Duration(milliseconds: 50),
                      () => scrollController
                          .jumpTo(scrollController.position.maxScrollExtent));
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "${iconsPath}ic_tag.png",
                    height: size.width * numD06,
                  ),
                  SizedBox(
                    width: size.width * numD02,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FAQScreen(
                                      priceTipsSelected: true,
                                      type: 'price_tips',
                                      index: 0,
                                    )));
                      },
                      child: Text(
                        "Check price tips, and learnings",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                ],
              ),
              Text(
                "You can make a counter offer only once",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD034,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ))
      ],
    );
  }

  Widget showTaskPriceWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: size.width * numD055),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                ]),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(size.width * numD01),
                child: Image.asset(
                  "${commonImagePath}ic_black_rabbit.png",
                  width: size.width * numD075,
                  height: size.width * numD075,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          ),
          Expanded(
              child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: size.width * numD055),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD03,
                    vertical: size.width * numD02),
                width: size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(size.width * numD04),
                        bottomLeft: Radius.circular(size.width * numD04),
                        bottomRight: Radius.circular(size.width * numD04))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.width * numD025,
                    ),
                    Row(
                      children: [
                        Text(
                          // "$taskText ${widget.taskDetail?.status}",
                          "TASK ACCEPTED",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Container(
                          height: size.width * numD12,
                          width: size.width * numD12,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    spreadRadius: 2)
                              ]),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.width * numD02),
                            child: Padding(
                              padding: EdgeInsets.all(size.width * numD013),
                              child: Image.network(
                                widget.taskDetail!.mediaHouseImage.toString(),
                                width: size.width * numD09,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                    Text(
                      "${widget.taskDetail?.title}",
                      style: TextStyle(
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontFamily: "AirbnbCereal",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.taskDetail!.isNeedPhoto
                                    ? "$euroUniqueCode${formatDouble(double.parse(widget.taskDetail!.photoPrice))}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD055,
                                    color: colorThemePink,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                offeredText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: size.width * numD03,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD02),
                                decoration: BoxDecoration(
                                    color: colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD02)),
                                child: Text(
                                  photoText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.taskDetail!.isNeedInterview
                                    ? "$euroUniqueCode${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD055,
                                    color: colorThemePink,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                offeredText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: size.width * numD03,
                              ),
                              Container(
                                // alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD018,
                                    vertical: size.width * numD02),
                                decoration: BoxDecoration(
                                    color: colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD02)),
                                child: Text(
                                  interviewText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.taskDetail!.isNeedVideo
                                    ? "$euroUniqueCode${formatDouble(double.parse(widget.taskDetail!.videoPrice))}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD055,
                                    color: colorThemePink,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                offeredText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: size.width * numD03,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD02),
                                decoration: BoxDecoration(
                                    color: colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD02)),
                                child: Text(
                                  videoText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(size.width * numD025),
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: size.width * numD07,
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget uploadMediaInfoWidget(String uploadTextType) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
              top: uploadTextType == "request_more_content"
                  ? size.width * numD04
                  : 0),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
              ]),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(size.width * numD01),
              child: Image.asset(
                "${commonImagePath}ic_black_rabbit.png",
                width: size.width * numD075,
                height: size.width * numD075,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
                top: uploadTextType == "request_more_content"
                    ? size.width * numD05
                    : 0),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * numD03, vertical: size.width * numD02),
            width: size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size.width * numD04),
                    bottomLeft: Radius.circular(size.width * numD04),
                    bottomRight: Radius.circular(size.width * numD04))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontFamily: "AirbnbCereal",
                            height: 1.5),
                        children: [
                      TextSpan(
                        text: uploadTextType == "request_more_content"
                            ? "Please upload more content by clicking the"
                            : "Please upload content by clicking the",
                      ),
                      TextSpan(
                        text: " Gallery or Camera",
                        style: TextStyle(
                          fontSize: size.width * numD035,
                          color: colorThemePink,
                          fontFamily: "AirbnbCereal",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: " buttons below",
                      ),
                    ])),
                SizedBox(
                  height: size.width * numD008,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget uploadNoContentWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: size.width * numD03),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
              ]),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(size.width * numD01),
              child: Image.asset(
                "${commonImagePath}ic_black_rabbit.png",
                width: size.width * numD075,
                height: size.width * numD075,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: size.width * numD03),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * numD03, vertical: size.width * numD03),
            width: size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size.width * numD04),
                    bottomLeft: Radius.circular(size.width * numD04),
                    bottomRight: Radius.circular(size.width * numD04))),
            child: Text(
              "Thank you ever so much for a splendid job well done!",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD035,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
    );
  }

  Widget thanksToUploadMediaWidget(String type) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
              ]),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(size.width * numD01),
              child: Image.asset(
                "${commonImagePath}ic_black_rabbit.png",
                width: size.width * numD075,
                height: size.width * numD075,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * numD03, vertical: size.width * numD03),
            width: size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size.width * numD04),
                    bottomLeft: Radius.circular(size.width * numD04),
                    bottomRight: Radius.circular(size.width * numD04))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.width * numD008,
                ),
                Row(
                  children: [
                    Text("Thanks. you've uploaded",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.normal)),
                    Text(" 1 $type",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: colorThemePink,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  height: size.width * numD008,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget rightVideoChatWidget(String thumbnail, String videoUrl) {
    debugPrint("----------------$videoUrl");
    debugPrint("-thumbnail---------------$thumbnail");
    return Container(
      margin: EdgeInsets.only(top: size.width * numD04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MediaViewScreen(
                              mediaFile: videoUrl,
                              type: MediaTypeEnum.video,
                            )));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD04),
                    child: Image.network(
                      thumbnail,
                      height: size.height / 3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    top: size.width * numD02,
                    left: size.width * numD02,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD006,
                          vertical: size.width * numD002),
                      decoration: BoxDecoration(
                          color: colorLightGreen.withOpacity(0.8),
                          borderRadius:
                              BorderRadius.circular(size.width * numD01)),
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: Colors.white,
                      ),
                    )),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MediaViewScreen(
                              mediaFile: videoUrl,
                              type: MediaTypeEnum.video,
                            )));
                  },
                  child: Icon(
                    Icons.play_circle,
                    color: Colors.white,
                    size: size.width * numD09,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          (avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? ""))
                  .isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  decoration: const BoxDecoration(
                      color: colorLightGrey, shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        avatarImageUrl +
                            (sharedPreferences!.getString(avatarKey) ?? ""),
                        fit: BoxFit.cover,
                        height: size.width * numD09,
                        width: size.width * numD09,
                      )))
              : Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD09,
                  width: size.width * numD09,
                  decoration: const BoxDecoration(
                      color: colorSwitchBack, shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset("${commonImagePath}rabbitLogo.png",
                        fit: BoxFit.contain),
                  ),
                ),
        ],
      ),
    );
  }

  Widget rightAudioChatWidget(String audioUrl) {
    debugPrint("----------------$audioUrl");
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MediaViewScreen(
                  mediaFile: audioUrl,
                  type: MediaTypeEnum.audio,
                )));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * numD04),
                  child: Container(
                    color: colorGrey2.withOpacity(.9),
                    height: size.width * numD80,
                    width: double.infinity,
                    child: Icon(
                      Icons.play_circle,
                      color: colorThemePink,
                      size: size.width * numD18,
                    ),
                  ),
                ),
                Positioned(
                    top: size.width * numD02,
                    left: size.width * numD02,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD008,
                          vertical: size.width * numD005),
                      decoration: BoxDecoration(
                          color: colorLightGreen.withOpacity(0.8),
                          borderRadius:
                              BorderRadius.circular(size.width * numD01)),
                      child: Image.asset(
                        "${iconsPath}ic_mic1.png",
                        fit: BoxFit.cover,
                        height: size.width * numD05,
                        width: size.width * numD05,
                      ),
                    )),
                ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD04),
                    child: Image.asset(
                      "${commonImagePath}watermark1.png",
                      height: size.height / 3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )),
              ],
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          (avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? ""))
                  .isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  decoration: const BoxDecoration(
                      color: colorLightGrey, shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        avatarImageUrl +
                            (sharedPreferences!.getString(avatarKey) ?? ""),
                        fit: BoxFit.cover,
                        height: size.width * numD09,
                        width: size.width * numD09,
                      )))
              : Container(
                  padding: EdgeInsets.all(
                    size.width * numD01,
                  ),
                  height: size.width * numD09,
                  width: size.width * numD09,
                  decoration: const BoxDecoration(
                      color: colorSwitchBack, shape: BoxShape.circle),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset("${commonImagePath}rabbitLogo.png",
                        fit: BoxFit.contain),
                  ),
                ),
        ],
      ),
    );
  }

  Widget rightImageChatWidget(String imageUrl, String time) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        debugPrint("imageTap:::::::${sharedPreferences!.getString(avatarKey)}");
        Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
            builder: (context) => MediaViewScreen(
                  mediaFile: imageUrl,
                  type: MediaTypeEnum.image,
                )));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: colorGreyChat,
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          child: Image.network(
                            imageUrl,
                            height: size.height / 3,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Center(
                                child: Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                  height: size.height / 3,
                                  width: size.width / 1.7,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          )),
                    ),
                    Positioned(
                        top: size.width * numD02,
                        left: size.width * numD02,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD006,
                              vertical: size.width * numD002),
                          decoration: BoxDecoration(
                              color: colorLightGreen.withOpacity(0.8),
                              borderRadius:
                                  BorderRadius.circular(size.width * numD01)),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                        )),
                    ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: Image.asset(
                          "${commonImagePath}watermark1.png",
                          height: size.height / 3,
                          width: size.width / 1.7,
                          fit: BoxFit.cover,
                        )),
                  ],
                ),
              ),
              SizedBox(
                width: size.width * numD02,
              ),
              sharedPreferences!.getString(avatarKey).toString().isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(
                        size.width * numD01,
                      ),
                      decoration: const BoxDecoration(
                          color: colorLightGrey, shape: BoxShape.circle),
                      child: ClipOval(
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                              avatarImageUrl +
                                  sharedPreferences!
                                      .getString(avatarKey)
                                      .toString(),
                              height: size.width * numD09,
                              width: size.width * numD09,
                              fit: BoxFit.cover, errorBuilder:
                                  (BuildContext context, Object exception,
                                      StackTrace? stackTrace) {
                            return Center(
                              child: Image.asset(
                                "${commonImagePath}rabbitLogo.png",
                                height: size.width * numD09,
                                width: size.width * numD09,
                                fit: BoxFit.contain,
                              ),
                            );
                          })))
                  : Container(
                      padding: EdgeInsets.all(
                        size.width * numD01,
                      ),
                      height: size.width * numD09,
                      width: size.width * numD09,
                      decoration: const BoxDecoration(
                          color: colorSwitchBack, shape: BoxShape.circle),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          height: size.width * numD09,
                          width: size.width * numD09,
                        ),
                      ),
                    ),
            ],
          ),
          SizedBox(
            height: size.width * numD018,
          ),
          Row(
            children: [
              Image.asset(
                "${iconsPath}ic_clock.png",
                height: size.width * numD038,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * numD012,
              ),
              Text(
                dateTimeFormatter(dateTime: time, format: 'hh:mm a'),
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD028,
                    color: colorHint,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                width: size.width * numD018,
              ),
              Image.asset(
                "${iconsPath}ic_yearly_calendar.png",
                height: size.width * numD035,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * numD01,
              ),
              Text(
                dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy'),
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD028,
                    color: colorHint,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
          SizedBox(
            height: size.width * numD018,
          ),
        ],
      ),
    );
  }

  Widget paymentReceivedWidget(ManageTaskChatModel model) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                    ]),
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.all(size.width * numD01),
                    child: Image.asset(
                      "${commonImagePath}ic_black_rabbit.png",
                      color: Colors.white,
                      width: size.width * numD07,
                      height: size.width * numD07,
                    ),
                  ),
                )),
            SizedBox(
              width: size.width * numD025,
            ),
            Expanded(
                child: Container(
              // margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: colorGoogleButtonBorder),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size.width * numD04),
                    bottomLeft: Radius.circular(size.width * numD04),
                    bottomRight: Radius.circular(size.width * numD04),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RichText(
                      text: TextSpan(
                          style: const TextStyle(
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                        TextSpan(
                          text: "Congratulations,",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: " ${model.mediaHouseName}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " have purchased your content for",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: " $euroUniqueCode${model.amount}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        // TextSpan(
                        //   text: item.hopperPrice.isEmpty
                        //       ? ""
                        //       : "$euroUniqueCode${amountFormat(item.hopperPrice)} ",
                        //   style: commonTextStyle(
                        //       size: size,
                        //       fontSize: size.width * numD036,
                        //       color: colorThemePink,
                        //       fontWeight: FontWeight.w600),
                        // ),
                      ])),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "View Transaction Details",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink), () {
                      callDetailApi(model.mediaHouseId);
                    }),
                  )
                ],
              ),
            ))
          ],
        ),
        chatBubbleSpacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                    ]),
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.all(size.width * numD01),
                    child: Image.asset(
                      "${commonImagePath}ic_black_rabbit.png",
                      color: Colors.white,
                      width: size.width * numD07,
                      height: size.width * numD07,
                    ),
                  ),
                )),
            SizedBox(
              width: size.width * numD025,
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: colorGoogleButtonBorder),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size.width * numD04),
                    bottomLeft: Radius.circular(size.width * numD04),
                    bottomRight: Radius.circular(size.width * numD04),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD01,
                  ),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * numD037,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                        TextSpan(
                          text: "Woohoo! We have paid ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: model.payableHopperPrice.isEmpty
                              ? ""
                              : "$euroUniqueCode${formatDouble(double.parse(model.payableHopperPrice))}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " into your bank account. Please visit ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: "My Earnings",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " to view your transaction ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        )
                      ])),
                  SizedBox(
                    height: size.width * numD025,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: commonElevatedButton(
                            "View My Earnings",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink), () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MyEarningScreen(
                                    openDashboard: false,
                                  )));
                        }),
                      ),
                    ],
                  )
                ],
              ),
            )),
          ],
        )
      ],
    );
  }

  Widget makeOverPriceWidget(String hopperAmount, String amount) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                    ]),
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.all(size.width * numD01),
                    child: Image.asset(
                      "${commonImagePath}ic_black_rabbit.png",
                      color: Colors.white,
                      width: size.width * numD07,
                      height: size.width * numD07,
                    ),
                  ),
                )),
            SizedBox(
              width: size.width * numD025,
            ),
            Expanded(
                child: Container(
              // margin: EdgeInsets.only(top: 0, right: size.width * numD04),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: colorGoogleButtonBorder),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(size.width * numD04),
                    bottomLeft: Radius.circular(size.width * numD04),
                    bottomRight: Radius.circular(size.width * numD04),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD01,
                  ),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * numD037,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                        TextSpan(
                          text:
                              "To maximise your chances of a sale, we’ve automatically adjusted the price from ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: "£$hopperAmount ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " to ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: '£$amount',
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text:
                              ". Stay tuned—we’ll update you as soon as your content is sold",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ])),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                ],
              ),
            )),
          ],
        ),
      ],
    );
  }

  Widget profilePicWidget() {
    return Container(
        //margin: EdgeInsets.only(top: size.width * numD03),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400)),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            widget.taskDetail?.mediaHouseImage ?? "",
            width: size.width * numD09,
            height: size.width * numD09,
            fit: BoxFit.contain,
            errorBuilder: (ctx, obj, stace) {
              return Image.asset(
                "${dummyImagePath}news.png",
                width: size.width * numD09,
                height: size.width * numD09,
              );
            },
          ),
        ));
  }

  /// PressHope Profile
  Widget presshopPicWidget() {
    return Container(
        margin: EdgeInsets.only(top: size.width * numD04),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
            ]),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            "${commonImagePath}rabbitLogo.png",
            width: size.width * numD09,
            height: size.width * numD09,
          ),
        ));
  }

  /// Do you have additional pictures
  Widget moreContentReqWidget(ManageTaskChatModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicWidget(),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD023,
              ),
              Text(
                "Do you have additional pictures related to the task?",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (item.requestStatus.isEmpty) {
                          var map1 = {
                            "chat_id": item.id,
                            "status": true,
                          };

                          socketEmitFunc(
                              socketEvent: "reqstatus",
                              messageType: "",
                              dataMap: map1);

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "contentupload",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: item.requestStatus.isEmpty
                              ? colorThemePink
                              : item.requestStatus == "true"
                                  ? Colors.grey
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              side: item.requestStatus == "true" ||
                                      item.requestStatus.isEmpty
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        yesText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: item.requestStatus == "true" ||
                                    item.requestStatus.isEmpty
                                ? Colors.white
                                : colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: size.width * numD04,
                  ),
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (item.requestStatus.isEmpty) {
                          var map1 = {
                            "chat_id": item.id,
                            "status": false,
                          };

                          socketEmitFunc(
                              socketEvent: "reqstatus",
                              messageType: "",
                              dataMap: map1);

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "NocontentUpload",
                          );

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "rating_hopper",
                          );

                          socketEmitFunc(
                            socketEvent: "chat message",
                            messageType: "rating_mediaHouse",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: item.requestStatus.isEmpty
                              ? Colors.black
                              : item.requestStatus == "false"
                                  ? Colors.grey
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              side: item.requestStatus == "false" ||
                                      item.requestStatus.isEmpty
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        noText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: item.requestStatus == "false" ||
                                    item.requestStatus.isEmpty
                                ? Colors.white
                                : colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
                ],
              ),
              SizedBox(
                height: size.width * numD023,
              ),
            ],
          ),
        ))
      ],
    );
  }

  Widget moreContentUploadWidget(ManageTaskChatModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicWidget(),
        SizedBox(
          width: size.width * numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(
              top: size.width * numD06, bottom: size.width * numD04),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05, vertical: size.width * numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: colorLightGrey,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * numD04),
                  bottomLeft: Radius.circular(size.width * numD04),
                  bottomRight: Radius.circular(size.width * numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD04,
              ),
              Text(
                "Send the content for approval",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              SizedBox(
                height: size.width * numD13,
                width: size.width,
                child: commonElevatedButton(
                    uploadText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                        size,
                        item.requestStatus == "true"
                            ? Colors.grey
                            : colorThemePink), () {
                  if (item.requestStatus.isEmpty) {
                    _againUpload = true;
                    _chatId = item.id;
                    setState(() {});
                  }
                }),
              )
            ],
          ),
        ))
      ],
    );
  }

  Widget errorImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        '${commonImagePath}rabbitLogo.png',
        height: 150.0,
        width: size.width,
      ),
    );
  }

  /// Not In use But Important
  Widget oldDataWidget() {
    return Column(
      children: [
        SizedBox(
          height: size.width * numD08,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: size.width * numD06),
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD03,
                      vertical: size.width * numD02),
                  width: size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(size.width * numD04),
                          bottomLeft: Radius.circular(size.width * numD04),
                          bottomRight: Radius.circular(size.width * numD04))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Text(
                        "$taskText ${widget.taskDetail?.status}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Text(
                          "Cate Blanchett and Rihanna while filming Oceans Eight",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${euroUniqueCode}150",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD055,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  offeredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorHint,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: size.width * numD04,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD02,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Text(
                                    photoText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${euroUniqueCode}350",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD055,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  offeredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorHint,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: size.width * numD04,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD02,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Text(
                                    interviewText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${euroUniqueCode}500",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD055,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  offeredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorHint,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: size.width * numD04,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD02,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Text(
                                    videoText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(size.width * numD03),
                    decoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size.width * numD07,
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      child: Image.asset(
                        "${dummyImagePath}walk5.png",
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                      ),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          child: Image.asset(
                            "${commonImagePath}watermark.png",
                            height: size.height / 3,
                            width: size.width / 1.7,
                            fit: BoxFit.cover,
                          )))
                ],
              ),
              SizedBox(
                width: size.width * numD02,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * numD08),
                  child: Image.asset(
                    "${dummyImagePath}avatar.png",
                    height: size.width * numD08,
                    width: size.width * numD08,
                    fit: BoxFit.cover,
                  ))
            ],
          ),
        ),
        chatBubbleSpacer(),

        /// Pending Request
        Row(
          children: [
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
            Text(
              "Pending reviews from Reuters",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD035,
                  color: colorGrey2,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// payment recicved
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Congrats, you’ve received £200 from Reuters Media ",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "View Transaction Details",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// More Content
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Do you have additional pictures related to the task?",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: colorGrey1, width: 2))),
                          child: Text(
                            noText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorThemePink,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              )),
                          child: Text(
                            "View Transaction Details",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// send Approval
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Send the content for approval",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        uploadText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// Upload Video
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      child: Image.asset(
                        "${dummyImagePath}walk6.png",
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                      ),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          child: Image.asset(
                            "${commonImagePath}watermark.png",
                            height: size.height / 3,
                            width: size.width / 1.7,
                            fit: BoxFit.cover,
                          )))
                ],
              ),
              SizedBox(
                width: size.width * numD02,
              ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * numD08),
                  child: Image.asset(
                    "${dummyImagePath}avatar.png",
                    height: size.width * numD08,
                    width: size.width * numD08,
                    fit: BoxFit.cover,
                  ))
            ],
          ),
        ),
        chatBubbleSpacer(),

        /// Pending Reviews
        Row(
          children: [
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
            Text(
              "Pending reviews from Reuters",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD035,
                  color: colorGrey2,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(
                child: Divider(
              color: colorGrey1,
              thickness: 1,
            )),
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// Offers From Media House
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*   Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: Image.asset(
                  "${dummyImagePath}news.png",
                  height: size.width * numD09,
                ),
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Reuters Media has offered ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "${euroUniqueCode}150 ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: colorThemePink,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "to buy your content",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            rejectText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorThemePink,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              )),
                          child: Text(
                            acceptText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  ),
                  chatBubbleSpacer(),
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(
                        color: colorTextFieldIcon,
                        thickness: 1,
                      )),
                      Text(
                        "or",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      const Expanded(
                          child: Divider(
                        color: colorTextFieldIcon,
                        thickness: 1,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "Make a Counter Offer",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "You can make a counter offer only once",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),

        /// Counter Field
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Make a counter offer to Reuters Media",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: TextFormField(
                      cursorColor: colorTextFieldIcon,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: "Enter price here...",
                        hintStyle: TextStyle(
                            color: Colors.black, fontSize: size.width * numD04),
                        disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: Colors.black)),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      validator: checkRequiredValidator,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        submitText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "${iconsPath}ic_tag.png",
                        height: size.width * numD06,
                      ),
                      SizedBox(
                        width: size.width * numD02,
                      ),
                      Expanded(
                        child: Text(
                          "Check price tips, and learnings",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "You can make a counter offer only once",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD031,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),

        SizedBox(
          height: size.width * numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*  Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: Image.asset(
                  "${dummyImagePath}news.png",
                  height: size.width * numD09,
                ),
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Reuters Media have increased their offered to ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "${euroUniqueCode}200 ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: colorThemePink,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "to buy your content",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            rejectText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorThemePink,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            acceptText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * numD04),
              padding: EdgeInsets.all(size.width * numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * numD07,
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Congrats, you’ve received £200 from Reuters Media ",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "View Transaction Details",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),

        SizedBox(
          height: size.width * numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(
                size.width * numD01,
              ),
              height: size.width * numD09,
              width: size.width * numD09,
              decoration: const BoxDecoration(
                  color: colorSwitchBack, shape: BoxShape.circle),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.width * numD09,
                  width: size.width * numD09,
                ),
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(size.width * numD04),
                      bottomLeft: Radius.circular(size.width * numD04),
                      bottomRight: Radius.circular(size.width * numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Text(
                    "Rate your experience with Reuters Media",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RatingBar(
                    ratingWidget: RatingWidget(
                      empty: Image.asset("${iconsPath}ic_empty_star.png"),
                      full: Image.asset("${iconsPath}ic_full_star.png"),
                      half: Image.asset("${iconsPath}ic_half_star.png"),
                    ),
                    onRatingUpdate: (value) {},
                    itemSize: size.width * numD09,
                    itemCount: 5,
                    initialRating: 0,
                    allowHalfRating: true,
                    itemPadding: EdgeInsets.only(left: size.width * numD03),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Write your review here",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        height: size.width * numD35,
                        child: TextFormField(
                          cursorColor: colorTextFieldIcon,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                "Please share your feedback on your experience with the publication. Your feedback is very important for improving your experience, and our service. Thank you",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: size.width * numD035),
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            contentPadding: EdgeInsets.only(
                                left: size.width * numD08,
                                right: size.width * numD03,
                                top: size.width * numD04,
                                bottom: size.width * numD04),
                            alignLabelWithHint: true,
                          ),
                          validator: checkRequiredValidator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * numD04,
                            left: size.width * numD01),
                        child: Icon(
                          Icons.sticky_note_2_outlined,
                          size: size.width * numD06,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        submitText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                ],
              ),
            ))
          ],
        ),
      ],
    );
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

  Future playSound() async {
    debugPrint("PlayTheSound");

    await controller.startPlayer();
  }

  Future pauseSound() async {
    await controller.pausePlayer();
  }

  void initialController() {
    if (widget.myContentData!.contentMediaList[_currentMediaIndex].mediaType ==
        "audio") {
      /*  initWaveData(contentImageUrl +
          myContentData!.contentMediaList[_currentMediaIndex].media);*/
      initWaveData(widget.myContentData!.paidStatus == paidText
          ? contentImageUrl +
              widget.myContentData!.contentMediaList[_currentMediaIndex].media
          : widget
              .myContentData!.contentMediaList[_currentMediaIndex].waterMark);
    } else if (widget
            .myContentData!.contentMediaList[_currentMediaIndex].mediaType ==
        "video") {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(widget
              .myContentData!.contentMediaList[_currentMediaIndex].waterMark),
        ),
        autoPlay: false,
      );
    }
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }

  /// Get Image
  Future<void> getImage(ImageSource source) async {
    bool cameraValue = await cameraPermission();
    bool storageValue = await storagePermission();

    if (cameraValue && storageValue) {
      final ImagePicker picker = ImagePicker();

      if (source == ImageSource.gallery) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(type: FileType.media, allowMultiple: true);
        debugPrint('Result from images picked::::$result');

        for (int i = result!.files.length - 1; i >= 0; i--) {
          debugPrint('extension::::${result.files[i].extension}');
          if (result.files.isNotEmpty) {
            if (result.files[i].extension == 'jpeg' ||
                result.files[i].extension == 'jpg' ||
                result.files[i].extension == 'png') {
              debugPrint("fileType====> ${result.files[i].extension}");
              debugPrint("imagePath======£> ${result.files[i].path!}");
              Map<String, String> mediaMap = {
                "imageAndVideo": result.files[i].path!,
              };
              callUploadMediaApi(mediaMap, "image");
            } else if (result.files[i].extension == 'mp4' ||
                result.files[i].extension == '.avi' ||
                result.files[i].extension == '.mov' ||
                result.files[i].extension == '.mkv') {
              debugPrint("fileType====> ${result.files[i].extension}");
              debugPrint("videoPath======> ${result.files[i].path!}");
              generateVideoThumbnail(result.files[i].path!);
            } else {
              Map<String, String> mediaMap = {
                "imageAndVideo": result.files[i].path!,
              };
              callUploadMediaApi(mediaMap, "audio");
            }
          }
        }
      }
    } else {
      debugPrint("Permission Denied");
    }
  }

  void generateVideoThumbnail(String path) async {
    final mimeType = lookupMimeType(path);
    debugPrint("mimeType====> : $mimeType");

    if (mimeType!.toLowerCase().contains("video")) {
      final thumnail = await VideoThumbnail.thumbnailFile(
        video: path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 1024,
        maxWidth: 1024,
        quality: 100,
      );

      Map<String, String> mediaMap = {
        "imageAndVideo": path,
        "videothubnail": thumnail!
      };
      callUploadMediaApi(mediaMap, "video");
    } else {
      debugPrint("hello=====>");
      Map<String, String> mediaMap = {
        "imageAndVideo": path,
      };
      callUploadMediaApi(mediaMap, "image");
    }
  }

  void socketEmitFunc({
    required String socketEvent,
    required String messageType,
    Map<String, dynamic>? dataMap,
    String mediaType = "",
  }) {
    debugPrint(":::: Inside Socket Emit :::::");

    Map<String, dynamic> map = {
      "message_type": messageType,
      "receiver_id": widget.taskDetail?.mediaHouseId ?? "5",
      "sender_id": _senderId,
      "message": "",
      "primary_room_id": "",
      "room_id": widget.roomId,
      "media_type": mediaType,
      "sender_type": "hopper",
    };

    if (dataMap != null) {
      map.addAll(dataMap);
    }

    debugPrint("Emit Socket : $map");
    debugPrint(" Socket=====>  : $socketEvent");
    socket.emit(socketEvent, map);
    callGetManageTaskListingApi();
  }

  void socketConnectionFunc() {
    debugPrint(":::: Inside Socket Func :::::");
    debugPrint("socketUrl:::::$socketUrl");
    socket =
        IO.io(socketUrl, OptionBuilder().setTransports(['websocket']).build());

    debugPrint("Socket Disconnect : ${socket.disconnected}");
    debugPrint("Socket Disconnect : ${widget.taskDetail?.mediaHouseId}");

    socket.connect();

    socket.onConnect((_) {
      if (widget.type == "content") {
        socket.emit('room join', {"room_id": widget.contentId});
      } else {
        socket.emit('room join', {"room_id": widget.roomId});
      }

      // socket.emit("chat message", {"room_id" : widget.roomId ,"receiver_id" : widget.taskDetail.mediaHouseId, "message" : "Tested Socket" ,"sender_id": _senderId});
    });

    socket.on("chat message", (data) => callGetManageTaskListingApi());
    socket.on("getallchat", (data) => callGetManageTaskListingApi());
    socket.on("updatehide", (data) => callGetManageTaskListingApi());
    socket.on("media message", (data) => callGetManageTaskListingApi());
    socket.on("offer message", (data) => callGetManageTaskListingApi());
    socket.on("rating", (data) => callGetManageTaskListingApi());
    socket.on("room join", (data) => callGetManageTaskListingApi());
    socket.on("initialoffer", (data) => callGetManageTaskListingApi());
    socket.on("updateOffer", (data) => callGetManageTaskListingApi());
    socket.on("leave room", (data) => callGetManageTaskListingApi());

    socket.onError((data) => debugPrint("Error Socket ::: $data"));
  }

  void callDetailApi(String id) {
    debugPrint("widget.type::::${widget.type}");
    Map<String, dynamic> map = {
      "content_id": widget.type == 'content'
          ? widget.contentId.toString()
          : widget.roomId,
      "media_house_id": id
/*      "limit": limit.toString(),
      "offset": offset.toString()*/
    };

    NetworkClass(GetDetailsById, this, reqGetDetailsById)
        .callRequestServiceHeader(true, 'get', map);
  }

  /// Upload media
  void callUploadMediaApi(Map<String, String> mediaMap, String type) {
    Map<String, String> map = {"type": type, 'task_id': widget.taskDetail!.id};

    debugPrint('map:::::::$map');
    NetworkClass.fromNetworkClass(
            uploadTaskMediaUrl, this, uploadTaskMediaReq, map)
        .callMultipartServiceNew(true, "post", mediaMap);
  }

  /// Get Listing
  void callGetManageTaskListingApi() {
    // Map<String, String> map = {"room_id": widget.type == 'content' ? widget.contentId.toString() : widget.roomId, "type": widget.type};
    // NetworkClass.fromNetworkClass(getMediaTaskChatListUrl, this, getMediaTaskChatListReq, map).callRequestServiceHeader(false, "post", null);

    Map<String, String> map = {"content_id": widget.contentId.toString()};
    NetworkClass.fromNetworkClass(
            getOfferPaymentChat, this, getOfferPaymentChatReq, map)
        .callRequestServiceHeader(false, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    switch (requestCode) {
      /// Upload Media
      case uploadTaskMediaReq:
        var data = jsonDecode(response);
        debugPrint("uploadTaskMediaReq Error : $data");
        showSnackBar("Manage task", data["message"].toString(), Colors.red);
        /*  if (data["errors"] != null) {
          showSnackBar("Error", data["errors"]["msg"].toString(), Colors.red);
        } else {
          showSnackBar("Error", data.toString(), Colors.red);
        }*/
        break;

      /// Get Chat Listing
      case getOfferPaymentChatReq:
      case getMediaTaskChatListReq:
        var data = jsonDecode(response);
        debugPrint("getMediaTaskChatListReq Error : $data");
        if (data["errors"] != null) {
          showSnackBar("Error", data["errors"]["msg"].toString(), Colors.red);
        } else {
          showSnackBar("Error", data.toString(), Colors.red);
        }
        break;

      case reqGetDetailsById:
        var data = jsonDecode(response);
        debugPrint("content detail Error : $data");
        break;
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    switch (requestCode) {
      /// Upload Media
      case uploadTaskMediaReq:
        var data = jsonDecode(response);
        debugPrint("uploadTaskMediaReq Success : $data");
        imageId = data["data"] != null ? data["data"]["_id"] : "";
        debugPrint("imageID=========> $imageId");
        var mediaMap = {
          "attachment": data["image_name"] ?? "",
          "watermark": data["watermark"] ?? "",
          "attachment_name": data["attachme_name"] ?? "",
          "attachment_size": data["video_size"] ?? "",
          "thumbnail_url": data["videothubnail_path"] ?? "",
          "image_id": data["data"] != null ? data["data"]["_id"] : "",
          // "image_id": widget.taskDetail?.id ?? widget.contentId ?? "",
        };
        //showSnackBar("Manage Task", "Content added successfully", Colors.red);
        socketEmitFunc(
            socketEvent: "media message",
            messageType: "media",
            dataMap: mediaMap,
            mediaType: data["type"] ?? "image");

        if (_chatId.isNotEmpty) {
          var map = {
            "chat_id": _chatId,
            "status": true,
          };

          socketEmitFunc(
              socketEvent: "reqstatus", messageType: "", dataMap: map);

          _chatId = "";
          _againUpload = false;
        }

        uploadSuccess = true;
        setState(() {});
        break;

      case getOfferPaymentChatReq:
        var data = jsonDecode(response);

        debugPrint("getOfferPaymentChat -> $data");
        var resp = data["resposne"];
        contentView = resp["viewCount"].toString();
        contentPurchased = resp["purchaseCount"].toString();
        if (resp["rating"] != null) {
          ratingReviewController1.text = data["rating"]["review"];
          ratings = double.parse(data["rating"]["rating"]);
          isRatingGiven = true;
          for (String data in data["rating"]["features"]) {
            dataList.add(data);
          }
        }
        final chats = resp["chat"] as List;
        chatList.clear();
        if (chats.isNotEmpty) {
          for (var item in chats) {
            var pub = item["publication"];
            for (var item2 in pub) {
              chatList.add(ManageTaskChatModel.fromJsonNew(item2));
            }
          }
        }
        // chats.map((e) => ManageTaskChatModel.fromJsonNew(e)).toList();
        // debugPrint("chatList length::::: ${chatList.first.messageType.toString()}");
        isLoading = true;
        if (mounted) {
          setState(() {});
        }
        break;

      /// Get Chat Listing
      case getMediaTaskChatListReq:
        var data = jsonDecode(response);
        debugPrint("getMediaTaskChatListReq Success::::: $data");
        var dataModel = data["response"] as List;
        contentView = data["views"].toString();
        contentPurchased = data["purchased_count"].toString();
        if (data["rating"] != null) {
          ratingReviewController1.text = data["rating"]["review"];
          ratings = double.parse(data["rating"]["rating"]);
          // dataList.addAll(data["rating"]["features"].toList());
          isRatingGiven = true;
          for (String data in data["rating"]["features"]) {
            dataList.add(data);
          }
        }
        chatList.clear();
        chatList =
            dataModel.map((e) => ManageTaskChatModel.fromJson(e)).toList();
        debugPrint("chatList length::::: ${chatList.length}");
        isLoading = true;
        /* WidgetsBinding.instance.addPostFrameCallback((_) {
          if(scrollController.hasClients){
         //   _scrollDown();
          }
        });*/
        if (mounted) {
          setState(() {});
        }
        // _chatUpdateTimer = Timer(const Duration(seconds: 2),()=>callGetManageTaskListingApi());
        break;

      case reqGetDetailsById:
        var data = jsonDecode(response);
        log("getDetail data Success::::: $data");
        var dataList = data['response'] as List;
        earningTransactionDataList =
            dataList.map((e) => EarningTransactionDetail.fromJson(e)).toList();
        setState(() {});
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionDetailScreen(
                      type: "received",
                      transactionData: earningTransactionDataList[0],
                      shouldShowPublication: true,
                    )));
        break;
    }
  }
}
