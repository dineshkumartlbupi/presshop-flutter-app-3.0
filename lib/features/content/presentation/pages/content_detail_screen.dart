import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/constants/string_constants_new2.dart';
import 'package:presshop/core/core_export.dart';
import 'package:video_player/video_player.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/animated_button.dart';
import 'package:presshop/core/widgets/video_thumbnail_widget.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../bloc/content_bloc.dart';
import '../bloc/content_event.dart';
import '../bloc/content_state.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/entities/content_metadata.dart';
import '../../../../core/di/injection_container.dart';

import '../../domain/mappers/content_item_mapper.dart';

// ignore: must_be_immutable
class MyContentDetailScreen extends StatefulWidget {
  MyContentDetailScreen(
      {super.key,
      required this.paymentStatus,
      required this.exclusive,
      required this.offerCount,
      required this.purchasedMediahouseCount,
      required this.contentId,
      this.hopperID = ""});
  String hopperID = "";
  final String contentId;
  final String paymentStatus;
  final bool exclusive;
  final int offerCount;
  final int purchasedMediahouseCount;

  @override
  State<StatefulWidget> createState() {
    return MyContentDetailScreenState();
  }
}

class MyContentDetailScreenState extends State<MyContentDetailScreen> {
  String selectedSellType = AppStringsNew2.sharedText;
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

    debugPrint(
        '🔍 ContentDetailScreen initState - contentId: ${widget.contentId}');
    debugPrint('🔍 Bloc isClosed: ${_contentBloc.isClosed}');
    debugPrint('🔍 Bloc current state: ${_contentBloc.state}');

    // Add events with safety checks
    try {
      if (!_contentBloc.isClosed) {
        debugPrint('✅ Adding FetchContentDetailEvent for ${widget.contentId}');
        _contentBloc.add(FetchContentDetailEvent(widget.contentId));
        _contentBloc.add(FetchMediaHouseOffersEvent(widget.contentId));
        _contentBloc.add(FetchContentTransactionsEvent(
            contentId: widget.contentId, limit: 10, offset: 0));
      } else {
        debugPrint('❌ Bloc is closed, cannot add events');
      }
    } catch (e) {
      debugPrint('❌ Error adding events to ContentBloc in initState: $e');
    }
  }

  void _checkOwnershipAndStartTimer() async {
    if (contentItem == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString("_id") ?? "";

    if (contentItem != null) {
      isOwner = currentUserId == (contentItem!.id);
    } else {
      isOwner = currentUserId == widget.hopperID;
    }

    if (isOwner) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (contentItem == null) return;
    DateTime createdTime = DateTime.parse(contentItem!.createdAt);
    DateTime endTime = createdTime.add(const Duration(hours: 24));

    if (DateTime.now().isAfter(endTime)) {
      if (mounted) {
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
      if (!mounted) return;
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
    // Don't close _contentBloc here since it's a singleton from the service locator
    // Closing it would affect all other screens using the same instance
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
    return BlocProvider.value(
      value: _contentBloc,
      child: BlocListener<ContentBloc, ContentState>(
        listener: (context, state) {
          debugPrint('📡 BlocListener received state: ${state.runtimeType}');

          if (state is ContentDetailLoaded) {
            debugPrint('✅ ContentDetailLoaded - Setting isLoading = false');
            debugPrint('💰 DEBUG: price: ${state.content.price}');
            debugPrint('💰 DEBUG: askPrice: ${state.content.askPrice}');
            debugPrint(
                '💰 DEBUG: priceOriginal: ${state.content.priceOriginal}');
            debugPrint(
                '💰 DEBUG: convertedAskPrice: ${state.content.convertedAskPrice}');
            debugPrint('💰 DEBUG: priceBase: ${state.content.priceBase}');
            debugPrint('💰 DEBUG: currency: ${state.content.currency}');
            debugPrint(
                '💰 DEBUG: currencySymbol: ${state.content.currencySymbol}');
            debugPrint(
                '💰 DEBUG: currencyOriginal: ${state.content.currencyOriginal}');

            setState(() {
              contentItem = state.content;
              isLoading = false;
              initialController();
              _checkOwnershipAndStartTimer();
            });
          } else if (state is MediaHouseOffersLoaded) {
            debugPrint('✅ MediaHouseOffersLoaded');
            setState(() {
              _mediaHouseList.clear();
              _mediaHouseList.addAll(state.offers);
              isMediaOffer = state.offers.any((element) => !element.paidStatus);
            });
          } else if (state is ContentTransactionsLoaded) {
            debugPrint('✅ ContentTransactionsLoaded');
            setState(() {
              publicationTransactionList = state.transactions;
            });
          } else if (state is ContentError) {
            debugPrint('❌ ContentError: ${state.message}');
            setState(() {
              isLoading = false;
            });
          }
        },
        child: Scaffold(
          /// app-bar
          appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                "${AppStrings.myContentText.toTitleCase()} ${AppStrings.detailsText.toTitleCase()}",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * AppDimensions.appBarHeadingFontSize),
              ),
              centerTitle: false,
              titleSpacing: 0,
              size: size,
              showActions: true,
              leadingFxn: () {
                context.pop(true);
              },
              actionWidget: [
                InkWell(
                  onTap: () {
                    context.goNamed(AppRoutes.dashboardName,
                        extra: {'initialPosition': 2});
                  },
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * AppDimensions.numD07,
                    width: size.width * AppDimensions.numD07,
                  ),
                ),
                SizedBox(
                  width: size.width * AppDimensions.numD04,
                )
              ]),

          /// body
          body: SafeArea(
              child: isLoading
                  ? showLoader()
                  : (contentItem != null
                      ? SingleChildScrollView(
                          child: Container(
                            margin: EdgeInsets.only(
                                top: size.width * AppDimensions.numD02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                showMediaWidget(),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        size.width * AppDimensions.numD04,
                                    vertical:
                                        (contentItem!.isExclusive ?? false)
                                            ? size.width * AppDimensions.numD01
                                            : 0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      headerWidget(),

                                      const Divider(
                                        color: AppColorTheme.colorGrey1,
                                      ),

                                      /// Description
                                      Text(
                                        contentItem!.description.trim(),
                                        textAlign: TextAlign.justify,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD03,
                                            color: Colors.black,
                                            lineHeight: 2,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      if (chatList.isNotEmpty) ...[
                                        SizedBox(
                                          height:
                                              size.width * AppDimensions.numD02,
                                        ),
                                        if (isOwner)
                                          const Divider(
                                              color: AppColorTheme.colorGrey1),
                                        SizedBox(
                                          height:
                                              size.width * AppDimensions.numD02,
                                        ),
                                        if (isOwner)
                                          Text(
                                              AppStrings.manageContentText
                                                  .toUpperCase(),
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width *
                                                      AppDimensions.numD035,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700)),
                                        if (isOwner)
                                          SizedBox(
                                            height: size.width *
                                                AppDimensions.numD02,
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
                                        height:
                                            size.width * AppDimensions.numD02,
                                      ),
                                      if (isOwner)
                                        const Divider(
                                            color: AppColorTheme.colorGrey1),

                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: size.width *
                                                  AppDimensions.numD03,
                                            ),
                                            // if (isOwner)
                                            AnimatedButtonWidget(
                                              shouldRestartAnimation:
                                                  shouldRestartAnimation,
                                              size: size,
                                              buttonText:
                                                  AppStrings.manageContentText,
                                              onPressed: () {
                                                context.pushNamed(
                                                    AppRoutes.manageTaskName,
                                                    extra: {
                                                      'roomId': contentItem!.id,
                                                      'contentId':
                                                          contentItem!.id,
                                                      'type': 'content',
                                                      'mediaHouseDetail': null,
                                                      'contentMedia':
                                                          showMediaWidget(),
                                                      'contentHeader':
                                                          headerWidget(),
                                                      'myContentData':
                                                          contentItem!
                                                              .toMyContentData(),
                                                    }).then((value) {
                                                  shouldRestartAnimation = true;

                                                  // Add events with safety checks
                                                  try {
                                                    if (!_contentBloc
                                                        .isClosed) {
                                                      _contentBloc.add(
                                                          FetchContentDetailEvent(
                                                              widget
                                                                  .contentId));
                                                      _contentBloc.add(
                                                          FetchMediaHouseOffersEvent(
                                                              widget
                                                                  .contentId));
                                                      _contentBloc.add(
                                                          FetchContentTransactionsEvent(
                                                              contentId: widget
                                                                  .contentId,
                                                              limit: 10,
                                                              offset: 0));
                                                    }
                                                  } catch (e) {
                                                    debugPrint(
                                                        'Error adding events to ContentBloc after navigation: \$e');
                                                  }
                                                });
                                              },
                                            ),
                                            SizedBox(
                                              height: size.width *
                                                  AppDimensions.numD05,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width *
                                                      AppDimensions.numD02),
                                              child: RichText(
                                                  textAlign: TextAlign.justify,
                                                  text: TextSpan(
                                                      style: commonTextStyle(
                                                          size: size,
                                                          fontSize: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      children: [
                                                        const TextSpan(
                                                          text: "Click",
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                " Manage Content",
                                                            style: commonTextStyle(
                                                                size: size,
                                                                fontSize: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD03,
                                                                color: AppColorTheme
                                                                    .colorThemePink,
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
                                              height: size.width *
                                                  AppDimensions.numD05,
                                            )
                                          ])
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container())),
        ),
      ),
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
          itemCount: contentItem!.mediaList.length,
          itemBuilder: (context, index) {
            var item = contentItem!.mediaList[index];
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(size.width * AppDimensions.numD04),
                child: InkWell(
                  onTap: () {
                    if (item.mediaType == "pdf" || item.mediaType == "doc") {
                      openUrl(getMediaImageUrl(item.mediaUrl));
                    }
                  },
                  child: Stack(
                    children: [
                      item.mediaType == "audio"
                          ? playAudioWidget()
                          : item.mediaType == "video"
                              ? videoWidget(index)
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
                                          contentItem!.mediaList[index]
                                                      .mediaType ==
                                                  "video"
                                              ? getMediaImageUrl(
                                                  contentItem!.mediaList[index]
                                                      .thumbnailUrl,
                                                  isVideo: true)
                                              : getMediaImageUrl(contentItem!
                                                  .mediaList[index].mediaUrl),
                                          width: double.infinity,
                                          height:
                                              size.width * AppDimensions.numD50,
                                          fit: BoxFit.cover,
                                        ),
                      Positioned(
                        right: size.width * AppDimensions.numD02,
                        top: size.width * AppDimensions.numD02,
                        child: Column(
                          children: getMediaCount(contentItem!.mediaList,
                              size), // Assuming getMediaCount can handle List<ContentMedia> or dynamic
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
            padding: EdgeInsets.symmetric(
                vertical: size.width * AppDimensions.numD02),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04,
                  vertical: size.width * AppDimensions.numD02),
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD02)),
              child: Text(
                "Time Left: $_timeLeft",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * AppDimensions.numD04),
              ),
            ),
          ),

        (contentItem!.mediaList.isNotEmpty)
            ? SizedBox(
                height: size.width * AppDimensions.numD02,
              )
            : Container(),

        Row(
          children: [
            Text(
              (contentItem!.isExclusive ?? false)
                  ? ""
                  : AppStrings.multipleText.toUpperCase(),
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
                  (contentItem!.isExclusive ?? false)
                      ? "${iconsPath}ic_exclusive.png"
                      : "${iconsPath}ic_share.png",
                  height: size.width * AppDimensions.numD035,
                ),
                SizedBox(
                  width: size.width * AppDimensions.numD02,
                ),
                Text(
                  (contentItem!.isExclusive ?? false)
                      ? AppStrings.exclusiveText
                      : AppStrings.sharedText,
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
                    contentItem!.title,
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ImageIcon(
                                  const AssetImage("${iconsPath}dollar1.png"),
                                  color: widget.purchasedMediahouseCount == 0
                                      ? Colors.grey
                                      : AppColorTheme.colorThemePink,
                                  size: size.width * AppDimensions.numD042),
                              SizedBox(
                                  width: size.width * AppDimensions.numD018),
                              Text(
                                '${widget.purchasedMediahouseCount} ${AppStrings.sold}',
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD029,
                                    color: widget.purchasedMediahouseCount == 0
                                        ? Colors.grey
                                        : AppColorTheme.colorThemePink,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          SizedBox(width: size.width * AppDimensions.numD02),
                          ImageIcon(const AssetImage("${iconsPath}dollar1.png"),
                              color: widget.offerCount == 0
                                  ? Colors.grey
                                  : AppColorTheme.colorThemePink,
                              size: size.width * AppDimensions.numD042),
                          SizedBox(width: size.width * AppDimensions.numD018),
                          Text(
                            '${widget.offerCount.toString()} ${widget.offerCount > 1 ? '${AppStrings.offerText}s' : AppStrings.offerText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD029,
                                color: widget.offerCount == 0
                                    ? Colors.grey
                                    : AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      SizedBox(width: size.width * AppDimensions.numD02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ImageIcon(const AssetImage("${iconsPath}ic_view.png"),
                              color: contentItem!.totalView == 0
                                  ? Colors.grey
                                  : AppColorTheme.colorThemePink,
                              size: size.width * AppDimensions.numD05),
                          SizedBox(width: size.width * AppDimensions.numD018),
                          Text(
                            '${contentItem!.totalView.toString()} ${contentItem!.totalView > 1 ? '${AppStrings.viewsText}s' : AppStrings.viewsText}',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD029,
                                color: (contentItem!.paidStatus &&
                                            contentItem!.totalView == 1) ||
                                        contentItem!.totalView == 0
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
                        width: size.width * AppDimensions.numD012,
                      ),
                      Text(
                        DateFormat('hh:mm a')
                            .format(DateTime.parse(contentItem!.createdAt)),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD028,
                            color: AppColorTheme.colorHint,
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
                        DateFormat("dd MMM yyyy")
                            .format(DateTime.parse(contentItem!.createdAt)),
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
                          contentItem!.location,
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
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD075,
            ),

            /// price
            Column(
              children: [
                Container(
                  width: size.width * AppDimensions.numD30,
                  padding: EdgeInsets.symmetric(
                      vertical: size.width * AppDimensions.numD012),
                  decoration: BoxDecoration(
                      color: !contentItem!.paidStatus
                          ? AppColorTheme.colorThemePink
                          : /*myContentData!.paidStatus == AppStrings.paidText &&
                                  !myContentData!.isPaidStatusToHopper
                              ? AppColorTheme.colorThemePink
                              :*/
                          AppColorTheme.colorLightGrey,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD03)),
                  child: Column(
                    children: [
                      Text(
                        contentItem!.paidStatus == false
                            ? 'Published Price'
                            : contentItem!.paidStatus == true &&
                                    (contentItem!.isPaidStatusToHopper)
                                ? AppStrings.receivedText
                                : AppStrings.soldText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: !contentItem!.paidStatus
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w400),
                        /*myContentData!.paidStatus == AppStrings.unPaidText
                                ? size.width * AppDimensions.numD035
                                : myContentData!.paidStatus == AppStrings.paidText &&
                                        myContentData!.isPaidStatusToHopper
                                    ? size.width * AppDimensions.numD035
                                    : size.width * AppDimensions.numD03,*/
                        /*myContentData!.paidStatus == AppStrings.paidText &&
                                        myContentData!.isPaidStatusToHopper
                                    ?
                                    : Colors.white*/
                      ),
                      FittedBox(
                        child: Container(
                          margin: EdgeInsets.only(
                            left: size.width * AppDimensions.numD02,
                            right: size.width * AppDimensions.numD02,
                          ),
                          child: Text(
                            "${contentItem!.currencySymbol.isNotEmpty ? contentItem!.currencySymbol : getCurrencySymbol(contentItem!.currency)}${formatDouble(double.parse(contentItem!.price ?? "0"))}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD05,
                                color: !contentItem!.paidStatus
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold),
                            /*myContentData!.paidStatus == AppStrings.paidText &&
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
                            "${(contentItem!.currencySymbol.isNotEmpty ? contentItem!.currencySymbol : getCurrencySymbol(contentItem!.currency))}${contentItem!.totalSold}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD05,
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
                  horizontal: size.width * AppDimensions.numD04,
                  vertical: size.width * AppDimensions.numD035,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD05),
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
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD04),
                              border: Border.all(
                                  color:
                                      AppColorTheme.lightGrey.withOpacity(.6)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD04),
                              child: Image.network(
                                item.mediaHouseImage,
                                fit: BoxFit.contain,
                                height: size.width * AppDimensions.numD20,
                                width: size.width * AppDimensions.numD20,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    "${commonImagePath}rabbitLogo.png",
                                    fit: BoxFit.contain,
                                    width: size.width * AppDimensions.numD20,
                                    height: size.width * AppDimensions.numD20,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * AppDimensions.numD025,
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
                                      fontSize:
                                          size.width * AppDimensions.numD033,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),

                                SizedBox(
                                  height: size.width * AppDimensions.numD02,
                                ),

                                /// Time
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_clock.png",
                                      height: size.width * AppDimensions.numD04,
                                      color: AppColorTheme.colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD01,
                                    ),
                                    Text(
                                      dateTimeFormatter(
                                          dateTime: item.createdAtTime,
                                          format: "hh:mm a",
                                          time: true),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize:
                                              size.width * AppDimensions.numD03,
                                          color: AppColorTheme.colorHint,
                                          fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * AppDimensions.numD02,
                                ),

                                /// date
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_yearly_calendar.png",
                                      height: size.width * AppDimensions.numD04,
                                      color: AppColorTheme.colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD01,
                                    ),
                                    Expanded(
                                      child: Text(
                                        dateTimeFormatter(
                                            dateTime: item.createdAtTime,
                                            format: "dd.MM.yyyy"),
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD03,
                                            color: AppColorTheme.colorHint,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * AppDimensions.numD02,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD01,
                    ),
                    Container(
                      width: size.width * AppDimensions.numD30,
                      padding: EdgeInsets.symmetric(
                          //horizontal: size.width * AppDimensions.numD06,
                          vertical: size.width * AppDimensions.numD012),
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          border: Border.all(color: AppColorTheme.lightGrey),
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD03)),
                      child: Column(
                        children: [
                          Text(
                            "Offered Price",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                          Text(
                            "${(contentItem!.currencySymbol.isNotEmpty ? contentItem!.currencySymbol : getCurrencySymbol(contentItem!.currency))}${numberFormatting(item.initialOfferAmount)}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD05,
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
          height: size.width * AppDimensions.numD05,
        );
      },
      itemCount: _mediaHouseList.length,
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

  /// video widget
  Widget videoWidget(int index) {
    if (index != _currentMediaIndex) {
      // If this is not the current page, show a placeholder or thumbnail
      // to avoid conflict with the single FlickManager instance.
      var item = contentItem!.mediaList[index];
      return Stack(
        children: [
          VideoThumbnailWidget(
            videoUrl: getMediaImageUrl(item.mediaUrl, isVideo: true),
            thumbnailUrl: fixS3Url(item.thumbnailUrl),
            width: double.infinity,
            height: size.width * AppDimensions.numD50,
            fit: BoxFit.cover,
          ),
          const Center(
            child:
                Icon(Icons.play_circle_outline, color: Colors.white, size: 50),
          ),
        ],
      );
    }

    var item = contentItem!.mediaList[index];
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
              flickVideoWithControls: FlickVideoWithControls(
                playerLoadingFallback: Stack(
                  children: [
                    VideoThumbnailWidget(
                      videoUrl: getMediaImageUrl(item.mediaUrl, isVideo: true),
                      thumbnailUrl: fixS3Url(item.thumbnailUrl),
                      width: double.infinity,
                      height: size.width * AppDimensions.numD50,
                      fit: BoxFit.cover,
                    ),
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColorTheme.colorThemePink,
                      ),
                    ),
                  ],
                ),
                closedCaptionTextStyle: const TextStyle(fontSize: 8),
                controls: const FlickPortraitControls(),
              ),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                playerLoadingFallback: Stack(
                  children: [
                    VideoThumbnailWidget(
                      videoUrl: getMediaImageUrl(item.mediaUrl, isVideo: true),
                      thumbnailUrl: fixS3Url(item.thumbnailUrl),
                      width: double.infinity,
                      height: size.width * AppDimensions.numD50,
                      fit: BoxFit.cover,
                    ),
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColorTheme.colorThemePink,
                      ),
                    ),
                  ],
                ),
                controls: const FlickLandscapeControls(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  List<Widget> getMediaCount(List<ContentMetadata> mediaList, Size size) {
    if (mediaList.isEmpty) return [];
    return [
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * AppDimensions.numD015,
          vertical: size.width * 0.005,
        ),
        decoration: BoxDecoration(
            color: AppColorTheme.colorLightGreen.withOpacity(0.8),
            borderRadius:
                BorderRadius.circular(size.width * AppDimensions.numD015)),
        child: Center(
          child: Text(
            "${mediaList.length} ",
            textAlign: TextAlign.center,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD038,
                color: Colors.white,
                fontWeight: FontWeight.w600),
          ),
        ),
      )
    ];
  }

  Future<void> openUrl(String url) async {
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

    m = (value - h * 3600) ~/ 60;

    s = value - (h * 3600) - (m * 60);

    String result = "$h:$m:$s";

    return result;
  }

  void initialController() {
    if (contentItem?.mediaList[_currentMediaIndex].mediaType == "audio") {
      var url =
          getMediaImageUrl(contentItem?.mediaList[_currentMediaIndex].mediaUrl);
      /*  initWaveData(contentImageUrl +
          myContentData!.contentMediaList[_currentMediaIndex].media);*/
      initWaveData(url);
    } else if (contentItem?.mediaList[_currentMediaIndex].mediaType ==
        "video") {
      var url = getMediaImageUrl(
          contentItem?.mediaList[_currentMediaIndex].mediaUrl,
          isVideo: true);
      debugPrint("Video Player URL: $url");
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(url),
        ),
        autoPlay: false,
      );
    }
  }
}
