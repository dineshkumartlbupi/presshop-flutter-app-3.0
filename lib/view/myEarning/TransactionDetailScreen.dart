import 'dart:io';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonWigdets.dart';
import '../dashboard/Dashboard.dart';
import '../menuScreen/PublicationListScreen.dart';
import 'earningDataModel.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String type;
  bool shouldShowPublication = false;
  EarningTransactionDetail? transactionData;

  TransactionDetailScreen(
      {super.key,
      required this.type,
      required this.transactionData,
      this.shouldShowPublication = false});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Size size;
  PageController pageController = PageController();
  PlayerController controller = PlayerController();
  FlickManager? flickManager;
  int _currentMediaIndex = 0;
  int feedIndex = 0;
  bool audioPlaying = false;

  @override
  void initState() {
    debugPrint("type::::::::${widget.type}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(transactionDetailsText,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize,
            )),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * numD05,
              vertical: size.width * numD05,
            ),
            child: Column(
              children: [
                widget.type == "pending"
                    ? pendingPaymentWidget()
                    : receivedPaymentWidget(),
                SizedBox(height: size.width * numD02),
                if (widget.shouldShowPublication) ...[
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PublicationListScreen(
                                contentId: widget.transactionData!.contentId,
                                contentType:
                                    widget.transactionData!.contentType,
                                publicationCount: "")));
                      },
                      child: Text(
                        viewPublicationsPurchasedText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD033,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                Text(
                  "*Your payment has been successfully processed from our end. Please note, it may take 2-3 business days to appear in your account due to bank processing times.",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD033,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget receivedPaymentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * numD02),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: colorThemePink,
                        borderRadius:
                            BorderRadius.circular(size.width * numD015)),
                    child: Row(
                      children: [
                        Text(
                          receivedText,
                          style: TextStyle(
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: "AirbnbCereal"),
                        ),
                        SizedBox(width: 6),
                        Text(
                          widget.transactionData!.payableT0Hopper != "null"
                              ? "£${formatDouble(double.parse(widget.transactionData!.payableT0Hopper))}"
                              : "",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD03),
                    child: Image.network(
                        avatarImageUrl + widget.transactionData!.hopperAvatar,
                        height: size.width * numD11,
                        width: size.width * numD12,
                        fit: BoxFit.cover,
                        errorBuilder: (context, i, b) => Image.asset(
                              "${commonImagePath}no_image.jpg",
                              fit: BoxFit.cover,
                              height: size.width * numD11,
                              width: size.width * numD12,
                            )),
                  )
                ],
              ),
              SizedBox(
                height: size.width * numD03,
              ),
              SizedBox(
                height: size.width * numD40,
                child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      _currentMediaIndex = value;
                      if (flickManager != null) {
                        flickManager?.dispose();
                        flickManager = null;
                      }
                      initialController(_currentMediaIndex);
                      setState(() {});
                    },
                    itemCount: widget.transactionData!.contentDataList.length,
                    itemBuilder: (context, idx) {
                      var item = widget.transactionData!.contentDataList[idx];
                      return ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: Stack(
                          children: [
                            item.mediaType == "audio"
                                ? playAudioWidget(size)
                                : item.mediaType == "video"
                                    ? videoWidget()
                                    : Image.network(
                                        item.mediaType == "video"
                                            ? "$contentImageUrl${item.thumbnail}"
                                            : "$contentImageUrl${item.media}",
                                        width: size.width,
                                        fit: BoxFit.cover,
                                      ),
                            Positioned(
                              right: size.width * numD02,
                              top: size.width * numD02,
                              child: Column(
                                children: getMediaCount2(
                                    widget.transactionData!.contentDataList,
                                    size),
                              ),
                            ),
                            /*Positioned(
                              right: size.width * numD02,
                              bottom: size.width * numD02,
                              child: Visibility(
                                visible: widget.transactionData!.contentDataList
                                        .length >
                                    1,
                                child: Text(
                                  "+${widget.transactionData!.contentDataList.length}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD04,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),*/
                            item.mediaType == "image"
                                ? Image.asset(
                                    "${commonImagePath}watermark1.png",
                                    width: size.width,
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    }),
              ),
              SizedBox(
                height: size.width * numD013,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * numD01),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   widget.transactionData!.contentTitle,
                    //   style: commonTextStyle(
                    //       size: size,
                    //       fontSize: size.width * numD035,
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w500),
                    // ),
                    widget.transactionData!.contentDataList.length > 1
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: DotsIndicator(
                              dotsCount: widget
                                  .transactionData!.contentDataList.length,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.transactionData!.type == "content"
                              ? contentSoldText
                              : taskCompletedText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        widget.transactionData!.type == "content"
                            ? Row(
                                children: [
                                  Image.asset(
                                    widget.transactionData!.typesOfContent
                                        ? "${iconsPath}ic_exclusive.png"
                                        : "${iconsPath}ic_share.png",
                                    height:
                                        widget.transactionData!.typesOfContent
                                            ? size.width * numD03
                                            : size.width * numD04,
                                    color: colorTextFieldIcon,
                                  ),
                                  SizedBox(
                                    width: size.width * numD02,
                                  ),
                                  Text(
                                    widget.transactionData!.typesOfContent
                                        ? "Exclusive"
                                        : "Shared",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Image.asset(
                                    "${iconsPath}ic_task.png",
                                    width: size.width * numD05,
                                  ),
                                  SizedBox(
                                    width: size.width * numD02,
                                  ),
                                  Text(
                                    "Yes",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),

                    /// Payment date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateOfSaleText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          /* widget.transactionData!.createdAT.isNotEmpty
                          ? DateFormat('dd MMMM,yyyy').format(
                              DateTime.parse(widget.transactionData!.createdAT))
                          : '',*/
                          widget.transactionData!.createdAT,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          paymentDateText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          /* widget.transactionData!.createdAT.isNotEmpty
                          ? DateFormat('dd MMMM,yyyy').format(
                              DateTime.parse(widget.transactionData!.createdAT))
                          : '',*/
                          widget.transactionData!.createdAT,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),

                    /// Payment made time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          paymentMadeTimeText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          /* widget.transactionData!.createdAT.isNotEmpty
                          ? DateFormat('hh:mm a').format(
                              DateTime.parse(widget.transactionData!.createdAT))
                          : '',*/

                          dateTimeFormatter(
                              dateTime: widget.transactionData!.createdAT,
                              time: true,
                              format: "hh:mm a"),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),

                    /// Transaction ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transactionIdText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          widget.transactionData!.id,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: size.width * numD1,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * numD01,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: widget.transactionData!.hopperBankLogo.isEmpty
                          ? Image.asset("assets/commonImages/no_image.jpg")
                          : Image.network(
                              widget.transactionData!.hopperBankLogo),
                    ),
                    SizedBox(width: 8),
                    Text(
                      widget.transactionData!.hopperBankName,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                    // SizedBox(
                    //   height: size.width * numD01,
                    // ),
                    // Text(
                    //   widget.transactionData!.adminFullName,
                    //   style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400),
                    // ),
                  ],
                ),
              ),

              /// Divider
              Padding(
                padding: EdgeInsets.only(top: size.width * numD01),
                child: const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),

              /// to
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD025,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "${widget.transactionData!.userFirstName} ${widget.transactionData!.userLastName}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// From
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fromText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      // "${widget.transactionData!.adminFullName} ",
                      "PressHop Media UK Limited",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Divider
              Padding(
                padding: EdgeInsets.only(top: size.width * numD01),
                child: const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),

              /// Payment Summary
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Text(
                  paymentSummaryText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD03,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),

              /// Offered amount
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // "Total earnings from sold content"
                      "Content sold for",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.totalEarningAmt != "null"
                          ? "£ ${formatDouble(double.parse(widget.transactionData!.totalEarningAmt))}"
                          : "£ 0",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// PressHop fees
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      presshopCommissionText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£ ${formatDouble(double.parse(widget.transactionData!.payableCommission))}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      processingFeeText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£ ${formatDouble(double.parse(widget.transactionData!.stripefee))}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Amount paid
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nett amount received by you",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.payableT0Hopper != "null"
                          ? "£ ${formatDouble(double.parse(widget.transactionData!.payableT0Hopper))}"
                          : "",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  void initialController(currentMediaIndex) {
    if (widget.transactionData!.contentDataList[currentMediaIndex].mediaType ==
        "audio") {
      initWaveData(contentImageUrl +
          widget.transactionData!.contentDataList[currentMediaIndex].media);
    } else if (widget
            .transactionData!.contentDataList[currentMediaIndex].mediaType ==
        "video") {
      debugPrint(
          "videoLink=====> ${widget.transactionData!.contentDataList[currentMediaIndex].media}");
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(contentImageUrl +
              widget.transactionData!.contentDataList[currentMediaIndex].media),
        ),
        autoPlay: false,
      );
    }
    setState(() {});
  }

  Widget playAudioWidget(size) {
    return Container(
      width: size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size.width * numD04),
      decoration: BoxDecoration(
        border: Border.all(color: colorGreyNew),
        color: colorThemePink,
        borderRadius: BorderRadius.circular(size.width * numD06),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // SizedBox(
          //   height: size.width * numD05,
          // ),
          // AudioFileWaveforms(
          //   size: Size(size.width, size.width * numD15),
          //   playerController: controller,
          //   enableSeekGesture: true,
          //   waveformType: WaveformType.long,
          //   continuousWaveform: true,
          //   playerWaveStyle: PlayerWaveStyle(
          //     fixedWaveColor: Colors.black,
          //     liveWaveColor: colorThemePink,
          //     spacing: 6,
          //     liveWaveGradient: ui.Gradient.linear(
          //       const Offset(70, 50),
          //       Offset(MediaQuery.of(context).size.width / 2, 0),
          //       [Colors.red, Colors.green],
          //     ),
          //     fixedWaveGradient: ui.Gradient.linear(
          //       const Offset(70, 50),
          //       Offset(MediaQuery.of(context).size.width / 2, 0),
          //       [Colors.red, Colors.green],
          //     ),
          //     seekLineColor: colorThemePink,
          //     seekLineThickness: 2,
          //     showSeekLine: true,
          //     showBottom: true,
          //   ),
          // ),
          // const Spacer(),
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
            onTap: () async {
              if (!audioPlaying) {
                await controller.startPlayer();
              } else {
                await controller.pausePlayer(); // Start audio player
              }
              audioPlaying = !audioPlaying;
              setState(() {});
            },
            child: Icon(
              audioPlaying ? Icons.pause : Icons.play_arrow_rounded,
              color: Colors.white,
              size: size.width * numD1,
            ),
          ),
          // Image.asset(
          //   "${commonImagePath}watermark1.png",
          //   height: 500,
          //   width: 500,
          //   fit: BoxFit.cover,
          // ),
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

  Widget pendingPaymentWidget() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: size.width * numD025,
                      bottom: size.width * numD02,
                      left: size.width * numD03,
                      right: size.width * numD03,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(size.width * numD015),
                        border: Border.all(
                            color: const Color(0xFFAEB4B3), width: 1)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pendingText,
                          style: TextStyle(
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontFamily: "AirbnbCereal"),
                        ),
                        Text(
                          " £ ${formatDouble(double.parse(widget.transactionData!.payableT0Hopper))}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * numD03),
                    child: Image.network(widget.transactionData!.companyLogo,
                        height: size.width * numD11,
                        width: size.width * numD12,
                        fit: BoxFit.cover,
                        errorBuilder: (context, i, b) => Image.asset(
                              "${dummyImagePath}news.png",
                              fit: BoxFit.cover,
                              height: size.width * numD11,
                              width: size.width * numD12,
                            )),
                  )
                ],
              ),

              SizedBox(
                height: size.width * numD03,
              ),

              SizedBox(
                height: size.width * numD40,
                child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      _currentMediaIndex = value;
                      if (flickManager != null) {
                        flickManager?.dispose();
                        flickManager = null;
                      }
                      initialController(_currentMediaIndex);
                      setState(() {});
                    },
                    itemCount: widget.transactionData!.contentDataList.length,
                    itemBuilder: (context, idx) {
                      var item = widget.transactionData!.contentDataList[idx];
                      return ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: InkWell(
                          onTap: () {
                            if (item.mediaType == "pdf" ||
                                item.mediaType == "doc") {
                              openUrl(contentImageUrl + item.media);
                            }
                          },
                          child: Stack(
                            children: [
                              /* item.mediaType == "audio"
                                  ? playAudioWidget(size)
                                  : item.mediaType == "video"
                                      ? videoWidget()
                                      : Image.network(
                                          item.mediaType == "video"
                                              ? "$contentImageUrl${item.thumbnail}"
                                              : "$contentImageUrl${item.media}",
                                          width: size.width,
                                          fit: BoxFit.cover,
                                        ),*/

                              item.mediaType == "audio"
                                  ? playAudioWidget(size)
                                  : item.mediaType == "video"
                                      ? videoWidget()
                                      : item.mediaType == "pdf"
                                          ? Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * numD04),
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
                                                  item.mediaType == "video"
                                                      ? "$contentImageUrl${item.thumbnail}"
                                                      : "$contentImageUrl${item.media}",
                                                  width: size.width,
                                                  fit: BoxFit.cover,
                                                ),
                              Positioned(
                                right: size.width * numD02,
                                top: size.width * numD02,
                                child: Column(
                                  children: getMediaCount2(
                                      widget.transactionData!.contentDataList,
                                      size),
                                ),
                              ),
                              /* Positioned(
                                right: size.width * numD02,
                                bottom: size.width * numD02,
                                child: Visibility(
                                  visible: widget.transactionData!
                                          .contentDataList.length >
                                      1,
                                  child: Text(
                                    "+${widget.transactionData!.contentDataList.length}",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),*/
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
                      );
                    }),
              ),

              widget.transactionData!.contentDataList.length > 1
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: DotsIndicator(
                        dotsCount:
                            widget.transactionData!.contentDataList.length,
                        position: _currentMediaIndex,
                        decorator: const DotsDecorator(
                          color: Colors.grey, // Inactive color
                          activeColor: Colors.redAccent,
                        ),
                      ),
                    )
                  : Container(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD01,
                ).copyWith(
                  top: size.width * numD025,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        widget.transactionData!.type == "content"
                            ? contentSoldText
                            : taskCompletedText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400)),
                    widget.transactionData!.type == "content"
                        ? Row(
                            children: [
                              Image.asset(
                                widget.transactionData!.typesOfContent
                                    ? "${iconsPath}ic_exclusive.png"
                                    : "${iconsPath}ic_share.png",
                                height: widget.transactionData!.typesOfContent
                                    ? size.width * numD04
                                    : size.width * numD05,
                                color: colorTextFieldIcon,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Text(
                                widget.transactionData!.typesOfContent
                                    ? "Exclusive"
                                    : "Shared",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Image.asset(
                                "${iconsPath}ic_task.png",
                                width: size.width * numD05,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Text(
                                "Yes",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              /// Date of sale
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateOfSaleText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.createdAT,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: size.width * numD1,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * numD03,
            vertical: size.width * numD03,
          ),
          decoration: BoxDecoration(
              color: colorLightGrey,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 0,
                    spreadRadius: 0.5)
              ],
              borderRadius: BorderRadius.circular(size.width * numD03),
              border: Border.all(width: 1, color: Colors.black)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Payment Summary
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Text(
                  paymentSummaryText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD042,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),

              /// Divider
              Padding(
                padding: EdgeInsets.only(top: size.width * numD01),
                child: const Divider(
                  thickness: 1,
                  color: Colors.white,
                ),
              ),

              /// Your earnings
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total earnings for sold content" /*yourEarningsText*/,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.totalEarningAmt != "null"
                          ? "£ ${formatDouble(double.parse(widget.transactionData!.totalEarningAmt))}"
                          : "£ 0",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// PressHop fees
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      presshopCommissionText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£ ${formatDouble(double.parse(widget.transactionData!.payableCommission))}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      processingFeeText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      widget.transactionData!.stripefee.isNotEmpty
                          ? "£ ${formatDouble(double.parse(widget.transactionData!.stripefee))}"
                          : "£ 0",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              /// Amount pending
              Padding(
                padding: EdgeInsets.only(
                  top: size.width * numD02,
                  left: size.width * numD01,
                  right: size.width * numD01,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Nett amount pending",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      "£ ${formatDouble(double.parse(widget.transactionData!.payableT0Hopper))}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                    left: size.width * numD01, top: size.width * numD02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      paymentDueDateText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    Text(
                      dateTimeFormatter(
                          dateTime: widget.transactionData!.dueDate,
                          format: "dd MMM yyyy"),
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
