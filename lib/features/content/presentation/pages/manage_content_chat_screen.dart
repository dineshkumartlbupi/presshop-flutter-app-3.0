import 'dart:async';

import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/constants/string_constants_new2.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/chat/presentation/pages/FullVideoView.dart';
import 'package:presshop/features/content/data/models/my_content_data_model.dart';
import 'package:presshop/features/earning/presentation/pages/TransactionDetailScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';

import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';

// ignore: must_be_immutable
class ManageContentChatScreen extends StatefulWidget {
  ManageContentChatScreen(
      {super.key,
      this.mediaHouseDetail,
      this.contentId,
      this.taskDetail,
      required this.roomId,
      required this.type,
      this.contentMedia,
      this.myContentData,
      this.contentHeader});
  final TaskDetail? taskDetail;
  MyContentData? myContentData;
  final String roomId;
  final Widget? contentMedia;
  final Widget? contentHeader;
  final String? contentId;
  final ManageTaskChatModel? mediaHouseDetail;
  final String type;

  @override
  State<StatefulWidget> createState() {
    return ManageContentChatScreenState();
  }
}

class ManageContentChatScreenState extends State<ManageContentChatScreen>
    with AnalyticsPageMixin {
  late Size size;

  late IO.Socket socket;

  final String _senderId =
      sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
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
  double ratings = 0.0;
  // bool _againUpload = false;
  bool showAcceptBtn = false;
  bool showRejectBtn = false;
  bool isRatingGiven = false;
  String imageId = "";
  String contentView = "0";
  String contentPurchased = "0";
  FlickManager? flickManager;
  PlayerController controller = PlayerController();
  int _currentMediaIndex = 0;
  bool audioPlaying = false;
  bool isDataLoaded = false;
  bool isRequiredVisible = false;
  bool showCelebration = false;
  bool uploadSuccess = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  // void _scrollDown() {
  //   scrollController.animateTo(
  //     scrollController.position.maxScrollExtent,
  //     duration: const Duration(seconds: 2),
  //     curve: Curves.fastOutSlowIn,
  //   );
  // }

  @override
  String get pageName => PageNames.manageContent;

  @override
  void initState() {
    debugPrint(
        "🚀 ManageTaskScreen: initState type=${widget.type} roomId=${widget.roomId}");
    debugPrint(
        "🚀 ManageTaskScreen: contentId=${widget.contentId} taskDetailId=${widget.taskDetail?.id}");

    // Debug: Check taskDetail flags and prices
    if (widget.taskDetail != null) {
      debugPrint("🔍 TaskDetail Debug:");
      debugPrint("  isNeedPhoto: ${widget.taskDetail!.isNeedPhoto}");
      debugPrint("  isNeedVideo: ${widget.taskDetail!.isNeedVideo}");
      debugPrint("  isNeedInterview: ${widget.taskDetail!.isNeedInterview}");
      debugPrint("  photoPrice: ${widget.taskDetail!.photoPrice}");
      debugPrint("  videoPrice: ${widget.taskDetail!.videoPrice}");
      debugPrint("  interviewPrice: ${widget.taskDetail!.interviewPrice}");
    }

    super.initState();

    socketConnectionFunc();
    callGetManageTaskListingApi();
    initialController();
  }

  void onTextChanged() {
    setState(() {
      isRequiredVisible = ratingReviewController1.text.isEmpty;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    flickManager?.dispose();
    controller.dispose();
    ratingReviewController1.dispose();
    socket.disconnect();
    socket.onDisconnect(
        (_) => socket.emit('room join', {"room_id": widget.roomId}));
    super.dispose();
  }

  Widget chatBubbleSpacer() {
    return SizedBox(
      height: size.width * AppDimensions.numD05,
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
      padding:
          EdgeInsets.symmetric(horizontal: size.width * AppDimensions.numD04),
      child: const Divider(color: AppColorTheme.colorGrey1),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.chatList.isNotEmpty) {
          chatList = state.chatList;
          isDataLoaded = true;
        }

        if (state.allTasksStatus == TaskStatus.loading ||
            state.taskDetailStatus == TaskStatus.loading ||
            state.localTasksStatus == TaskStatus.loading) {
          isDataLoaded = false;
        } else if (state.taskDetail != null &&
            state.taskDetailStatus == TaskStatus.success) {
          isDataLoaded = true;
        } else if (state.actionStatus == TaskStatus.success) {
          // If action is success, data loading should stop
          isDataLoaded = true;

          // Check for upload response to distinguish from chat load
          // Only show snackbar/refresh if it seems to be an upload
          if (state.uploadResponse != null) {
            showSnackBar(
                "Success", "Media uploaded successfully", Colors.green);
            _onRefresh();
          }
        } else if (state.transactions.isNotEmpty) {
          if (state.transactions.isNotEmpty) {
            context.pushNamed(
              AppRoutes.transactionDetailName,
              extra: {
                'type': "received",
                'pageType':
                    widget.type == 'content' ? PageType.CONTENT : PageType.TASK,
                'transactionData': state.transactions.first.toEntity(),
                'shouldShowPublication': true,
              },
            );
          }
        } else if (state.errorMessage != null) {
          isDataLoaded = true;
          showSnackBar("Error", state.errorMessage!, Colors.red);
        }

        setState(() {});
      },
      builder: (context, state) {
        return WillPopScope(
            onWillPop: () async {
              context.pop();
              return false;
            },
            child: Scaffold(
                appBar: CommonAppBar(
                  elevation: 0,
                  hideLeading: false,
                  title: Text(
                    widget.contentMedia != null && widget.contentHeader != null
                        ? AppStringsNew2.manageContentText
                        : AppStringsNew2.manageTaskText,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            size.width * AppDimensions.appBarHeadingFontSize),
                  ),
                  centerTitle: false,
                  titleSpacing: 0,
                  size: size,
                  showActions: true,
                  leadingFxn: () {
                    context.pop();
                  },
                  actionWidget: [
                    InkWell(
                      onTap: () {
                        context.goNamed(
                          AppRoutes.dashboardName,
                          extra: {'initialPosition': 2},
                        );
                      },
                      child: Image.asset(
                        "${commonImagePath}ic_black_rabbit.png",
                        height: size.width * AppDimensions.numD07,
                        width: size.width * AppDimensions.numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    )
                  ],
                ),
                body:
                    ((state.allTasksStatus == TaskStatus.loading ||
                                    state.taskDetailStatus ==
                                        TaskStatus.loading ||
                                    state.localTasksStatus ==
                                        TaskStatus.loading) &&
                                !isDataLoaded) ||
                            (state.allTasksStatus == TaskStatus.initial &&
                                !isDataLoaded)
                        ? Center(child: showLoader())
                        : SafeArea(
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
                                                      horizontal: size.width *
                                                          AppDimensions.numD04),
                                                  child:
                                                      uploadMediaInfoWidget(""),
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            margin: EdgeInsets.only(
                                                                left: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD04),
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
                                                                padding: EdgeInsets.all(size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD01),
                                                                child:
                                                                    Image.asset(
                                                                  "${commonImagePath}ic_black_rabbit.png",
                                                                  color: Colors
                                                                      .white,
                                                                  width: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD07,
                                                                  height: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD07,
                                                                ),
                                                              ),
                                                            )),
                                                        SizedBox(
                                                          width: size.width *
                                                              AppDimensions
                                                                  .numD025,
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                          margin: EdgeInsets.only(
                                                              top: 0,
                                                              right: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD04),
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD05,
                                                              vertical: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD02),
                                                          width: size.width,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border.all(
                                                                      color: AppColorTheme
                                                                          .colorGoogleButtonBorder),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topRight: Radius.circular(size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD04),
                                                                    bottomLeft: Radius.circular(size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD04),
                                                                    bottomRight: Radius.circular(size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD04),
                                                                  )),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD01,
                                                              ),
                                                              contentPurchased !=
                                                                      "0"
                                                                  ? RichText(
                                                                      text: TextSpan(
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                size.width * AppDimensions.numD037,
                                                                            fontFamily:
                                                                                "AirbnbCereal",
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "This is fab. Your content was ",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.normal),
                                                                          ),
                                                                          int.parse(contentView) < 2
                                                                              ? TextSpan(
                                                                                  text: int.parse(contentView) > 2 ? 'viewed by $contentView publications' : 'viewed by $contentView publication',
                                                                                  style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD036, color: AppColorTheme.colorThemePink, fontWeight: FontWeight.w600),
                                                                                )
                                                                              : TextSpan(
                                                                                  text: int.parse(contentView) < 10 ? 'viewed by $contentView publications' : 'viewed by $contentView publications',
                                                                                  style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD036, color: AppColorTheme.colorThemePink, fontWeight: FontWeight.w600),
                                                                                ),
                                                                          TextSpan(
                                                                            text:
                                                                                " and ",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.normal),
                                                                          ),
                                                                          int.parse(contentPurchased) < 2
                                                                              ? TextSpan(
                                                                                  text: int.parse(contentPurchased) < 2 ? 'purchased by $contentPurchased publication' : 'purchased by $contentPurchased publications',
                                                                                  style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD036, color: AppColorTheme.colorThemePink, fontWeight: FontWeight.w600),
                                                                                )
                                                                              : TextSpan(
                                                                                  text: int.parse(contentPurchased) < 10 ? 'purchased by $contentPurchased publications' : 'purchased by $contentPurchased publications',
                                                                                  style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD036, color: AppColorTheme.colorThemePink, fontWeight: FontWeight.w600),
                                                                                ),
                                                                        ]))
                                                                  : int.parse(contentView) < 1
                                                                      ? RichText(
                                                                          text: TextSpan(children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "You’re officially a newsmaker!  Your content has been ",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.normal),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                "successfully published.",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: AppColorTheme.colorThemePink,
                                                                                fontWeight: FontWeight.w600),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                "Get ready for ",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.normal),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                "offers to start rolling in!",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: AppColorTheme.colorThemePink,
                                                                                fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ]))
                                                                      : RichText(
                                                                          text: TextSpan(children: [
                                                                          TextSpan(
                                                                            text:
                                                                                "This is fab. Your content was ",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.normal),
                                                                          ),
                                                                          TextSpan(
                                                                            text: int.parse(contentView) > 2
                                                                                ? 'viewed by $contentView publications'
                                                                                : 'viewed by $contentView publication',
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: AppColorTheme.colorThemePink,
                                                                                fontWeight: FontWeight.w600),
                                                                          ),
                                                                        ])),
                                                              SizedBox(
                                                                height: contentPurchased !=
                                                                        "0"
                                                                    ? size.width *
                                                                        AppDimensions
                                                                            .numD05
                                                                    : size.width *
                                                                        AppDimensions
                                                                            .numD01,
                                                              ),
                                                              contentPurchased !=
                                                                      "0"
                                                                  ? SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          AppDimensions
                                                                              .numD13,
                                                                      width: size
                                                                          .width,
                                                                      child: commonElevatedButton(
                                                                          "View My Earnings",
                                                                          size,
                                                                          commonButtonTextStyle(
                                                                              size),
                                                                          commonButtonStyle(
                                                                              size,
                                                                              AppColorTheme.colorThemePink),
                                                                          () {
                                                                        context
                                                                            .pushNamed(
                                                                          AppRoutes
                                                                              .myEarningName,
                                                                          extra: {
                                                                            'openDashboard':
                                                                                false,
                                                                            'initialTapPosition':
                                                                                2,
                                                                          },
                                                                        );
                                                                      }),
                                                                    )
                                                                  : Container(),
                                                              SizedBox(
                                                                height: size
                                                                        .height *
                                                                    AppDimensions
                                                                        .numD01,
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: size.width *
                                                          AppDimensions.numD025,
                                                    ),
                                                    // widgetDivider()
                                                    chatDividerSpacer()
                                                  ],
                                                ),

                                          SizedBox(
                                            height: size.height *
                                                AppDimensions.numD01,
                                          ),

                                          ListView.separated(
                                              separatorBuilder:
                                                  (context, index) {
                                                return SizedBox(
                                                  height: size.height *
                                                      AppDimensions.numD02,
                                                );
                                              },
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: size.width *
                                                    AppDimensions.numD04,
                                              ),
                                              itemBuilder: (context, index) {
                                                var item = chatList[index];
                                                if (item.messageType ==
                                                    "media") {
                                                  if (item.media!.type
                                                      .contains("video")) {
                                                    return Column(
                                                      children: [
                                                        rightVideoChatWidget(
                                                            item.media!
                                                                .thumbnail,
                                                            item.media!
                                                                .imageVideoUrl),
                                                        SizedBox(
                                                          height: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                        ),
                                                        thanksToUploadMediaWidget(
                                                            "video"),
                                                        SizedBox(
                                                          height: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                        ),
                                                      ],
                                                    );
                                                  } else if (item.media!.type
                                                      .contains("audio")) {
                                                    return Column(
                                                      children: [
                                                        rightAudioChatWidget(
                                                            item.media!
                                                                .imageVideoUrl),
                                                        SizedBox(
                                                          height: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                        ),
                                                        thanksToUploadMediaWidget(
                                                            "audio"),
                                                        SizedBox(
                                                          height: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                        ),
                                                      ],
                                                    );
                                                  } else {
                                                    return Column(
                                                      children: [
                                                        rightImageChatWidget(
                                                          item.media!.type
                                                                  .contains(
                                                                      "video")
                                                              ? item.media!
                                                                  .thumbnail
                                                              : item.media!
                                                                  .imageVideoUrl,
                                                          item.createdAtTime,
                                                        ),
                                                        SizedBox(
                                                          height: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                        ),
                                                        thanksToUploadMediaWidget(
                                                            "photo"),
                                                        SizedBox(
                                                          height: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                } else if (item.messageType ==
                                                    "Payment") {
                                                  return paymentReceivedWidget(
                                                      item);
                                                } else if (item.messageType ==
                                                    "request_more_content") {
                                                  return moreContentReqWidget(
                                                      item);
                                                } else if (item.messageType ==
                                                    "contentupload") {
                                                  return Column(
                                                    children: [
                                                      uploadMediaInfoWidget(
                                                          "request_more_content"),
                                                      SizedBox(
                                                        height: size.width *
                                                            AppDimensions
                                                                .numD03,
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
                                                  return counterFieldWidget(
                                                      item);
                                                }
                                                // else if (item.messageType == "rating_hopper") {
                                                //   return ratingWidget(item);
                                                // }
                                                else if (item.messageType ==
                                                    "MakeOverPrice") {
                                                  return makeOverPriceWidget(
                                                      item.hopperPrice,
                                                      item.amount);
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
                                                          height: size.height *
                                                              AppDimensions
                                                                  .numD01,
                                                        ),
                                                        chatDividerSpacer(),
                                                        SizedBox(
                                                          height: size.height *
                                                              AppDimensions
                                                                  .numD01,
                                                        ),
                                                        Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                    margin: EdgeInsets.only(
                                                                        left: size.width *
                                                                            AppDimensions
                                                                                .numD04),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        shape: BoxShape.circle,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                              color: Colors.grey.shade300,
                                                                              spreadRadius: 2)
                                                                        ]),
                                                                    child:
                                                                        ClipOval(
                                                                      clipBehavior:
                                                                          Clip.antiAlias,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(size.width *
                                                                                AppDimensions.numD01),
                                                                        child: Image
                                                                            .asset(
                                                                          "${commonImagePath}ic_black_rabbit.png",
                                                                          color:
                                                                              Colors.white,
                                                                          width:
                                                                              size.width * AppDimensions.numD07,
                                                                          height:
                                                                              size.width * AppDimensions.numD07,
                                                                        ),
                                                                      ),
                                                                    )),
                                                                SizedBox(
                                                                  width: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD025,
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        Container(
                                                                  margin: EdgeInsets.only(
                                                                      right: size
                                                                              .width *
                                                                          AppDimensions
                                                                              .numD04),
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal: size
                                                                              .width *
                                                                          AppDimensions
                                                                              .numD04,
                                                                      vertical: size
                                                                              .width *
                                                                          AppDimensions
                                                                              .numD02),
                                                                  width: size
                                                                      .width,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          border:
                                                                              Border.all(color: AppColorTheme.colorGoogleButtonBorder),
                                                                          borderRadius: BorderRadius.only(
                                                                            topRight:
                                                                                Radius.circular(size.width * AppDimensions.numD04),
                                                                            bottomLeft:
                                                                                Radius.circular(size.width * AppDimensions.numD04),
                                                                            bottomRight:
                                                                                Radius.circular(size.width * AppDimensions.numD04),
                                                                          )),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        height: size.height *
                                                                            AppDimensions.numD01,
                                                                      ),
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                            TextSpan(
                                                                              text: "Rate your experience with PressHop",
                                                                              style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD036, color: Colors.black, fontWeight: FontWeight.w600),
                                                                            ),
                                                                          ])),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD04,
                                                                      ),
                                                                      RatingBar(
                                                                        glowRadius:
                                                                            0,
                                                                        ratingWidget:
                                                                            RatingWidget(
                                                                          empty:
                                                                              Image.asset("${iconsPath}emptystar.png"),
                                                                          full:
                                                                              Image.asset("${iconsPath}star.png"),
                                                                          half:
                                                                              Image.asset("${iconsPath}ic_half_star.png"),
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
                                                                                AppDimensions.numD09,
                                                                        itemCount:
                                                                            5,
                                                                        initialRating:
                                                                            ratings,
                                                                        allowHalfRating:
                                                                            true,
                                                                        itemPadding:
                                                                            EdgeInsets.only(left: size.width * AppDimensions.numD03),
                                                                      ),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            0.04,
                                                                      ),
                                                                      const Text(
                                                                        "Tell us what you liked about the App",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight: FontWeight.w700),
                                                                      ),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD018,
                                                                      ),
                                                                      Wrap(
                                                                          spacing:
                                                                              0.2,
                                                                          runSpacing:
                                                                              0.1,
                                                                          children: List<Widget>.generate(
                                                                              intList.length,
                                                                              (index) {
                                                                            return Container(
                                                                              margin: EdgeInsets.only(left: size.width * 0.012, right: size.width * 0.012),
                                                                              child: ChoiceChip(
                                                                                label: Text(intList[index]),
                                                                                labelStyle: TextStyle(color: dataList.contains(intList[index]) ? Colors.white : AppColorTheme.colorGrey6),
                                                                                onSelected: (bool selected) {
                                                                                  if (selected) {
                                                                                    for (int i = 0; i < intList.length; i++) {
                                                                                      if (intList[i] == intList[index] && !dataList.contains(intList[i])) {
                                                                                        dataList.add(intList[i]);
                                                                                        indexList.add(i);
                                                                                      }
                                                                                    }
                                                                                  } else {
                                                                                    for (int i = 0; i < intList.length; i++) {
                                                                                      if (intList[i] == intList[index] && dataList.contains(intList[i])) {
                                                                                        dataList.remove(intList[i]);
                                                                                        indexList.remove(i);
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                  setState(() {});
                                                                                },
                                                                                selectedColor: AppColorTheme.colorThemePink,
                                                                                disabledColor: AppColorTheme.colorGreyChat.withOpacity(.3),
                                                                                selected: dataList.contains(intList[index]) ? true : false,
                                                                              ),
                                                                            );
                                                                          })),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD02,
                                                                      ),
                                                                      Stack(
                                                                        children: [
                                                                          TextFormField(
                                                                            controller:
                                                                                ratingReviewController1,
                                                                            cursorColor:
                                                                                AppColorTheme.colorTextFieldIcon,
                                                                            keyboardType:
                                                                                TextInputType.multiline,
                                                                            maxLines:
                                                                                6,
                                                                            readOnly:
                                                                                false,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: size.width * AppDimensions.numD035,
                                                                            ),
                                                                            onChanged:
                                                                                (v) {
                                                                              onTextChanged();
                                                                            },
                                                                            decoration:
                                                                                InputDecoration(
                                                                              hintText: AppStringsNew2.textData,
                                                                              contentPadding: EdgeInsets.only(left: size.width * AppDimensions.numD08, right: size.width * AppDimensions.numD02, top: size.width * AppDimensions.numD075),
                                                                              hintStyle: TextStyle(color: Colors.grey.shade400, wordSpacing: 2, fontSize: size.width * AppDimensions.numD035),
                                                                              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * 0.03), borderSide: BorderSide(width: 1, color: Colors.grey.shade300)),
                                                                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * 0.03), borderSide: BorderSide(width: 1, color: Colors.grey.shade300)),
                                                                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * 0.03), borderSide: const BorderSide(width: 1, color: Colors.black)),
                                                                              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * 0.03), borderSide: BorderSide(width: 1, color: Colors.grey.shade300)),
                                                                              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * 0.03), borderSide: const BorderSide(width: 1, color: Colors.grey)),
                                                                              alignLabelWithHint: false,
                                                                            ),
                                                                            autovalidateMode:
                                                                                AutovalidateMode.onUserInteraction,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(top: size.width * AppDimensions.numD038, left: size.width * AppDimensions.numD014),
                                                                            child:
                                                                                Image.asset(
                                                                              "${iconsPath}docs.png",
                                                                              width: size.width * 0.06,
                                                                              height: size.width * 0.07,
                                                                              color: Colors.grey.shade400,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              size.width * AppDimensions.numD017),
                                                                      ratingReviewController1
                                                                              .text
                                                                              .isEmpty
                                                                          ? const Text(
                                                                              "Required",
                                                                              style: TextStyle(fontSize: 11, color: AppColorTheme.colorThemePink, fontWeight: FontWeight.w400),
                                                                            )
                                                                          : Container(),
                                                                      SizedBox(
                                                                          height:
                                                                              size.width * AppDimensions.numD04),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD13,
                                                                        width: size
                                                                            .width,
                                                                        child: commonElevatedButton(
                                                                            isRatingGiven ? "Thanks a Ton" : AppStringsNew2.submitText,
                                                                            size,
                                                                            isRatingGiven ? TextStyle(color: Colors.black, fontSize: size.width * AppDimensions.numD037, fontFamily: "AirbnbCereal", fontWeight: FontWeight.bold) : commonButtonTextStyle(size),
                                                                            commonButtonStyle(size, isRatingGiven ? Colors.grey : AppColorTheme.colorThemePink),
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
                                                                                      showSnackBar("Required *", "Please enter some review for mediahouse", Colors.red);
                                                                                    }
                                                                                  }
                                                                                : () {
                                                                                    debugPrint("already rated:::;");
                                                                                  }),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              size.width * 0.02),
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD03, color: Colors.black, fontWeight: FontWeight.w400),
                                                                              children: [
                                                                            TextSpan(
                                                                              text: "Please refer to our ",
                                                                              style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD03, color: Colors.black, fontWeight: FontWeight.w400),
                                                                            ),
                                                                            TextSpan(
                                                                                text: "Terms & Conditions. ",
                                                                                style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD03, color: AppColorTheme.colorThemePink, fontWeight: FontWeight.w400),
                                                                                recognizer: TapGestureRecognizer()
                                                                                  ..onTap = () {
                                                                                    context.pushNamed(
                                                                                      AppRoutes.termName,
                                                                                      extra: {
                                                                                        'type': 'legal'
                                                                                      },
                                                                                    );
                                                                                  }),
                                                                            TextSpan(
                                                                              text: "The price of your content can be automatically adjusted in order to increase sales. If you have any questions, please ",
                                                                              style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD03, color: Colors.black, fontWeight: FontWeight.w400),
                                                                            ),
                                                                            TextSpan(
                                                                                text: "contact ",
                                                                                style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD03, color: AppColorTheme.colorThemePink, fontWeight: FontWeight.w400),
                                                                                recognizer: TapGestureRecognizer()
                                                                                  ..onTap = () {
                                                                                    context.pushNamed(AppRoutes.contactUsName);
                                                                                  }),
                                                                            TextSpan(
                                                                              text: "our helpful teams who are available 24x7 to assist you. Thank you",
                                                                              style: commonTextStyle(size: size, fontSize: size.width * AppDimensions.numD03, color: Colors.black, fontWeight: FontWeight.w400),
                                                                            ),
                                                                          ])),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            0.01,
                                                                      ),

                                                                      /*Row(
                                                                    children: [
                                                                      Expanded(
                                                                              child: SizedBox(
                                                                                height: size.width * AppDimensions.numD13,
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
                                                  BorderRadius.circular(size.width * AppDimensions.numD04),
                                                  side: (item.requestStatus == "false" ||
                                                      item.requestStatus.isEmpty) &&
                                                      !item.isMakeCounterOffer
                                                      ? BorderSide.none
                                                      : const BorderSide(
                                                      color: Colors.black, width: 1))),
                                                                                  child: Text(
                                                                                        AppStringsNew2.rejectText,
                                                                                        style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * AppDimensions.numD037,
                                                color: (item.requestStatus == "false" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? Colors.white
                                                    : AppColorTheme.colorLightGreen,
                                                fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ),
                                                                              )),
                                                                      SizedBox(
                                                                        width: size.width * AppDimensions.numD04,
                                                                      ),
                                                                      Expanded(
                                                                              child: SizedBox(
                                                                                height: size.width * AppDimensions.numD13,
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
                                                  ? AppColorTheme.colorThemePink
                                                  : item.requestStatus == "true"
                                                  ? Colors.grey
                                                  : Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(size.width * AppDimensions.numD04),
                                                  side: (item.requestStatus == "true" ||
                                                      item.requestStatus.isEmpty) &&
                                                      !item.isMakeCounterOffer
                                                      ? BorderSide.none
                                                      : const BorderSide(
                                                      color: Colors.black, width: 1))),
                                                                                  child: Text(
                                                                                        AppStringsNew2.acceptText,
                                                                                        style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * AppDimensions.numD037,
                                                color: (item.requestStatus == "true" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? Colors.white
                                                    : AppColorTheme.colorLightGreen,
                                                fontWeight: FontWeight.w500),
                                                                                  ),
                                                                                ),
                                                                              )),
                                                
                                                                      */
                                                                      /* Expanded(
                                                                              child: SizedBox(
                                                                                height: size.width * AppDimensions.numD13,
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
                                                  ? AppColorTheme.colorThemePink
                                                  :item.requestStatus == "true"
                                                  ?  Colors.grey
                                                  :  Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    size.width * AppDimensions.numD04),
                                                  side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                                      color: AppColorTheme.colorGrey1, width: 2)
                                              )),
                                                                                  child: Text(
                                                                                        AppStringsNew2.yesText,
                                                                                        style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * AppDimensions.numD04,
                                                color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : AppColorTheme.colorLightGreen,
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
                                              ? (widget.taskDetail!
                                                          .paidStatus ==
                                                      "paid"
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          left: size.width *
                                                              AppDimensions
                                                                  .numD04,
                                                          right: size.width *
                                                              AppDimensions
                                                                  .numD04),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                top: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD013),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
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
                                                              child: Padding(
                                                                padding: EdgeInsets.all(size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD01),
                                                                child:
                                                                    Image.asset(
                                                                  "${commonImagePath}ic_black_rabbit.png",
                                                                  width: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD075,
                                                                  height: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD075,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD04,
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD05,
                                                                  vertical: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD02),
                                                              width: size.width,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topRight:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                        bottomLeft:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                        bottomRight:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                      )),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD01,
                                                                  ),
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                "AirbnbCereal",
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Congratulations, ",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.normal),
                                                                        ),
                                                                        TextSpan(
                                                                          text: widget
                                                                              .taskDetail!
                                                                              .mediaHouseName,
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: AppColorTheme.colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              " has purchased your content for ",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.normal),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              "$currencySymbol${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: AppColorTheme.colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ])),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD03,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD13,
                                                                        width: size
                                                                            .width,
                                                                        child: commonElevatedButton(
                                                                            "View Transaction Details task",
                                                                            size,
                                                                            commonButtonTextStyle(
                                                                                size),
                                                                            commonButtonStyle(size,
                                                                                AppColorTheme.colorThemePink),
                                                                            () {
                                                                          callDetailApi(widget
                                                                              .taskDetail!
                                                                              .mediaHouseId);
                                                                        }),
                                                                      ),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD01,
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
                                            height: size.width *
                                                AppDimensions.numD04,
                                          ),
                                          widget.type == "task_content"
                                              ? (widget.taskDetail!
                                                          .paidStatus ==
                                                      "paid"
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          left: size.width *
                                                              AppDimensions
                                                                  .numD04,
                                                          right: size.width *
                                                              AppDimensions
                                                                  .numD04),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                top: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD013),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
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
                                                              child: Padding(
                                                                padding: EdgeInsets.all(size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD01),
                                                                child:
                                                                    Image.asset(
                                                                  "${commonImagePath}ic_black_rabbit.png",
                                                                  width: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD075,
                                                                  height: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD075,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD04,
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD05,
                                                                  vertical: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD02),
                                                              width: size.width,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      border: Border.all(
                                                                          color: AppColorTheme
                                                                              .colorGoogleButtonBorder),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topRight:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                        bottomLeft:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                        bottomRight:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                      )),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD01,
                                                                  ),
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                size.width * AppDimensions.numD037,
                                                                            fontFamily:
                                                                                "AirbnbCereal",
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Woohoo! We have paid ",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.normal),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              "$currencySymbol${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: AppColorTheme.colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              " into your bank account. Please visit ",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.normal),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              "My Earnings",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: AppColorTheme.colorThemePink,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              " to view your transaction ",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.normal),
                                                                        )
                                                                      ])),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD025,
                                                                  ),
                                                                  /*Row(
                            children: [
                              Expanded(
                                    child: SizedBox(
                                      height: size.width * AppDimensions.numD13,
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
                                                BorderRadius.circular(size.width * AppDimensions.numD04),
                                                side: (item.requestStatus == "false" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? BorderSide.none
                                                    : const BorderSide(
                                                    color: Colors.black, width: 1))),
                                        child: Text(
                                          AppStringsNew2.rejectText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * AppDimensions.numD037,
                                              color: (item.requestStatus == "false" ||
                                                  item.requestStatus.isEmpty) &&
                                                  !item.isMakeCounterOffer
                                                  ? Colors.white
                                                  : AppColorTheme.colorLightGreen,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                    child: SizedBox(
                                      height: size.width * AppDimensions.numD13,
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
                                                ? AppColorTheme.colorThemePink
                                                : item.requestStatus == "true"
                                                ? Colors.grey
                                                : Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(size.width * AppDimensions.numD04),
                                                side: (item.requestStatus == "true" ||
                                                    item.requestStatus.isEmpty) &&
                                                    !item.isMakeCounterOffer
                                                    ? BorderSide.none
                                                    : const BorderSide(
                                                    color: Colors.black, width: 1))),
                                        child: Text(
                                          AppStringsNew2.acceptText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * AppDimensions.numD037,
                                              color: (item.requestStatus == "true" ||
                                                  item.requestStatus.isEmpty) &&
                                                  !item.isMakeCounterOffer
                                                  ? Colors.white
                                                  : AppColorTheme.colorLightGreen,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )),
                                                
                              */
                                                                  /* Expanded(
                                    child: SizedBox(
                                      height: size.width * AppDimensions.numD13,
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
                                                ? AppColorTheme.colorThemePink
                                                :item.requestStatus == "true"
                                                ?  Colors.grey
                                                :  Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  size.width * AppDimensions.numD04),
                                                side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                                    color: AppColorTheme.colorGrey1, width: 2)
                                            )),
                                        child: Text(
                                          AppStringsNew2.yesText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * AppDimensions.numD04,
                                              color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : AppColorTheme.colorLightGreen,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    )),*/ /*
                            ],
                                                    ),*/
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD03,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD13,
                                                                        width: size
                                                                            .width,
                                                                        child: commonElevatedButton(
                                                                            "View My Earnings",
                                                                            size,
                                                                            commonButtonTextStyle(
                                                                                size),
                                                                            commonButtonStyle(size,
                                                                                AppColorTheme.colorThemePink),
                                                                            () {
                                                                          context
                                                                              .pushNamed(
                                                                            AppRoutes.myEarningName,
                                                                            extra: {
                                                                              'openDashboard': false,
                                                                              'initialTapPosition': 2,
                                                                            },
                                                                          );
                                                                        }),
                                                                      ),
                                                                      SizedBox(
                                                                        height: size.width *
                                                                            AppDimensions.numD01,
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
                                            height: size.width *
                                                AppDimensions.numD04,
                                          ),

                                          widget.type == "task_content"
                                              ? (widget.taskDetail!
                                                          .paidStatus ==
                                                      "paid"
                                                  ? Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets.only(
                                                                  left: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD04),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
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
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD01),
                                                                  child: Image
                                                                      .asset(
                                                                    "${commonImagePath}ic_black_rabbit.png",
                                                                    width: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD075,
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD075,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD04,
                                                            ),
                                                            Expanded(
                                                                child:
                                                                    Container(
                                                              margin: EdgeInsets.only(
                                                                  right: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD04,
                                                                  bottom: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD06),
                                                              padding: EdgeInsets.symmetric(
                                                                  horizontal: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD05,
                                                                  vertical: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD02),
                                                              width: size.width,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade400),
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topRight:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                        bottomLeft:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                        bottomRight:
                                                                            Radius.circular(size.width *
                                                                                AppDimensions.numD04),
                                                                      )),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD04,
                                                                  ),
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: const TextStyle(
                                                                            fontFamily:
                                                                                "AirbnbCereal",
                                                                          ),
                                                                          children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Rate your experience with PressHop",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD035,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                        ),
                                                                      ])),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD04,
                                                                  ),
                                                                  RatingBar(
                                                                    glowRadius:
                                                                        0,
                                                                    ratingWidget:
                                                                        RatingWidget(
                                                                      empty: Image
                                                                          .asset(
                                                                              "${iconsPath}emptystar.png"),
                                                                      full: Image
                                                                          .asset(
                                                                              "${iconsPath}star.png"),
                                                                      half: Image
                                                                          .asset(
                                                                              "${iconsPath}ic_half_star.png"),
                                                                    ),
                                                                    onRatingUpdate:
                                                                        (value) {
                                                                      ratings =
                                                                          value;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    itemSize: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD09,
                                                                    itemCount:
                                                                        5,
                                                                    initialRating:
                                                                        ratings,
                                                                    allowHalfRating:
                                                                        true,
                                                                    itemPadding:
                                                                        EdgeInsets.only(
                                                                            left:
                                                                                size.width * AppDimensions.numD03),
                                                                  ),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        0.04,
                                                                  ),
                                                                  Text(
                                                                    "Tell us what you liked about the App",
                                                                    style: TextStyle(
                                                                        fontSize: size.width *
                                                                            AppDimensions
                                                                                .numD035,
                                                                        color: Colors
                                                                            .black,
                                                                        fontFamily:
                                                                            "AirbnbCereal",
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  ),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD018,
                                                                  ),
                                                                  Wrap(
                                                                      children: List<
                                                                              Widget>.generate(
                                                                          intList
                                                                              .length,
                                                                          (index) {
                                                                    return Container(
                                                                      margin: EdgeInsets.only(
                                                                          left: size.width *
                                                                              0.02,
                                                                          right:
                                                                              size.width * 0.02),
                                                                      child:
                                                                          ChoiceChip(
                                                                        label: Text(
                                                                            intList[index]),
                                                                        labelStyle: TextStyle(
                                                                            color: dataList.contains(intList[index])
                                                                                ? Colors.white
                                                                                : AppColorTheme.colorGrey6,
                                                                            fontFamily: "AirbnbCereal",
                                                                            fontSize: size.width * AppDimensions.numD035),
                                                                        onSelected:
                                                                            (selected) {
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
                                                                            AppColorTheme.colorThemePink,
                                                                        disabledColor: AppColorTheme
                                                                            .colorGreyChat
                                                                            .withOpacity(.3),
                                                                        selected: dataList.contains(intList[index])
                                                                            ? true
                                                                            : false,
                                                                      ),
                                                                    );
                                                                  })),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD02,
                                                                  ),
                                                                  Stack(
                                                                    children: [
                                                                      TextFormField(
                                                                        controller:
                                                                            ratingReviewController1,
                                                                        cursorColor:
                                                                            AppColorTheme.colorTextFieldIcon,
                                                                        keyboardType:
                                                                            TextInputType.multiline,
                                                                        maxLines:
                                                                            6,
                                                                        readOnly:
                                                                            false,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontSize:
                                                                              size.width * AppDimensions.numD035,
                                                                        ),
                                                                        onChanged:
                                                                            (v) {
                                                                          onTextChanged();
                                                                        },
                                                                        decoration:
                                                                            InputDecoration(
                                                                          hintText:
                                                                              AppStringsNew2.textData,
                                                                          contentPadding: EdgeInsets.only(
                                                                              left: size.width * AppDimensions.numD08,
                                                                              right: size.width * AppDimensions.numD02,
                                                                              top: size.width * AppDimensions.numD075),
                                                                          hintStyle: TextStyle(
                                                                              color: Colors.grey.shade400,
                                                                              wordSpacing: 2,
                                                                              fontSize: size.width * AppDimensions.numD035),
                                                                          disabledBorder: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(size.width * 0.03),
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey.shade300)),
                                                                          focusedBorder: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(size.width * 0.03),
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey.shade300)),
                                                                          enabledBorder: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(size.width * 0.03),
                                                                              borderSide: const BorderSide(width: 1, color: Colors.black)),
                                                                          errorBorder: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(size.width * 0.03),
                                                                              borderSide: BorderSide(width: 1, color: Colors.grey.shade300)),
                                                                          focusedErrorBorder: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(size.width * 0.03),
                                                                              borderSide: const BorderSide(width: 1, color: Colors.grey)),
                                                                          alignLabelWithHint:
                                                                              false,
                                                                        ),
                                                                        autovalidateMode:
                                                                            AutovalidateMode.onUserInteraction,
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            top:
                                                                                size.width * AppDimensions.numD038,
                                                                            left: size.width * AppDimensions.numD014),
                                                                        child: Image
                                                                            .asset(
                                                                          "${iconsPath}docs.png",
                                                                          width:
                                                                              size.width * 0.06,
                                                                          height:
                                                                              size.width * 0.07,
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
                                                                          AppDimensions
                                                                              .numD017),
                                                                  ratingReviewController1
                                                                          .text
                                                                          .isEmpty
                                                                      ? const Text(
                                                                          "Required",
                                                                          style: TextStyle(
                                                                              fontSize: 11,
                                                                              color: AppColorTheme.colorThemePink,
                                                                              fontWeight: FontWeight.w400),
                                                                        )
                                                                      : Container(),
                                                                  SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          AppDimensions
                                                                              .numD04),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD13,
                                                                    width: size
                                                                        .width,
                                                                    child: commonElevatedButton(
                                                                        isRatingGiven ? "Thanks a Ton" : AppStringsNew2.submitText,
                                                                        size,
                                                                        isRatingGiven ? TextStyle(color: Colors.black, fontSize: size.width * AppDimensions.numD037, fontFamily: "AirbnbCereal", fontWeight: FontWeight.bold) : commonButtonTextStyle(size),
                                                                        commonButtonStyle(size, isRatingGiven ? Colors.grey : AppColorTheme.colorThemePink),
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
                                                                                  showSnackBar("Required *", "Please enter some review for mediahouse", Colors.red);
                                                                                }
                                                                              }
                                                                            : () {
                                                                                debugPrint("already rated:::;");
                                                                              }),
                                                                  ),
                                                                  SizedBox(
                                                                      height: size
                                                                              .width *
                                                                          0.01),
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Please refer to our ",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              lineHeight: 1.2,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                        TextSpan(
                                                                            text:
                                                                                "Terms & Conditions. ",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: AppColorTheme.colorThemePink,
                                                                                lineHeight: 2,
                                                                                fontWeight: FontWeight.w600),
                                                                            recognizer: TapGestureRecognizer()
                                                                              ..onTap = () {
                                                                                context.pushNamed(
                                                                                  AppRoutes.termName,
                                                                                  extra: {
                                                                                    'type': 'legal'
                                                                                  },
                                                                                );
                                                                              }),
                                                                        TextSpan(
                                                                          text:
                                                                              "If you have any questions, please ",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                        TextSpan(
                                                                            text:
                                                                                "contact ",
                                                                            style: commonTextStyle(
                                                                                size: size,
                                                                                fontSize: size.width * AppDimensions.numD036,
                                                                                color: AppColorTheme.colorThemePink,
                                                                                fontWeight: FontWeight.w600),
                                                                            recognizer: TapGestureRecognizer()
                                                                              ..onTap = () {
                                                                                context.pushNamed(AppRoutes.contactUsName);
                                                                              }),
                                                                        TextSpan(
                                                                          text:
                                                                              "our helpful teams who are available 24x7 to assist you. Thank you",
                                                                          style: commonTextStyle(
                                                                              size: size,
                                                                              fontSize: size.width * AppDimensions.numD036,
                                                                              color: Colors.black,
                                                                              lineHeight: 1.4,
                                                                              fontWeight: FontWeight.w400),
                                                                        ),
                                                                      ])),
                                                                  SizedBox(
                                                                    height: size
                                                                            .width *
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
                                                      size.width *
                                                          AppDimensions.numD03),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      profilePicWidget(),
                                                      SizedBox(
                                                        width: size.width *
                                                            AppDimensions
                                                                .numD04,
                                                      ),
                                                      Expanded(
                                                          child: Container(
                                                        padding: EdgeInsets.all(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD02),
                                                        width: size.width,
                                                        decoration: BoxDecoration(
                                                            color: AppColorTheme
                                                                .colorLightGrey,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black),
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD04),
                                                                bottomLeft: Radius.circular(
                                                                    size.width *
                                                                        AppDimensions
                                                                            .numD04),
                                                                bottomRight:
                                                                    Radius.circular(
                                                                        size.width * AppDimensions.numD04))),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              height: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD04,
                                                            ),
                                                            Text(
                                                              showRejectBtn
                                                                  ? " The offer is rejected by you."
                                                                  : "Well done, the offer is now accepted",
                                                              style: commonTextStyle(
                                                                  size: size,
                                                                  fontSize: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD035,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                            ),
                                                            SizedBox(
                                                              height: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD04,
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
                                                bottom: size.height *
                                                    AppDimensions.numD01),
                                            child: Text(
                                              "Please refresh to view more offers.",
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width *
                                                      AppDimensions.numD035,
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
                                  visible: widget.type != "content",
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width *
                                                  AppDimensions.numD04,
                                              vertical: size.width *
                                                  AppDimensions.numD02),
                                          height:
                                              size.width * AppDimensions.numD18,
                                          child: commonElevatedButton(
                                              AppStringsNew2.galleryText,
                                              size,
                                              commonButtonTextStyle(size),
                                              commonButtonStyle(
                                                  size, Colors.black), () {
                                            getImage(ImageSource.gallery);
                                          }),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width *
                                                  AppDimensions.numD04,
                                              vertical: size.width *
                                                  AppDimensions.numD02),
                                          margin: EdgeInsets.only(bottom: 8),
                                          height:
                                              size.width * AppDimensions.numD18,
                                          child: commonElevatedButton(
                                              AppStringsNew2.cameraText,
                                              size,
                                              commonButtonTextStyle(size),
                                              commonButtonStyle(size,
                                                  AppColorTheme.colorThemePink),
                                              () {
                                            context.pushNamed(
                                              AppRoutes.cameraName,
                                              extra: {
                                                'picAgain': true,
                                                'previousScreen': ScreenNameEnum
                                                    .manageTaskScreen,
                                              },
                                            ).then((value) {
                                              if (value != null) {
                                                debugPrint("value:::::$value");
                                                List<CameraData> cameraData =
                                                    value as List<CameraData>;

                                                if (cameraData.first.mimeType ==
                                                    "video") {
                                                  generateVideoThumbnail(
                                                      cameraData.first.path);
                                                } else if (cameraData
                                                        .first.mimeType ==
                                                    "audio") {
                                                  Map<String, String> mediaMap =
                                                      {
                                                    "imageAndVideo":
                                                        cameraData.first.path,
                                                  };
                                                  callUploadMediaApi(
                                                      mediaMap, "audio");
                                                } else {
                                                  Map<String, String> mediaMap =
                                                      {
                                                    "imageAndVideo":
                                                        cameraData.first.path,
                                                  };
                                                  callUploadMediaApi(
                                                      mediaMap, "image");
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
                          )));
      },
    );
  }

  Widget contentDetailWidget() {
    return Column(
      children: [
        showMediaWidget(),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD04,
              vertical: widget.myContentData!.exclusive
                  ? size.width * AppDimensions.numD02
                  : 0),
          child: headerWidget(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD04),
          child: const Divider(
            color: AppColorTheme.colorGrey1,
          ),
        ),
        SizedBox(
          height: size.height * AppDimensions.numD015,
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
          height: size.width * AppDimensions.numD03,
        ),
        Row(
          children: [
            Text(
              widget.myContentData!.exclusive
                  ? ""
                  : AppStringsNew2.multipleText.toUpperCase(),
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD033,
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
                  height: size.width * AppDimensions.numD035,
                ),
                SizedBox(
                  width: size.width * AppDimensions.numD02,
                ),
                Text(
                  widget.myContentData!.exclusive
                      ? AppStringsNew2.exclusiveText
                      : AppStringsNew2.sharedText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD04,
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
                    height: size.width * AppDimensions.numD005,
                  ),
                  Text(
                    widget.myContentData!.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD04,
                        color: Colors.black,
                        lineHeight: 1.5,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
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
                              color: widget.myContentData
                                          ?.purchasedMediahouseCount ==
                                      0
                                  ? Colors.grey
                                  : AppColorTheme.colorThemePink,
                              size: size.width * AppDimensions.numD042),
                          SizedBox(width: size.width * AppDimensions.numD018),
                          Text(
                            '${widget.myContentData?.purchasedMediahouseCount} ${AppStringsNew2.sold}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD029,
                                color: widget.myContentData
                                            ?.purchasedMediahouseCount ==
                                        0
                                    ? Colors.grey
                                    : AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: widget.myContentData!.offerCount >= 0
                              ? size.width * AppDimensions.numD04
                              : size.width * AppDimensions.numD02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageIcon(const AssetImage("${iconsPath}dollar1.png"),
                              color: widget.myContentData?.offerCount == 0
                                  ? Colors.grey
                                  : AppColorTheme.colorThemePink,
                              size: size.width * AppDimensions.numD042),
                          SizedBox(width: size.width * AppDimensions.numD018),
                          Text(
                            '${widget.myContentData?.offerCount} ${widget.myContentData!.offerCount > 1 ? '${AppStringsNew2.offerText}s' : AppStringsNew2.offerText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD029,
                                color: widget.myContentData?.offerCount == 0
                                    ? Colors.grey
                                    : AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: widget.myContentData!.offerCount >= 0
                              ? size.width * AppDimensions.numD04
                              : size.width * AppDimensions.numD02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageIcon(const AssetImage("${iconsPath}ic_view.png"),
                              color: widget.myContentData!.contentView == 0
                                  ? Colors.grey
                                  : AppColorTheme.colorThemePink,
                              size: size.width * AppDimensions.numD05),
                          SizedBox(width: size.width * AppDimensions.numD018),
                          Text(
                            '${widget.myContentData!.contentView.toString()} ${widget.myContentData!.contentView > 1 ? '${AppStringsNew2.viewsText}s' : AppStringsNew2.viewsText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD029,
                                color: (widget.myContentData!.paidStatus ==
                                                AppStringsNew2.paidText &&
                                            widget.myContentData!.contentView ==
                                                1) ||
                                        widget.myContentData!.contentView == 0
                                    ? Colors.grey
                                    : AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
                  ),

                  /// Time Date
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_clock.png",
                        height: size.width * AppDimensions.numD04,
                        color: AppColorTheme.colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD018,
                      ),
                      Text(
                        DateFormat('hh:mm a').format(
                            DateTime.parse(widget.myContentData!.dateTime)),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD028,
                            color: AppColorTheme.colorHint,
                            fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD012,
                      ),
                      Image.asset(
                        "${iconsPath}ic_yearly_calendar.png",
                        height: size.width * AppDimensions.numD04,
                        color: AppColorTheme.colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD02,
                      ),
                      Text(
                        DateFormat("dd MMM yyyy").format(
                            DateTime.parse(widget.myContentData!.dateTime)),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD028,
                            color: AppColorTheme.colorHint,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
                  ),

                  /// Location
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_location.png",
                        height: size.width * AppDimensions.numD045,
                        color: AppColorTheme.colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD01,
                      ),
                      Expanded(
                        child: Text(
                          widget.myContentData!.location,
                          overflow: TextOverflow.ellipsis,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD028,
                              color: AppColorTheme.colorHint,
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD07,
            ),

            /// price
            Column(
              children: [
                Container(
                  width: size.width * AppDimensions.numD30,
                  padding: EdgeInsets.symmetric(
                      vertical: size.width * AppDimensions.numD012),
                  /*    padding: EdgeInsets.symmetric(
                      horizontal: myContentData!.paidStatus == AppStringsNew2.unPaidText
                          ? size.width * AppDimensions.numD06
                          : myContentData!.paidStatus == AppStringsNew2.paidText &&
                                  !myContentData!.isPaidStatusToHopper
                              ? size.width * AppDimensions.numD04
                              : size.width * AppDimensions.numD06,
                      vertical: size.width * AppDimensions.numD01),*/
                  decoration: BoxDecoration(
                      color: widget.myContentData!.paidStatus ==
                              AppStringsNew2.unPaidText
                          ? AppColorTheme.colorThemePink
                          : /*myContentData!.paidStatus == AppStringsNew2.paidText &&
                                  !myContentData!.isPaidStatusToHopper
                              ? AppColorTheme.colorThemePink
                              :*/
                          AppColorTheme.colorLightGrey,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD03)),
                  child: Column(
                    children: [
                      Text(
                        widget.myContentData!.paidStatus ==
                                AppStringsNew2.unPaidText
                            ? 'Published Price'
                            : widget.myContentData!.paidStatus ==
                                        AppStringsNew2.paidText &&
                                    widget.myContentData!.isPaidStatusToHopper
                                ? AppStringsNew2.receivedText
                                : AppStringsNew2.soldText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: widget.myContentData!.paidStatus ==
                                    AppStringsNew2.unPaidText
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      FittedBox(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: size.width * AppDimensions.numD02,
                            right: size.width * AppDimensions.numD02,
                          ),
                          child: Text(
                            "$currencySymbol${formatDouble(double.parse(widget.myContentData!.amount))}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD05,
                                color: widget.myContentData!.paidStatus ==
                                        AppStringsNew2.unPaidText
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold),
                            /*myContentData!.paidStatus == AppStringsNew2.paidText &&
                                            myContentData!.isPaidStatusToHopper
                                        ?
                            : Colors.white*/
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * AppDimensions.numD015,
                ),
                Container(
                  width: size.width * AppDimensions.numD30,
                  padding: EdgeInsets.symmetric(
                      vertical: size.width * AppDimensions.numD012),
                  decoration: BoxDecoration(
                      color: AppColorTheme.colorGreyChat,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD03)),
                  child: Column(
                    children: [
                      Text(
                        'Total Earnings',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      FittedBox(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: size.width * AppDimensions.numD02,
                            right: size.width * AppDimensions.numD02,
                          ),
                          child: Text(
                            "$currencySymbol${formatDouble(double.parse(widget.myContentData!.totalEarning))}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD05,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            /*myContentData!.paidStatus == AppStringsNew2.paidText &&
                                            myContentData!.isPaidStatusToHopper
                                        ?
                            : Colors.white*/
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget showMediaWidget() {
    return SizedBox(
      height: size.width * AppDimensions.numD50,
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
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(size.width * AppDimensions.numD04),
                child: InkWell(
                  onTap: () {
                    if (item.mediaType == "pdf" || item.mediaType == "doc") {
                      openUrl(widget.myContentData!.paidStatus ==
                              AppStringsNew2.paidText
                          ? getMediaImageUrl(item.media)
                          : item.waterMark);
                    }
                  },
                  child: Stack(
                    children: [
                      item.mediaType == "audio"
                          ? playAudioWidget()
                          : item.mediaType == "video"
                              ? videoWidget()
                              // ? Container()
                              : item.mediaType == "pdf"
                                  ? Padding(
                                      padding: EdgeInsets.all(
                                          size.width * AppDimensions.numD04),
                                      child: Image.asset(
                                        "${dummyImagePath}pngImage.png",
                                        fit: BoxFit.contain,
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
                                            width: size.width,
                                          ),
                                        )
                                      : Image.network(
                                          widget
                                                      .myContentData!
                                                      .contentMediaList[index]
                                                      .mediaType ==
                                                  "video"
                                              ? getMediaImageUrl(
                                                  widget
                                                      .myContentData!
                                                      .contentMediaList[index]
                                                      .thumbNail,
                                                  isVideo: true)
                                              : getMediaImageUrl(widget
                                                  .myContentData!
                                                  .contentMediaList[index]
                                                  .media),
                                          width: double.infinity,
                                          height:
                                              size.width * AppDimensions.numD50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              "${commonImagePath}rabbitLogo.png",
                                              width: double.infinity,
                                              height: size.width *
                                                  AppDimensions.numD50,
                                              fit: BoxFit.contain,
                                            );
                                          },
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
                          right: size.width * AppDimensions.numD02,
                          top: size.width * AppDimensions.numD02,
                          child: Column(
                              children: getMediaCount(
                                  widget.myContentData!.contentMediaList,
                                  size))),
                      // Positioned(
                      //   right: size.width * AppDimensions.numD02,
                      //   bottom: size.width * AppDimensions.numD02,
                      //   child: Visibility(
                      //     visible: myContentData!.contentMediaList.length > 1,
                      //     child: Text(
                      //       "+${myContentData!.contentMediaList.length - 1}",
                      //       style: commonTextStyle(
                      //           size: size,
                      //           fontSize: size.width * AppDimensions.numD04,
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
      padding: EdgeInsets.all(size.width * AppDimensions.numD04),
      decoration: BoxDecoration(
        color: AppColorTheme.colorThemePink,
        border: Border.all(color: AppColorTheme.colorGreyNew),
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD06),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /*AudioFileWaveforms(
            size: Size(size.width, size.width * AppDimensions.numD20),
            playerController: controller,
            enableSeekGesture: true,
            waveformType: WaveformType.long,
            continuousWaveform: true,
            playerWaveStyle: PlayerWaveStyle(
              fixedWaveColor: Colors.black,
              liveWaveColor: AppColorTheme.colorThemePink,
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
              seekLineColor: AppColorTheme.colorThemePink,
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
              size: size.width * AppDimensions.numD15,
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
                    color: AppColorTheme.colorThemePink,
                  ),
                ),
                closedCaptionTextStyle: TextStyle(fontSize: 8),
                controls: FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                playerLoadingFallback: Center(
                  child: CircularProgressIndicator(
                    color: AppColorTheme.colorThemePink,
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
                padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                child: Image.asset(
                  "${commonImagePath}ic_black_rabbit.png",
                  color: Colors.white,
                  width: size.width * AppDimensions.numD07,
                  height: size.width * AppDimensions.numD07,
                ),
              ),
            )),
        SizedBox(
          width: size.width * AppDimensions.numD02,
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD05,
              vertical: size.width * AppDimensions.numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColorTheme.colorGoogleButtonBorder),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(size.width * AppDimensions.numD04),
                bottomLeft: Radius.circular(size.width * AppDimensions.numD04),
                bottomRight: Radius.circular(size.width * AppDimensions.numD04),
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * AppDimensions.numD002,
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
                                fontSize: size.width * AppDimensions.numD036,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: " ${item.mediaHouseName}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD036,
                                color: AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),

                          // TextSpan(
                          //   text: item.hopperPrice.isEmpty
                          //       ? ""
                          //       : "$currencySymbol${amountFormat(item.hopperPrice)} ",
                          //   style: commonTextStyle(
                          //       size: size,
                          //       fontSize: size.width * AppDimensions.numD036,
                          //       color: AppColorTheme.colorThemePink,
                          //       fontWeight: FontWeight.w600),
                          // ),
                        ])),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD03),
                    child: CachedNetworkImage(
                      imageUrl: item.mediaHouseImage,
                      height: size.width * AppDimensions.numD11,
                      width: size.width * AppDimensions.numD12,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        "assets/dummyImages/placeholderImage.png",
                        fit: BoxFit.cover,
                        height: size.width * AppDimensions.numD11,
                        width: size.width * AppDimensions.numD12,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        fit: BoxFit.cover,
                        height: size.width * AppDimensions.numD11,
                        width: size.width * AppDimensions.numD12,
                      ),
                    ),
                  ),
                  // Container(
                  //     margin: EdgeInsets.only(left: size.width * AppDimensions.numD01),
                  //     width: size.width * AppDimensions.numD13,
                  //     height: size.width * AppDimensions.numD13,
                  //     decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius:
                  //             BorderRadius.circular(size.width * AppDimensions.numD03),
                  //         boxShadow: [
                  //           BoxShadow(
                  //               color: Colors.grey.shade200, spreadRadius: 1)
                  //         ]),
                  //     child: ClipOval(
                  //       clipBehavior: Clip.hardEdge,
                  //       child: Image.network(
                  //         item.mediaHouseImage,
                  //         fit: BoxFit.contain,
                  //         height: size.width * AppDimensions.numD20,
                  //         width: size.width * AppDimensions.numD20,
                  //         errorBuilder: (BuildContext context, Object exception,
                  //             StackTrace? stackTrace) {
                  //           return Image.asset(
                  //             "${dummyImagePath}news.png",
                  //             fit: BoxFit.contain,
                  //             width: size.width * AppDimensions.numD20,
                  //             height: size.width * AppDimensions.numD20,
                  //           );
                  //         },
                  //       ),
                  //     )),
                ],
              ),
              SizedBox(
                height: size.width * AppDimensions.numD01,
              ),
              /*Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                            height: size.width * AppDimensions.numD13,
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
                                      BorderRadius.circular(size.width * AppDimensions.numD04),
                                      side: (item.requestStatus == "false" ||
                                          item.requestStatus.isEmpty) &&
                                          !item.isMakeCounterOffer
                                          ? BorderSide.none
                                          : const BorderSide(
                                          color: Colors.black, width: 1))),
                              child: Text(
                                AppStringsNew2.rejectText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD037,
                                    color: (item.requestStatus == "false" ||
                                        item.requestStatus.isEmpty) &&
                                        !item.isMakeCounterOffer
                                        ? Colors.white
                                        : AppColorTheme.colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),
                      SizedBox(
                        width: size.width * AppDimensions.numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                            height: size.width * AppDimensions.numD13,
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
                                      ? AppColorTheme.colorThemePink
                                      : item.requestStatus == "true"
                                      ? Colors.grey
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(size.width * AppDimensions.numD04),
                                      side: (item.requestStatus == "true" ||
                                          item.requestStatus.isEmpty) &&
                                          !item.isMakeCounterOffer
                                          ? BorderSide.none
                                          : const BorderSide(
                                          color: Colors.black, width: 1))),
                              child: Text(
                                AppStringsNew2.acceptText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD037,
                                    color: (item.requestStatus == "true" ||
                                        item.requestStatus.isEmpty) &&
                                        !item.isMakeCounterOffer
                                        ? Colors.white
                                        : AppColorTheme.colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),

                      */
              /*
                       Expanded(
                          child: SizedBox(
                            height: size.width * AppDimensions.numD13,
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
                                      ? AppColorTheme.colorThemePink
                                      :item.requestStatus == "true"
                                      ?  Colors.grey
                                      :  Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                      side: item.requestStatus == "true" || item.requestStatus.isEmpty ? BorderSide.none : const BorderSide(
                                          color: AppColorTheme.colorGrey1, width: 2)
                                  )),
                              child: Text(
                                AppStringsNew2.yesText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD04,
                                    color: item.requestStatus == "true" || item.requestStatus.isEmpty ? Colors.white : AppColorTheme.colorLightGreen,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )),*/ /*
                    ],
                  ),*/
              SizedBox(
                height: size.width * AppDimensions.numD03,
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: EdgeInsets.all(size.width * AppDimensions.numD012),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD03),
                    border: Border.all(color: Colors.black, width: 2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Offered Price",
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.white,
                          fontFamily: 'AirbnbCereal_W_Lt Light'),
                    ),
                    Text(
                      item.amount.isEmpty
                          ? ""
                          : "$currencySymbol${formatDouble(double.parse(item.amount))}",
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD045,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'AirbnbCereal_W_Bd'),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD03,
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
          width: size.width * AppDimensions.numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD05,
              vertical: size.width * AppDimensions.numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * AppDimensions.numD04),
                  bottomLeft:
                      Radius.circular(size.width * AppDimensions.numD04),
                  bottomRight:
                      Radius.circular(size.width * AppDimensions.numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              Text(
                "Make a counter offer to ${item.mediaHouseName} Media",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD036,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              TextFormField(
                controller: item.priceController,
                readOnly: item.finalCounterAmount.isNotEmpty,
                cursorColor: AppColorTheme.colorTextFieldIcon,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    counterText: "",
                    filled: false,
                    hintText: "Enter price here...",
                    hintStyle: TextStyle(
                      color: AppColorTheme.colorHint,
                      fontSize: size.width * AppDimensions.numD035,
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
                    contentPadding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD02)),
                textAlignVertical: TextAlignVertical.center,
                validator: null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              SizedBox(
                height: size.width * AppDimensions.numD13,
                width: size.width,
                child: commonElevatedButton(
                    AppStringsNew2.submitText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                        size,
                        item.finalCounterAmount.isEmpty
                            ? AppColorTheme.colorThemePink
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
                    height: size.width * AppDimensions.numD06,
                  ),
                  SizedBox(
                    width: size.width * AppDimensions.numD02,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        context.pushNamed(
                          AppRoutes.faqName,
                          extra: {
                            'priceTipsSelected': true,
                            'type': 'price_tips',
                            'index': 0,
                          },
                        );
                      },
                      child: Text(
                        "Check price tips, and learnings",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: AppColorTheme.colorThemePink,
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
                    fontSize: size.width * AppDimensions.numD034,
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
      padding:
          EdgeInsets.symmetric(horizontal: size.width * AppDimensions.numD04),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: size.width * AppDimensions.numD055),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                ]),
            child: ClipOval(
              child: Padding(
                padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                child: Image.asset(
                  "${commonImagePath}ic_black_rabbit.png",
                  width: size.width * AppDimensions.numD075,
                  height: size.width * AppDimensions.numD075,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * AppDimensions.numD04,
          ),
          Expanded(
              child: Stack(
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: size.width * AppDimensions.numD055),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD03,
                    vertical: size.width * AppDimensions.numD02),
                width: size.width,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.only(
                        topRight:
                            Radius.circular(size.width * AppDimensions.numD04),
                        bottomLeft:
                            Radius.circular(size.width * AppDimensions.numD04),
                        bottomRight: Radius.circular(
                            size.width * AppDimensions.numD04))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.width * AppDimensions.numD025,
                    ),
                    Row(
                      children: [
                        Text(
                          // "${AppStringsNew2.taskText} ${widget.taskDetail?.status}",
                          "TASK ACCEPTED",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Container(
                          height: size.width * AppDimensions.numD12,
                          width: size.width * AppDimensions.numD12,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    spreadRadius: 2)
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD02),
                            child: Padding(
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD013),
                              child: Image.network(
                                widget.taskDetail!.mediaHouseImage.toString(),
                                width: size.width * AppDimensions.numD09,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD03,
                    ),
                    Text(
                      "${widget.taskDetail?.title}",
                      style: TextStyle(
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontFamily: "AirbnbCereal",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD04,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                widget.taskDetail!.isNeedPhoto
                                    ? "${widget.taskDetail!.currencySymbol.isNotEmpty ? widget.taskDetail!.currencySymbol : currencySymbol}${formatDouble(double.parse(widget.taskDetail!.photoPrice))}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD055,
                                    color: AppColorTheme.colorThemePink,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                AppStringsNew2.offeredText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD03,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        size.width * AppDimensions.numD04,
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02)),
                                child: Text(
                                  AppStringsNew2.photoText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD033,
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
                                    ? "${widget.taskDetail!.currencySymbol.isNotEmpty ? widget.taskDetail!.currencySymbol : currencySymbol}${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD055,
                                    color: AppColorTheme.colorThemePink,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                AppStringsNew2.offeredText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD03,
                              ),
                              Container(
                                // alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        size.width * AppDimensions.numD018,
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02)),
                                child: Text(
                                  AppStringsNew2.interviewText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD033,
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
                                    ? "${widget.taskDetail!.currencySymbol.isNotEmpty ? widget.taskDetail!.currencySymbol : currencySymbol}${formatDouble(double.parse(widget.taskDetail!.videoPrice))}"
                                    : "-",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD055,
                                    color: AppColorTheme.colorThemePink,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text(
                                AppStringsNew2.offeredText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD03,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        size.width * AppDimensions.numD04,
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02)),
                                child: Text(
                                  AppStringsNew2.videoText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD033,
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
                      height: size.width * AppDimensions.numD03,
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(size.width * AppDimensions.numD025),
                  decoration: const BoxDecoration(
                      color: Colors.black, shape: BoxShape.circle),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: size.width * AppDimensions.numD07,
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
                  ? size.width * AppDimensions.numD04
                  : 0),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
              ]),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(size.width * AppDimensions.numD01),
              child: Image.asset(
                "${commonImagePath}ic_black_rabbit.png",
                width: size.width * AppDimensions.numD075,
                height: size.width * AppDimensions.numD075,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * AppDimensions.numD04,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
                top: uploadTextType == "request_more_content"
                    ? size.width * AppDimensions.numD05
                    : 0),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD03,
                vertical: size.width * AppDimensions.numD02),
            width: size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.only(
                    topRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                    text: TextSpan(
                        style: TextStyle(
                            fontSize: size.width * AppDimensions.numD035,
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
                          fontSize: size.width * AppDimensions.numD035,
                          color: AppColorTheme.colorThemePink,
                          fontFamily: "AirbnbCereal",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: " buttons below",
                      ),
                    ])),
                SizedBox(
                  height: size.width * AppDimensions.numD008,
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
          margin: EdgeInsets.only(top: size.width * AppDimensions.numD03),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
              ]),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(size.width * AppDimensions.numD01),
              child: Image.asset(
                "${commonImagePath}ic_black_rabbit.png",
                width: size.width * AppDimensions.numD075,
                height: size.width * AppDimensions.numD075,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * AppDimensions.numD04,
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: size.width * AppDimensions.numD03),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD03,
                vertical: size.width * AppDimensions.numD03),
            width: size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.only(
                    topRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04))),
            child: Text(
              "Thank you ever so much for a splendid job well done!",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD035,
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
              padding: EdgeInsets.all(size.width * AppDimensions.numD01),
              child: Image.asset(
                "${commonImagePath}ic_black_rabbit.png",
                width: size.width * AppDimensions.numD075,
                height: size.width * AppDimensions.numD075,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * AppDimensions.numD04,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD03,
                vertical: size.width * AppDimensions.numD03),
            width: size.width,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.only(
                    topRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.width * AppDimensions.numD008,
                ),
                Row(
                  children: [
                    Text("Thanks. you've uploaded",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.normal)),
                    Text(" 1 $type",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD008,
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
      margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
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
                    context.pushNamed(
                      AppRoutes.fullVideoViewName,
                      extra: {
                        'mediaFile': videoUrl,
                        'type': MediaTypeEnum.video,
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD04),
                    child: Image.network(
                      thumbnail,
                      height: size.height / 3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    top: size.width * AppDimensions.numD02,
                    left: size.width * AppDimensions.numD02,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD006,
                          vertical: size.width * AppDimensions.numD002),
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGreen.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD01)),
                      child: const Icon(
                        Icons.videocam_outlined,
                        color: Colors.white,
                      ),
                    )),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.fullVideoViewName,
                      extra: {
                        'mediaFile': videoUrl,
                        'type': MediaTypeEnum.video,
                      },
                    );
                  },
                  child: Icon(
                    Icons.play_circle,
                    color: Colors.white,
                    size: size.width * AppDimensions.numD09,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: size.width * AppDimensions.numD02,
          ),
          (sharedPreferences!.getString(SharedPreferencesKeys.avatarKey) ?? "")
                  .isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * AppDimensions.numD01,
                  ),
                  decoration: const BoxDecoration(
                      color: AppColorTheme.colorLightGrey,
                      shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        sharedPreferences!
                                .getString(SharedPreferencesKeys.avatarKey) ??
                            "",
                        fit: BoxFit.cover,
                        height: size.width * AppDimensions.numD09,
                        width: size.width * AppDimensions.numD09,
                      )))
              : Container(
                  padding: EdgeInsets.all(
                    size.width * AppDimensions.numD01,
                  ),
                  height: size.width * AppDimensions.numD09,
                  width: size.width * AppDimensions.numD09,
                  decoration: const BoxDecoration(
                      color: AppColorTheme.colorSwitchBack,
                      shape: BoxShape.circle),
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
        context.pushNamed(
          AppRoutes.fullVideoViewName,
          extra: {
            'mediaFile': audioUrl,
            'type': MediaTypeEnum.audio,
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD04),
                  child: Container(
                    color: AppColorTheme.colorGrey2.withOpacity(.9),
                    height: size.width * AppDimensions.numD80,
                    width: double.infinity,
                    child: Icon(
                      Icons.play_circle,
                      color: AppColorTheme.colorThemePink,
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
                          vertical: size.width * AppDimensions.numD005),
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGreen.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD01)),
                      child: Image.asset(
                        "${iconsPath}ic_mic1.png",
                        fit: BoxFit.cover,
                        height: size.width * AppDimensions.numD05,
                        width: size.width * AppDimensions.numD05,
                      ),
                    )),
                ClipRRect(
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD04),
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
            width: size.width * AppDimensions.numD02,
          ),
          (sharedPreferences!.getString(SharedPreferencesKeys.avatarKey) ?? "")
                  .isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(
                    size.width * AppDimensions.numD01,
                  ),
                  decoration: const BoxDecoration(
                      color: AppColorTheme.colorLightGrey,
                      shape: BoxShape.circle),
                  child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        sharedPreferences!
                                .getString(SharedPreferencesKeys.avatarKey) ??
                            "",
                        fit: BoxFit.cover,
                        height: size.width * AppDimensions.numD09,
                        width: size.width * AppDimensions.numD09,
                      )))
              : Container(
                  padding: EdgeInsets.all(
                    size.width * AppDimensions.numD01,
                  ),
                  height: size.width * AppDimensions.numD09,
                  width: size.width * AppDimensions.numD09,
                  decoration: const BoxDecoration(
                      color: AppColorTheme.colorSwitchBack,
                      shape: BoxShape.circle),
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
        debugPrint(
            "imageTap:::::::${sharedPreferences!.getString(SharedPreferencesKeys.avatarKey)}");
        context.pushNamed(
          AppRoutes.fullVideoViewName,
          extra: {
            'mediaFile': imageUrl,
            'type': MediaTypeEnum.image,
          },
        );
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
                          color: AppColorTheme.colorGreyChat,
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD04),
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD04),
                          child: Image.network(
                            imageUrl,
                            height: size.height / 3,
                            fit: BoxFit.cover,
                            errorBuilder: (context, exception, stackTrace) {
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
                        top: size.width * AppDimensions.numD02,
                        left: size.width * AppDimensions.numD02,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD006,
                              vertical: size.width * AppDimensions.numD002),
                          decoration: BoxDecoration(
                              color: AppColorTheme.colorLightGreen
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD01)),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                        )),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD04),
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
                width: size.width * AppDimensions.numD02,
              ),
              sharedPreferences!
                      .getString(SharedPreferencesKeys.avatarKey)
                      .toString()
                      .isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(
                        size.width * AppDimensions.numD01,
                      ),
                      decoration: const BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          shape: BoxShape.circle),
                      child: ClipOval(
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                              sharedPreferences!
                                  .getString(SharedPreferencesKeys.avatarKey)
                                  .toString(),
                              height: size.width * AppDimensions.numD09,
                              width: size.width * AppDimensions.numD09,
                              fit: BoxFit.cover,
                              errorBuilder: (context, exception, stackTrace) {
                            return Center(
                              child: Image.asset(
                                "${commonImagePath}rabbitLogo.png",
                                height: size.width * AppDimensions.numD09,
                                width: size.width * AppDimensions.numD09,
                                fit: BoxFit.contain,
                              ),
                            );
                          })))
                  : Container(
                      padding: EdgeInsets.all(
                        size.width * AppDimensions.numD01,
                      ),
                      height: size.width * AppDimensions.numD09,
                      width: size.width * AppDimensions.numD09,
                      decoration: const BoxDecoration(
                          color: AppColorTheme.colorSwitchBack,
                          shape: BoxShape.circle),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          height: size.width * AppDimensions.numD09,
                          width: size.width * AppDimensions.numD09,
                        ),
                      ),
                    ),
            ],
          ),
          SizedBox(
            height: size.width * AppDimensions.numD018,
          ),
          Row(
            children: [
              Image.asset(
                "${iconsPath}ic_clock.png",
                height: size.width * AppDimensions.numD038,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * AppDimensions.numD012,
              ),
              Text(
                dateTimeFormatter(dateTime: time, format: 'hh:mm a'),
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD028,
                    color: AppColorTheme.colorHint,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                width: size.width * AppDimensions.numD018,
              ),
              Image.asset(
                "${iconsPath}ic_yearly_calendar.png",
                height: size.width * AppDimensions.numD035,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * AppDimensions.numD01,
              ),
              Text(
                dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy'),
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD028,
                    color: AppColorTheme.colorHint,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
          SizedBox(
            height: size.width * AppDimensions.numD018,
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
                    padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                    child: Image.asset(
                      "${commonImagePath}ic_black_rabbit.png",
                      color: Colors.white,
                      width: size.width * AppDimensions.numD07,
                      height: size.width * AppDimensions.numD07,
                    ),
                  ),
                )),
            SizedBox(
              width: size.width * AppDimensions.numD025,
            ),
            Expanded(
                child: Container(
              // margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(color: AppColorTheme.colorGoogleButtonBorder),
                  borderRadius: BorderRadius.only(
                    topRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
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
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: " ${model.mediaHouseName}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " have purchased your content for",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: " $currencySymbol${model.amount}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        // TextSpan(
                        //   text: item.hopperPrice.isEmpty
                        //       ? ""
                        //       : "$currencySymbol${amountFormat(item.hopperPrice)} ",
                        //   style: commonTextStyle(
                        //       size: size,
                        //       fontSize: size.width * AppDimensions.numD036,
                        //       color: AppColorTheme.colorThemePink,
                        //       fontWeight: FontWeight.w600),
                        // ),
                      ])),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "View Transaction Details",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, AppColorTheme.colorThemePink),
                        () {
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
                    padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                    child: Image.asset(
                      "${commonImagePath}ic_black_rabbit.png",
                      color: Colors.white,
                      width: size.width * AppDimensions.numD07,
                      height: size.width * AppDimensions.numD07,
                    ),
                  ),
                )),
            SizedBox(
              width: size.width * AppDimensions.numD025,
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(color: AppColorTheme.colorGoogleButtonBorder),
                  borderRadius: BorderRadius.only(
                    topRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD01,
                  ),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * AppDimensions.numD037,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                        TextSpan(
                          text: "Woohoo! We have paid ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: model.payableHopperPrice.isEmpty
                              ? ""
                              : "$currencySymbol${formatDouble(double.parse(model.payableHopperPrice))}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " into your bank account. Please visit ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: "My Earnings",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " to view your transaction ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        )
                      ])),
                  SizedBox(
                    height: size.width * AppDimensions.numD025,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width,
                        child: commonElevatedButton(
                            "View My Earnings",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink), () {
                          context.pushNamed(
                            AppRoutes.myEarningName,
                            extra: {
                              'openDashboard': false,
                              'initialTapPosition': 2,
                            },
                          );
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
                    padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                    child: Image.asset(
                      "${commonImagePath}ic_black_rabbit.png",
                      color: Colors.white,
                      width: size.width * AppDimensions.numD07,
                      height: size.width * AppDimensions.numD07,
                    ),
                  ),
                )),
            SizedBox(
              width: size.width * AppDimensions.numD025,
            ),
            Expanded(
                child: Container(
              // margin: EdgeInsets.only(top: 0, right: size.width * AppDimensions.numD04),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border:
                      Border.all(color: AppColorTheme.colorGoogleButtonBorder),
                  borderRadius: BorderRadius.only(
                    topRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomLeft:
                        Radius.circular(size.width * AppDimensions.numD04),
                    bottomRight:
                        Radius.circular(size.width * AppDimensions.numD04),
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD01,
                  ),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * AppDimensions.numD037,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                        TextSpan(
                          text:
                              "To maximise your chances of a sale, we’ve automatically adjusted the price from ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: "$currencySymbol$hopperAmount ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " to ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: '$currencySymbol$amount',
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text:
                              ". Stay tuned—we’ll update you as soon as your content is AppStringsNew2.sold",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ])),
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
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
        //margin: EdgeInsets.only(top: size.width * AppDimensions.numD03),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400)),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            widget.taskDetail?.mediaHouseImage ?? "",
            width: size.width * AppDimensions.numD09,
            height: size.width * AppDimensions.numD09,
            fit: BoxFit.contain,
            errorBuilder: (ctx, obj, stace) {
              return Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * AppDimensions.numD09,
                height: size.width * AppDimensions.numD09,
              );
            },
          ),
        ));
  }

  /// PressHope Profile
  Widget presshopPicWidget() {
    return Container(
        margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
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
            width: size.width * AppDimensions.numD09,
            height: size.width * AppDimensions.numD09,
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
          width: size.width * AppDimensions.numD04,
        ),
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD05,
              vertical: size.width * AppDimensions.numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * AppDimensions.numD04),
                  bottomLeft:
                      Radius.circular(size.width * AppDimensions.numD04),
                  bottomRight:
                      Radius.circular(size.width * AppDimensions.numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * AppDimensions.numD023,
              ),
              Text(
                "Do you have additional pictures related to the task?",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              Row(
                children: [
                  Expanded(
                      child: SizedBox(
                    height: size.width * AppDimensions.numD13,
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
                              ? AppColorTheme.colorThemePink
                              : item.requestStatus == "true"
                                  ? Colors.grey
                                  : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD04),
                              side: item.requestStatus == "true" ||
                                      item.requestStatus.isEmpty
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        AppStringsNew2.yesText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD04,
                            color: item.requestStatus == "true" ||
                                    item.requestStatus.isEmpty
                                ? Colors.white
                                : AppColorTheme.colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: size.width * AppDimensions.numD04,
                  ),
                  Expanded(
                      child: SizedBox(
                    height: size.width * AppDimensions.numD13,
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
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD04),
                              side: item.requestStatus == "false" ||
                                      item.requestStatus.isEmpty
                                  ? BorderSide.none
                                  : const BorderSide(
                                      color: Colors.black, width: 1))),
                      child: Text(
                        AppStringsNew2.noText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD04,
                            color: item.requestStatus == "false" ||
                                    item.requestStatus.isEmpty
                                ? Colors.white
                                : AppColorTheme.colorLightGreen,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
                ],
              ),
              SizedBox(
                height: size.width * AppDimensions.numD023,
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
          width: size.width * AppDimensions.numD04,
        ),
        Expanded(
            child: Container(
          margin: EdgeInsets.only(
              top: size.width * AppDimensions.numD06,
              bottom: size.width * AppDimensions.numD04),
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD05,
              vertical: size.width * AppDimensions.numD02),
          width: size.width,
          decoration: BoxDecoration(
              color: AppColorTheme.colorLightGrey,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(size.width * AppDimensions.numD04),
                  bottomLeft:
                      Radius.circular(size.width * AppDimensions.numD04),
                  bottomRight:
                      Radius.circular(size.width * AppDimensions.numD04))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              Text(
                "Send the content for approval",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              SizedBox(
                height: size.width * AppDimensions.numD13,
                width: size.width,
                child: commonElevatedButton(
                    AppStringsNew2.uploadText,
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(
                        size,
                        item.requestStatus == "true"
                            ? Colors.grey
                            : AppColorTheme.colorThemePink), () {
                  if (item.requestStatus.isEmpty) {
                    // _againUpload = true;

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
          height: size.width * AppDimensions.numD08,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicWidget(),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Stack(
              children: [
                Container(
                  margin:
                      EdgeInsets.only(top: size.width * AppDimensions.numD06),
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD03,
                      vertical: size.width * AppDimensions.numD02),
                  width: size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(
                              size.width * AppDimensions.numD04),
                          bottomLeft: Radius.circular(
                              size.width * AppDimensions.numD04),
                          bottomRight: Radius.circular(
                              size.width * AppDimensions.numD04))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                      Text(
                        "${AppStringsNew2.taskText} ${widget.taskDetail?.status}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                      Text(
                          "Cate Blanchett and Rihanna while filming Oceans Eight",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w600)),
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "${currencySymbol}150",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD055,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  AppStringsNew2.offeredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: AppColorTheme.colorHint,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: size.width * AppDimensions.numD04,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          size.width * AppDimensions.numD02,
                                      vertical:
                                          size.width * AppDimensions.numD02),
                                  decoration: BoxDecoration(
                                      color: AppColorTheme.colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD02)),
                                  child: Text(
                                    AppStringsNew2.photoText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
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
                                  "${currencySymbol}350",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD055,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  AppStringsNew2.offeredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: AppColorTheme.colorHint,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: size.width * AppDimensions.numD04,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          size.width * AppDimensions.numD02,
                                      vertical:
                                          size.width * AppDimensions.numD02),
                                  decoration: BoxDecoration(
                                      color: AppColorTheme.colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD02)),
                                  child: Text(
                                    AppStringsNew2.interviewText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
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
                                  "${currencySymbol}500",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD055,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  AppStringsNew2.offeredText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: AppColorTheme.colorHint,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: size.width * AppDimensions.numD04,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          size.width * AppDimensions.numD02,
                                      vertical:
                                          size.width * AppDimensions.numD02),
                                  decoration: BoxDecoration(
                                      color: AppColorTheme.colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD02)),
                                  child: Text(
                                    AppStringsNew2.videoText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
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
                    padding: EdgeInsets.all(size.width * AppDimensions.numD03),
                    decoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: size.width * AppDimensions.numD07,
                    ),
                  ),
                ),
              ],
            ))
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD07,
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
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD04),
                      child: Image.asset(
                        "${dummyImagePath}walk5.png",
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD04),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD04),
                          child: Image.asset(
                            "${commonImagePath}watermark.png",
                            height: size.height / 3,
                            width: size.width / 1.7,
                            fit: BoxFit.cover,
                          )))
                ],
              ),
              SizedBox(
                width: size.width * AppDimensions.numD02,
              ),
              ClipRRect(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD08),
                  child: Image.asset(
                    "${dummyImagePath}avatar.png",
                    height: size.width * AppDimensions.numD08,
                    width: size.width * AppDimensions.numD08,
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
              color: AppColorTheme.colorGrey1,
              thickness: 1,
            )),
            Text(
              "Pending reviews from Reuters",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD035,
                  color: AppColorTheme.colorGrey2,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(
                child: Divider(
              color: AppColorTheme.colorGrey1,
              thickness: 1,
            )),
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD07,
        ),

        /// payment recicved
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
              padding: EdgeInsets.all(size.width * AppDimensions.numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * AppDimensions.numD07,
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "Congrats, you’ve received £200 from Reuters Media ",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "View Transaction Details",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, AppColorTheme.colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD07,
        ),

        /// More Content
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profilePicWidget(),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: AppColorTheme.colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "Do you have additional pictures related to the task?",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  side: const BorderSide(
                                      color: AppColorTheme.colorGrey1,
                                      width: 2))),
                          child: Text(
                            AppStringsNew2.noText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: AppColorTheme.colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * AppDimensions.numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorTheme.colorThemePink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                              )),
                          child: Text(
                            "View Transaction Details",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
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
          height: size.width * AppDimensions.numD07,
        ),

        /// send Approval
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
              padding: EdgeInsets.all(size.width * AppDimensions.numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * AppDimensions.numD07,
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: AppColorTheme.colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "Send the content for approval",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        AppStringsNew2.uploadText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, AppColorTheme.colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD07,
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
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD04),
                      child: Image.asset(
                        "${dummyImagePath}walk6.png",
                        height: size.height / 3,
                        width: size.width / 1.7,
                        fit: BoxFit.cover,
                      )),
                  Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD04),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD04),
                          child: Image.asset(
                            "${commonImagePath}watermark.png",
                            height: size.height / 3,
                            width: size.width / 1.7,
                            fit: BoxFit.cover,
                          )))
                ],
              ),
              SizedBox(
                width: size.width * AppDimensions.numD02,
              ),
              ClipRRect(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD08),
                  child: Image.asset(
                    "${dummyImagePath}avatar.png",
                    height: size.width * AppDimensions.numD08,
                    width: size.width * AppDimensions.numD08,
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
              color: AppColorTheme.colorGrey1,
              thickness: 1,
            )),
            Text(
              "Pending reviews from Reuters",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD035,
                  color: AppColorTheme.colorGrey2,
                  fontWeight: FontWeight.w600),
            ),
            const Expanded(
                child: Divider(
              color: AppColorTheme.colorGrey1,
              thickness: 1,
            )),
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD07,
        ),

        /// Offers From Media House
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*   Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
              padding: EdgeInsets.all(size.width * AppDimensions.numD01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * AppDimensions.numD04),
                child: Image.asset(
                  "${dummyImagePath}news.png",
                  height: size.width * AppDimensions.numD09,
                ),
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: AppColorTheme.colorLightGrey,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Reuters Media has offered ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "${currencySymbol}150 ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: AppColorTheme.colorThemePink,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "to buy your content",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            AppStringsNew2.rejectText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: AppColorTheme.colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * AppDimensions.numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorTheme.colorThemePink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                              )),
                          child: Text(
                            AppStringsNew2.acceptText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
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
                        color: AppColorTheme.colorTextFieldIcon,
                        thickness: 1,
                      )),
                      Text(
                        "or",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      const Expanded(
                          child: Divider(
                        color: AppColorTheme.colorTextFieldIcon,
                        thickness: 1,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "Make a Counter Offer",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, AppColorTheme.colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "You can make a counter offer only once",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD07,
        ),

        /// Counter Field
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
              padding: EdgeInsets.all(size.width * AppDimensions.numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * AppDimensions.numD07,
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "Make a counter offer to Reuters Media",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: TextFormField(
                      cursorColor: AppColorTheme.colorTextFieldIcon,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: false,
                        hintText: "Enter price here...",
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * AppDimensions.numD04),
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
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        AppStringsNew2.submitText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, AppColorTheme.colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "${iconsPath}ic_tag.png",
                        height: size.width * AppDimensions.numD06,
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD02,
                      ),
                      Expanded(
                        child: Text(
                          "Check price tips, and learnings",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "You can make a counter offer only once",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD031,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ))
          ],
        ),

        SizedBox(
          height: size.width * AppDimensions.numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*  Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
              padding: EdgeInsets.all(size.width * AppDimensions.numD01),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * AppDimensions.numD04),
                child: Image.asset(
                  "${dummyImagePath}news.png",
                  height: size.width * AppDimensions.numD09,
                ),
              ),
            ),*/
            profilePicWidget(),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: AppColorTheme.colorLightGrey,
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Reuters Media have increased their offered to ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "${currencySymbol}200 ",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: AppColorTheme.colorThemePink,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "to buy your content",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            AppStringsNew2.rejectText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: AppColorTheme.colorLightGreen,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: size.width * AppDimensions.numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorTheme.colorThemePink,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  side: const BorderSide(
                                      color: Colors.black, width: 1))),
                          child: Text(
                            AppStringsNew2.acceptText,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
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
          height: size.width * AppDimensions.numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD04),
              padding: EdgeInsets.all(size.width * AppDimensions.numD03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                  ]),
              child: Image.asset(
                "${commonImagePath}rabbitLogo.png",
                width: size.width * AppDimensions.numD07,
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "Congrats, you’ve received £200 from Reuters Media ",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        "View Transaction Details",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, AppColorTheme.colorThemePink),
                        () {}),
                  )
                ],
              ),
            ))
          ],
        ),

        SizedBox(
          height: size.width * AppDimensions.numD07,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(
                size.width * AppDimensions.numD01,
              ),
              height: size.width * AppDimensions.numD09,
              width: size.width * AppDimensions.numD09,
              decoration: const BoxDecoration(
                  color: AppColorTheme.colorSwitchBack, shape: BoxShape.circle),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.width * AppDimensions.numD09,
                  width: size.width * AppDimensions.numD09,
                ),
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD02),
              width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.only(
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomRight:
                          Radius.circular(size.width * AppDimensions.numD04))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Text(
                    "Rate your experience with Reuters Media",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  RatingBar(
                    ratingWidget: RatingWidget(
                      empty: Image.asset("${iconsPath}ic_empty_star.png"),
                      full: Image.asset("${iconsPath}ic_full_star.png"),
                      half: Image.asset("${iconsPath}ic_half_star.png"),
                    ),
                    onRatingUpdate: (value) {},
                    itemSize: size.width * AppDimensions.numD09,
                    itemCount: 5,
                    initialRating: 0,
                    allowHalfRating: true,
                    itemPadding: EdgeInsets.only(
                        left: size.width * AppDimensions.numD03),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Write your review here",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Stack(
                    children: [
                      SizedBox(
                        height: size.width * AppDimensions.numD35,
                        child: TextFormField(
                          cursorColor: AppColorTheme.colorTextFieldIcon,
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                "Please share your feedback on your experience with the publication. Your feedback is very important for improving your experience, and our service. Thank you",
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: size.width * AppDimensions.numD035),
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
                                left: size.width * AppDimensions.numD08,
                                right: size.width * AppDimensions.numD03,
                                top: size.width * AppDimensions.numD04,
                                bottom: size.width * AppDimensions.numD04),
                            alignLabelWithHint: true,
                          ),
                          validator: checkRequiredValidator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * AppDimensions.numD04,
                            left: size.width * AppDimensions.numD01),
                        child: Icon(
                          Icons.sticky_note_2_outlined,
                          size: size.width * AppDimensions.numD06,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        AppStringsNew2.submitText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, AppColorTheme.colorThemePink),
                        () {}),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
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
    if (widget.myContentData == null ||
        widget.myContentData!.contentMediaList.isEmpty) {
      debugPrint("🚀 initialController: myContentData is null or empty");
      return;
    }

    if (widget.myContentData!.contentMediaList[_currentMediaIndex].mediaType ==
        "audio") {
      var url = getMediaImageUrl(
          widget.myContentData!.contentMediaList[_currentMediaIndex].media);
      /*  initWaveData(getMediaImageUrl(
          myContentData!.contentMediaList[_currentMediaIndex].media));*/
      initWaveData(url);
    } else if (widget
            .myContentData!.contentMediaList[_currentMediaIndex].mediaType ==
        "video") {
      var url = getMediaImageUrl(
          widget.myContentData!.contentMediaList[_currentMediaIndex].media,
          isVideo: true);
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(url),
        ),
        autoPlay: false,
      );
    }
  }

  Future<void> openUrl(String url) async {
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
              debugPrint(
                  "imagePath======$currencySymbol> ${result.files[i].path!}");
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
      context.pushNamed(
        AppRoutes.permissionErrorName,
        extra: {
          'permissionsStatus': {
            Permission.camera: false,
            Permission.microphone: false,
          },
        },
      );
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
    debugPrint(":::: Inside Manage Content Socket Func :::::");
    debugPrint(":::: Inside Manage Content Socket Func :::::");
    debugPrint(":::: Inside Manage Content Socket Func :::::");
    debugPrint(":::: Inside Manage Content Socket Func :::::");
    debugPrint(":::: Inside Manage Content Socket Func :::::");
    debugPrint(":::: Inside Manage Content Socket Func :::::");

    debugPrint("socketUrl:::::${ApiConstantsNew.config.socketUrl2}");
    socket = IO.io(ApiConstantsNew.config.socketUrl2,
        OptionBuilder().setTransports(['websocket']).build());

    socket.connect();

    socket.onConnect((_) {
      debugPrint("✅ SOCKET CONNECTED: ${socket.id}");
      debugPrint("🔌 Joining Room: ${widget.roomId}");
      socket.emit('room join', {"room_id": widget.roomId});
    });

    socket.onDisconnect((_) {
      debugPrint("❌ SOCKET DISCONNECTED");
    });

    socket.onConnectError((data) {
      debugPrint("⚠️ SOCKET CONNECT ERROR: $data");
    });

    socket.onReconnect((_) {
      debugPrint("🔄 SOCKET RECONNECTED");
    });

    void refreshChat(data) {
      debugPrint("📥 SOCKET EVENT RECEIVED: $data");
      if (mounted) {
        callGetManageTaskListingApi();
      }
    }

    socket.on("chat message", refreshChat);
    socket.on("getallchat", refreshChat);
    socket.on("updatehide", refreshChat);
    socket.on("media message", refreshChat);
    socket.on("offer message", refreshChat);
    socket.on("rating", refreshChat);
    socket.on("room join", (data) {
      debugPrint("🤝 ROOM JOIN SUCCESSFUL: $data");
      refreshChat(data);
    });
    socket.on("initialoffer", refreshChat);
    socket.on("updateOffer", refreshChat);
    socket.on("leave room", refreshChat);

    socket.onError((data) => debugPrint("⚠️ SOCKET ERROR ::: $data"));
  }

  void callDetailApi(String id) {
    if (widget.type == 'content') {
      context.read<TaskBloc>().add(GetContentTransactionDetailsEvent(
          roomId: widget.roomId,
          mediaHouseId: widget.mediaHouseDetail?.id ?? ""));
    } else {
      context.read<TaskBloc>().add(GetTaskTransactionDetailsEvent(id));
    }
  }

  /// Upload media
  void callUploadMediaApi(Map<String, String> mediaMap, String type) async {
    Map<String, String> map = {
      "type": type,
      'task_id': widget.taskDetail?.id ?? widget.contentId ?? ""
    };

    var formData = FormData.fromMap(map);
    for (var entry in mediaMap.entries) {
      formData.files
          .add(MapEntry(entry.key, await MultipartFile.fromFile(entry.value)));
    }
    if (context.mounted) {
      context.read<TaskBloc>().add(UploadTaskMediaEvent(formData));
    }
  }

  /// Get Listing
  void callGetManageTaskListingApi() {
    if (!mounted) return;
    final contentId = (widget.contentId == null || widget.contentId!.isEmpty)
        ? (widget.taskDetail?.id ?? "")
        : widget.contentId!;

    debugPrint(
        "🚀 callGetManageTaskListingApi: effective contentId='$contentId'");

    context.read<TaskBloc>().add(GetTaskChatEvent(
        roomId: widget.roomId,
        type: widget.type,
        contentId: contentId,
        showLoader: false));
  }
}
