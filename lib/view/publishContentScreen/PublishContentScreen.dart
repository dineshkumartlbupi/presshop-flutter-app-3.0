import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/dashboardInterface.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/bankScreens/AddBankScreen.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/menuScreen/ContactUsScreen.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:presshop/view/menuScreen/MyContentScreen.dart';
import 'package:presshop/view/menuScreen/MyDraftScreen.dart';
import 'package:presshop/view/publishContentScreen/ContentSubmittedScreen.dart';
import 'package:presshop/view/publishContentScreen/HashTagSearchScreen.dart';
import 'package:presshop/view/publishContentScreen/TutorialsScreen.dart';

import '../../utils/networkOperations/NetworkClass.dart';
import '../cameraScreen/PreviewScreen.dart';
import 'AudioRecorderScreen.dart';

class PublishContentScreen extends StatefulWidget {
  PublishData? publishData;
  MyContentData? myContentData;
  bool hideDraft = false;
  String docType = "";

  PublishContentScreen(
      {super.key,
      required this.publishData,
      required this.myContentData,
      required this.docType,
      required this.hideDraft});

  @override
  State<StatefulWidget> createState() {
    return PublishContentScreenState();
  }
}

class PublishContentScreenState extends State<PublishContentScreen>
    with SingleTickerProviderStateMixin
    implements NetworkResponse, DashBoardInterface {
  var formKey = GlobalKey<FormState>();
  PlayerController controller = PlayerController(); // Initialise
  List<HashTagData> hashtagList = [];
  List<HashTagData> selectedHashtagList = [];
  List<CategoryDataModel> categoryList = [];
  List<AllCharityModel> allCharityList = [];
  late AnimationController? _controller;

  String selectedSellType = sharedText;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController timestampController = TextEditingController();
  TextEditingController hashtagController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String dropDownValue = "",
      audioPath = "",
      audioDuration = "",
      sharedPrice = "",
      exclusivePrice = "";
  CategoryDataModel? selectedCategory;
  bool audioPlaying = false,
      draftSelected = false,
      _checkCharityBoxVal = false,
      _showCelebrationJson = false,
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
  String getFileNameFromUrl(String url) {
    String fileName = url.split('/').toList().last;
    return fileName;
  }

  /// Save file locally
  Future<void> saveNetworkFileToLocalDirectory(String fileSrcUrl) async {
    debugPrint('-------->$fileSrcUrl');
    Dio dio = Dio();
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String fileName = getFileNameFromUrl(fileSrcUrl);
    // String filePath = join(documentsDirectory.path, fileName);
    String filePath = join(documentsDirectory.path, 'recording.m4a');
    /*var file = File(filePath);
    int length = await file.length();
    debugPrint("Audio File Size: $length bytes");*/

    try {
      await dio.download(fileSrcUrl, filePath);
      debugPrint("fileSrcUrl:::::$fileSrcUrl");
      debugPrint("filePath::::${widget.publishData!.mediaList.length}");

      audioPath = filePath;
      setState(() {});

      /*emit(state.copyWith(
          pickedAudioPath: filePath,
          currentAudioStatus: 'play',
          hasRecording: true));
      preparePlayer();*/
      preparePlayer();
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

  /// selected-category
  void selectedCategoryFunc() {
    if (widget.myContentData != null) {
      final newCategoryId = widget.myContentData!.categoryData!.id;
      final selectedIndex =
          categoryList.indexWhere((element) => element.selected);

      if (selectedIndex != -1) {
        categoryList[selectedIndex].selected = false;
      }

      final newCategoryIndex =
          categoryList.indexWhere((element) => element.id == newCategoryId);
      if (newCategoryIndex != -1) {
        categoryList[newCategoryIndex].selected = true;
      }
    }
    if (widget.myContentData != null) {
      selectedCategory = widget.myContentData!.categoryData;
    }
    setState(() {});
  }

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
      saveNetworkFileToLocalDirectory(
          contentImageUrl + widget.myContentData!.audioDescription);
    }

    DashboardState.dashBoardInterface = this;

    if (showCelebration) {
      Timer.periodic(const Duration(seconds: 2), (timer) {
        showCelebration = false;
      });
    }

    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    // ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
    //   categoryApi();
    //   callCharityListApi();
    //   callGetShareExclusivePrice();
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      categoryApi();
      callCharityListApi();
      callGetShareExclusivePrice();
    });

    /// this function fills all the existing data in the draft
    fillExistingDataFunc();
  }

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          //   publishContentText,
          "Submit content",
          style: commonTextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize,
              size: size),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)));
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

      /// body
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.width * numD06,
                ),
                widget.publishData != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04),
                        child: SizedBox(
                            height: size.width * numD35,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD06),
                                    child: Stack(
                                      children: [
                                        Visibility(
                                          visible: widget.publishData!.mimeType
                                              .contains("doc"),
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                size.width * numD01),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: colorGreyNew),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD06),
                                            ),
                                            child: Image.asset(
                                              "${dummyImagePath}doc_black_icon.png",
                                              width: size.width * numD30,
                                              height: size.width * numD35,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mimeType
                                              .contains("pdf"),
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                size.width * numD01),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: colorGreyNew),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD06),
                                            ),
                                            child: Image.asset(
                                              "${dummyImagePath}pngImage.png",
                                              width: size.width * numD30,
                                              height: size.width * numD35,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mediaList
                                                  .first.mimeType ==
                                              "audio",
                                          child: Container(
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            padding: EdgeInsets.all(
                                                size.width * numD01),
                                            decoration: BoxDecoration(
                                              color: colorThemePink,
                                              border: Border.all(
                                                  color: colorGreyNew),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD06),
                                            ),
                                            child: Icon(
                                              Icons.play_arrow_rounded,
                                              size: size.width * numD18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mediaList
                                                  .first.mimeType ==
                                              "video",
                                          child: Image.file(
                                            File(widget.publishData!.mediaList
                                                .first.thumbnail),
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mediaList
                                                  .first.mimeType ==
                                              "image",
                                          child: Image.file(
                                            File(widget.publishData!.mediaList
                                                .first.mediaPath),
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        ///Watermark and Content count display UI
                                        Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Container(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                width: size.width * numD30,
                                                height: size.width * numD35,
                                                child: Image.asset(
                                                  "${commonImagePath}watermark1.png",
                                                  width: size.width * numD30,
                                                  height: size.width * numD35,
                                                  fit: BoxFit.cover,
                                                )),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: size.width * numD03,
                                                  bottom: size.width * numD02,
                                                  right: size.width * numD03),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 6),
                                              decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width *
                                                              numD013)),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      (imageCount +
                                                              videoCount +
                                                              audioCount)
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: size.width *
                                                              numD03,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  // if (imageCount > 0) ...[
                                                  //   Container(
                                                  //     padding: EdgeInsets.only(left: size.width * numD01, right: size.width * numD01, top: size.width * numD005, bottom: size.width * numD005),
                                                  //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(size.width * numD013)),
                                                  //     child: Row(
                                                  //       children: [
                                                  //         Text(imageCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w600)),
                                                  //         SizedBox(
                                                  //           width: size.width * numD005,
                                                  //         ),
                                                  //         Image.asset("${iconsPath}ic_camera_publish.png", color: Colors.white, height: size.width * numD028),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (videoCount > 0) ...[
                                                  //   Container(
                                                  //     padding: EdgeInsets.only(left: size.width * numD01, right: size.width * numD01, top: size.width * numD005, bottom: size.width * numD005),
                                                  //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(size.width * numD013)),
                                                  //     child: Row(
                                                  //       children: [
                                                  //         Text(videoCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //         SizedBox(
                                                  //           width: size.width * numD005,
                                                  //         ),
                                                  //         Image.asset("${iconsPath}ic_v_cam.png", color: Colors.white, height: size.width * numD035),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (audioCount > 0) ...[
                                                  //   Container(
                                                  //     padding: EdgeInsets.only(left: size.width * numD01, right: size.width * numD01, top: size.width * numD005, bottom: size.width * numD005),
                                                  //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(size.width * numD013)),
                                                  //     child: Row(
                                                  //       children: [
                                                  //         Text(audioCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //         SizedBox(
                                                  //           width: size.width * numD005,
                                                  //         ),
                                                  //         /*Icon(Icons.mic_none,
                                                  //             color:Colors.white,
                                                  //             size:size.width * numD037),*/
                                                  //
                                                  //         Image.asset(
                                                  //           "${iconsPath}ic_mic.png",
                                                  //           color: Colors.white.withOpacity(0.8),
                                                  //           height: size.width * numD03,
                                                  //           width: size.width * numD036,
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (docCount > 0) ...[
                                                  //   Container(
                                                  //     padding: EdgeInsets.only(left: size.width * numD01, right: size.width * numD01, top: size.width * numD005, bottom: size.width * numD005),
                                                  //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(size.width * numD013)),
                                                  //     child: Row(
                                                  //       children: [
                                                  //         Text(docCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //         SizedBox(
                                                  //           width: size.width * numD005,
                                                  //         ),
                                                  //         Image.asset(
                                                  //           "${iconsPath}doc_icon.png",
                                                  //           color: Colors.red,
                                                  //           height: size.width * numD03,
                                                  //           width: size.width * numD022,
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (pdfCount > 0) ...[
                                                  //   Container(
                                                  //     padding: EdgeInsets.only(left: size.width * numD01, right: size.width * numD01, top: size.width * numD005, bottom: size.width * numD005),
                                                  //     decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(size.width * numD013)),
                                                  //     child: Row(
                                                  //       children: [
                                                  //         Text(pdfCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //         SizedBox(
                                                  //           width: size.width * numD005,
                                                  //         ),
                                                  //         Image.asset(
                                                  //           "${iconsPath}doc_icon.png",
                                                  //           color: Colors.red,
                                                  //           height: size.width * numD03,
                                                  //           width: size.width * numD022,
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        /*   widget.hideDraft && widget.myContentData != null
                                      ? Positioned(
                                          right: size.width * numD02,
                                          top: size.width * numD02,
                                          child: Container(
                                              width: size.width * numD06,
                                              height: size.width * numD06,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width * numD01,
                                                  vertical: size.width * 0.002),
                                              decoration: BoxDecoration(
                                                  color: colorLightGreen
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * numD015)),
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
                                                      ? size.width * numD09
                                                      : widget
                                                                  .myContentData!
                                                                  .contentMediaList
                                                                  .first
                                                                  .mediaType ==
                                                              "image"
                                                          ? size.width * numD05
                                                          : size.width * numD08,
                                                ),
                                              )),
                                        )
                                      : const SizedBox.shrink(),*/
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * numD03,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: size.height,
                                    child: TextFormField(
                                      controller: descriptionController,
                                      maxLines: 100,
                                      keyboardType: TextInputType.multiline,
                                      cursorColor: Colors.black,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                      decoration: InputDecoration(
                                        hintText: publishContentHintText,
                                        hintStyle: TextStyle(
                                            color: colorHint,
                                            fontWeight: FontWeight.normal,
                                            fontSize: size.width * numD03),
                                        disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
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
                            horizontal: size.width * numD04),
                        child: SizedBox(
                            height: size.width * numD35,
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
                                          latitude:
                                              widget.myContentData?.latitude ??
                                                  "",
                                          longitude:
                                              widget.myContentData?.longitude ??
                                                  "",
                                          location:
                                              widget.myContentData?.location ??
                                                  "",
                                          dateTime: timestampController.text,
                                          mediaPath: item.media,
                                          thumbnail: item.thumbNail));
                                    });
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => PreviewScreen(
                                                pickAgain: false,
                                                cameraListData: [],
                                                cameraData: null,
                                                mediaList: mediaListData,
                                                type: "draft",
                                                myContentData:
                                                    widget.myContentData)));
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD06),
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
                                                size.width * numD01),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: colorGreyNew),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD06),
                                            ),
                                            child: Image.asset(
                                              "${dummyImagePath}doc_black_icon.png",
                                              width: size.width * numD30,
                                              height: size.width * numD35,
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
                                                size.width * numD01),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: colorGreyNew),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD06),
                                            ),
                                            child: Image.asset(
                                              "${dummyImagePath}pngImage.png",
                                              width: size.width * numD30,
                                              height: size.width * numD35,
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
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            padding: EdgeInsets.all(
                                                size.width * numD01),
                                            decoration: BoxDecoration(
                                              color: colorThemePink,
                                              border: Border.all(
                                                  color: colorGreyNew),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD06),
                                            ),
                                            child: Icon(
                                              Icons.play_arrow_rounded,
                                              size: size.width * numD18,
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
                                            contentImageUrl +
                                                widget
                                                    .myContentData!
                                                    .contentMediaList
                                                    .first
                                                    .thumbNail,
                                            width: size.width * numD30,
                                            height: size.width * numD35,
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
                                            contentImageUrl +
                                                widget
                                                    .myContentData!
                                                    .contentMediaList
                                                    .first
                                                    .media,
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        ///Watermark and Content count display UI
                                        Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Container(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                width: size.width * numD30,
                                                height: size.width * numD35,
                                                child: Image.asset(
                                                  "${commonImagePath}watermark1.png",
                                                  width: size.width * numD30,
                                                  height: size.width * numD35,
                                                  fit: BoxFit.cover,
                                                )),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: size.width * numD03,
                                                  bottom: size.width * numD02,
                                                  right: size.width * numD03),
                                              // padding: EdgeInsets.only(left: size.width * numD02, right: size.width * numD01, top: size.width * numD005, bottom: size.width * numD005),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 6),
                                              decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width *
                                                              numD013)),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      (imageCount +
                                                              videoCount +
                                                              audioCount)
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: size.width *
                                                              numD03,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  // if (imageCount > 0) ...[
                                                  //   Row(
                                                  //     children: [
                                                  //       Text(imageCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w600)),
                                                  //       SizedBox(
                                                  //         width: size.width * numD005,
                                                  //       ),
                                                  //       Image.asset("${iconsPath}ic_camera_publish.png", color: Colors.white, height: size.width * numD028),
                                                  //     ],
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (videoCount > 0) ...[
                                                  //   Row(
                                                  //     children: [
                                                  //       Text(videoCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //       SizedBox(
                                                  //         width: size.width * numD005,
                                                  //       ),
                                                  //       Image.asset("${iconsPath}ic_v_cam.png", color: Colors.white, height: size.width * numD035),
                                                  //     ],
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (audioCount > 0) ...[
                                                  //   Row(
                                                  //     children: [
                                                  //       Text(audioCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //       SizedBox(
                                                  //         width: size.width * numD005,
                                                  //       ),
                                                  //       Image.asset(
                                                  //         "${iconsPath}ic_mic.png",
                                                  //         color: Colors.white.withOpacity(0.8),
                                                  //         height: size.width * numD03,
                                                  //         width: size.width * numD022,
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (docCount > 0) ...[
                                                  //   Row(
                                                  //     children: [
                                                  //       Text(docCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //       SizedBox(
                                                  //         width: size.width * numD005,
                                                  //       ),
                                                  //       Image.asset(
                                                  //         "${iconsPath}doc_icon.png",
                                                  //         color: Colors.red,
                                                  //         height: size.width * numD03,
                                                  //         width: size.width * numD022,
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                  // if (pdfCount > 0) ...[
                                                  //   Row(
                                                  //     children: [
                                                  //       Text(pdfCount.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w700)),
                                                  //       SizedBox(
                                                  //         width: size.width * numD005,
                                                  //       ),
                                                  //       Image.asset(
                                                  //         "${iconsPath}doc_icon.png",
                                                  //         color: Colors.red,
                                                  //         height: size.width * numD03,
                                                  //         width: size.width * numD022,
                                                  //       ),
                                                  //     ],
                                                  //   ),
                                                  //   SizedBox(
                                                  //     height: size.width * numD005,
                                                  //   ),
                                                  // ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        /*   widget.hideDraft && widget.myContentData != null
                                      ? Positioned(
                                          right: size.width * numD02,
                                          top: size.width * numD02,
                                          child: Container(
                                              width: size.width * numD06,
                                              height: size.width * numD06,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width * numD01,
                                                  vertical: size.width * 0.002),
                                              decoration: BoxDecoration(
                                                  color: colorLightGreen
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * numD015)),
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
                                                      ? size.width * numD09
                                                      : widget
                                                                  .myContentData!
                                                                  .contentMediaList
                                                                  .first
                                                                  .mediaType ==
                                                              "image"
                                                          ? size.width * numD05
                                                          : size.width * numD08,
                                                ),
                                              )),
                                        )
                                      : const SizedBox.shrink(),*/
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * numD03,
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: size.height,
                                    child: TextFormField(
                                      controller: descriptionController,
                                      maxLines: 100,
                                      keyboardType: TextInputType.multiline,
                                      cursorColor: Colors.black,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                      decoration: InputDecoration(
                                        hintText: publishContentHintText,
                                        hintStyle: TextStyle(
                                            color: colorHint,
                                            fontWeight: FontWeight.normal,
                                            fontSize: size.width * numD03),
                                        disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black)),
                                      ),
                                      // validator: checkRequiredValidator,
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD025,
                ),

                /// Speak
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * numD32,
                        child: Text(
                          speakText.toUpperCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      /// audio
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      const AudioRecorderScreen()))
                              .then((value) {
                            if (value != null) {
                              audioPath = value[0].toString();
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
                              vertical: size.width * numD03,
                              horizontal: size.width * numD05),
                          decoration: BoxDecoration(
                              color: colorLightGrey,
                              borderRadius:
                                  BorderRadius.circular(size.width * numD06)),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: audioPath.isNotEmpty
                                    ? () {
                                        debugPrint('audio::::::$audioPath');
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
                                  height: size.width * numD06,
                                  child: audioPath.isEmpty
                                      ? Image.asset(
                                          "${iconsPath}ic_mic.png",
                                          width: size.width * numD04,
                                          height: size.width * numD04,
                                        )
                                      : Icon(
                                          audioPlaying
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.black,
                                          size: size.width * numD06,
                                        ),
                                ),
                              ),
                              audioPath.isNotEmpty
                                  ? Expanded(
                                      child: AudioFileWaveforms(
                                        size: Size(
                                            size.width, size.width * numD04),
                                        playerController: controller,
                                        enableSeekGesture: false,
                                        animationCurve: Curves.bounceIn,
                                        waveformType: WaveformType.long,
                                        continuousWaveform: true,
                                        playerWaveStyle: PlayerWaveStyle(
                                          fixedWaveColor: Colors.black,
                                          liveWaveColor: colorThemePink,
                                          spacing: 6,
                                          liveWaveGradient: ui.Gradient.linear(
                                            const Offset(70, 50),
                                            Offset(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                0),
                                            [Colors.green, Colors.white70],
                                          ),
                                          fixedWaveGradient: ui.Gradient.linear(
                                            const Offset(70, 50),
                                            Offset(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                0),
                                            [Colors.green, Colors.white70],
                                          ),
                                          seekLineColor: colorThemePink,
                                          seekLineThickness: 2,
                                          showSeekLine: true,
                                          showBottom: true,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD02),
                                      child: Text(
                                        "00:00",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
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
                  height: size.width * numD025,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD022,
                ),

                /// Location
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * numD32,
                        child: Text(
                          locationText.toUpperCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
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
                            fontSize: size.width * numD028,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: colorLightGrey,
                            hintText: "",
                            hintStyle: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: colorHint,
                                fontWeight: FontWeight.normal),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                  left: size.width * numD04,
                                  right: size.width * numD02),
                              child: const ImageIcon(
                                  AssetImage("${iconsPath}ic_location.png")),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              maxHeight: size.width * numD05,
                            ),
                            prefixIconColor: colorTextFieldIcon,
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            contentPadding:
                                EdgeInsets.only(left: size.width * numD06)),
                        //  validator: checkRequiredValidator,
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD025,
                ),

                /// Time Stamp
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * numD32,
                        child: Text(
                          timestampText.toUpperCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: TextFormField(
                        readOnly: true,
                        controller: timestampController,
                        style: commonTextStyle(
                            fontSize: size.width * numD028,
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            size: size),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: colorLightGrey,
                            hintText: "Grenfell Tower, London",
                            hintStyle: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: colorHint,
                                fontWeight: FontWeight.normal),
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                  left: size.width * numD04,
                                  right: size.width * numD02),
                              child: const ImageIcon(
                                  AssetImage("${iconsPath}ic_clock.png")),
                            ),
                            prefixIconConstraints: BoxConstraints(
                              maxHeight: size.width * numD04,
                            ),
                            prefixIconColor: colorTextFieldIcon,
                            disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD08),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )),
                            contentPadding:
                                EdgeInsets.only(left: size.width * numD06)),
                        //  validator: checkRequiredValidator,
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),

                /// hash Tags
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: size.width * numD32,
                        margin: EdgeInsets.only(top: size.width * numD04),
                        child: Text(
                          "${hashtagText.toUpperCase()}S",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
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
                                              (selectedHashtagList.length - 1)
                                          ? size.width * numD02
                                          : 0),
                                  child: Chip(
                                    label: Text(
                                      "#${selectedHashtagList[index].name}",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    backgroundColor: colorLightGrey,
                                    deleteIcon: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: size.width * numD045,
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
                              height: size.width * numD02,
                            ),
                            TextFormField(
                              controller: hashtagController,
                              readOnly: true,
                              autofocus: false,
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            HashTagSearchScreen(
                                              country: widget.publishData !=
                                                      null
                                                  ? widget.publishData!.country
                                                  : '',
                                              tagData: hashtagList,
                                              countryTagId:
                                                  hashtagList.isNotEmpty
                                                      ? hashtagList.first.id
                                                      : "",
                                            )))
                                    .then((value) {
                                  if (value != null) {
                                    // hashtagList.clear();
                                    //  hashtagList.addAll(value as List<HashTagData>);
                                    selectedHashtagList
                                        .addAll(value as List<HashTagData>);
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
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                              decoration: InputDecoration(
                                  hintText: "Add hashtags",
                                  hintStyle: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD03,
                                      color: colorHint,
                                      fontWeight: FontWeight.normal),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD08),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: colorGoogleButtonBorder)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD08),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: colorGoogleButtonBorder)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD08),
                                      borderSide: const BorderSide(
                                          width: 1,
                                          color: colorGoogleButtonBorder)),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(size.width * numD08),
                                      borderSide: const BorderSide(width: 1, color: colorGoogleButtonBorder)),
                                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(size.width * numD08), borderSide: const BorderSide(width: 1, color: colorGoogleButtonBorder)),
                                  contentPadding: EdgeInsets.only(left: size.width * numD06)),
                              /* validator: (value) {
                                if (hashtagList.isEmpty) {
                                  return requiredText;
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
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    children: [
                      Text(
                        categoryText.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      selectedCategory != null
                          ? InkWell(
                              onTap: () {
                                int selectedPos = categoryList
                                    .indexWhere((element) => element.selected);
                                if (selectedPos > 0) {
                                  categoryList.swap(0, selectedPos);
                                }
                                //  showCategoryDialogBox(context, size);
                                showCategoryBottomSheet(size);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    selectedCategory!.name.toCapitalized(),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.black,
                                    size: size.width * numD06,
                                  )
                                ],
                              ),
                            )
                          : Container(),

                      /*selectedCategory != null
                          ? DropdownButton<CategoryData>(
                              underline: Container(),
                              value: selectedCategory,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value!;
                                  dropDownValue = value.name;
                                });
                              },
                              items: categoryList
                                  .map<DropdownMenuItem<CategoryData>>(
                                      (CategoryData e) {
                                return DropdownMenuItem<CategoryData>(
                                    value: e, child: Text(e.name));
                              }).toList(),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.black,
                                size: size.width * numD06,
                              ),
                            )
                          : Container()*/
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
                ),
                const Divider(
                  color: colorLightGrey,
                  thickness: 1,
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Text(
                  chooseHowSellText.toUpperCase(),
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD12),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectedSellType = sharedText;
                            setState(() {});
                          },
                          child: Container(
                            height: size.width * numD40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: selectedSellType == sharedText
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1.5),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      color: selectedSellType == sharedText
                                          ? colorThemePink
                                          : Colors.white,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: size.width * numD35,
                                        height: size.width * numD08,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.width * numD017),
                                        decoration: BoxDecoration(
                                          color: selectedSellType == sharedText
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                        child: Text(
                                          recommendedPriceText,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: size.width * numD026,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * numD04,
                                      ),
                                      Image.asset(
                                        "${iconsPath}ic_share.png",
                                        height: size.width * numD07,
                                      )
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          sharedText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD04,
                                              color:
                                                  selectedSellType == sharedText
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: size.width * numD01,
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: size.width * numD35,
                                          height: size.width * numD08,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.width * numD017),
                                          decoration: BoxDecoration(
                                            color:
                                                selectedSellType == sharedText
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          child: Text(
                                            sharedPrice,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size.width * numD03,
                                                fontWeight: FontWeight.bold),
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
                        width: size.width * numD12,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            selectedSellType = exclusiveText;
                            setState(() {});
                          },
                          child: Container(
                            height: size.width * numD40,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: selectedSellType == exclusiveText
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1.5),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      color: selectedSellType == exclusiveText
                                          ? colorThemePink
                                          : Colors.white,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: size.width * numD35,
                                        height: size.width * numD08,
                                        padding: EdgeInsets.symmetric(
                                            vertical: size.width * numD017),
                                        decoration: BoxDecoration(
                                          color:
                                              selectedSellType == exclusiveText
                                                  ? Colors.black
                                                  : Colors.white,
                                        ),
                                        child: Text(
                                          recommendedPriceText,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: size.width * numD026,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * numD04,
                                      ),
                                      Image.asset(
                                        "${iconsPath}ic_exclusive.png",
                                        height: size.width * numD07,
                                      )
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          exclusiveText,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD04,
                                              color: selectedSellType ==
                                                      exclusiveText
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: size.width * numD01,
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: size.width * numD35,
                                          height: size.width * numD08,
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.width * numD017),
                                          decoration: BoxDecoration(
                                            color: selectedSellType ==
                                                    exclusiveText
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          child: Text(
                                            exclusivePrice,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size.width * numD03,
                                                fontWeight: FontWeight.bold),
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
                  height: size.width * numD06,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Text(
                    selectedSellType == exclusiveText
                        ? publishContentSellNote2Text
                        : publishContentSellNote1Text,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD03,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    textAlign: TextAlign.justify,
                  ),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                Text(
                  enterYourPriceText.toUpperCase(),
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.width * numD038,
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD09),
                  child: TextFormField(
                    controller: priceController,
                    textAlign: TextAlign.center,
                    cursorColor: Colors.black,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: false),
                    inputFormatters: [
                      // CurrencyTextInputFormatter(NumberFormat.compactCurrency(
                      //   decimalDigits: 0,
                      //   symbol: euroUniqueCode,
                      // )),
                      CurrencyTextInputFormatter(NumberFormat.currency(
                          decimalDigits: 0, symbol: euroUniqueCode))
                    ],
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                      hintText: "${euroUniqueCode}0",
                      hintStyle: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD06,
                          color: colorHint,
                          fontWeight: FontWeight.normal),
                      prefixIconColor: colorTextFieldIcon,
                      disabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black)),
                    ),
                    //validator: checkRequiredValidator,
                  ),
                ),

                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    chooseCharityBottomSheet(context, size);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.width * numD13,
                        width: size.width * numD08,
                        child: Checkbox(
                          activeColor: colorThemePink,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * numD013),
                          ),
                          side: MaterialStateBorderSide.resolveWith(
                            (states) => BorderSide(
                                width: 1.0,
                                color: _checkCharityBoxVal
                                    ? colorThemePink
                                    : Colors.grey.withOpacity(.5)),
                          ),
                          value: _checkCharityBoxVal,
                          onChanged: (val) {
                            setState(() {
                              _checkCharityBoxVal = val!;
                              chooseCharityBottomSheet(context, size);
                            });
                          },
                        ),
                      ),
                      Text(
                        donateYourEarningsToCharityText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: colorThemePink,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD06),
                  child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                          children: [
                            const TextSpan(
                              text: "$publishContentFooter1Text ",
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FAQScreen(
                                                  priceTipsSelected: true,
                                                  type: '',
                                                  index: 0,
                                                )));
                                  },
                                  child: Text(priceTipsText.toLowerCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w500)),
                                )),
                            const TextSpan(
                              text: " $publishContentFooter2Text ",
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const TutorialsScreen()));
                                  },
                                  child: Text(tutorialsText.toLowerCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w500)),
                                )),
                            const TextSpan(
                              text: " $publishContentFooter3Text ",
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => FAQScreen(
                                                  priceTipsSelected: false,
                                                  type: 'faq',
                                                  index: 0,
                                                )));
                                  },
                                  child: Text("guidelines ".toLowerCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w500)),
                                )),
                            const TextSpan(
                              text: publishContentFooter4Text,
                            ),
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ContactUsScreen()));
                                  },
                                  child: Text(contactText.toLowerCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w500)),
                                )),
                            const TextSpan(
                              text: publishContentFooter5Text,
                            ),
                          ])),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),

                /// save draft and sell buttons
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      /// save-draft-button
                      !widget.hideDraft
                          ? Expanded(
                              child: SizedBox(
                              height: size.width * numD15,
                              child: commonElevatedButton(
                                  "${saveText.toTitleCase()} ${draftText.toTitleCase()}",
                                  size,
                                  commonButtonTextStyle(size),
                                  commonButtonStyle(size, Colors.black), () {
                                draftSelected = true;
                                isSelectLetsGo = false;
                                isShowDraftLoader = true;
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                callAddContentApi();
                                showSnackBar("Draft",
                                    "Draft successfully saved", Colors.green);
                                Future.delayed(
                                  const Duration(seconds: 2),
                                  // This matches the SnackBar duration
                                  () {
                                    isShowDraftLoader = false;
                                    Navigator.push(
                                      navigatorKey.currentContext!,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Dashboard(initialPosition: 2)),
                                    );
                                  },
                                );

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
                              }),
                            ))
                          : Container(),
                      SizedBox(
                        width: !widget.hideDraft ? size.width * numD04 : 0,
                      ),

                      /// Submit-button
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            "Submit",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink), () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          draftSelected = false;
                          debugPrint("HideDraft-> ${widget.hideDraft}");
                          if (descriptionController.text.trim().isEmpty &&
                              audioPath.isEmpty) {
                            showSnackBar(
                                "Description",
                                "Please type or record what you saw",
                                Colors.red);
                          } else if (priceController.text.trim().isEmpty ||
                              priceController.text == '0') {
                            showSnackBar(
                                "Price", "Please enter your price", Colors.red);
                          } else {
                            if (widget.hideDraft) {
                              updateDraftListAPI(widget.myContentData!.id);
                            } else {
                              callCheckOnboardingCompleteOrNotApi();
                            }
                          }
                        }),
                      )),
                    ],
                  ),
                ),

                SizedBox(
                  height: size.width * numD04,
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
  }

  /// show-category-bottom-sheet
  void showCategoryBottomSheet(Size size) {
    showModalBottomSheet(
        context: navigatorKey.currentContext!,
        builder: (context) {
          return StatefulBuilder(builder: (context, sheetState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: size.width * numD04),
                  child: Row(
                    children: [
                      Text(
                        categoryText.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                          splashRadius: size.width * numD06,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: size.width * numD08,
                          ))
                    ],
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * numD04),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: size.width * numD04,
                    ),
                    itemBuilder: (context, index) {
                      String selectedCat = selectedCategory!.name;
                      return InkWell(
                        onTap: () {
                          int selPos = categoryList
                              .indexWhere((element) => element.selected);

                          if (selPos >= 0) {
                            categoryList[selPos].selected = false;
                          }

                          categoryList[index].selected = true;

                          if (categoryList[index].selected) {
                            if (categoryList[index].name == "Shared" ||
                                categoryList[index].name == "Exclusive") {
                              selectedSellType = categoryList[index].name;
                            }
                          }
                          selectedCategory = categoryList[index];
                          setState(() {});

                          Navigator.pop(context);
                        },
                        child: Chip(
                          label: Text(
                            categoryList[index].name,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: categoryList[index].selected
                                    ? Colors.white
                                    : colorHint,
                                fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: categoryList[index].selected
                              ? Colors.black
                              : colorLightGrey,
                        ),
                      );
                    },
                    itemCount: categoryList.length,
                  ),
                ),
              ],
            );
          });
        });
  }

  void _startAnimation() {
    setState(() {
      _showCelebrationJson = true;
      debugPrint('Animation start running');
    });
    _controller!.reset();
    _controller!.forward(from: _controller!.value);
  }

  /// choose charity bottom sheet
  void chooseCharityBottomSheet(BuildContext context, Size size) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD07),
          topRight: Radius.circular(size.width * numD07),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter stateSetter) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size.width * numD07),
                    topRight: Radius.circular(size.width * numD07),
                  ), // Optional: for rounded border
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD045,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: size.width * numD035),
                          Row(
                            children: [
                              ...[
                                Text(
                                  chooseYourCharityText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD045,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(width: size.width * numD015),
                                Image.asset(
                                  'assets/icons/ic_charity.png',
                                  height: size.width * numD06,
                                ),
                              ],
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _checkCharityBoxVal = false;
                                  });
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Colors.black,
                            thickness: 1.3,
                          ),
                          SizedBox(height: size.width * numD035),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ListView.separated(
                                  itemCount: allCharityList.length,
                                  itemBuilder: (context, index) {
                                    var item = allCharityList[index];
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        for (var item in allCharityList) {
                                          item.isSelectCharity = false;
                                        }
                                        item.isSelectCharity = true;
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
                                                ? colorGreyChat
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD03),
                                            border: Border.all(
                                                color: Colors.grey.shade300)),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: size.width * numD02,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: size.width * numD02,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD02),
                                                child: Image.network(
                                                  item.charityImage,
                                                  height: size.width * numD11,
                                                  width: size.width * numD11,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD02,
                                            ),
                                            Expanded(
                                                child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: size.width * numD01,
                                              ),
                                              child: Text(
                                                item.charityName,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize:
                                                        size.width * numD034),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      height: size.width * numD02,
                                    );
                                  },
                                ),
                                showCelebration
                                    ? Lottie.asset(
                                        "assets/lottieFiles/celebrate.json",
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          SizedBox(height: size.width * numD05),
                          Row(
                            children: [
                              Image.asset(
                                "${iconsPath}ic_donation.png",
                                height: size.width * numD06,
                                width: size.width * numD06,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: size.width * numD02),
                              Text(
                                "Choose your donation ${formatDouble(currentSliderValue)}%",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD045,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Slider(
                            value: currentSliderValue,
                            max: 100,
                            activeColor: colorThemePink,
                            inactiveColor: colorGreyChat,
                            divisions: 100,
                            label: currentSliderValue.round().toString(),
                            onChanged: (double value) {
                              currentSliderValue = value;
                              debugPrint("value:::::::$value");
                              setState(() {});
                              stateSetter(() {});
                            },
                          ),
                          SizedBox(height: size.width * numD05),
                          SizedBox(
                            width: size.width,
                            height: size.width * numD13,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorThemePink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD03),
                                ),
                              ),
                              onPressed: () {
                                bool isAnyCharitySelected = allCharityList
                                    .any((charity) => charity.isSelectCharity);
                                if (isAnyCharitySelected) {
                                  showCelebration = true;
                                  Future.delayed(const Duration(seconds: 2),
                                      () {
                                    Navigator.pop(context);
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
                                  fontSize: size.width * numD04,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.width * numD05),
                          Text(
                            thankYouForDonatingCharityText,
                            textAlign: TextAlign.center,
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD032,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: size.width * numD05),
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
        });
      },
    );
  }

  /// add pre data
  void fillExistingDataFunc() {
    debugPrint("draft::::${widget.hideDraft}:::::");
    if (widget.hideDraft) {
      locationController.text = widget.myContentData!.location;
      timestampController.text = DateFormat("hh:mm a, dd MMM yyyy")
          .format(DateTime.parse(widget.myContentData!.time));
      descriptionController.text = widget.myContentData!.textValue;
      selectedHashtagList.addAll(widget.myContentData!.hashTagList);
      debugPrint("priceValuee=====> ${widget.myContentData!.amount}");
      priceController.text = widget.myContentData!.amount.isNotEmpty
          ? "$euroUniqueCode${widget.myContentData!.amount}"
          : '';
      selectedCategory = widget.myContentData!.categoryData;
      selectedSellType =
          widget.myContentData!.exclusive ? exclusiveText : sharedText;
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

  updateDraftListAPI(String contentId) {
    Map<String, String> map = {
      'content_id': contentId,
    };

    NetworkClass.fromNetworkClass(
            removeFromDraftContentAPI, this, reqRemoveFromDraftContentAPI, map)
        .callRequestServiceHeader(true, "patch", null);
  }

  Future playSound() async {
    await controller.startPlayer();
  }

  Future pauseSound() async {
    await controller.pausePlayer();
  }

  ///--------Apis Section------------

  /// Hash Tag
  void getHashTagsApi(String searchParam) {
    Map<String, String> params = {};
    if (searchParam.trim().isNotEmpty) {
      params["tagName"] = searchParam;
      params["type"] = "hopper";
      debugPrint("GetHashTagsQueryParams: $params");
    }

    NetworkClass(getHashTagsUrl, this, getHashTagsUrlRequest)
        .callRequestServiceHeader(
            false, "get", searchParam.trim().isNotEmpty ? params : null);
  }

  /// Category
  void categoryApi() {
    NetworkClass(categoryUrl, this, categoryUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }

  void callGetShareExclusivePrice() {
    Map<String, String> map = {
      'type': 'selling_price',
    };
    NetworkClass(getAllCmsUrl, this, getAllCmsUrlRequest)
        .callRequestServiceHeader(false, "get", map);
  }

  /// add-content-api
  void callAddContentApi() {
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

    params = {
      "description": descriptionController.text.trim(),
      "location": widget.publishData != null
          ? widget.publishData!.address
          : widget.myContentData!.location,
      "latitude": widget.publishData != null
          ? widget.publishData!.latitude
          : widget.myContentData!.latitude,
      "longitude": widget.publishData != null
          ? widget.publishData!.longitude
          : widget.myContentData!.longitude,
      "tag_ids": jsonEncode(tagsIdList),
      "category_id": selectedCategory!.id,
      "type": selectedSellType == sharedText ? "shared" : "exclusive",
      "ask_price": priceController.text.isNotEmpty
          ? priceController.text
              .trim()
              .replaceAll(',', '')
              .split(euroUniqueCode)
              .last
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
          selectMediaList.add(element.media.toString());
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

    debugPrint("LocalMedia: ${filesPath.length}");
    log("AddContent Params: $params");
    log("AddContent URL: $addContentUrl");
    uploadMediaUsingDio(
      addContentUrl,
      params,
      filesPath,
      "images",
    );
    // widget.hideDraft ? [] :

    /* NetworkClass.multipartNetworkClassFiles(
        addContentUrl, this, addContentUrlRequest, params, filesPath)
        .callMultipartServiceSameParamMultiImage(true, "post", "images");*/
  }

  void callCheckOnboardingCompleteOrNotApi() {
    NetworkClass(checkOnboardingCompleteOrNotUrl, this,
            checkOnboardingCompleteOrNotReq)
        .callRequestServiceHeader(true, "get", null);
  }

  void callCharityListApi() {
    Map<String, String> map = {"limit": "10", "offset": offset.toString()};
    NetworkClass(allCharityUrl, this, allCharityReq)
        .callRequestServiceHeader(false, "get", map);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case getHashTagsUrlRequest:
          debugPrint("getHashTagsUrlRequestError: $response");
          break;
        case addContentUrlRequest:
          debugPrint("AddContent Error::::::: $response");
          var data = jsonDecode(response);
          isLoading = false;
          setState(() {});
          // if (data['errors']['msg'] == "not verified") {
          //   onBoardingCompleteDialog(
          //       size: MediaQuery.of(navigatorKey.currentContext!).size,
          //       func: () {
          //         draftSelected = true;
          //         isSelectLetsGo = true;
          //         callAddContentApi();
          //         Navigator.push(
          //             navigatorKey.currentContext!,
          //             MaterialPageRoute(
          //                 builder: (context) => AddBankScreen(
          //                       editBank: false,
          //                       myBankList: const [],
          //                       screenType: "publish",
          //                       myBankData: null,
          //                     )));
          //       });
          // }
          break;

        case checkOnboardingCompleteOrNotReq:
          debugPrint("checkOnboardingCompleteOrNotReq error: $response");
          var data = jsonDecode(response);
          if (data['message'] == "not verified") {
            callAddContentApi();
            // currently publish not required for publish content
            //if (data['message'] == "verified") {
            widget.publishData?.mediaList.forEach((media) {
              widget.myContentData?.contentMediaList.add(ContentMediaData(
                  "",
                  media.mediaPath,
                  media.mimeType,
                  media.thumbnail,
                  media.thumbnail));
            });
            Navigator.push(
                navigatorKey.currentContext!,
                MaterialPageRoute(
                    builder: (context) => ContentSubmittedScreen(
                          myContentDetail: widget.myContentData,
                          publishData: widget.publishData,
                          sellType: selectedSellType,
                          price: priceController.text,
                        )));
            // onBoardingCompleteDialog(
            //     size: MediaQuery.of(navigatorKey.currentContext!).size,
            //     func: () {
            //       Navigator.pop(navigatorKey.currentContext!);
            //       draftSelected = true;
            //       isSelectLetsGo = true;
            //       callAddContentApi();
            //       Future.delayed(const Duration(milliseconds: 500), () {
            //         Navigator.push(
            //             navigatorKey.currentContext!,
            //             MaterialPageRoute(
            //                 builder: (context) => AddBankScreen(
            //                       editBank: false,
            //                       myBankList: const [],
            //                       screenType: "publish",
            //                       myBankData: null,
            //                     )));
            //       });
            //     });
          }
          break;

        case getAllCmsUrlRequest:
          debugPrint("getAllCmsUrlRequestError===>: $response");
          break;
        case allCharityReq:
          debugPrint("allCharityReq error::::::: $response");
          break;
        case multipleImageReq:
          debugPrint("multipleImageReq error::::::: $response");
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case getHashTagsUrlRequest:
          var map = jsonDecode(response);
          log("GetHashTags: $response");
          if (map["code"] == 200) {
            var list = map["tags"] as List;
            hashtagList = list.map((e) => HashTagData.fromJson(e)).toList();
            setState(() {});
          }

          break;
        case categoryUrlRequest:
          var map = jsonDecode(response);
          log("CategoryData:$response");
          if (map["code"] == 200) {
            var list = map["categories"] as List;

            categoryList =
                list.map((e) => CategoryDataModel.fromJson(e)).toList();

            if (categoryList.isNotEmpty) {
              dropDownValue = categoryList.first.name;
              selectedCategory = categoryList.first;
              selectedCategory!.selected = true;
              categoryList.first.selected = true;
            }

            /// if coming from drafts then select the previous selected category
            selectedCategoryFunc();
            if (mounted) {
              setState(() {});
            }
          }

          break;
        case addContentUrlRequest:
          log("AddContentResponse: $response");
          var map = jsonDecode(response);
          MyContentData detail = MyContentData.fromJson(map["data"] ?? {});

          if (detail.toString().isNotEmpty) {
            debugPrint('Draft-selected::::::::::$draftSelected');
            debugPrint('isSaveDraftFromTask:::::::::$isSaveDraftFromTask');

            /*if (draftSelected) {
              */
            /*  Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => MyDraftScreen(
                            publishedContent: true,
                          )),
                  (route) => false);*/
            /*

              draftSelected = false;
              if (!isSaveDraftFromTask) {
                Navigator.push(
                    navigatorKey.currentContext!,
                    MaterialPageRoute(
                        builder: (context) => Dashboard(initialPosition: 2)));
                showSnackBar("Draft", "Draft successfully saved", Colors.green);
              }
              else if (draftSelected && isSelectLetsGo) {
                Navigator.push(
                    navigatorKey.currentContext!,
                    MaterialPageRoute(
                        builder: (context) => AddBankScreen(
                              editBank: false,
                              myBankList: const [],
                              screenType: "publish",
                              myBankData: null,
                            )));
              }
              else {
                isSaveDraftFromTask = false;
                debugPrint(":::Draft successfully saved:::::::::");
              }
            }
            else {
              //  Navigator.pop(navigatorKey.currentContext!);
              Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => ContentSubmittedScreen(
                            myContentDetail: detail,
                          )),
                  (route) => false);
            }
          } else {
            Navigator.pop(navigatorKey.currentContext!);
          }*/

            if (!isSaveDraftFromTask) {
              Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)));
              showSnackBar("Draft", "Draft successfully saved", Colors.green);
            } else {
              /*Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          ContentSubmittedScreen(
                            myContentDetail: detail,
                          )),
                      (route) => false);*/
              Navigator.push(
                  navigatorKey.currentContext!,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)));
            }
          }
          isLoading = true;
          setState(() {});
          break;

        case checkOnboardingCompleteOrNotReq:
          debugPrint("checkOnboardingCompleteOrNotReq success: $response");
          var data = jsonDecode(response);
          callAddContentApi();
          // currently publish not required for publish content
          //if (data['message'] == "verified") {
          widget.publishData?.mediaList.forEach((media) {
            widget.myContentData?.contentMediaList.add(ContentMediaData(
                "",
                media.mediaPath,
                media.mimeType,
                media.thumbnail,
                media.thumbnail));
          });
          Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(
                  builder: (context) => ContentSubmittedScreen(
                        myContentDetail: widget.myContentData,
                        publishData: widget.publishData,
                        sellType: selectedSellType,
                        price: priceController.text,
                      )));

          break;

        case getAllCmsUrlRequest:
          log("getAllCmsUrlRequest======>: $response");
          var data = jsonDecode(response);

          sharedPrice = data['status']['shared'] ?? '';
          exclusivePrice = data['status']['exclusive'] ?? '';
          setState(() {});
          break;

        case reqRemoveFromDraftContentAPI:
          log("reqRemoveFromDraftContentAPI===> ${jsonDecode(response)}");
          callCheckOnboardingCompleteOrNotApi();

          break;
        case allCharityReq:
          debugPrint("allCharityReq success::::::: $response");
          var data = jsonDecode(response);
          var dataModel = data['data'] as List;
          allCharityList =
              dataModel.map((e) => AllCharityModel.fromJson(e)).toList();
          setState(() {});

          break;

        case multipleImageReq:
          debugPrint("multipleImageReq suucess::::::: $response");
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  ///---------------------------------------------------------------------------
  /// INTERFACE CLASS OVERRIDE METHOD
  @override
  void saveDraft() {
    debugPrint("saveDraft:::::::Interface:::");

    FocusScope.of(navigatorKey.currentContext!).requestFocus(FocusNode());
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
}

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
