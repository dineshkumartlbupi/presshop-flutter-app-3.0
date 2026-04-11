import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/services/media_upload_service.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' hide Context, context;
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/camera/presentation/pages/preview_screen.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/dashboard/presentation/pages/dashboard.dart';
import 'package:presshop/features/content/data/models/my_content_data_model.dart';
import 'package:presshop/features/publish/presentation/pages/hash_tag_search_screen.dart';
import 'package:presshop/core/api/api_client.dart';
import '../../domain/entities/content_category.dart';
import '../../domain/entities/charity.dart';
import '../bloc/publish_bloc.dart';
import '../bloc/publish_event.dart';
import '../bloc/publish_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class PublishContentScreen extends StatefulWidget {
  PublishContentScreen(
      {super.key,
      required this.publishData,
      required this.myContentData,
      required this.docType,
      required this.hideDraft});
  PublishData? publishData;
  MyContentData? myContentData;
  bool hideDraft = false;
  String docType = "";

  @override
  State<StatefulWidget> createState() {
    return PublishContentScreenState();
  }
}

class PublishContentScreenState extends State<PublishContentScreen>
    with SingleTickerProviderStateMixin, AnalyticsPageMixin
    implements DashBoardInterface {
  var formKey = GlobalKey<FormState>();
  PlayerController controller = PlayerController(); // Initialise
  List<HashTagData> hashtagList = [];
  List<HashTagData> selectedHashtagList = [];
  List<ContentCategory> categoryList = [];
  List<Charity> allCharityList = [];
  late AnimationController? _controller;

  String selectedSellType = AppStrings.sharedText;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController timestampController = TextEditingController();
  TextEditingController hashtagController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String dropDownValue = "",
      audioPath = "",
      audioDuration = "",
      sharedPrice = "",
      exclusivePrice = "",
      userSharedPriceValue = "",
      userExclusivePriceValue = "";
  ContentCategory? selectedCategory;
  bool audioPlaying = false,
      draftSelected = false,
      _checkCharityBoxVal = false,
      isSaveDraftFromTask = false,
      isLoading = false,
      isSelectLetsGo = false,
      showCelebration = false,
      isShowDraftLoader = false;
  double currentSliderValue = 5.0;

  int imageCount = 0;
  int videoCount = 0;
  int audioCount = 0;
  int docCount = 0;
  int pdfCount = 0;

  Map<String, String> params = {};

  int offset = 0;
  String organisationNumber = "";

  /// Returns the file name with extension.

  /// Save file locally
  Future<void> saveNetworkFileToLocalDirectory(String fileSrcUrl) async {
    debugPrint('-------->$fileSrcUrl');
    Dio dio = Dio();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // String filePath = join(documentsDirectory.path, fileName);
    String filePath = join(documentsDirectory.path, 'recording.m4a');
    /*var file = File(filePath);
    int length = await file.length();
    debugPrint("Audio File Size: $length bytes");*/

    try {
      await dio.download(fileSrcUrl, filePath);
      debugPrint("fileSrcUrl:::::$fileSrcUrl");
      // debugPrint("filePath::::${widget.publishData!.mediaList.length}");

      audioPath = filePath;

      setState(() {});

      /*emit(state.copyWith(
          pickedAudioPath: filePath,
          currentAudioStatus: 'play',
          hasRecording: true));
      preparePlayer();*/
      await preparePlayer();
      // The file has been downloaded and saved at the filePath specified, in this case,
      // the app's document directory.
    } catch (e) {
      // Handle download error
      debugPrint('Failed to download file: $e');
    }
  }

  Future preparePlayer() async {
    await controller.preparePlayer(
      path: audioPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    controller.onCompletion.listen((_) {
      debugPrint('Playback completed');
      controller.setRefresh(true);
      audioPlaying = false;
      setState(() {});
    });
  }

  String get localCurrencySymbol {
    final priceStr = sharedPrice.isNotEmpty ? sharedPrice : exclusivePrice;
    if (priceStr.isEmpty) return currencySymbol;
    final extractedSymbol =
        priceStr.replaceAll(RegExp(r'[0-9.\-\s]'), '').trim();
    if (extractedSymbol.isNotEmpty) {
      return extractedSymbol[0];
    }
    return currencySymbol;
  }

  String _formatPrice(String price) {
    if (price.isEmpty) return price;
    final currentSymbol = localCurrencySymbol;
    if (price.contains('-')) {
      final parts = price.split('-');
      final minStr = parts[0].replaceAll(RegExp(r'[^0-9.]'), '').trim();
      final maxStr = parts[1].replaceAll(RegExp(r'[^0-9.]'), '').trim();
      return '$currentSymbol$minStr - $currentSymbol$maxStr';
    } else {
      final valStr = price.replaceAll(RegExp(r'[^0-9.]'), '').trim();
      return '$currentSymbol$valStr';
    }
  }

  /// selected-category
  void selectedCategoryFunc() {
    if (widget.myContentData != null) {
      final newCategoryId = widget.myContentData!.categoryData!.id;
      final selectedIndex =
          categoryList.indexWhere((element) => element.selected);

      if (selectedIndex != -1) {
        // categoryList[selectedIndex].selected = false;
        categoryList[selectedIndex] =
            categoryList[selectedIndex].copyWith(selected: false);
      }

      final newCategoryIndex =
          categoryList.indexWhere((element) => element.id == newCategoryId);
      if (newCategoryIndex != -1) {
        // categoryList[newCategoryIndex].selected = true;
        categoryList[newCategoryIndex] =
            categoryList[newCategoryIndex].copyWith(selected: true);
      }
    }
    if (widget.myContentData != null &&
        widget.myContentData!.categoryData != null) {
      var cat = widget.myContentData!.categoryData!;
      selectedCategory = ContentCategory(
          id: cat.id,
          name: cat.name,
          type: cat.type,
          percentage: cat.percentage,
          selected: true);
    }
    setState(() {});
  }

  @override
  String get pageName => PageNames.publishContent;

  /// init-state
  @override
  void initState() {
    debugPrint("Class Name : $runtimeType::::::::${widget.docType}");
    // debugPrint("Data : ${widget.myContentData}");
    if (widget.publishData != null) {
      for (var media in widget.publishData!.mediaList) {
        debugPrint("mimeType::::::::${media.mimeType}");
        if (media.mimeType == 'image') imageCount++;
        if (media.mimeType == 'video') videoCount++;
        if (media.mimeType == 'audio') audioCount++;
        if (media.mimeType == 'doc') docCount++;
        if (media.mimeType == 'pdf') pdfCount++;
      }
    }

    if (widget.myContentData != null) {
      for (var media in widget.myContentData!.contentMediaList) {
        debugPrint(" mediaType::::::::${media.mediaType}");

        if (media.mediaType == 'image') imageCount++;
        if (media.mediaType == 'video') videoCount++;
        if (media.mediaType == 'audio') audioCount++;
        if (media.mediaType == 'doc') docCount++;
        if (media.mediaType == 'pdf') pdfCount++;
      }
    }

    if (widget.myContentData != null &&
        widget.myContentData!.audioDescription.isNotEmpty) {
      saveNetworkFileToLocalDirectory(widget.myContentData!.audioDescription);
    }

    DashboardState.dashBoardInterface = this;

    if (showCelebration) {
      // Fixed timer leak: was never cancelled before. Now uses one-shot Timer instead.
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showCelebration = false;
          });
        }
      });
    }

    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   categoryApi();
    //   callCharityListApi();
    //   callGetShareExclusivePrice();
    // });

    /// this function fills all the existing data in the draft
    fillExistingDataFunc();
  }

  String get currencySymbol =>
      getCurrencySymbol(widget.myContentData?.currency ?? 'GBP');
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void dispose() {
    descriptionController.dispose();
    locationController.dispose();
    timestampController.dispose();
    hashtagController.dispose();
    priceController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    debugPrint('screen-name:::::::::PublishContentScreen');

    if (widget.myContentData != null) {
      debugPrint(
          'screen-name:::::::::${widget.myContentData!.contentMediaList.length}');
    }
    if (widget.publishData != null) {
      debugPrint('publishData:::::::::${widget.publishData!.mediaList.length}');
    }

    final String country = widget.publishData?.country ?? "";

    return BlocProvider(
      create: (_) => sl<PublishBloc>()
        ..add(LoadPublishDataEvent(country: country))
        ..add(const FetchCharitiesEvent()),
      child: BlocConsumer<PublishBloc, PublishState>(
        listener: (context, state) {
          if (state.status == PublishStatus.failure) {
            showSnackBar("Error", state.errorMessage, Colors.red);
          }
          if (state.status == PublishStatus.loaded ||
              state.categories.isNotEmpty) {
            categoryList = state.categories;
            if (state.selectedCategory != null) {
              selectedCategory = state.selectedCategory;
            } else if (categoryList.isNotEmpty && selectedCategory == null) {
              if (widget.hideDraft &&
                  widget.myContentData != null &&
                  widget.myContentData!.categoryId.isNotEmpty) {
                try {
                  selectedCategory = categoryList.firstWhere((element) =>
                      element.id == widget.myContentData!.categoryId);
                } catch (e) {
                  selectedCategory = categoryList.first;
                }
              } else {
                selectedCategory = categoryList.first;
              }

              context
                  .read<PublishBloc>()
                  .add(SelectCategoryEvent(selectedCategory!.id));
            }
            setState(() {});
          }

          if (state.charities.isNotEmpty) {
            allCharityList = state.charities;
            setState(() {});
          }
          if (state.prices.isNotEmpty) {
            sharedPrice = state.prices['shared'] ?? sharedPrice;
            exclusivePrice = state.prices['exclusive'] ?? exclusivePrice;
            setState(() {});
          }
        },
        builder: (context, state) {
          // Fallback to ensure UI has data if listener didn't cover (e.g. initial build after reload)
          if (state.categories.isNotEmpty) categoryList = state.categories;
          if (state.charities.isNotEmpty) allCharityList = state.charities;
          if (state.prices.isNotEmpty) {
            sharedPrice = state.prices['shared'] ?? sharedPrice;
            exclusivePrice = state.prices['exclusive'] ?? exclusivePrice;
          }
          // Ensure selectedCategory is not null if list is not empty
          if (selectedCategory == null && categoryList.isNotEmpty) {
            selectedCategory = categoryList.first;
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                //   AppStrings.publishContentText,
                "Submit content",
                style: commonTextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * AppDimensions.appBarHeadingFontSize,
                    size: size),
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

            /// body
            body: SafeArea(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      widget.publishData != null ||
                              (widget.hideDraft && widget.myContentData != null)
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      size.width * AppDimensions.numD04),
                              child: SizedBox(
                                  height: size.width * AppDimensions.numD35,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          context.pop();
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD06),
                                          child: Stack(
                                            children: [
                                              Visibility(
                                                visible: widget.publishData !=
                                                        null
                                                    ? widget
                                                        .publishData!.mimeType
                                                        .contains("doc")
                                                    : widget
                                                            .myContentData!
                                                            .contentMediaList
                                                            .first
                                                            .mediaType ==
                                                        "doc",
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      size.width *
                                                          AppDimensions.numD01),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColorTheme
                                                            .colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD06),
                                                  ),
                                                  child: Image.asset(
                                                    "${dummyImagePath}doc_black_icon.png",
                                                    width: size.width *
                                                        AppDimensions.numD30,
                                                    height: size.width *
                                                        AppDimensions.numD35,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget.publishData !=
                                                        null
                                                    ? widget
                                                        .publishData!.mimeType
                                                        .contains("pdf")
                                                    : widget
                                                            .myContentData!
                                                            .contentMediaList
                                                            .first
                                                            .mediaType ==
                                                        "pdf",
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      size.width *
                                                          AppDimensions.numD01),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColorTheme
                                                            .colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD06),
                                                  ),
                                                  child: Image.asset(
                                                    "${dummyImagePath}pngImage.png",
                                                    width: size.width *
                                                        AppDimensions.numD30,
                                                    height: size.width *
                                                        AppDimensions.numD35,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget.publishData !=
                                                        null
                                                    ? widget
                                                            .publishData!
                                                            .mediaList
                                                            .first
                                                            .mimeType ==
                                                        "audio"
                                                    : widget
                                                            .myContentData!
                                                            .contentMediaList
                                                            .first
                                                            .mediaType ==
                                                        "audio",
                                                child: Container(
                                                  width: size.width *
                                                      AppDimensions.numD30,
                                                  height: size.width *
                                                      AppDimensions.numD35,
                                                  padding: EdgeInsets.all(
                                                      size.width *
                                                          AppDimensions.numD01),
                                                  decoration: BoxDecoration(
                                                    color: AppColorTheme
                                                        .colorThemePink,
                                                    border: Border.all(
                                                        color: AppColorTheme
                                                            .colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD06),
                                                  ),
                                                  child: Icon(
                                                    Icons.play_arrow_rounded,
                                                    size: size.width *
                                                        AppDimensions.numD18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget.publishData !=
                                                        null
                                                    ? widget
                                                            .publishData!
                                                            .mediaList
                                                            .first
                                                            .mimeType ==
                                                        "video"
                                                    : widget
                                                            .myContentData!
                                                            .contentMediaList
                                                            .first
                                                            .mediaType ==
                                                        "video",
                                                child: widget.publishData !=
                                                        null
                                                    ? (widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .thumbnail
                                                                .isNotEmpty &&
                                                            File(widget
                                                                    .publishData!
                                                                    .mediaList
                                                                    .first
                                                                    .thumbnail)
                                                                .existsSync())
                                                        ? Image.file(
                                                            File(widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .thumbnail),
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD30,
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD35,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD30,
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD35,
                                                            color: Colors.black,
                                                            child: const Icon(
                                                                Icons.videocam,
                                                                color: Colors
                                                                    .white),
                                                          )
                                                    : Image.network(
                                                        widget
                                                            .myContentData!
                                                            .contentMediaList
                                                            .first
                                                            .thumbNail,
                                                        width: size.width *
                                                            AppDimensions
                                                                .numD30,
                                                        height: size.width *
                                                            AppDimensions
                                                                .numD35,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                              Visibility(
                                                visible: widget.publishData !=
                                                        null
                                                    ? widget
                                                            .publishData!
                                                            .mediaList
                                                            .first
                                                            .mimeType ==
                                                        "image"
                                                    : widget
                                                            .myContentData!
                                                            .contentMediaList
                                                            .first
                                                            .mediaType ==
                                                        "image",
                                                child:
                                                    widget.publishData != null
                                                        ? Image.file(
                                                            File(widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .mediaPath),
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD30,
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD35,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.network(
                                                            widget
                                                                .myContentData!
                                                                .contentMediaList
                                                                .first
                                                                .media,
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD30,
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD35,
                                                            fit: BoxFit.cover,
                                                          ),
                                              ),

                                              ///Watermark and Content count display UI
                                              Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  Container(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.3),
                                                      width: size.width *
                                                          AppDimensions.numD30,
                                                      height: size.width *
                                                          AppDimensions.numD35,
                                                      child: Image.asset(
                                                        "${commonImagePath}watermark1.png",
                                                        width: size.width *
                                                            AppDimensions
                                                                .numD30,
                                                        height: size.width *
                                                            AppDimensions
                                                                .numD35,
                                                        fit: BoxFit.cover,
                                                      )),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: size.width *
                                                            AppDimensions
                                                                .numD03,
                                                        bottom: size.width *
                                                            AppDimensions
                                                                .numD02,
                                                        right: size.width *
                                                            AppDimensions
                                                                .numD03),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 4,
                                                            horizontal: 6),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.4),
                                                        borderRadius: BorderRadius
                                                            .circular(size
                                                                    .width *
                                                                AppDimensions
                                                                    .numD013)),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            (imageCount +
                                                                    videoCount +
                                                                    audioCount)
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD03,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                        // if (imageCount > 0) ...[
                                                        //   Container(
                                                        //     padding: EdgeInsets.only(left: size.width * AppDimensions.numD01, right: size.width * AppDimensions.numD01, top: size.width * AppDimensions.numD005, bottom: size.width * AppDimensions.numD005),
                                                        //     decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(size.width * AppDimensions.numD013)),
                                                        //     child: Row(
                                                        //       children: [
                                                        //         Text(imageCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w600)),
                                                        //         SizedBox(
                                                        //           width: size.width * AppDimensions.numD005,
                                                        //         ),
                                                        //         Image.asset("${iconsPath}ic_camera_publish.png", color: Colors.white, height: size.width * AppDimensions.numD028),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (videoCount > 0) ...[
                                                        //   Container(
                                                        //     padding: EdgeInsets.only(left: size.width * AppDimensions.numD01, right: size.width * AppDimensions.numD01, top: size.width * AppDimensions.numD005, bottom: size.width * AppDimensions.numD005),
                                                        //     decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(size.width * AppDimensions.numD013)),
                                                        //     child: Row(
                                                        //       children: [
                                                        //         Text(videoCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //         SizedBox(
                                                        //           width: size.width * AppDimensions.numD005,
                                                        //         ),
                                                        //         Image.asset("${iconsPath}ic_v_cam.png", color: Colors.white, height: size.width * AppDimensions.numD035),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (audioCount > 0) ...[
                                                        //   Container(
                                                        //     padding: EdgeInsets.only(left: size.width * AppDimensions.numD01, right: size.width * AppDimensions.numD01, top: size.width * AppDimensions.numD005, bottom: size.width * AppDimensions.numD005),
                                                        //     decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(size.width * AppDimensions.numD013)),
                                                        //     child: Row(
                                                        //       children: [
                                                        //         Text(audioCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //         SizedBox(
                                                        //           width: size.width * AppDimensions.numD005,
                                                        //         ),
                                                        //         /*Icon(Icons.mic_none,
                                                        //             color:Colors.white,
                                                        //             size:size.width * AppDimensions.numD037),*/
                                                        //
                                                        //         Image.asset(
                                                        //           "${iconsPath}ic_mic.png",
                                                        //           color: Colors.white.withValues(alpha: 0.8),
                                                        //           height: size.width * AppDimensions.numD03,
                                                        //           width: size.width * AppDimensions.numD036,
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (docCount > 0) ...[
                                                        //   Container(
                                                        //     padding: EdgeInsets.only(left: size.width * AppDimensions.numD01, right: size.width * AppDimensions.numD01, top: size.width * AppDimensions.numD005, bottom: size.width * AppDimensions.numD005),
                                                        //     decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(size.width * AppDimensions.numD013)),
                                                        //     child: Row(
                                                        //       children: [
                                                        //         Text(docCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //         SizedBox(
                                                        //           width: size.width * AppDimensions.numD005,
                                                        //         ),
                                                        //         Image.asset(
                                                        //           "${iconsPath}doc_icon.png",
                                                        //           color: Colors.red,
                                                        //           height: size.width * AppDimensions.numD03,
                                                        //           width: size.width * AppDimensions.numD022,
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (pdfCount > 0) ...[
                                                        //   Container(
                                                        //     padding: EdgeInsets.only(left: size.width * AppDimensions.numD01, right: size.width * AppDimensions.numD01, top: size.width * AppDimensions.numD005, bottom: size.width * AppDimensions.numD005),
                                                        //     decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(size.width * AppDimensions.numD013)),
                                                        //     child: Row(
                                                        //       children: [
                                                        //         Text(pdfCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //         SizedBox(
                                                        //           width: size.width * AppDimensions.numD005,
                                                        //         ),
                                                        //         Image.asset(
                                                        //           "${iconsPath}doc_icon.png",
                                                        //           color: Colors.red,
                                                        //           height: size.width * AppDimensions.numD03,
                                                        //           width: size.width * AppDimensions.numD022,
                                                        //         ),
                                                        //       ],
                                                        //     ),
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              /*   widget.hideDraft && widget.myContentData != null
                                      ? Positioned(
                                          right: size.width * AppDimensions.numD02,
                                          top: size.width * AppDimensions.numD02,
                                          child: Container(
                                              width: size.width * AppDimensions.numD06,
                                              height: size.width * AppDimensions.numD06,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width * AppDimensions.numD01,
                                                  vertical: size.width * 0.002),
                                              decoration: BoxDecoration(
                                                  color: AppColorTheme.colorLightGreen
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * AppDimensions.numD015)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: widget
                                                                    .myContentData!
                                                                    .contentMediaList
                                                                    .first
                                                                    .mediaType ==
                                                                "video" ||
                                                            widget
                                                                    .myContentData!
                                                                    .contentMediaList
                                                                    .first
                                                                    .mediaType ==
                                                                "audio"
                                                        ? 0
                                                        : size.width * 0.005,
                                                    vertical: widget
                                                                .myContentData!
                                                                .contentMediaList
                                                                .first
                                                                .mediaType ==
                                                            "video"
                                                        ? size.width * 0.005
                                                        : widget
                                                                    .myContentData!
                                                                    .contentMediaList
                                                                    .first
                                                                    .mediaType ==
                                                                "audio"
                                                            ? size.width * 0.009
                                                            : size.width * 0.01),
                                                child: Image.asset(
                                                  widget
                                                              .myContentData!
                                                              .contentMediaList
                                                              .first
                                                              .mediaType ==
                                                          "image"
                                                      ? "${iconsPath}ic_camera_publish.png"
                                                      : widget
                                                                  .myContentData!
                                                                  .contentMediaList
                                                                  .first
                                                                  .mediaType ==
                                                              "video"
                                                          ? "${iconsPath}ic_v_cam.png"
                                                          : widget
                                                                      .myContentData!
                                                                      .contentMediaList
                                                                      .first
                                                                      .mediaType ==
                                                                  "audio"
                                                              ? "${iconsPath}ic_mic.png"
                                                              : "${iconsPath}doc_icon.png",
                                                  color: Colors.white,
                                                  height: widget
                                                              .myContentData!
                                                              .contentMediaList
                                                              .first
                                                              .mediaType ==
                                                          "video"
                                                      ? size.width * AppDimensions.numD09
                                                      : widget
                                                                  .myContentData!
                                                                  .contentMediaList
                                                                  .first
                                                                  .mediaType ==
                                                              "image"
                                                          ? size.width * AppDimensions.numD05
                                                          : size.width * AppDimensions.numD08,
                                                ),
                                              )),
                                        )
                                      : const SizedBox.shrink(),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD03,
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: size.height,
                                          child: TextFormField(
                                            controller: descriptionController,
                                            maxLines: 100,
                                            keyboardType:
                                                TextInputType.multiline,
                                            cursorColor: Colors.black,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                            decoration: InputDecoration(
                                              hintText: AppStrings
                                                  .publishContentHintText,
                                              hintStyle: TextStyle(
                                                  color:
                                                      AppColorTheme.colorHint,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: size.width *
                                                      AppDimensions.numD03),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.width *
                                                                  AppDimensions
                                                                      .numD04),
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 1,
                                                              color: Colors
                                                                  .black)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(size
                                                              .width *
                                                          AppDimensions.numD04),
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(size
                                                              .width *
                                                          AppDimensions.numD04),
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(size
                                                              .width *
                                                          AppDimensions.numD04),
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.width *
                                                                  AppDimensions
                                                                      .numD04),
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 1,
                                                              color: Colors
                                                                  .black)),
                                            ),
                                            // validator: checkRequiredValidator,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      size.width * AppDimensions.numD04),
                              child: SizedBox(
                                  height: size.width * AppDimensions.numD35,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          debugPrint("tapped here ");
                                          List<MediaData> mediaListData = [];
                                          debugPrint(
                                              "Media: ${widget.myContentData?.longitude} , ${widget.myContentData?.latitude}");
                                          widget.myContentData?.contentMediaList
                                              .forEach((item) {
                                            mediaListData.add(MediaData(
                                                mimeType: item.mediaType,
                                                latitude: widget.myContentData
                                                        ?.latitude ??
                                                    "",
                                                longitude: widget.myContentData
                                                        ?.longitude ??
                                                    "",
                                                location: widget.myContentData
                                                        ?.location ??
                                                    "",
                                                country: "",
                                                state: "",
                                                city: "",
                                                dateTime:
                                                    timestampController.text,
                                                mediaPath: item.media,
                                                thumbnail: item.thumbNail));
                                          });
                                          context.pushNamed(
                                            AppRoutes.previewName,
                                            extra: {
                                              'pickAgain': false,
                                              'cameraListData': <CameraData>[],
                                              'cameraData': null,
                                              'mediaList': mediaListData,
                                              'type': "draft",
                                              'myContentData':
                                                  widget.myContentData,
                                            },
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD06),
                                          child: Stack(
                                            children: [
                                              Visibility(
                                                visible: widget
                                                        .myContentData!
                                                        .contentMediaList
                                                        .first
                                                        .mediaType ==
                                                    "doc",
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      size.width *
                                                          AppDimensions.numD01),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColorTheme
                                                            .colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD06),
                                                  ),
                                                  child: Image.asset(
                                                    "${dummyImagePath}doc_black_icon.png",
                                                    width: size.width *
                                                        AppDimensions.numD30,
                                                    height: size.width *
                                                        AppDimensions.numD35,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget
                                                        .myContentData!
                                                        .contentMediaList
                                                        .first
                                                        .mediaType ==
                                                    "pdf",
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      size.width *
                                                          AppDimensions.numD01),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: AppColorTheme
                                                            .colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD06),
                                                  ),
                                                  child: Image.asset(
                                                    "${dummyImagePath}pngImage.png",
                                                    width: size.width *
                                                        AppDimensions.numD30,
                                                    height: size.width *
                                                        AppDimensions.numD35,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget
                                                        .myContentData!
                                                        .contentMediaList
                                                        .first
                                                        .mediaType ==
                                                    "audio",
                                                child: Container(
                                                  width: size.width *
                                                      AppDimensions.numD30,
                                                  height: size.width *
                                                      AppDimensions.numD35,
                                                  padding: EdgeInsets.all(
                                                      size.width *
                                                          AppDimensions.numD01),
                                                  decoration: BoxDecoration(
                                                    color: AppColorTheme
                                                        .colorThemePink,
                                                    border: Border.all(
                                                        color: AppColorTheme
                                                            .colorGreyNew),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD06),
                                                  ),
                                                  child: Icon(
                                                    Icons.play_arrow_rounded,
                                                    size: size.width *
                                                        AppDimensions.numD18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget
                                                        .myContentData!
                                                        .contentMediaList
                                                        .first
                                                        .thumbNail ==
                                                    "video",
                                                child: Image.network(
                                                  widget
                                                      .myContentData!
                                                      .contentMediaList
                                                      .first
                                                      .thumbNail,
                                                  width: size.width *
                                                      AppDimensions.numD30,
                                                  height: size.width *
                                                      AppDimensions.numD35,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Visibility(
                                                visible: widget
                                                        .myContentData!
                                                        .contentMediaList
                                                        .first
                                                        .mediaType ==
                                                    "image",
                                                child: Image.network(
                                                  widget
                                                      .myContentData!
                                                      .contentMediaList
                                                      .first
                                                      .media,
                                                  width: size.width *
                                                      AppDimensions.numD30,
                                                  height: size.width *
                                                      AppDimensions.numD35,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),

                                              ///Watermark and Content count display UI
                                              Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  Container(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.3),
                                                      width: size.width *
                                                          AppDimensions.numD30,
                                                      height: size.width *
                                                          AppDimensions.numD35,
                                                      child: Image.asset(
                                                        "${commonImagePath}watermark1.png",
                                                        width: size.width *
                                                            AppDimensions
                                                                .numD30,
                                                        height: size.width *
                                                            AppDimensions
                                                                .numD35,
                                                        fit: BoxFit.cover,
                                                      )),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: size.width *
                                                            AppDimensions
                                                                .numD03,
                                                        bottom: size.width *
                                                            AppDimensions
                                                                .numD02,
                                                        right: size.width *
                                                            AppDimensions
                                                                .numD03),
                                                    // padding: EdgeInsets.only(left: size.width * AppDimensions.numD02, right: size.width * AppDimensions.numD01, top: size.width * AppDimensions.numD005, bottom: size.width * AppDimensions.numD005),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 4,
                                                            horizontal: 6),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.4),
                                                        borderRadius: BorderRadius
                                                            .circular(size
                                                                    .width *
                                                                AppDimensions
                                                                    .numD013)),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            (imageCount +
                                                                    videoCount +
                                                                    audioCount)
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD03,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                        // if (imageCount > 0) ...[
                                                        //   Row(
                                                        //     children: [
                                                        //       Text(imageCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w600)),
                                                        //       SizedBox(
                                                        //         width: size.width * AppDimensions.numD005,
                                                        //       ),
                                                        //       Image.asset("${iconsPath}ic_camera_publish.png", color: Colors.white, height: size.width * AppDimensions.numD028),
                                                        //     ],
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (videoCount > 0) ...[
                                                        //   Row(
                                                        //     children: [
                                                        //       Text(videoCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //       SizedBox(
                                                        //         width: size.width * AppDimensions.numD005,
                                                        //       ),
                                                        //       Image.asset("${iconsPath}ic_v_cam.png", color: Colors.white, height: size.width * AppDimensions.numD035),
                                                        //     ],
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (audioCount > 0) ...[
                                                        //   Row(
                                                        //     children: [
                                                        //       Text(audioCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //       SizedBox(
                                                        //         width: size.width * AppDimensions.numD005,
                                                        //       ),
                                                        //       Image.asset(
                                                        //         "${iconsPath}ic_mic.png",
                                                        //         color: Colors.white.withValues(alpha: 0.8),
                                                        //         height: size.width * AppDimensions.numD03,
                                                        //         width: size.width * AppDimensions.numD022,
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (docCount > 0) ...[
                                                        //   Row(
                                                        //     children: [
                                                        //       Text(docCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //       SizedBox(
                                                        //         width: size.width * AppDimensions.numD005,
                                                        //       ),
                                                        //       Image.asset(
                                                        //         "${iconsPath}doc_icon.png",
                                                        //         color: Colors.red,
                                                        //         height: size.width * AppDimensions.numD03,
                                                        //         width: size.width * AppDimensions.numD022,
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                        // if (pdfCount > 0) ...[
                                                        //   Row(
                                                        //     children: [
                                                        //       Text(pdfCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * AppDimensions.numD03, fontWeight: FontWeight.w700)),
                                                        //       SizedBox(
                                                        //         width: size.width * AppDimensions.numD005,
                                                        //       ),
                                                        //       Image.asset(
                                                        //         "${iconsPath}doc_icon.png",
                                                        //         color: Colors.red,
                                                        //         height: size.width * AppDimensions.numD03,
                                                        //         width: size.width * AppDimensions.numD022,
                                                        //       ),
                                                        //     ],
                                                        //   ),
                                                        //   SizedBox(
                                                        //     height: size.width * AppDimensions.numD005,
                                                        //   ),
                                                        // ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              /*   widget.hideDraft && widget.myContentData != null
                                      ? Positioned(
                                          right: size.width * AppDimensions.numD02,
                                          top: size.width * AppDimensions.numD02,
                                          child: Container(
                                              width: size.width * AppDimensions.numD06,
                                              height: size.width * AppDimensions.numD06,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width * AppDimensions.numD01,
                                                  vertical: size.width * 0.002),
                                              decoration: BoxDecoration(
                                                  color: AppColorTheme.colorLightGreen
                                                      .withValues(alpha: 0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * AppDimensions.numD015)),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: widget
                                                                    .myContentData!
                                                                    .contentMediaList
                                                                    .first
                                                                    .mediaType ==
                                                                "video" ||
                                                            widget
                                                                    .myContentData!
                                                                    .contentMediaList
                                                                    .first
                                                                    .mediaType ==
                                                                "audio"
                                                        ? 0
                                                        : size.width * 0.005,
                                                    vertical: widget
                                                                .myContentData!
                                                                .contentMediaList
                                                                .first
                                                                .mediaType ==
                                                            "video"
                                                        ? size.width * 0.005
                                                        : widget
                                                                    .myContentData!
                                                                    .contentMediaList
                                                                    .first
                                                                    .mediaType ==
                                                                "audio"
                                                            ? size.width * 0.009
                                                            : size.width * 0.01),
                                                child: Image.asset(
                                                  widget
                                                              .myContentData!
                                                              .contentMediaList
                                                              .first
                                                              .mediaType ==
                                                          "image"
                                                      ? "${iconsPath}ic_camera_publish.png"
                                                      : widget
                                                                  .myContentData!
                                                                  .contentMediaList
                                                                  .first
                                                                  .mediaType ==
                                                              "video"
                                                          ? "${iconsPath}ic_v_cam.png"
                                                          : widget
                                                                      .myContentData!
                                                                      .contentMediaList
                                                                      .first
                                                                      .mediaType ==
                                                                  "audio"
                                                              ? "${iconsPath}ic_mic.png"
                                                              : "${iconsPath}doc_icon.png",
                                                  color: Colors.white,
                                                  height: widget
                                                              .myContentData!
                                                              .contentMediaList
                                                              .first
                                                              .mediaType ==
                                                          "video"
                                                      ? size.width * AppDimensions.numD09
                                                      : widget
                                                                  .myContentData!
                                                                  .contentMediaList
                                                                  .first
                                                                  .mediaType ==
                                                              "image"
                                                          ? size.width * AppDimensions.numD05
                                                          : size.width * AppDimensions.numD08,
                                                ),
                                              )),
                                        )
                                      : const SizedBox.shrink(),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD03,
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: size.height,
                                          child: TextFormField(
                                            controller: descriptionController,
                                            maxLines: 100,
                                            keyboardType:
                                                TextInputType.multiline,
                                            cursorColor: Colors.black,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                            decoration: InputDecoration(
                                              hintText: AppStrings
                                                  .publishContentHintText,
                                              hintStyle: TextStyle(
                                                  color:
                                                      AppColorTheme.colorHint,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: size.width *
                                                      AppDimensions.numD03),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.width *
                                                                  AppDimensions
                                                                      .numD04),
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 1,
                                                              color: Colors
                                                                  .black)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(size
                                                              .width *
                                                          AppDimensions.numD04),
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(size
                                                              .width *
                                                          AppDimensions.numD04),
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black)),
                                              errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(size
                                                              .width *
                                                          AppDimensions.numD04),
                                                  borderSide: const BorderSide(
                                                      width: 1,
                                                      color: Colors.black)),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.width *
                                                                  AppDimensions
                                                                      .numD04),
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 1,
                                                              color: Colors
                                                                  .black)),
                                            ),
                                            // validator: checkRequiredValidator,
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      const Divider(
                        color: AppColorTheme.colorLightGrey,
                        thickness: 1,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD025,
                      ),

                      /// Speak
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: Row(
                          children: [
                            SizedBox(
                              width: size.width * AppDimensions.numD32,
                              child: Text(
                                AppStrings.speakText.toUpperCase(),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            /// audio
                            Expanded(
                                child: InkWell(
                              onTap: () {
                                context
                                    .pushNamed(AppRoutes.audioRecorderName)
                                    .then((value) {
                                  if (value != null) {
                                    audioPath = (value as List)[0].toString();
                                    audioDuration = value[1].toString();
                                    setState(() {});
                                    debugPrint("AudioPath:$audioPath");
                                    debugPrint("audioDuration:$audioDuration");
                                    initWaveData();
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * AppDimensions.numD03,
                                    horizontal:
                                        size.width * AppDimensions.numD05),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD06)),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: audioPath.isNotEmpty
                                          ? () {
                                              debugPrint(
                                                  'audio::::::$audioPath');
                                              if (audioPlaying) {
                                                pauseSound();
                                              } else {
                                                playSound();
                                              }
                                              audioPlaying = !audioPlaying;
                                              setState(() {});
                                            }
                                          : null,
                                      child: SizedBox(
                                        height:
                                            size.width * AppDimensions.numD06,
                                        child: audioPath.isEmpty
                                            ? Image.asset(
                                                "${iconsPath}ic_mic.png",
                                                width: size.width *
                                                    AppDimensions.numD04,
                                                height: size.width *
                                                    AppDimensions.numD04,
                                              )
                                            : Icon(
                                                audioPlaying
                                                    ? Icons.pause_circle
                                                    : Icons.play_circle,
                                                color: Colors.black,
                                                size: size.width *
                                                    AppDimensions.numD06,
                                              ),
                                      ),
                                    ),
                                    audioPath.isNotEmpty
                                        ? Expanded(
                                            child: AudioFileWaveforms(
                                              size: Size(
                                                  size.width,
                                                  size.width *
                                                      AppDimensions.numD04),
                                              playerController: controller,
                                              enableSeekGesture: false,
                                              animationCurve: Curves.bounceIn,
                                              waveformType: WaveformType.long,
                                              continuousWaveform: true,
                                              playerWaveStyle: PlayerWaveStyle(
                                                fixedWaveColor: Colors.black,
                                                liveWaveColor: AppColorTheme
                                                    .colorThemePink,
                                                spacing: 6,
                                                liveWaveGradient:
                                                    ui.Gradient.linear(
                                                  const Offset(70, 50),
                                                  Offset(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2,
                                                      0),
                                                  [
                                                    Colors.green,
                                                    Colors.white70
                                                  ],
                                                ),
                                                fixedWaveGradient:
                                                    ui.Gradient.linear(
                                                  const Offset(70, 50),
                                                  Offset(
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2,
                                                      0),
                                                  [
                                                    Colors.green,
                                                    Colors.white70
                                                  ],
                                                ),
                                                seekLineColor: AppColorTheme
                                                    .colorThemePink,
                                                seekLineThickness: 2,
                                                showSeekLine: true,
                                                showBottom: true,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width *
                                                    AppDimensions.numD02),
                                            child: Text(
                                              "00:00",
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width *
                                                      AppDimensions.numD03,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD025,
                      ),
                      const Divider(
                        color: AppColorTheme.colorLightGrey,
                        thickness: 1,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD022,
                      ),

                      /// Location
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: Row(
                          children: [
                            SizedBox(
                              width: size.width * AppDimensions.numD32,
                              child: Text(
                                AppStrings.locationText.toUpperCase(),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                child: TextFormField(
                              controller: locationController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              readOnly: true,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD028,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColorTheme.colorLightGrey,
                                  hintText: "",
                                  hintStyle: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD03,
                                      color: AppColorTheme.colorHint,
                                      fontWeight: FontWeight.normal),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * AppDimensions.numD04,
                                        right:
                                            size.width * AppDimensions.numD02),
                                    child: const ImageIcon(AssetImage(
                                        "${iconsPath}ic_location.png")),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    maxHeight:
                                        size.width * AppDimensions.numD05,
                                  ),
                                  prefixIconColor:
                                      AppColorTheme.colorTextFieldIcon,
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  contentPadding: EdgeInsets.only(
                                      left: size.width * AppDimensions.numD06)),
                              //  validator: checkRequiredValidator,
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      const Divider(
                        color: AppColorTheme.colorLightGrey,
                        thickness: 1,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD025,
                      ),

                      /// Time Stamp
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: Row(
                          children: [
                            SizedBox(
                              width: size.width * AppDimensions.numD32,
                              child: Text(
                                AppStrings.timestampText.toUpperCase(),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                                child: TextFormField(
                              readOnly: true,
                              controller: timestampController,
                              style: commonTextStyle(
                                  fontSize: size.width * AppDimensions.numD028,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  size: size),
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColorTheme.colorLightGrey,
                                  hintText: "Grenfell Tower, London",
                                  hintStyle: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD03,
                                      color: AppColorTheme.colorHint,
                                      fontWeight: FontWeight.normal),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * AppDimensions.numD04,
                                        right:
                                            size.width * AppDimensions.numD02),
                                    child: const ImageIcon(
                                        AssetImage("${iconsPath}ic_clock.png")),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    maxHeight:
                                        size.width * AppDimensions.numD04,
                                  ),
                                  prefixIconColor:
                                      AppColorTheme.colorTextFieldIcon,
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD08),
                                      borderSide: const BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      )),
                                  contentPadding: EdgeInsets.only(
                                      left: size.width * AppDimensions.numD06)),
                              //  validator: checkRequiredValidator,
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      const Divider(
                        color: AppColorTheme.colorLightGrey,
                        thickness: 1,
                      ),

                      /// hash Tags
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: size.width * AppDimensions.numD32,
                              margin: EdgeInsets.only(
                                  top: size.width * AppDimensions.numD04),
                              child: Text(
                                "${AppStrings.hashtagText.toUpperCase()}S",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    children: List.generate(
                                        selectedHashtagList.length, (index) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            right: index <
                                                    (selectedHashtagList
                                                            .length -
                                                        1)
                                                ? size.width *
                                                    AppDimensions.numD02
                                                : 0),
                                        child: Chip(
                                          label: Text(
                                            "#${selectedHashtagList[index].name}",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          backgroundColor:
                                              AppColorTheme.colorLightGrey,
                                          deleteIcon: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: size.width *
                                                AppDimensions.numD045,
                                          ),
                                          onDeleted: () {
                                            selectedHashtagList.removeAt(index);
                                            hashtagController.text =
                                                selectedHashtagList.isNotEmpty
                                                    ? "Add more"
                                                    : "Add hashtags";
                                            setState(() {});
                                          },
                                        ),
                                      );
                                    }),
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD02,
                                  ),
                                  TextFormField(
                                    controller: hashtagController,
                                    readOnly: true,
                                    autofocus: false,
                                    onTap: () {
                                      context.pushNamed(
                                          AppRoutes.hashTagSearchName,
                                          extra: {
                                            'country': widget.publishData !=
                                                    null
                                                ? widget.publishData!.country
                                                : '',
                                            'tagData': hashtagList,
                                            'initialSelectedHashTags':
                                                selectedHashtagList,
                                            'countryTagId':
                                                hashtagList.isNotEmpty
                                                    ? hashtagList.first.id
                                                    : "",
                                          }).then((value) {
                                        if (value != null) {
                                          // hashtagList.clear();
                                          //  hashtagList.addAll(value as List<HashTagData>);
                                          selectedHashtagList.addAll(
                                              value as List<HashTagData>);
                                          hashtagController.text =
                                              selectedHashtagList.isNotEmpty
                                                  ? "Add more"
                                                  : "Add hashtags";
                                          setState(() {});
                                        }
                                      });
                                    },
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                    decoration: InputDecoration(
                                        hintText: "Add hashtags",
                                        hintStyle: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD03,
                                            color: AppColorTheme.colorHint,
                                            fontWeight: FontWeight.normal),
                                        disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width *
                                                    AppDimensions.numD08),
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: AppColorTheme
                                                    .colorGoogleButtonBorder)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width *
                                                    AppDimensions.numD08),
                                            borderSide: const BorderSide(
                                                width: 1,
                                                color: AppColorTheme.colorGoogleButtonBorder)),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * AppDimensions.numD08), borderSide: const BorderSide(width: 1, color: AppColorTheme.colorGoogleButtonBorder)),
                                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * AppDimensions.numD08), borderSide: const BorderSide(width: 1, color: AppColorTheme.colorGoogleButtonBorder)),
                                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * AppDimensions.numD08), borderSide: const BorderSide(width: 1, color: AppColorTheme.colorGoogleButtonBorder)),
                                        contentPadding: EdgeInsets.only(left: size.width * AppDimensions.numD06)),
                                    /* validator: (value) {
                                if (hashtagList.isEmpty) {
                                  return AppStrings.requiredText;
                                }
                                return null;
                              },*/
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      const Divider(
                        color: AppColorTheme.colorLightGrey,
                        thickness: 1,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: Row(
                          children: [
                            Text(
                              AppStrings.categoryText.toUpperCase(),
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            BlocBuilder<PublishBloc, PublishState>(
                              builder: (context, state) {
                                final currentSelected = state.selectedCategory;
                                return InkWell(
                                  onTap: () {
                                    showCategoryBottomSheet(
                                        size, context.read<PublishBloc>());
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        currentSelected?.name.toCapitalized() ??
                                            "Select",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD03,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.black,
                                        size: size.width * AppDimensions.numD06,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      const Divider(
                        color: AppColorTheme.colorLightGrey,
                        thickness: 1,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                      Text(
                        AppStrings.chooseHowSellText.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD12),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (selectedSellType ==
                                      AppStrings.sharedText) {
                                    return;
                                  }
                                  userExclusivePriceValue =
                                      priceController.text;
                                  priceController.text = userSharedPriceValue;
                                  selectedSellType = AppStrings.sharedText;
                                  setState(() {});
                                },
                                child: Container(
                                  height: size.width * AppDimensions.numD40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: selectedSellType ==
                                                  AppStrings.sharedText
                                              ? Colors.white
                                              : Colors.black,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD04)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            color: selectedSellType ==
                                                    AppStrings.sharedText
                                                ? AppColorTheme.colorThemePink
                                                : Colors.white,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              width: size.width *
                                                  AppDimensions.numD35,
                                              height: size.width *
                                                  AppDimensions.numD08,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: size.width *
                                                      AppDimensions.numD017),
                                              decoration: BoxDecoration(
                                                color: selectedSellType ==
                                                        AppStrings.sharedText
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                              child: Text(
                                                AppStrings.recommendedPriceText,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: size.width *
                                                        AppDimensions.numD026,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.width *
                                                  AppDimensions.numD04,
                                            ),
                                            Image.asset(
                                              "${iconsPath}ic_share.png",
                                              height: size.width *
                                                  AppDimensions.numD07,
                                            )
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                AppStrings.sharedText,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD04,
                                                    color: selectedSellType ==
                                                            AppStrings
                                                                .sharedText
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: size.width *
                                                    AppDimensions.numD01,
                                              ),
                                              Opacity(
                                                opacity: selectedSellType ==
                                                        AppStrings.sharedText
                                                    ? 1.0
                                                    : 0.0,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: size.width *
                                                      AppDimensions.numD35,
                                                  height: size.width *
                                                      AppDimensions.numD08,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: size.width *
                                                          AppDimensions
                                                              .numD017),
                                                  decoration: BoxDecoration(
                                                    color: selectedSellType ==
                                                            AppStrings
                                                                .sharedText
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                  child: Text(
                                                    _formatPrice(sharedPrice),
                                                    style: TextStyle(
                                                        color: selectedSellType ==
                                                                AppStrings
                                                                    .sharedText
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: size.width *
                                                            AppDimensions
                                                                .numD03,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD12,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (selectedSellType ==
                                      AppStrings.exclusiveText) {
                                    return;
                                  }
                                  userSharedPriceValue = priceController.text;
                                  priceController.text =
                                      userExclusivePriceValue;
                                  selectedSellType = AppStrings.exclusiveText;
                                  setState(() {});
                                },
                                child: Container(
                                  height: size.width * AppDimensions.numD40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: selectedSellType ==
                                                  AppStrings.exclusiveText
                                              ? Colors.white
                                              : Colors.black,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD04)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          child: Container(
                                            color: selectedSellType ==
                                                    AppStrings.exclusiveText
                                                ? AppColorTheme.colorThemePink
                                                : Colors.white,
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              width: size.width *
                                                  AppDimensions.numD35,
                                              height: size.width *
                                                  AppDimensions.numD08,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: size.width *
                                                      AppDimensions.numD017),
                                              decoration: BoxDecoration(
                                                color: selectedSellType ==
                                                        AppStrings.exclusiveText
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                              child: Text(
                                                AppStrings.recommendedPriceText,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: size.width *
                                                        AppDimensions.numD026,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.width *
                                                  AppDimensions.numD04,
                                            ),
                                            Image.asset(
                                              "${iconsPath}ic_exclusive.png",
                                              height: size.width *
                                                  AppDimensions.numD07,
                                            )
                                          ],
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                AppStrings.exclusiveText,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD04,
                                                    color: selectedSellType ==
                                                            AppStrings
                                                                .exclusiveText
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: size.width *
                                                    AppDimensions.numD01,
                                              ),
                                              Opacity(
                                                opacity: selectedSellType ==
                                                        AppStrings.exclusiveText
                                                    ? 1.0
                                                    : 0.0,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: size.width *
                                                      AppDimensions.numD35,
                                                  height: size.width *
                                                      AppDimensions.numD08,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: size.width *
                                                          AppDimensions
                                                              .numD017),
                                                  decoration: BoxDecoration(
                                                    color: selectedSellType ==
                                                            AppStrings
                                                                .exclusiveText
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                  child: Text(
                                                    _formatPrice(
                                                        exclusivePrice),
                                                    style: TextStyle(
                                                        color: selectedSellType ==
                                                                AppStrings
                                                                    .exclusiveText
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: size.width *
                                                            AppDimensions
                                                                .numD03,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: Text(
                          selectedSellType == AppStrings.exclusiveText
                              ? AppStrings.publishContentSellNote2Text
                              : AppStrings.publishContentSellNote1Text,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      Text(
                        AppStrings.enterYourPriceText.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD038,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD09),
                        child: TextFormField(
                          controller: priceController,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.black,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: false),
                          inputFormatters: [
                            // CurrencyTextInputFormatter(NumberFormat.compactCurrency(
                            //   decimalDigits: 0,
                            //   symbol: localCurrencySymbol,
                            // )),
                            CurrencyTextInputFormatter(NumberFormat.currency(
                                decimalDigits: 0, symbol: localCurrencySymbol))
                          ],
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD06,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                            hintText: "${localCurrencySymbol}0",
                            hintStyle: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD06,
                                color: AppColorTheme.colorHint,
                                fontWeight: FontWeight.normal),
                            prefixIconColor: AppColorTheme.colorTextFieldIcon,
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.black)),
                          ),
                          //validator: checkRequiredValidator,
                        ),
                      ),

                      InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          chooseCharityBottomSheet(
                              context, size, context.read<PublishBloc>());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: size.width * AppDimensions.numD13,
                              width: size.width * AppDimensions.numD08,
                              child: Checkbox(
                                activeColor: AppColorTheme.colorThemePink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD013),
                                ),
                                side: WidgetStateBorderSide.resolveWith(
                                  (states) => BorderSide(
                                    width: 1.0,
                                    color: _checkCharityBoxVal
                                        ? AppColorTheme.colorThemePink
                                        : Colors.grey.withValues(alpha: 0.5),
                                  ),
                                ),
                                value: _checkCharityBoxVal,
                                onChanged: (val) {
                                  setState(() {
                                    _checkCharityBoxVal = val!;
                                    chooseCharityBottomSheet(context, size,
                                        context.read<PublishBloc>());
                                  });
                                },
                              ),
                            ),
                            Text(
                              AppStrings.donateYourEarningsToCharityText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: AppColorTheme.colorThemePink,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD06),
                        child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                                children: [
                                  const TextSpan(
                                    text:
                                        "${AppStrings.publishContentFooter1Text} ",
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                            AppRoutes.faqName,
                                            extra: {
                                              'priceTipsSelected': true,
                                              'type': '',
                                              'index': 0,
                                            },
                                          );
                                        },
                                        child: Text(
                                            AppStrings.priceTipsText
                                                .toLowerCase(),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w500)),
                                      )),
                                  const TextSpan(
                                    text:
                                        " ${AppStrings.publishContentFooter2Text} ",
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                            AppRoutes.tutorialsName,
                                          );
                                        },
                                        child: Text(
                                            AppStrings.tutorialsText
                                                .toLowerCase(),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w500)),
                                      )),
                                  const TextSpan(
                                    text:
                                        " ${AppStrings.publishContentFooter3Text} ",
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                            AppRoutes.faqName,
                                            extra: {
                                              'priceTipsSelected': false,
                                              'type': 'faq',
                                              'index': 0,
                                            },
                                          );
                                        },
                                        child: Text("guidelines ".toLowerCase(),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w500)),
                                      )),
                                  const TextSpan(
                                    text: AppStrings.publishContentFooter4Text,
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                              AppRoutes.contactUsName);
                                        },
                                        child: Text(
                                            AppStrings.contactText
                                                .toLowerCase(),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w500)),
                                      )),
                                  const TextSpan(
                                    text: AppStrings.publishContentFooter5Text,
                                  ),
                                ])),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),

                      /// save draft and sell buttons
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            /// save-draft-button
                            !widget.hideDraft
                                ? Expanded(
                                    child: SizedBox(
                                    height: size.width * AppDimensions.numD15,
                                    child: commonElevatedButton(
                                      "${AppStrings.saveText.toTitleCase()} ${AppStrings.draftText.toTitleCase()}",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, Colors.black),
                                      () {
                                        draftSelected = true;
                                        isSelectLetsGo = false;
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());

                                        unawaited(callAddContentApi());

                                        if (!mounted) return;
                                        context.goNamed(
                                          AppRoutes.dashboardName,
                                          extra: {'initialPosition': 2},
                                        );
                                      },

                                      /* if (descriptionController.text.trim().isEmpty &&
                                    audioPath.isEmpty) {
                                  showSnackBar(
                                      "Error",
                                      "Description or speak is required",
                                      Colors.red);
                                } else if (locationController.text
                                    .trim()
                                    .isEmpty) {
                                  showSnackBar("Error", "Location is required",
                                      Colors.red);
                                } else if (timestampController.text
                                    .trim()
                                    .isEmpty) {
                                  showSnackBar("Error", "TimeStamp is required",
                                      Colors.red);
                                } else if (priceController.text
                                        .trim()
                                        .isEmpty ||
                                    priceController.text == '0') {
                                  showSnackBar(
                                      "Error", "Price is required", Colors.red);
                                } else {

                                }*/
                                    ),
                                  ))
                                : Container(),
                            SizedBox(
                              width: !widget.hideDraft
                                  ? size.width * AppDimensions.numD04
                                  : 0,
                            ),

                            /// Submit-button
                            Expanded(
                                child: SizedBox(
                              height: size.width * AppDimensions.numD15,
                              child: commonElevatedButton(
                                  "Submit",
                                  size,
                                  commonButtonTextStyle(size),
                                  commonButtonStyle(
                                      size, AppColorTheme.colorThemePink),
                                  () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                draftSelected = false;
                                debugPrint("HideDraft-> ${widget.hideDraft}");
                                if (descriptionController.text.trim().isEmpty &&
                                    audioPath.isEmpty) {
                                  showSnackBar(
                                      "Description",
                                      "Please type or record what you saw",
                                      Colors.red);
                                } else if (priceController.text
                                        .replaceAll(RegExp(r'[^0-9.]'), '')
                                        .trim()
                                        .isEmpty ||
                                    priceController.text
                                            .replaceAll(RegExp(r'[^0-9.]'), '')
                                            .trim() ==
                                        '0') {
                                  showSnackBar("Price",
                                      "Please enter your price", Colors.red);
                                } else {
                                  if (widget.hideDraft) {
                                    await updateDraftListAPI(
                                        widget.myContentData!.id);
                                  } else {
                                    await callCheckOnboardingCompleteOrNotApi();
                                  }
                                }
                              }),
                            )),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            /*if (_showCelebrationJson)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Lottie.asset(
                  'assets/lottieFiles/celebration.json',
                  controller: _controller,
                  repeat: false,
                  onLoaded: (composition) {
                    _controller!
                      ..duration = composition.duration
                      ..forward();
                    _controller?.addStatusListener((status) {
                      if (status == AnimationStatus.completed) {
                        setState(() {
                          _showCelebrationJson = false;
                          debugPrint(
                              '_showCelebrationJson::::$_showCelebrationJson');
                        });
                        // Navigator.pop(context);
                      }
                    });
                  },
                  // onLoaded: (composition) {
                  //   _controller?.duration = composition.duration;
                  //   _controller?.addStatusListener((status) {
                  //     if (status == AnimationStatus.completed) {
                  //       setState(() {
                  //         _showCelebrationJson = false;
                  //       });
                  //       Navigator.pop(context);
                  //     }
                  //   });
                  // },
                ),
              ),
            ),*/
          );
        },
      ),
    );
  }

  /// show-category-bottom-sheet
  void showCategoryBottomSheet(Size size, PublishBloc publishBloc) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BlocProvider.value(
              value: publishBloc,
              child: StatefulBuilder(builder: (context, sheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: size.width * AppDimensions.numD04),
                      child: Row(
                        children: [
                          Text(
                            AppStrings.categoryText.toUpperCase(),
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                              splashRadius: size.width * AppDimensions.numD06,
                              onPressed: () {
                                context.pop();
                              },
                              icon: Icon(
                                Icons.cancel_outlined,
                                size: size.width * AppDimensions.numD08,
                              ))
                        ],
                      ),
                    ),
                    Flexible(
                      child: BlocBuilder<PublishBloc, PublishState>(
                        builder: (context, state) {
                          final categories = state.categories;
                          final currentSelected = state.selectedCategory;

                          return GridView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * AppDimensions.numD04),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing:
                                  size.width * AppDimensions.numD04,
                            ),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected =
                                  category.id == currentSelected?.id;

                              return InkWell(
                                onTap: () {
                                  context
                                      .read<PublishBloc>()
                                      .add(SelectCategoryEvent(category.id));

                                  if (category.name == "Shared" ||
                                      category.name == "Exclusive") {
                                    selectedSellType = category.name;
                                  }

                                  // Local update for immediate feedback if needed
                                  setState(() {
                                    selectedCategory = category;
                                  });

                                  context.pop();
                                },
                                child: Chip(
                                  label: Text(
                                    category.name,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColorTheme.colorHint,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  backgroundColor: isSelected
                                      ? Colors.black
                                      : AppColorTheme.colorLightGrey,
                                ),
                              );
                            },
                            itemCount: categories.length,
                          );
                        },
                      ),
                    ),
                  ],
                );
              }));
        });
  }

  /// choose charity bottom sheet
  void chooseCharityBottomSheet(
      BuildContext context, Size size, PublishBloc bloc) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * AppDimensions.numD07),
          topRight: Radius.circular(size.width * AppDimensions.numD07),
        ),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: bloc,
          child: StatefulBuilder(builder: (context, stateSetter) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(size.width * AppDimensions.numD07),
                      topRight:
                          Radius.circular(size.width * AppDimensions.numD07),
                    ), // Optional: for rounded border
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD045,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                                height: size.width * AppDimensions.numD035),
                            Row(
                              children: [
                                ...[
                                  Text(
                                    AppStrings.chooseYourCharityText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD045,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                      width:
                                          size.width * AppDimensions.numD015),
                                  Image.asset(
                                    'assets/icons/ic_charity.png',
                                    height: size.width * AppDimensions.numD06,
                                  ),
                                ],
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _checkCharityBoxVal = false;
                                    });
                                    context.pop();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                              thickness: 1.3,
                            ),
                            SizedBox(
                                height: size.width * AppDimensions.numD035),
                            Expanded(
                              child: BlocBuilder<PublishBloc, PublishState>(
                                  builder: (context, state) {
                                final charities = state.charities;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ListView.separated(
                                      itemCount: charities.length,
                                      itemBuilder: (context, index) {
                                        var item = charities[index];
                                        return InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            context.read<PublishBloc>().add(
                                                SelectCharityEvent(item.id));
                                            _checkCharityBoxVal = true;
                                            organisationNumber =
                                                item.organisationNumber;
                                            debugPrint(
                                                "organisationNumber:::$organisationNumber");
                                            setState(() {});
                                            stateSetter(() {});
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: item.isSelectCharity
                                                    ? AppColorTheme
                                                        .colorGreyChat
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(size
                                                            .width *
                                                        AppDimensions.numD03),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300)),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: size.width *
                                                      AppDimensions.numD02,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: size.width *
                                                        AppDimensions.numD02,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD02),
                                                    child: item.charityImage
                                                            .isNotEmpty
                                                        ? Image.network(
                                                            item.charityImage,
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD11,
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD11,
                                                            fit: BoxFit.contain,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                size: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD11,
                                                                color:
                                                                    Colors.grey,
                                                              );
                                                            },
                                                          )
                                                        : Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: size.width *
                                                                AppDimensions
                                                                    .numD11,
                                                            color: Colors.grey,
                                                          ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: size.width *
                                                      AppDimensions.numD02,
                                                ),
                                                Expanded(
                                                    child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: size.width *
                                                        AppDimensions.numD01,
                                                  ),
                                                  child: Text(
                                                    item.charityName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: size.width *
                                                            AppDimensions
                                                                .numD034),
                                                  ),
                                                )),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return SizedBox(
                                          height:
                                              size.width * AppDimensions.numD02,
                                        );
                                      },
                                    ),
                                    showCelebration
                                        ? Lottie.asset(
                                            "assets/lottieFiles/celebrate.json",
                                          )
                                        : Container(),
                                  ],
                                );
                              }),
                            ),
                            SizedBox(height: size.width * AppDimensions.numD05),
                            Row(
                              children: [
                                Image.asset(
                                  "${iconsPath}ic_donation.png",
                                  height: size.width * AppDimensions.numD06,
                                  width: size.width * AppDimensions.numD06,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                    width: size.width * AppDimensions.numD02),
                                Text(
                                  "Choose your donation ${formatDouble(currentSliderValue)}%",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD045,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Slider(
                              value: currentSliderValue,
                              max: 100,
                              activeColor: AppColorTheme.colorThemePink,
                              inactiveColor: AppColorTheme.colorGreyChat,
                              divisions: 100,
                              label: currentSliderValue.round().toString(),
                              onChanged: (value) {
                                currentSliderValue = value;
                                debugPrint("value:::::::$value");
                                setState(() {});
                                stateSetter(() {});
                              },
                            ),
                            SizedBox(height: size.width * AppDimensions.numD05),
                            SizedBox(
                              width: size.width,
                              height: size.width * AppDimensions.numD13,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColorTheme.colorThemePink,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD03),
                                  ),
                                ),
                                onPressed: () {
                                  final charities = context
                                      .read<PublishBloc>()
                                      .state
                                      .charities;
                                  bool isAnyCharitySelected = charities.any(
                                      (charity) => charity.isSelectCharity);
                                  if (isAnyCharitySelected) {
                                    showCelebration = true;
                                    Future.delayed(const Duration(seconds: 2),
                                        () {
                                      if (!mounted) return;
                                      context.pop();
                                      showCelebration = false;
                                    });
                                    setState(() {});
                                    stateSetter(() {});
                                  } else {
                                    showSnackBar("Charity",
                                        "Please select a charity!", Colors.red);
                                  }
                                },
                                child: Text(
                                  'Well Done',
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD04,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.width * AppDimensions.numD05),
                            Text(
                              AppStrings.thankYouForDonatingCharityText,
                              textAlign: TextAlign.center,
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD032,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: size.width * AppDimensions.numD05),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                showCelebration
                    ? Lottie.asset(
                        "assets/lottieFiles/celebrate.json",
                      )
                    : Container(),
              ],
            );
          }),
        );
      },
    );
  }

  /// add pre data
  void fillExistingDataFunc() {
    debugPrint("draft::::${widget.hideDraft}:::::");
    if (widget.hideDraft) {
      locationController.text = widget.myContentData!.location;
      timestampController.text = dateTimeFormatter(
          dateTime: widget.myContentData!.dateTime,
          format: "hh:mm a, dd MMM yyyy",
          utc: true);
      descriptionController.text = widget.myContentData!.textValue;
      selectedHashtagList.addAll(widget.myContentData!.hashTagList
          .map((e) => HashTagData.fromJson(e))
          .toList());
      debugPrint("priceValuee=====> ${widget.myContentData!.amount}");
      priceController.text = widget.myContentData!.amount.isNotEmpty
          ? "$localCurrencySymbol${widget.myContentData!.amount}"
          : '';
      if (widget.myContentData!.categoryData != null) {
        var cat = widget.myContentData!.categoryData!;
        selectedCategory = ContentCategory(
            id: cat.id,
            name: cat.name,
            type: cat.type,
            percentage: cat.percentage,
            selected: true);
      }
      selectedSellType = widget.myContentData!.exclusive
          ? AppStrings.exclusiveText
          : AppStrings.sharedText;
      if (widget.myContentData!.exclusive) {
        userExclusivePriceValue = priceController.text;
      } else {
        userSharedPriceValue = priceController.text;
      }
      if (widget.myContentData!.audioDuration.isNotEmpty) {
        audioDuration = widget.myContentData!.audioDuration;
      }
    } else {
      locationController.text = widget.publishData!.address;
      timestampController.text = widget.publishData!.date;
      Future.delayed(Duration.zero, () {
        getHashTagsApi(widget.publishData!.country);
      });
    }
  }

  Future initWaveData() async {
    await controller.preparePlayer(
      path: audioPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );

    controller.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        audioPlaying = false;
        setState(() {});
      }
    });
  }

  Future<void> updateDraftListAPI(String contentId) async {
    debugPrint("updateDraftListAPI contentId: $contentId");
    Map<String, String> map = {
      'content_id': contentId,
    };

    try {
      final response = await sl<ApiClient>()
          .patch(ApiConstantsNew.content.removeFromDraft, data: map);
      if (response.statusCode == 200) {
        log("reqRemoveFromDraftContentAPI===> ${response.data}");
        await callCheckOnboardingCompleteOrNotApi();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future playSound() async {
    await controller.startPlayer();
  }

  Future pauseSound() async {
    await controller.pausePlayer();
  }

  ///--------Apis Section------------

  /// Hash Tag
  Future<void> getHashTagsApi(String searchParam) async {
    Map<String, String> params = {};
    if (searchParam.trim().isNotEmpty) {
      params["tagName"] = searchParam;
      params["type"] = "hopper";
      debugPrint("GetHashTagsQueryParams: $params");
    }

    try {
      final response = await sl<ApiClient>().get(
          ApiConstantsNew.content.getTags,
          showLoader: false,
          queryParameters: searchParam.trim().isNotEmpty ? params : null);

      if (response.statusCode == 200) {
        var decodedResponse = response.data;
        if (decodedResponse is String) {
          decodedResponse = jsonDecode(decodedResponse);
        }
        log("GetHashTags: $decodedResponse");

        // Check if the response is a Map (normal success case)
        if (decodedResponse is Map<String, dynamic>) {
          if (decodedResponse["code"] == 200 ||
              decodedResponse["success"] == true) {
            var list = decodedResponse["data"] ??
                decodedResponse["tags"] ??
                decodedResponse["hashtags"] ??
                [];
            if (list is List) {
              hashtagList = list.map((e) => HashTagData.fromJson(e)).toList();
            }
            setState(() {});
          }
        }
        // Check if the response is a List (likely empty list [])
        else if (decodedResponse is List) {
          // Handle empty list case (no tags found)
          hashtagList = [];
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint("getHashTagsApi Error: $e");
    }
  }

  /// add-content-api
  Future<bool> callAddContentApi() async {
    debugPrint("DEBUG: callAddContentApi called");
    log("callAddContentApi called${DateTime.now()}");
    List<String> tagsIdList = [];
    List<File> filesPath = [];
    List<String> selectMediaList = [];
    timestampController.text =
        timestampController.text.replaceAll(" AM", "").trim();
    timestampController.text =
        timestampController.text.replaceAll(" PM", "").trim();

    for (int i = 0; i < selectedHashtagList.length; i++) {
      tagsIdList.add(selectedHashtagList[i].id);
    }
    if (widget.hideDraft) {
      for (var element in widget.myContentData!.contentMediaList) {
        selectMediaList.add(element.media);
      }
    } else {
      for (var element in widget.publishData!.mediaList) {
        selectMediaList.add(element.mediaPath);
      }
    }

    debugPrint(
        "DEBUG: Checking category. List size: ${categoryList.length}, Selected: $selectedCategory");
    if (selectedCategory == null) {
      if (categoryList.isNotEmpty) {
        selectedCategory = categoryList.first;
        debugPrint(
            "DEBUG: Auto-selected first category: ${selectedCategory?.name}");
      } else {
        debugPrint(
            "DEBUG: Category list empty and none selected. Returning false.");
        showSnackBar("Error", "Please select a category", Colors.red);
        return false;
      }
    }

    params = {
      "description": descriptionController.text.trim(),
      "location": locationController.text.isNotEmpty
          ? locationController.text
          : (widget.publishData != null
              ? widget.publishData!.address
              : widget.myContentData!.location),
      "latitude": widget.publishData != null
          ? widget.publishData!.latitude
          : widget.myContentData!.latitude,
      "longitude": widget.publishData != null
          ? widget.publishData!.longitude
          : widget.myContentData!.longitude,
      "tag_ids": jsonEncode(tagsIdList),
      "category_id": selectedCategory!.id,
      "type":
          selectedSellType == AppStrings.sharedText ? "shared" : "exclusive",
      "ask_price": priceController.text.isNotEmpty
          ? priceController.text.replaceAll(RegExp(r'[^0-9.]'), '')
          : "",
      "timestamp": changeDateFormat("HH:mm, dd MMM yyyy",
          timestampController.text, "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
    };

    if (audioDuration.isNotEmpty) {
      params["audio_description_duration"] = audioDuration;
    }

    if (draftSelected) {
      params["is_draft"] = draftSelected.toString();
    }
    if (_checkCharityBoxVal) {
      params["is_charity"] = _checkCharityBoxVal.toString();
      params["charity"] = currentSliderValue.toString();
    }

    if (widget.myContentData != null && widget.myContentData!.id.isNotEmpty) {
      params["content_id"] = widget.myContentData!.id;
    }

    if (organisationNumber.isNotEmpty) {
      params["organisation_number"] = organisationNumber;
    }

    if (widget.myContentData != null) {
      params["is_already_media"] = jsonEncode(selectMediaList);
    }
    selectMediaList.clear();
    final alreadyUploadedMediaList = [];
    if (widget.hideDraft) {
      if (widget.docType == "draft") {
        for (int i = 0; i < widget.publishData!.mediaList.length; i++) {
          var element = widget.publishData!.mediaList[i];
          if (element.isLocalMedia) {
            selectMediaList.add(element.mediaPath.toString());
          } else {
            alreadyUploadedMediaList.add(element.mediaPath.toString());
          }
          debugPrint("MediaPath-> ${element.mediaPath.toString()}");
        }
      } else {
        for (int i = 0;
            i < widget.myContentData!.contentMediaList.length;
            i++) {
          var element = widget.myContentData!.contentMediaList[i];
          if (element.media.startsWith('http') ||
              element.media.startsWith('https')) {
            alreadyUploadedMediaList.add(element.media.toString());
          } else {
            selectMediaList.add(element.media.toString());
          }
        }
      }
    } else {
      for (int i = 0; i < widget.publishData!.mediaList.length; i++) {
        var element = widget.publishData!.mediaList[i];
        if (element.isLocalMedia) {
          selectMediaList.add(element.mediaPath.toString());
        } else {
          alreadyUploadedMediaList.add(element.mediaPath.toString());
        }
        debugPrint("MediaPath-> ${element.mediaPath.toString()}");
      }
    }

    if (alreadyUploadedMediaList.isNotEmpty) {
      params["is_already_media"] = jsonEncode(alreadyUploadedMediaList);
    }

    filesPath.addAll(selectMediaList.map((path) => File(path)).toList());
    debugPrint("FILES COUNT: ${filesPath.length}");
    for (var f in filesPath) {
      debugPrint("FILE PATH: ${f.path}");
    }
    debugPrint("LocalMedia: ${filesPath.length}");
    log("AddContent Params: $params");
    log("AddContent URL: ${ApiConstantsNew.content.addContent}");

    Map<String, String> additionalFiles = {};
    if (audioPath.isNotEmpty) {
      additionalFiles["audio_description"] = audioPath;
    }

    return await MediaUploadService.uploadMedia(
      endUrl: ApiConstantsNew.content.addContent,
      jsonBody: params,
      filePathList: filesPath,
      imageParams: "images",
      additionalFiles: additionalFiles,
    );
    // widget.hideDraft ? [] :

    /* NetworkClass.multipartNetworkClassFiles(
        addContentUrl, this, addContentUrlRequest, params, filesPath)
        .callMultipartServiceSameParamMultiImage(true, "post", "images");*/
  }

  Future<void> callCheckOnboardingCompleteOrNotApi() async {
    debugPrint("Checking onboarding status API called");

    try {
      final response = await sl<ApiClient>().get(
        ApiConstantsNew.profile.onboardingStatus,
        showLoader: false,
      );
      var data = response.data;
      if (data is String) data = jsonDecode(data);
      debugPrint("Onboarding response: $data");

      if (response.statusCode == 200) {
        var isBeta = data['is_beta'] ?? false;
        debugPrint("isBeta========>>>> $isBeta");

        debugPrint("DEBUG: Starting background upload...");
        unawaited(callAddContentApi());

        debugPrint("DEBUG: Navigating to ContentSubmittedScreen");
        widget.publishData?.mediaList.forEach((media) {
          widget.myContentData?.contentMediaList.add(ContentMediaData(
              "",
              media.mediaPath,
              media.mimeType,
              media.thumbnail,
              media.thumbnail));
        });
        if (!mounted) return;
        if (!mounted) return;
        await context.pushNamed(
          AppRoutes.contentSubmittedName,
          extra: {
            'myContentDetail': widget.myContentData,
            'publishData': widget.publishData,
            'sellType': selectedSellType,
            'price': priceController.text,
            'isBeta': isBeta,
          },
        );
      }
    } catch (e) {
      debugPrint("checkOnboardingCompleteOrNotReq error: $e");
      if (e is DioException && e.response != null) {
        var data = e.response!.data;
        if (data is String) data = jsonDecode(data);
        var isBeta = data['is_beta'] ?? false;

        if (data['message'] == "not verified") {
          unawaited(callAddContentApi());

          widget.publishData?.mediaList.forEach((media) {
            widget.myContentData?.contentMediaList.add(ContentMediaData(
                "",
                media.mediaPath,
                media.mimeType,
                media.thumbnail,
                media.thumbnail));
          });
          if (!mounted) return;
          if (!mounted) return;
          await context.pushNamed(
            AppRoutes.contentSubmittedName,
            extra: {
              'myContentDetail': widget.myContentData,
              'publishData': widget.publishData,
              'sellType': selectedSellType,
              'price': priceController.text,
              'isBeta': isBeta,
            },
          );
        }
      }
    }
  }

  ///---------------------------------------------------------------------------
  /// INTERFACE CLASS OVERRIDE METHOD
  @override
  void saveDraft() {
    debugPrint("saveDraft:::::::Interface:::");
    if (!mounted) return;
    FocusScope.of(context).requestFocus(FocusNode());
    draftSelected = true;
    isSaveDraftFromTask = true;

    ///-> mounted - refers to whether or not the widget is currently part of the widget tree and is being displayed on the screen
    if (mounted) {
      setState(() {});
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      //callUploadMediaApi(false);
    });
  }

/*
class AllCharityModel {
  String id = "";
  String organisationNumber = "";
  String charityName = "";
  String charityImage = "";
  String country = "";
  bool isSelectCharity = false;

  AllCharityModel({
    required this.id,
    required this.organisationNumber,
    required this.charityName,
    required this.charityImage,
    required this.country,
    required this.isSelectCharity,
  });

  factory AllCharityModel.fromJson(Map<String, dynamic> json) {
    return AllCharityModel(
        id: json['_id'] ?? "",
        organisationNumber: json['organisation_number'] ?? "",
        charityName: json['name'] ?? "",
        charityImage: json['logo'] ?? "",
        country: json['country'] ?? "",
        isSelectCharity: false);
  }
}
*/
}
