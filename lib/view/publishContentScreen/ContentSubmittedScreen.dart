import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/authentication/TermCheckScreen.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/menuScreen/ContactUsScreen.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:presshop/view/myEarning/MyEarningScreen.dart';
import '../cameraScreen/PreviewScreen.dart';
import '../menuScreen/MyContentScreen.dart';
import '../menuScreen/MyDraftScreen.dart';

class ContentSubmittedScreen extends StatefulWidget {
  MyContentData? myContentDetail;
  PublishData? publishData;
  String price = "";
  String sellType = "";

  ContentSubmittedScreen({
    super.key,
    required this.myContentDetail,
    required this.publishData,
    required this.price,
    required this.sellType,
  });

  @override
  State<StatefulWidget> createState() {
    return ContentSubmittedScreenState();
  }
}

class ContentSubmittedScreenState extends State<ContentSubmittedScreen> {
  String selectedSellType = sharedText;
  int imageCount = 0;
  int videoCount = 0;
  int audioCount = 0;
  int docCount = 0;
  int pdfCount = 0;

  @override
  void initState() {
    super.initState();
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

    if (widget.myContentDetail != null) {
      for (var media in widget.myContentDetail!.contentMediaList) {
        debugPrint(" mediaType::::::::${media.mediaType}");

        if (media.mediaType == 'image') imageCount++;
        if (media.mediaType == 'video') videoCount++;
        if (media.mediaType == 'audio') audioCount++;
        if (media.mediaType == 'doc') docCount++;
        if (media.mediaType == 'pdf') pdfCount++;
      }
    }
  }

  @override
  void dispose() {
    debugPrint("widget.sellType::::::${widget.sellType}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)));
        return Future.value(false);
      },
      child: Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: true,
            title: Text(
              contentSubmittedText,
              style: commonTextStyle(size: size, color: Colors.black, fontSize: size.width * appBarHeadingFontSize, fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            titleSpacing: size.width * numD04,
            size: size,
            showActions: true,
            leadingFxn: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)));
            },
            actionWidget: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)));
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
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD04),
                    decoration: BoxDecoration(color: colorLightGrey, borderRadius: BorderRadius.circular(size.width * numD04)),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.myContentDetail != null
                                ? Expanded(
                                    child: Container(
                                      height: size.width * numD35,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(size.width * numD06),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(size.width * numD06),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            showImage(
                                              widget.myContentDetail!.contentMediaList[0].mediaType,
                                              widget.myContentDetail!.contentMediaList[0].mediaType == "video" ? widget.myContentDetail!.contentMediaList[0].thumbNail : widget.myContentDetail!.contentMediaList[0].media,
                                            ),
                                            Visibility(
                                              visible: widget.myContentDetail!.contentMediaList[0].mediaType != "audio",
                                              child: Container(
                                                  color: Colors.black.withOpacity(0.2),
                                                  child: Image.asset(
                                                    "${commonImagePath}watermark1.png",
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                            Positioned(
                                              right: size.width * numD02,
                                              top: size.width * numD02,
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: size.width * numD015,
                                                    vertical: size.width * 0.005,
                                                  ),
                                                  decoration: BoxDecoration(color: colorLightGreen.withOpacity(0.8), borderRadius: BorderRadius.circular(size.width * numD015)),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        "${widget.myContentDetail!.contentMediaList.length} ",
                                                        style: commonTextStyle(size: size, fontSize: size.width * numD038, color: Colors.white, fontWeight: FontWeight.w600),
                                                      ),
                                                      const Padding(padding: EdgeInsets.only(left: 2, bottom: 2)),
                                                      Image.asset(
                                                          widget.myContentDetail!.contentMediaList.first.mediaType == "image"
                                                              ? "${iconsPath}ic_camera_publish.png"
                                                              : widget.myContentDetail!.contentMediaList.first.mediaType == "video"
                                                                  ? "${iconsPath}ic_v_cam.png"
                                                                  : widget.myContentDetail!.contentMediaList.first.mediaType == "audio"
                                                                      ? "${iconsPath}ic_mic.png"
                                                                      : "${iconsPath}doc_icon.png",
                                                          color: Colors.white,
                                                          height: widget.myContentDetail!.contentMediaList.first.mediaType == "image"
                                                              ? size.width * 0.029
                                                              : widget.myContentDetail!.contentMediaList.first.mediaType == "video"
                                                                  ? size.width * 0.041
                                                                  : widget.myContentDetail!.contentMediaList.first.mediaType == "audio"
                                                                      ? size.width * 0.028
                                                                      : size.width * 0.04,
                                                          fit: BoxFit.contain),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(size.width * numD03),
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Visibility(
                                          visible: widget.publishData!.mimeType.contains("doc"),
                                          child: Container(
                                            padding: EdgeInsets.all(size.width * numD01),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: colorGreyNew),
                                              borderRadius: BorderRadius.circular(size.width * numD06),
                                            ),
                                            child: Image.asset(
                                              "${dummyImagePath}doc_black_icon.png",
                                              width: size.width * numD30,
                                              height: size.width * numD35,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mimeType.contains("pdf"),
                                          child: Container(
                                            padding: EdgeInsets.all(size.width * numD01),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: colorGreyNew),
                                              borderRadius: BorderRadius.circular(size.width * numD06),
                                            ),
                                            child: Image.asset(
                                              "${dummyImagePath}pngImage.png",
                                              width: size.width * numD30,
                                              height: size.width * numD35,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mediaList.first.mimeType == "audio",
                                          child: Container(
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            padding: EdgeInsets.all(size.width * numD01),
                                            decoration: BoxDecoration(
                                              color: colorThemePink,
                                              border: Border.all(color: colorGreyNew),
                                              borderRadius: BorderRadius.circular(size.width * numD04),
                                            ),
                                            child: Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: size.width * numD15,
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mediaList.first.mimeType == "video",
                                          child: Image.file(
                                            File(widget.publishData!.mediaList.first.thumbnail),
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Visibility(
                                          visible: widget.publishData!.mediaList.first.mimeType == "image",
                                          child: Image.file(
                                            File(widget.publishData!.mediaList.first.mediaPath),
                                            width: size.width * numD30,
                                            height: size.width * numD35,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Image.asset(
                                          "${commonImagePath}watermark1.png",
                                          width: size.width * numD30,
                                          height: size.width * numD35,
                                          fit: BoxFit.cover,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: size.width * numD02, bottom: size.width * numD02, right: size.width * numD02),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(size.width * numD013)),
                                                child: Row(
                                                  children: [
                                                    Text((imageCount+videoCount+audioCount).toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w600)),
                                                  ],
                                                ),
                                              ),
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
                                              //                 color:Colors.white,
                                              //                 size:size.width * numD037),*/
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
                                    /*widget.publishData != null
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
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .mimeType ==
                                                            "video" ||
                                                        widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .mimeType ==
                                                            "audio"
                                                    ? 0
                                                    : size.width * 0.005,
                                                vertical: widget
                                                            .publishData!
                                                            .mediaList
                                                            .first
                                                            .mimeType ==
                                                        "video"
                                                    ? size.width * 0.005
                                                    : widget
                                                                .publishData!
                                                                .mediaList
                                                                .first
                                                                .mimeType ==
                                                            "audio"
                                                        ? size.width * 0.009
                                                        : size.width * 0.01),
                                            child: Image.asset(
                                              widget.publishData!.mediaList
                                                          .first.mimeType ==
                                                      "image"
                                                  ? "${iconsPath}ic_camera_publish.png"
                                                  : widget
                                                              .publishData!
                                                              .mediaList
                                                              .first
                                                              .mimeType ==
                                                          "video"
                                                      ? "${iconsPath}ic_v_cam.png"
                                                      : widget
                                                                  .publishData!
                                                                  .mediaList
                                                                  .first
                                                                  .mimeType ==
                                                              "audio"
                                                          ? "${iconsPath}ic_mic.png"
                                                          : "${iconsPath}doc_icon.png",
                                              color: Colors.white,
                                              height: widget
                                                          .publishData!
                                                          .mediaList
                                                          .first
                                                          .mimeType ==
                                                      "video"
                                                  ? size.width * numD09
                                                  : widget
                                                              .publishData!
                                                              .mediaList
                                                              .first
                                                              .mimeType ==
                                                          "image"
                                                      ? size.width * numD05
                                                      : size.width * numD08,
                                            ),
                                          )),
                                    )
                                  : const SizedBox.shrink(),*/
                                    /*
                              */
                                    /*   widget.publishData != null
                                  ? Positioned.fill(
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * numD01,
                                              vertical: size.width * 0.002),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD015)),
                                          child: GridView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 4,
                                              ),
                                              itemCount: widget.publishData!
                                                  .mediaList.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Padding(
                                                  padding: EdgeInsets.all(
                                                      size.width * numD015),
                                                  child: Image.asset(
                                                    widget.publishData!
                                                                .mediaList[index]
                                                                .mimeType ==
                                                            "image"
                                                        ?"${iconsPath}ic_camera_publish.png"
                                                        :widget.publishData!.mediaList[index]
                                                                    .mimeType ==
                                                                "video"
                                                            ? "${iconsPath}ic_v_cam.png"
                                                            : widget.publishData!
                                                                        .mediaList[
                                                                            index]
                                                                        .mimeType ==
                                                                    "audio"
                                                                ? "${iconsPath}ic_mic.png"
                                                                : "${iconsPath}doc_icon.png",
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    height: widget
                                                                .publishData!
                                                                .mediaList[
                                                                    index]
                                                                .mimeType ==
                                                            "video"
                                                        ? size.width * numD09
                                                        : widget
                                                                    .publishData!
                                                                    .mediaList[
                                                                        index]
                                                                    .mimeType ==
                                                                "image"
                                                            ? size.width *
                                                                numD05
                                                            : size.width *
                                                                numD08,
                                                  ),
                                                );
                                              })),
                                    )
                                  : const SizedBox.shrink(),*/
                                    /*
                            ),
                            ),*/
                                  ),
                            SizedBox(
                              width: size.width * numD04,
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: size.width * numD04),
                                child: Text(
                                  contentSubmittedHeadingText,
                                  style: commonTextStyle(size: size, fontSize: size.width * numD038, color: Colors.black, fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: size.width * numD15,
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(size.width * numD04)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ImageIcon(
                                      AssetImage(widget.sellType == "Shared" ? "${iconsPath}ic_share.png" : "${iconsPath}ic_exclusive.png"),
                                      size: size.width * numD06,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      widget.sellType == "Shared" ? "Shared" : "Exclusive",
                                      style: commonTextStyle(size: size, fontSize: size.width * numD04, color: Colors.white, fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * numD06,
                            ),
                            Expanded(
                              child: Container(
                                height: size.width * numD15,
                                decoration: BoxDecoration(color: colorThemePink, borderRadius: BorderRadius.circular(size.width * numD04)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      amountQuoted,
                                      style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.normal),
                                    ),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),
                                    Text(
                                      widget.price,
                                      //   "$euroUniqueCode ${amountFormat(widget.myContentDetail!.originalAmount.toString())}",
                                      style: commonTextStyle(size: size, fontSize: size.width * numD045, color: Colors.white, fontWeight: FontWeight.w700),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(children: [
                        TextSpan(
                          text: "$contentSubmittedMessageText ",
                          style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.normal),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TermCheckScreen(
                                          type: 'legal',
                                        )));
                          },
                          child: Text(
                            "${privacyLawText.toLowerCase()} ",
                            style: commonTextStyle(size: size, fontSize: size.width * numD03, color: colorThemePink, fontWeight: FontWeight.w600),
                          ),
                        )),
                        TextSpan(
                          text: " $contentSubmittedMessage1Text\n\n",
                          style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.normal, lineHeight: 1.5),
                        ),
                        TextSpan(
                          text: "$contentSubmittedMessage2Text ",
                          style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.normal, lineHeight: 1.5),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FAQScreen(
                                          priceTipsSelected: false,
                                          type: 'faq',
                                          index: 0,
                                        )));
                          },
                          child: Text(
                            faqText,
                            style: commonTextStyle(size: size, fontSize: size.width * numD03, color: colorThemePink, fontWeight: FontWeight.w600),
                          ),
                        )),
                        TextSpan(
                          text: " $orText ",
                          style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                        WidgetSpan(
                            child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
                          },
                          child: Text(
                            "${contactText.toLowerCase()} ",
                            style: commonTextStyle(size: size, fontSize: size.width * numD03, color: colorThemePink, fontWeight: FontWeight.w600),
                          ),
                        )),
                        TextSpan(
                          text: "$contentSubmittedMessage3Text ",
                          style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                      ])),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(myContentText.toTitleCase(), size, commonButtonTextStyle(size), commonButtonStyle(size, Colors.black), () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => Dashboard(
                                        initialPosition: 0,
                                      )),
                              (route) => false);
                        }),
                      )),
                      SizedBox(
                        width: size.width * numD04,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton("Home", size, commonButtonTextStyle(size), commonButtonStyle(size, colorThemePink), () {
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
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
          )),
    );
  }

  Widget showImage(String type, String url) {
    return type == "audio"
        ? Icon(
            Icons.play_circle,
            color: colorThemePink,
            size: MediaQuery.of(context).size.width * numD15,
          )
        : type == "pdf"
            ? Image.asset(
                "${dummyImagePath}pngImage.png",
                fit: BoxFit.contain,
              )
            : type == "doc"
                ? Image.asset(
                    "${dummyImagePath}doc_black_icon.png",
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    "$imageUrlBefore$url",
                    fit: BoxFit.cover,
                  );
  }
}
