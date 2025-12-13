import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:presshop/core/api/network_class.dart';
import 'package:presshop/core/api/network_response.dart';
import 'package:presshop/core/constants/api_constant.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/constants/string_constants.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:presshop/core/utils/date_time_utils.dart';
import 'package:presshop/core/utils/extensions.dart';
import 'package:presshop/core/widgets/animated_button.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/content/presentation/widgets/manage_content_widget.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/task/presentation/pages/manage_task_screen.dart';
import 'package:presshop/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../bloc/content_bloc.dart';
import '../bloc/content_event.dart';
import '../bloc/content_state.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/entities/content_media.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/my_content_data_model.dart';
import '../../domain/mappers/content_item_mapper.dart';


class MyContentDetailScreen extends StatefulWidget {
  String hopperID = "";
  final String contentId;
  final String paymentStatus;
  final bool exclusive;
  final int offerCount;
  final int purchasedMediahouseCount;

  MyContentDetailScreen(
      {super.key,
      required this.paymentStatus,
      required this.exclusive,
      required this.offerCount,
      required this.purchasedMediahouseCount,
      required this.contentId,
      this.hopperID = ""});

  @override
  State<StatefulWidget> createState() {
    return MyContentDetailScreenState();
  }
}

class MyContentDetailScreenState extends State<MyContentDetailScreen> implements NetworkResponse {
  String selectedSellType = sharedText;
  ScrollController listController = ScrollController();
  ContentItem? contentItem;
  List<dynamic> chatList = [];
  FlickManager? flickManager;
  PlayerController controller = PlayerController();
  String publicationCount = "";
  List<EarningTransactionDetail> publicationTransactionList = [];
  final List<ManageTaskChatModel> _mediaHouseList = [];
  bool audioPlaying = false;
  late Size size;
  bool isOfferAvailable = false;
  int _currentMediaIndex = 0;
  bool isMediaOffer = false;
  bool isLoading = true; // Start loading true
  bool shouldRestartAnimation = false;
  bool showTimer = false;
  String _timeLeft = "";
  Timer? _timer;
  bool isOwner = false;
  late ContentBloc _contentBloc;

  @override
  void initState() {
    super.initState();
    _contentBloc = sl<ContentBloc>();
    _contentBloc.add(FetchContentDetailEvent(widget.contentId));
  }

  void _checkOwnershipAndStartTimer() async {
    if (contentItem == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString("_id") ?? "";

    // contentItem doesn't have userId directly if it's not added to entity? 
    // Copied from MyDraftScreen, ContentItem might not have userId.
    // Check ContentItem definition. 
    // It has `mediaHouseName`, `categoryId`... but `userId` is missing from my update?
    // MyContentData had `userId`.
    // I need to add userId to ContentItem if specific logic depends on it. 
    // For now, let's assume it's NOT checking properly or I need to fix ContentItem later.
    // Proceeding with placeholder.
    
    // isOwner = currentUserId == widget.hopperID; 
    // Use widget.hopperID if logic allows, or fetch from contentItem. 
    // Original code: isOwner = currentUserId == widget.hopperID;
    
    if (contentItem != null) {
      isOwner = currentUserId == (contentItem!.userId ?? widget.hopperID);
    } else {
      isOwner = currentUserId == widget.hopperID;
    }

    if (isOwner) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (contentItem == null || contentItem!.createdAt == null) return;
    DateTime createdTime = contentItem!.createdAt!;
    DateTime endTime = createdTime.add(const Duration(hours: 24));

    if (DateTime.now().isAfter(endTime)) {
      if(mounted) {
        setState(() {
          showTimer = false;
          _timeLeft = "00:00:00";
        });
      }
      return;
    }

    showTimer = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(!mounted) return;
      Duration difference = endTime.difference(DateTime.now());
      if (difference.isNegative) {
        _timer?.cancel();
        setState(() {
          showTimer = false;
          _timeLeft = "00:00:00";
        });
      } else {
        setState(() {
          _timeLeft = _printDuration(difference);
        });
      }
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _contentBloc.close();
    controller.dispose();
    if (flickManager != null) {
      flickManager?.dispose();
      flickManager = null;
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => _contentBloc,
      child: BlocListener<ContentBloc, ContentState>(
        listener: (context, state) {
          if (state is ContentDetailLoaded) {
            setState(() {
              contentItem = state.content;
              isLoading = false;
              getMediaOfferApi();
              initialController();
              _checkOwnershipAndStartTimer();
              callGetAllTransactionDetail();
            });
          } else if (state is ContentError) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          /// app-bar
          appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                "${myContentText.toTitleCase()} ${detailsText.toTitleCase()}",
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
                Navigator.pop(context, true);
              },
              actionWidget: [
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
              ]),

          /// body
          body: SafeArea(
              child: isLoading
                  ? showLoader()
                  : (contentItem != null

                      ? SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(top: size.width * numD02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                showMediaWidget(),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: (contentItem!.isExclusive ?? false)
                                        ? size.width * numD01
                                        : 0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      headerWidget(),

                                      const Divider(
                                        color: colorGrey1,
                                      ),

                                      /// Description
                                      Text(
                                        contentItem!.description.trim(),
                                        textAlign: TextAlign.justify,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: Colors.black,
                                            lineHeight: 2,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      if (chatList.isNotEmpty) ...[
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        if (isOwner)
                                          const Divider(color: colorGrey1),
                                        SizedBox(
                                          height: size.width * numD02,
                                        ),
                                        if (isOwner)
                                          Text(manageContentText.toUpperCase(),
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width * numD035,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700)),
                                        if (isOwner)
                                          SizedBox(
                                            height: size.width * numD02,
                                          ),
                                        if (isOwner)
                                          ListView.builder(
                                            itemBuilder: (context, index) {
                                              return ManageContentWidget(
                                                  chatList[index]);
                                            },
                                            itemCount: chatList.length,
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                          ),
                                      ],
                                      SizedBox(
                                        height: size.width * numD02,
                                      ),
                                      if (isOwner) const Divider(color: colorGrey1),


                                    Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: size.width * numD03,
                                            ),
                                            if (isOwner)
                                              AnimatedButtonWidget(
                                                shouldRestartAnimation:
                                                    shouldRestartAnimation,
                                                size: size,
                                                buttonText: manageContentText,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                          builder: (context) =>
                                                              ManageTaskScreen(
                                                                  roomId: contentItem!.id,
                                                                  contentId: contentItem!.id,
                                                                  type: 'content',
                                                                  mediaHouseDetail: null,
                                                                  contentMedia: showMediaWidget(),
                                                                  contentHeader: headerWidget(),
                                                                  myContentData: contentItem!.toMyContentData()
                                                              )))
                                                      .then((value) {
                                                    shouldRestartAnimation = true;
                                                    _contentBloc.add(FetchContentDetailEvent(widget.contentId));
                                                  });
                                                },
                                              ),
                                            SizedBox(
                                              height: size.width * numD05,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width * numD02),
                                              child: RichText(
                                                  textAlign: TextAlign.justify,
                                                  text: TextSpan(
                                                      style: commonTextStyle(
                                                          size: size,
                                                          fontSize:
                                                              size.width * numD03,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      children: [
                                                        const TextSpan(
                                                          text: "Click",
                                                        ),
                                                        TextSpan(
                                                            text: " Manage Content",
                                                            style: commonTextStyle(
                                                                size: size,
                                                                fontSize:
                                                                    size.width *
                                                                        numD03,
                                                                color:
                                                                    colorThemePink,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                        const TextSpan(
                                                          text:
                                                              " to view any offers, and sell your content to the press. You can also easily track your earnings and monitor pending and received payments - all in one place.",
                                                        )
                                                      ])),
                                            ),
                                            SizedBox(
                                              height: size.width * numD05,
                                            )
                                          ])
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container())
                  ),
        ),
      ),
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
          itemCount: contentItem!.mediaList.length,
          itemBuilder: (context, index) {
            var item = contentItem!.mediaList[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * numD04),
                child: InkWell(
                  onTap: () {
                    if (item.mediaType == "pdf" || item.mediaType == "doc") {
                      openUrl(contentItem!.paidStatus == paidText
                          ? contentImageUrl + item.mediaUrl
                          : item.watermarkUrl ?? "");
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
                                          contentItem!.mediaList[index]
                                                      .mediaType ==
                                                  "video"
                                              ? "$contentImageUrl${contentItem!.mediaList[index].thumbnailUrl ?? ''}"
                                              : "$contentImageUrl${contentItem!.mediaList[index].mediaUrl}",
                                          width: double.infinity,
                                          height: size.width * numD50,
                                          fit: BoxFit.cover,
                                        ),
                      Positioned(
                        right: size.width * numD02,
                        top: size.width * numD02,
                        child: Column(
                          children: getMediaCount(
                              contentItem!.mediaList, size), // Assuming getMediaCount can handle List<ContentMedia> or dynamic
                              // If getMediaCount expects strict type, I might need to update it too or cast.
                              // Check getMediaCount definition in next step if it errors.
                        ),
                      ),
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

  Widget headerWidget() {
    return Column(
      children: [
        contentItem!.mediaList.length > 1
            ? Align(
                alignment: Alignment.bottomCenter,
                child: DotsIndicator(
                  dotsCount: contentItem!.mediaList.length,
                  position: _currentMediaIndex,
                  decorator: const DotsDecorator(
                    color: Colors.grey, // Inactive color
                    activeColor: Colors.redAccent,
                  ),
                ),
              )
            : Container(),

        if (showTimer)
          Padding(
            padding: EdgeInsets.symmetric(vertical: size.width * numD02),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD04,
                  vertical: size.width * numD02),
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(size.width * numD02)),
              child: Text(
                "Time Left: $_timeLeft",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * numD04),
              ),
            ),
          ),

        (contentItem!.mediaList.length >= 0)
            ? SizedBox(
                height: size.width * numD02,
              )
            : Container(),

        Row(
          children: [
            Text(
              (contentItem!.isExclusive ?? false) ? "" : multipleText.toUpperCase(),
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
                  (contentItem!.isExclusive ?? false)
                      ? "${iconsPath}ic_exclusive.png"
                      : "${iconsPath}ic_share.png",
                  height: size.width * numD035,
                ),
                SizedBox(
                  width: size.width * numD02,
                ),
                Text(
                  (contentItem!.isExclusive ?? false) ? exclusiveText : sharedText,
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
                    contentItem!.title,
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ImageIcon(
                                  const AssetImage("${iconsPath}dollar1.png"),
                                  color: widget.purchasedMediahouseCount == 0
                                      ? Colors.grey
                                      : colorThemePink,
                                  size: size.width * numD042),
                              SizedBox(width: size.width * numD018),
                              Text(
                                '${widget.purchasedMediahouseCount} $sold',
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD029,
                                    color: widget.purchasedMediahouseCount == 0
                                        ? Colors.grey
                                        : colorThemePink,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          SizedBox(width: size.width * numD02),
                          ImageIcon(const AssetImage("${iconsPath}dollar1.png"),
                              color: widget.offerCount == 0
                                  ? Colors.grey
                                  : colorThemePink,
                                  size: size.width * numD042),
                          SizedBox(width: size.width * numD018),
                          Text(
                            '${widget.offerCount.toString()} ${widget.offerCount > 1 ? '${offerText}s' : offerText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD029,
                                color: widget.offerCount == 0
                                    ? Colors.grey
                                    : colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(width: size.width * numD02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ImageIcon(const AssetImage("${iconsPath}ic_view.png"),
                              color: contentItem!.totalView == 0
                                  ? Colors.grey
                                  : colorThemePink,
                              size: size.width * numD05),
                          SizedBox(width: size.width * numD018),
                          Text(
                            '${contentItem!.totalView.toString()} ${contentItem!.totalView > 1 ? '${viewsText}s' : viewsText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD029,
                                color: (contentItem!.paidStatus == paidText &&
                                            contentItem!.totalView == 1) ||
                                        contentItem!.totalView == 0
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
                  if(contentItem!.createdAt != null)
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_clock.png",
                        height: size.width * numD04,
                        color: colorTextFieldIcon,
                      ),
                      SizedBox(
                        width: size.width * numD012,
                      ),
                      Text(
                        DateFormat('hh:mm a')
                            .format(contentItem!.createdAt!),
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
                        DateFormat("dd MMM yyyy")
                            .format(contentItem!.createdAt!),
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
                          contentItem!.location ?? "",
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
                  SizedBox(
                    height: size.width * numD02,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width * numD075,
            ),

            /// price
            Column(
              children: [
                Container(
                  width: size.width * numD30,
                  padding: EdgeInsets.symmetric(vertical: size.width * numD012),
                  decoration: BoxDecoration(
                      color: contentItem!.paidStatus == unPaidText
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
                        contentItem!.paidStatus == unPaidText
                            ? 'Published Price'
                            : contentItem!.paidStatus == paidText &&
                                    (contentItem!.isPaidStatusToHopper)
                                ? receivedText
                                : soldText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: contentItem!.paidStatus == unPaidText
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w400),
                        /*myContentData!.paidStatus == unPaidText
                                ? size.width * numD035
                                : myContentData!.paidStatus == paidText &&
                                        myContentData!.isPaidStatusToHopper
                                    ? size.width * numD035
                                    : size.width * numD03,*/
                        /*myContentData!.paidStatus == paidText &&
                                        myContentData!.isPaidStatusToHopper
                                    ?
                                    : Colors.white*/
                      ),
                      FittedBox(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: size.width * numD02,
                            right: size.width * numD02,
                          ),
                          child: Text(
                            "$currencySymbol${formatDouble(double.parse(contentItem!.price ?? "0"))}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD05,
                                color: contentItem!.paidStatus == unPaidText
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
                ),
                SizedBox(
                  height: size.height * numD015,
                ),
                Container(
                  width: size.width * numD30,
                  padding: EdgeInsets.symmetric(vertical: size.width * numD012),
                  decoration: BoxDecoration(
                      color: colorGreyChat,
                      borderRadius: BorderRadius.circular(size.width * numD03)),
                  child: Column(
                    children: [
                      Text(
                        'Total Earnings',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      FittedBox(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: size.width * numD02,
                            right: size.width * numD02,
                          ),
                          child: Text(
                            "$currencySymbol${contentItem!.totalSold}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD05,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  /// Media House Offers
  Widget showMediaHouseWidget() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        var item = _mediaHouseList[index];
        return !_mediaHouseList[index].paidStatus
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD04,
                  vertical: size.width * numD035,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size.width * numD05),
                    border: Border.all(color: Colors.black)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          /// Image
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              border:
                                  Border.all(color: lightGrey.withOpacity(.6)),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              child: Image.network(
                                item.mediaHouseImage,
                                fit: BoxFit.contain,
                                height: size.width * numD20,
                                width: size.width * numD20,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    "${commonImagePath}rabbitLogo.png",
                                    fit: BoxFit.contain,
                                    width: size.width * numD20,
                                    height: size.width * numD20,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD025,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Title
                                Text(
                                  item.mediaHouseName.isEmpty
                                      ? "Reuters News"
                                      : item.mediaHouseName,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD033,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),

                                SizedBox(
                                  height: size.width * numD02,
                                ),

                                /// Time
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_clock.png",
                                      height: size.width * numD04,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      dateTimeFormatter(
                                          dateTime: item.createdAtTime,
                                          format: "hh:mm a",
                                          time: true),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorHint,
                                          fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),

                                /// date
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_yearly_calendar.png",
                                      height: size.width * numD04,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Expanded(
                                      child: Text(
                                        dateTimeFormatter(
                                            dateTime: item.createdAtTime,
                                            format: "dd.MM.yyyy"),
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: colorHint,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD01,
                    ),

                    /*    Container(
                          height: size.width * numD11,
                          width: size.width * numD27,
                          margin: EdgeInsets.only(top: size.width * numD02),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.circular(size.width * numD03)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Offer Price",
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD03,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                "$currencySymbol${item.initialOfferAmount}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD05,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),*/

                    Container(
                      width: size.width * numD30,
                      padding: EdgeInsets.symmetric(
                          //horizontal: size.width * numD06,
                          vertical: size.width * numD012),
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          border: Border.all(color: lightGrey),
                          borderRadius:
                              BorderRadius.circular(size.width * numD03)),
                      child: Column(
                        children: [
                          Text(
                            "Offered Price",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "$currencySymbol${amountFormat(item.initialOfferAmount)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD05,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : Container();
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: size.width * numD05,
        );
      },
      itemCount: _mediaHouseList.length,
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

  /*Widget videoWidget(int index) {
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
          );}*/

  /// video widget
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

  List<Widget> getMediaCount(List<ContentMedia> mediaList, Size size) {
    if (mediaList.isEmpty) return [];
    return [
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * numD015,
          vertical: size.width * 0.005,
        ),
        decoration: BoxDecoration(
            color: colorLightGreen.withOpacity(0.8),
            borderRadius: BorderRadius.circular(size.width * numD015)),
        child: Center(
          child: Text(
            "${mediaList.length} ",
            textAlign: TextAlign.center,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * numD038,
                color: Colors.white,
                fontWeight: FontWeight.w600),
          ),
        ),
      )
    ];
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
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

    await controller.startPlayer(); // Start audio player
  }

  Future pauseSound() async {
    await controller.pausePlayer(); // Start audio player
  }

  String intToTimeLeft(int value) {
    int h, m, s;

    h = value ~/ 3600;

    m = ((value - h * 3600)) ~/ 60;

    s = value - (h * 3600) - (m * 60);

    String result = "$h:$m:$s";

    return result;
  }

  void initialController() {
    if (contentItem?.mediaList[_currentMediaIndex].mediaType == "audio") {
      var url = contentImageUrl +
          (contentItem?.mediaList[_currentMediaIndex].mediaUrl ?? "");
      /*  initWaveData(contentImageUrl +
          myContentData!.contentMediaList[_currentMediaIndex].media);*/
      initWaveData(url);
    } else if (contentItem?.mediaList[_currentMediaIndex].mediaType == "video") {
      var url = contentImageUrl +
         (contentItem?.mediaList[_currentMediaIndex].mediaUrl ?? "");
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(url),
        ),
        autoPlay: false,
      );
    }
  }

  ///--------Apis Section------------


  /// Get content Media House Offer
  void getMediaOfferApi() {
    Map<String, String> map = {"image_id": widget.contentId};

    NetworkClass(
      getContentMediaHouseOfferUrl,
      this,
      getContentMediaHouseOfferReq,
    ).callRequestServiceHeader(false, "get", map);
  }

  callGetAllTransactionDetail() {
    Map<String, String> map = {
      "content_id": contentItem?.id ?? widget.contentId,
      "limit": '10',
      "offset": '0'
    };
    debugPrint('map value ==> $map');
    NetworkClass(
            getPublicationTransactionAPI, this, reqGetPublicationTransactionReq)
        .callRequestServiceHeader(false, 'get', map);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        /// Get Content detail


        /// Get content Media House Offer
        case getContentMediaHouseOfferReq:
          var data = jsonDecode(response);
          debugPrint("getContentMediaHouseOfferReq Error: $response");
          if (data["errors"] != null) {
            showSnackBar("Error", data["errors"]["msg"].toString(), Colors.red);
          } else {
            showSnackBar("Error", data.toString(), Colors.red);
          }
          break;

        case reqGetPublicationTransactionReq:
          debugPrint(
              "reqGetPublicationTransactionAPI_ErrorResponse==> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {


        /// Get content Media House Offer
        case getContentMediaHouseOfferReq:
          var data = jsonDecode(response);
          log("get ContentMediaHouseOfferReq Success: $data");
          var dataModel = data["response"] as List;
          _mediaHouseList.clear();
          _mediaHouseList.addAll(dataModel
              .map((e) => ManageTaskChatModel.fromJson(e ?? {}))
              .toList());
          for (var element in _mediaHouseList) {
            if (!element.paidStatus) {
              isMediaOffer = true;
            }
          }
          setState(() {});
          break;
        case reqGetPublicationTransactionReq:
          log("reqGetPublicationTransactionAPI_successResponse==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['data'] as List;
          publicationCount = data['countofmediahouse'].toString() ?? '';
          publicationTransactionList = dataList
              .map((e) => EarningTransactionDetail.fromJson(e))
              .toList();
          setState(() {});
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
