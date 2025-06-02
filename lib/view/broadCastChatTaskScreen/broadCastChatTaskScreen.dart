import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/cameraScreen/AudioWaveFormWidgetScreen.dart';

import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/VideoWidget.dart';
import '../../utils/commonEnums.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../authentication/TermCheckScreen.dart';
import '../cameraScreen/CameraScreen.dart';
import '../cameraScreen/PreviewScreen.dart';
import '../chatScreens/FullVideoView.dart';
import '../dashboard/Dashboard.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../menuScreen/ContactUsScreen.dart';
import '../myEarning/MyEarningScreen.dart';
import '../myEarning/TransactionDetailScreen.dart';
import '../myEarning/earningDataModel.dart';
import 'package:video_player/video_player.dart';
import 'package:location/location.dart' as lc;

class BroadCastChatTaskScreen extends StatefulWidget {
  final TaskDetailModel? taskDetail;
  final String roomId;

  const BroadCastChatTaskScreen(
      {super.key, required this.taskDetail, required this.roomId});

  @override
  State<BroadCastChatTaskScreen> createState() =>
      _BroadCastChatTaskScreenState();
}

class _BroadCastChatTaskScreenState extends State<BroadCastChatTaskScreen>
    implements NetworkResponse {
  List<ManageTaskChatModel> chatList = [];
  late IO.Socket socket;
  final String _senderId = sharedPreferences!.getString(hopperIdKey) ?? "";
  TextEditingController ratingReviewController1 = TextEditingController();
  List<String> intList = [
    "User experience",
    "Safe",
    "Easy to use",
    "Instant money",
    "Anonymity",
    "Secure Payment",
    "Hopper Support"
  ];
  List<int> indexList = [];
  List<String> dataList = [];
  List<MediaData> selectMultipleMediaList = [];
  List<EarningTransactionDetail> earningTransactionDataList = [];
  double ratings = 0.0;
  int currentPage = 0;
  bool isRequiredVisible = false;
  bool isRatingGiven = false;
  bool showCelebration = false;
  bool isLoading = false;
  String imageId = "", chatId = "", contentView = "", contentPurchased = "";
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;
  lc.LocationData? locationData;
  lc.Location location = lc.Location();
  double latitude = 0, longitude = 0;
  String address = "";

  @override
  void initState() {
    debugPrint("class name :::$runtimeType");
    super.initState();
    socketConnectionFunc();
    callGetManageTaskListingApi();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    try {
      locationData = await location.getLocation();
      debugPrint("GettingLocation ==> $locationData");
      if (locationData != null) {
        debugPrint("NotNull");
        if (locationData!.latitude != null) {
          latitude = locationData!.latitude!;
          longitude = locationData!.longitude!;
          GeoData data = await Geocoder2.getDataFromCoordinates(
              latitude: latitude,
              longitude: longitude,
              googleMapApiKey:
                  Platform.isIOS ? appleMapAPiKey : googleMapAPiKey);
          address = data.address;
        }
        debugPrint("Address:> $address");
      }
    } on Exception catch (e) {
      debugPrint("PEx: $e");
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.onDisconnect(
        (_) => socket.emit('room join', {"room_id": widget.roomId}));
    super.dispose();
  }

  void onTextChanged() {
    setState(() {
      isRequiredVisible = ratingReviewController1.text.isEmpty;
    });
  }

  String mediaInfo(ManageTaskChatModel model) {
    int imageCount = int.parse(model.imageCount);
    int audioCount = int.parse(model.audioCount);
    int videoCount = int.parse(model.videoCount);

    List<String> mediaDetails = [];

    if (imageCount > 0) {
      mediaDetails.add("$imageCount ${imageCount > 1 ? "photos" : "photo"}");
    }
    if (audioCount > 0) {
      mediaDetails
          .add("$audioCount ${audioCount > 1 ? "interviews" : "interview"}");
    }
    if (videoCount > 0) {
      mediaDetails.add("$videoCount ${videoCount > 1 ? "videos" : "video"}");
    }

    return mediaDetails.isNotEmpty ? mediaDetails.join(" and ") : "";
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          manageTaskText,
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
                      builder: (context) => Dashboard(initialPosition: 2)),
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
      bottomNavigationBar: !isLoading
          ? showLoader()
          : Padding(
              padding: EdgeInsets.only(bottom: size.height * numD03),
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
                          commonButtonStyle(size, Colors.black), () {
                        showGallaryChooser();
                      }),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                          vertical: size.width * numD02),
                      height: size.width * numD18,
                      child: commonElevatedButton(
                          cameraText,
                          size,
                          commonButtonTextStyle(size),
                          commonButtonStyle(size, colorThemePink), () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CameraScreen(
                                      picAgain: true,
                                      previousScreen:
                                          ScreenNameEnum.manageTaskScreen,
                                    ))).then((value) {
                          if (value != null) {
                            debugPrint(
                                "value:::::$value::::::::${value.first.path}");
                            List<CameraData> temData = value;
                            temData.forEach((element) {
                              selectMultipleMediaList.add(
                                MediaData(
                                  isFromGallery: element.fromGallary,
                                  dateTime: "",
                                  latitude: "",
                                  location: "",
                                  longitude: "",
                                  mediaPath: element.path,
                                  mimeType: element.mimeType,
                                  thumbnail: "",
                                ),
                              );
                            });
                            previewBottomSheet();
                          }
                        });
                      }),
                    ),
                  ),
                ],
              ),
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * numD04),
        child: Column(
          children: [
            Stack(
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
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.shade300,
                                      spreadRadius: 2)
                                ]),
                            child: ClipOval(
                              child: Image.network(
                                widget.taskDetail!.mediaHouseImage.toString(),
                                height: size.width * numD10,
                                width: size.width * numD10,
                                fit: BoxFit.contain,
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
                                  width: size.width * numD24,
                                  padding: EdgeInsets.symmetric(
                                      // horizontal: size.width * numD05,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorThemePink,
                                      // color: colorThemePink,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Center(
                                    child: Text(
                                      photoText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD033,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
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
                                  width: size.width * numD24,
                                  padding: EdgeInsets.symmetric(
                                      // horizontal: size.width * numD05,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorThemePink,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Center(
                                    child: Text(
                                      interviewText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD033,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
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
                                  width: size.width * numD24,
                                  padding: EdgeInsets.symmetric(
                                      // horizontal: size.width * numD05,
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorThemePink,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Center(
                                    child: Text(
                                      videoText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD033,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
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
            ),
            SizedBox(
              height: size.width * numD04,
            ),
            uploadMediaInfoWidget('', size),
            SizedBox(
              height: size.width * numD033,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var item = chatList[index];
                  return Column(
                    children: [
                      Visibility(
                        visible: item.messageType == "media",
                        child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                height: size.width * numD035,
                              );
                            },
                            shrinkWrap: true,
                            itemBuilder: (context, idx) {
                              var item1 = item.mediaList[idx];
                              if (item.messageType == "media") {
                                if (item1.type == "video") {
                                  return rightVideoChatWidget(
                                      item1.thumbnail,
                                      item1.imageVideoUrl,
                                      item.createdAtTime,
                                      size,
                                      item1.address);
                                } else if (item1.type == "audio") {
                                  return rightAudioChatWidget(
                                      item1.imageVideoUrl,
                                      item.createdAtTime,
                                      size,
                                      item1.address);
                                } else {
                                  return rightImageChatWidget(
                                      taskMediaUrl + item1.imageVideoUrl,
                                      item.createdAtTime,
                                      size,
                                      item1.address);
                                }
                              } else if (item.messageType ==
                                  "NocontentUpload") {
                                return uploadNoContentWidget(size);
                              } else if (item.messageType ==
                                      "PaymentIntentApp" &&
                                  item.paidStatus) {
                                return mediaHouseOfferWidget(
                                    item,
                                    item.messageType ==
                                        "Mediahouse_initial_offer",
                                    size);
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                            itemCount: item.mediaList.length),
                      ),

                      Visibility(
                        visible: item.mediaList.isNotEmpty &&
                            (item.imageCount != "0" ||
                                item.videoCount != "0" ||
                                item.audioCount != "0"),
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.width * numD035,
                            ),
                            thanksToUploadMediaWidget("", size, item.imageCount,
                                item.videoCount, item.audioCount),
                          ],
                        ),
                      ),

                      /// Payment Received
                      Visibility(
                        visible: item.messageType == "PaymentIntent",
                        child: Column(
                          children: [
                            paymentReceivedWidget(
                                item.mediaHouseName.toCapitalized(),
                                mediaInfo(item),
                                item.hopperPrice,
                                size,
                                item.transactionId),
                            SizedBox(
                              height: size.width * numD04,
                            ),
                            myEarningWidget(item.mediaHouseName,
                                mediaInfo(item), item.payableHopperPrice, size)
                          ],
                        ),
                      ),
                      Visibility(
                        visible: item.messageType == "request_more_content",
                        child: moreContentReqWidget(item, size),
                      ),
                      Visibility(
                        visible: item.messageType == "contentupload",
                        child:
                            uploadMediaInfoWidget("request_more_content", size),
                      ),
                      Visibility(
                          visible: item.messageType == "NocontentUpload",
                          child: uploadNoContentWidget(size))
                    ],
                  );
                },
                itemCount: chatList.length,
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: size.width * numD035,
                  );
                },
              ),
              widget.taskDetail!.paidStatus == "paid"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: size.width * numD013),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    spreadRadius: 2)
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
                                horizontal: size.width * numD05,
                                vertical: size.width * numD02),
                            width: size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.only(
                                  topRight:
                                      Radius.circular(size.width * numD04),
                                  bottomLeft:
                                      Radius.circular(size.width * numD04),
                                  bottomRight:
                                      Radius.circular(size.width * numD04),
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.width * numD01,
                                ),
                                RichText(
                                    text: TextSpan(
                                        style: const TextStyle(
                                          fontFamily: "AirbnbCereal",
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                      TextSpan(
                                        text: "Congratulations, ",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD036,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      TextSpan(
                                        text: widget.taskDetail!.mediaHouseName,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD036,
                                            color: colorThemePink,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      TextSpan(
                                        text:
                                            " has purchased your content for ",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD036,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      TextSpan(
                                        text: widget.taskDetail!.interviewPrice
                                                .isNotEmpty
                                            ? "$euroUniqueCode${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}"
                                            : "-",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD036,
                                            color: colorThemePink,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ])),
                                SizedBox(
                                  height: size.width * numD03,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.width * numD13,
                                      width: size.width,
                                      child: commonElevatedButton(
                                          "View Transaction Details",
                                          size,
                                          commonButtonTextStyle(size),
                                          commonButtonStyle(
                                              size, colorThemePink), () {
                                        callDetailApi(
                                            widget.taskDetail!.mediaHouseId);
                                      }),
                                    ),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: widget.taskDetail!.paidStatus == "paid"
                    ? size.width * numD035
                    : 0,
              ),
              widget.taskDetail!.paidStatus == "paid"
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: size.width * numD013),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade300,
                                    spreadRadius: 2)
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
                                horizontal: size.width * numD05,
                                vertical: size.width * numD02),
                            width: size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: colorGoogleButtonBorder),
                                borderRadius: BorderRadius.only(
                                  topRight:
                                      Radius.circular(size.width * numD04),
                                  bottomLeft:
                                      Radius.circular(size.width * numD04),
                                  bottomRight:
                                      Radius.circular(size.width * numD04),
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
                                        text:
                                            "$euroUniqueCode${formatDouble(double.parse(widget.taskDetail!.interviewPrice))}",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD036,
                                            color: colorThemePink,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      TextSpan(
                                        text:
                                            " into your bank account. Please visit ",
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
                                  height: size.width * numD03,
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
                                          commonButtonStyle(
                                              size, colorThemePink), () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MyEarningScreen(
                                                      openDashboard: false,
                                                    )));
                                      }),
                                    ),
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(),
              widget.taskDetail!.paidStatus == "paid"
                  ? ratingReview(size, widget.taskDetail!)
                  : Container()
            ]),
          ],
        ),
      ),
    );
  }

  Widget uploadMediaInfoWidget(String uploadTextType, var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // margin: EdgeInsets.only(top: uploadTextType == "request_more_content" ? size.width * numD04 : 0),
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
            // margin: EdgeInsets.only(top: uploadTextType == "request_more_content" ? size.width * numD05 : 0),
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget rightVideoChatWidget(String thumbnail, String videoUrl, String time,
      var size, String address) {
    debugPrint("----------------$videoUrl");
    debugPrint("-thumbnail---------------$thumbnail");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    child: Container(
                      height: size.height / 3,
                      width: double.infinity,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey, // border color
                          width: 2, // border width
                        ),
                        borderRadius:
                            BorderRadius.circular(12), // rounded corners
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          mediaThumbnailUrl + videoUrl,
                          height: size.height / 3,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, s, o) {
                            return Image.asset(
                              '${dummyImagePath}placeholderImage.png',
                              height: size.height / 3,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
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
              "${dateTimeFormatter(dateTime: time, format: 'hh:mm a')}, ${dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy')}",
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
              "${iconsPath}ic_location.png",
              height: size.width * numD035,
              color: Colors.black,
            ),
            SizedBox(
              width: size.width * numD01,
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: size.width * numD13),
                child: Text(
                  address.isNotEmpty ? address : "N/A",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD028,
                      color: colorHint,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: size.width * numD018,
        ),
      ],
    );
  }

  Widget rightAudioChatWidget(
      String audioUrl, String time, var size, String address) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      child: Container(
                        color: colorThemePink,
                        height: size.height / 3,
                        width: double.infinity,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
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
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
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
                "${dateTimeFormatter(dateTime: time, format: 'hh:mm a')}, ${dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy')}",
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
                "${iconsPath}ic_location.png",
                height: size.width * numD035,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * numD01,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: size.width * numD13),
                  child: Text(
                    address.isNotEmpty ? address : "N/A",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD028,
                        color: colorHint,
                        fontWeight: FontWeight.normal),
                  ),
                ),
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

  Widget rightImageChatWidget(
      String imageUrl, String time, var size, String address) {
    debugPrint("imageUrl:::::::$imageUrl");
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Navigator.of(navigatorKey.currentState!.context).push(
          MaterialPageRoute(
            builder: (context) => MediaViewScreen(
              mediaFile: imageUrl,
              type: MediaTypeEnum.image,
            ),
          ),
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
                            horizontal: size.width * numD01,
                          ),
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
                "${dateTimeFormatter(dateTime: time, format: 'hh:mm a')}, ${dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy')}",
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
                "${iconsPath}ic_location.png",
                height: size.width * numD035,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * numD01,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: size.width * numD13),
                  child: Text(
                    address.isNotEmpty ? address : "N/A",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD028,
                        color: colorHint,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: size.width * numD018,
          ),
        ],
      ),
    );
  }

  Widget thanksToUploadMediaWidget(String type, var size, String imgCount,
      String vidCount, String audioCount) {
    print("Thanks $imgCount, $vidCount, $audioCount");
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
                        text: "Thanks, you've uploaded ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: (imgCount.isNotEmpty &&
                                vidCount == "0" &&
                                audioCount == "0")
                            ? (imgCount == "1"
                                ? "$imgCount photo"
                                : "$imgCount photos")
                            : (vidCount.isNotEmpty &&
                                    imgCount == "0" &&
                                    audioCount == "0")
                                ? (vidCount == "1"
                                    ? "$vidCount video"
                                    : "$vidCount videos")
                                : (audioCount.isNotEmpty &&
                                        imgCount == "0" &&
                                        vidCount == "0")
                                    ? (audioCount == "1"
                                        ? "$audioCount interview"
                                        : "$audioCount interviews")
                                    : (imgCount.isNotEmpty &&
                                            vidCount.isNotEmpty &&
                                            audioCount == "0")
                                        ? "${imgCount == "1" ? "$imgCount photo" : "$imgCount photos"} and ${vidCount == "1" ? "$vidCount video" : "$vidCount videos"}"
                                        : (imgCount.isNotEmpty &&
                                                audioCount.isNotEmpty &&
                                                vidCount == "0")
                                            ? "${imgCount == "1" ? "$imgCount photo" : "$imgCount photos"} and ${audioCount == "1" ? "$audioCount interview" : "$audioCount interviews"}"
                                            : (vidCount.isNotEmpty &&
                                                    audioCount.isNotEmpty &&
                                                    imgCount == "0")
                                                ? "${vidCount == "1" ? "$vidCount video" : "$vidCount videos"} and ${audioCount == "1" ? "$audioCount interview" : "$audioCount interviews"}"
                                                : (imgCount.isNotEmpty &&
                                                        vidCount.isNotEmpty &&
                                                        audioCount.isNotEmpty)
                                                    ? "${imgCount == "1" ? "$imgCount photo" : "$imgCount photos"}, ${vidCount == "1" ? "$vidCount video" : "$vidCount videos"} and ${audioCount == "1" ? "$audioCount interview" : "$audioCount interviews"}"
                                                    : '',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ])),
                // SizedBox(
                //   height: size.width * numD008,
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget paymentReceivedWidget(String mediaHouseName, String mediaCount,
      String amount, var size, String transactionId) {
    // print("paymentReceivedWidget: $mediaHouseName, $amount, $transactionId");
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*profilePicWidget(),*/
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
                        text: "Congratulations,",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: ' $mediaHouseName',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " have purchased ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: mediaCount,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " for ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: "$euroUniqueCode$amount",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
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
                    commonButtonStyle(size, colorThemePink), () {
                  callTransactionDetailApi(transactionId);
                }),
              )
            ],
          ),
        ))
      ],
    );
  }

  void callTransactionDetailApi(String id) {
    Map<String, String> map = {"transaction_id": id};
    NetworkClass.fromNetworkClass(
            getTaskTransactionDetails, this, getTaskTransactionDetailsReq, map)
        .callRequestServiceHeader(true, 'post', null);
  }

  Widget myEarningWidget(
      String mediaHouseName, String mediaInfo, String amount, var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*profilePicWidget(),*/
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
                        text: "Woohoo! We have paid",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: " $euroUniqueCode$amount",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " into your bank account. Please visit  ",
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
                        text: " to view your transaction",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ]),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
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
              )
            ],
          ),
        ))
      ],
    );
  }

  Widget oldpaymentReceivedWidget(String amount, var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*profilePicWidget(),*/
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
              horizontal: size.width * numD05, vertical: size.width * numD02),
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
                "Congrats, you’ve received £$amount from Reuters Media ",
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
    );
  }

  Widget profilePicWidget(var size) {
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

  Widget moreContentReqWidget(ManageTaskChatModel item, var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicWidget(size),
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
                                  : Colors.black,
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
                                : Colors.white,
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

  Widget uploadNoContentWidget(var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // margin: EdgeInsets.only(top: size.width * numD03),
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
            // margin: EdgeInsets.only(top: size.width * numD03),
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

  Widget mediaHouseOfferWidget(
      ManageTaskChatModel item, bool isMakeCounter, var size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.width * numD026,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                      height: size.width * numD009,
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
                                  text:
                                      "Well done! You've received\nan offer from",
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
                                      color: Colors.grey.shade200,
                                      spreadRadius: 1)
                                ]),
                            child: ClipOval(
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                item.mediaHouseImage,
                                fit: BoxFit.contain,
                                height: size.width * numD20,
                                width: size.width * numD20,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
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
                      height: size.width * numD03,
                    ),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(size.width * numD012),
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius:
                              BorderRadius.circular(size.width * numD03),
                          border: Border.all(
                              color: const Color(0xFFd4dedd), width: 2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Offered Price",
                            style: TextStyle(
                                fontSize: size.width * numD035,
                                color: colorLightGreen,
                                fontFamily: 'AirbnbCereal'),
                          ),
                          Text(
                            item.hopperPrice.isEmpty
                                ? ""
                                : "$euroUniqueCode${formatDouble(double.parse(item.hopperPrice))}",
                            style: TextStyle(
                                fontSize: size.width * numD045,
                                color: colorLightGreen,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'AirbnbCereal'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * numD01,
                    )
                  ],
                ),
              )),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(top: size.width * numD06),
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
                margin: EdgeInsets.only(top: size.width * numD06),
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
                            style: const TextStyle(
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                          TextSpan(
                            text: "Congratulations, ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD036,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: item.mediaHouseName,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD036,
                                color: colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: " has purchased your content for ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD036,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: item.hopperPrice.isEmpty
                                ? ""
                                : "$euroUniqueCode${formatDouble(double.parse(item.hopperPrice))}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD036,
                                color: colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                        ])),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * numD13,
                          width: size.width,
                          child: commonElevatedButton(
                              "View Transaction Details ",
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(size, colorThemePink), () {
                            callDetailApi(item.mediaHouseId);
                          }),
                        ),
                        SizedBox(
                          height: size.width * numD01,
                        ),
                      ],
                    )
                  ],
                ),
              )),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(top: size.width * numD06),
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
                margin: EdgeInsets.only(top: size.width * numD06),
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
                            text: item.payableHopperPrice.isEmpty
                                ? ""
                                : "$euroUniqueCode${formatDouble(double.parse(item.payableHopperPrice))}",
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
                      height: size.width * numD03,
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
                        SizedBox(
                          height: size.width * numD01,
                        ),
                      ],
                    )
                  ],
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget ratingReview(var size, TaskDetailModel item) {
    return Stack(
      alignment: Alignment.center,
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
              margin: EdgeInsets.only(bottom: size.width * numD06),
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
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Rate your experience with PressHop",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD036,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  RatingBar(
                    glowRadius: 0,
                    ratingWidget: RatingWidget(
                      empty: Image.asset("${iconsPath}emptystar.png"),
                      full: Image.asset("${iconsPath}star.png"),
                      half: Image.asset("${iconsPath}ic_half_star.png"),
                    ),
                    onRatingUpdate: (value) {
                      ratings = value;
                      setState(() {});
                    },
                    itemSize: size.width * numD09,
                    itemCount: 5,
                    initialRating: ratings,
                    allowHalfRating: true,
                    itemPadding: EdgeInsets.only(left: size.width * numD03),
                  ),
                  SizedBox(
                    height: size.width * 0.04,
                  ),
                  const Text(
                    "Tell us what you liked about the App",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD018,
                  ),
                  Wrap(
                      children:
                          List<Widget>.generate(intList.length, (int index) {
                    return Container(
                      margin: EdgeInsets.only(
                          left: size.width * 0.02, right: size.width * 0.02),
                      child: ChoiceChip(
                        label: Text(intList[index]),
                        labelStyle: TextStyle(
                            color: dataList.contains(intList[index])
                                ? Colors.white
                                : colorGrey6),
                        onSelected: (bool selected) {
                          if (selected) {
                            for (int i = 0; i < intList.length; i++) {
                              if (intList[i] == intList[index] &&
                                  !dataList.contains(intList[i])) {
                                dataList.add(intList[i]);
                                indexList.add(i);
                              }
                            }
                          } else {
                            for (int i = 0; i < intList.length; i++) {
                              if (intList[i] == intList[index] &&
                                  dataList.contains(intList[i])) {
                                dataList.remove(intList[i]);
                                indexList.remove(i);
                              }
                            }
                          }
                          setState(() {});
                        },
                        selectedColor: colorThemePink,
                        disabledColor: colorGreyChat.withOpacity(.3),
                        selected:
                            dataList.contains(intList[index]) ? true : false,
                      ),
                    );
                  })),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Stack(
                    children: [
                      TextFormField(
                        controller: ratingReviewController1,
                        cursorColor: colorTextFieldIcon,
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        readOnly: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD035,
                        ),
                        onChanged: (v) {
                          onTextChanged();
                        },
                        decoration: InputDecoration(
                          hintText: textData,
                          contentPadding: EdgeInsets.only(
                              left: size.width * numD08,
                              right: size.width * numD02,
                              top: size.width * numD075),
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              wordSpacing: 2,
                              fontSize: size.width * numD035),
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.black)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: BorderSide(
                                  width: 1, color: Colors.grey.shade300)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 1, color: Colors.grey)),
                          alignLabelWithHint: false,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * numD038,
                            left: size.width * numD014),
                        child: Image.asset(
                          "${iconsPath}docs.png",
                          width: size.width * 0.06,
                          height: size.width * 0.07,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.width * numD017),
                  ratingReviewController1.text.isEmpty
                      ? const Text(
                          "Required",
                          style: TextStyle(
                              fontSize: 11,
                              color: colorThemePink,
                              fontWeight: FontWeight.w400),
                        )
                      : Container(),
                  SizedBox(height: size.width * numD04),
                  SizedBox(
                    height: size.width * numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        isRatingGiven ? "Thanks a Ton" : submitText,
                        size,
                        isRatingGiven
                            ? TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD037,
                                fontFamily: "AirbnbCereal",
                                fontWeight: FontWeight.bold)
                            : commonButtonTextStyle(size),
                        commonButtonStyle(
                            size, isRatingGiven ? Colors.grey : colorThemePink),
                        !isRatingGiven
                            ? () {
                                if (ratingReviewController1.text.isNotEmpty) {
                                  var map = {
                                    // "chat_id": item.id,
                                    "rating": ratings,
                                    "review": ratingReviewController1.text,
                                    "features": dataList,
                                    "image_id": imageId,
                                    "type": "content",
                                    "sender_type": "hopper"
                                  };
                                  debugPrint("map function $map");
                                  socketEmitFunc(
                                      socketEvent: "rating",
                                      messageType: "rating_for_hopper",
                                      dataMap: map);
                                  showSnackBar(
                                      "Rating & Review",
                                      "Thanks for the love! Your feedback makes all the difference ❤️",
                                      Colors.green);
                                  showCelebration = true;
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    showCelebration = false;
                                  });
                                  setState(() {});
                                } else {
                                  showSnackBar(
                                      "Required *",
                                      "Please Enter some review for mediahouse",
                                      Colors.red);
                                }
                              }
                            : () {
                                debugPrint("already rated:::;");
                              }),
                  ),
                  SizedBox(height: size.width * 0.01),
                  RichText(
                      text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "AirbnbCereal",
                          ),
                          children: [
                        TextSpan(
                          text: "Please refer to our ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              lineHeight: 1.2,
                              fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                            text: "Terms & Conditions. ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: colorThemePink,
                                lineHeight: 2,
                                fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => TermCheckScreen(
                                          type: 'legal',
                                        )));
                              }),
                        TextSpan(
                          text: "If you have any questions, please ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                            text: "contact ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: colorThemePink,
                                fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const ContactUsScreen()));
                              }),
                        TextSpan(
                          text:
                              "our helpful teams who are available 24x7 to assist you. Thank you",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              lineHeight: 1.4,
                              fontWeight: FontWeight.w400),
                        ),
                      ])),
                  SizedBox(
                    height: size.width * 0.01,
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
    );
  }

  Widget videoWidget(String videoUrl, var size) {
    _controller = VideoPlayerController.file(File(videoUrl));
    super.initState();
    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      setState(() {});
    });
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: VideoPlayer(_controller!)),
                Container(
                  padding: EdgeInsets.only(
                      left: size.width * numD02, right: size.width * numD04),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                          });
                        },
                        child: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: size.width * numD08,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: size.width * numD02),
                        child: VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            backgroundColor: Colors.black.withOpacity(0.2),
                            playedColor: colorThemePink,
                            bufferedColor: Colors.grey.withOpacity(0.5),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      )),
                      Text(
                        "${_controller!.value.duration.inSeconds}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD025,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        } else {
          return Center(
            child: showLoader(),
          );
        }
      },
    );
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

    debugPrint("Socket Disconnect : ${socket.connected}");
    debugPrint("Socket Disconnect : ${widget.taskDetail?.mediaHouseId}");

    socket.connect();

    socket.onConnect((_) {
      socket.emit('room join', {"room_id": widget.roomId});
    });

    debugPrint("Socket connected : ${socket.connected}");

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

  Future<void> getMultipleImages(String fileType) async {
    try {
      late FilePickerResult? result;
      if (fileType == "file") {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: [
            'mp4',
            'avi',
            'mov',
            'mkv',
            'flv',
            'mp3',
            'wav',
            'aac',
            'ogg',
            'jpg',
            'jpeg',
            'png',
            'gif',
            'bmp',
            'webp'
          ],
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          final String filePath = file.path!;
          final String? mimeType = lookupMimeType(filePath);

          debugPrint("Picked File: $filePath");
          debugPrint("MIME Type: $mimeType");

          selectMultipleMediaList.add(
            MediaData(
              isFromGallery: true,
              dateTime: "",
              latitude: "",
              location: "",
              longitude: "",
              mediaPath: filePath,
              mimeType: mimeType!,
              thumbnail: "",
            ),
          );
        }

        previewBottomSheet();
        setState(() {});
      } else {
        debugPrint("No videos selected.");
      }
    } catch (e) {
      debugPrint("Error picking videos: $e");
    }
  }

  void previewBottomSheet() {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, avatarState) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          PageView.builder(
                            onPageChanged: (value) {
                              currentPage = value;
                              avatarState(() {});
                            },
                            itemBuilder: (context, index) {
                              var item = selectMultipleMediaList[index];
                              debugPrint("type:::${item.mimeType}");
                              debugPrint("file:::${item.mediaPath}");
                              if (item.mimeType.startsWith('image')) {
                                return Container(
                                  color: Colors.black,
                                  child: Image.file(
                                    File(item.mediaPath),
                                    fit: item.isFromGallery
                                        ? BoxFit.contain
                                        : BoxFit.fill,
                                    gaplessPlayback: true,
                                  ),
                                );
                              } else if (item.mimeType.startsWith('video')) {
                                return VideoWidget(mediaData: item);
                              } else if (item.mimeType.startsWith('audio')) {
                                return AudioWaveFormWidgetScreen(
                                    mediaPath: item.mediaPath);
                              }
                            },
                            itemCount: selectMultipleMediaList.length,
                          ),
                          selectMultipleMediaList.isNotEmpty &&
                                  selectMultipleMediaList.length > 1
                              ? Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: DotsIndicator(
                                    dotsCount: selectMultipleMediaList.length,
                                    position: currentPage,
                                    decorator: const DotsDecorator(
                                      color: Colors.grey, // Inactive color
                                      activeColor: Colors.redAccent,
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD04,
                                vertical: size.width * numD02),
                            height: size.width * numD18,
                            child: commonElevatedButton(
                                "Add more",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, Colors.black), () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const CameraScreen(
                                            picAgain: true,
                                            previousScreen:
                                                ScreenNameEnum.manageTaskScreen,
                                          ))).then((value) {
                                if (value != null) {
                                  debugPrint(
                                      "value:::::$value::::::::${value.first.path}");
                                  List<CameraData> temData = value;
                                  temData.forEach((element) {
                                    selectMultipleMediaList.add(
                                      MediaData(
                                        isFromGallery: element.fromGallary,
                                        dateTime: "",
                                        latitude: "",
                                        location: "",
                                        longitude: "",
                                        mediaPath: element.path,
                                        mimeType: element.mimeType,
                                        thumbnail: "",
                                      ),
                                    );
                                  });
                                  previewBottomSheet();
                                }
                              });
                            }),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD04,
                                vertical: size.width * numD02),
                            height: size.width * numD18,
                            child: commonElevatedButton(
                                "Next",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink), () {
                              Navigator.pop(context);
                              callUploadMediaApi({}, "");
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.height * numD015,
                    ),
                  ],
                ),
                Positioned(
                    top: size.width * numD06,
                    right: size.width * numD02,
                    child: IconButton(
                        onPressed: () {
                          selectMultipleMediaList.removeAt(currentPage);
                          if (selectMultipleMediaList.isEmpty) {
                            Navigator.pop(context);
                          }
                          avatarState(() {});
                        },
                        icon: Icon(
                          Icons.highlight_remove,
                          color: Colors.white,
                          size: size.width * numD07,
                        ))),
              ],
            );
          });
        });
  }

  void callDetailApi(String id) {
    Map<String, dynamic> map = {
      "content_id": widget.roomId,
      "media_house_id": id
    };

    NetworkClass(GetDetailsById, this, reqGetDetailsById)
        .callRequestServiceHeader(true, 'get', map);
  }

  /// Upload media
  void callUploadMediaApi(Map<String, String> mediaMap, String type) async {
    List<String> mediaList = [];
    List<File> filesPath = [];
    for (var element in selectMultipleMediaList) {
      mediaList.add(element.mediaPath);
    }

    filesPath.addAll(mediaList.map((path) => File(path)).toList());
    debugPrint("mediaList :::::$mediaList");

    Map<String, String> map = {
      'task_id': widget.taskDetail!.id,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
    };

    debugPrint('map:::::::$map');

    // await uploadMediaUsingDio(
    //   uploadTaskMediaUrl,
    //   map,
    //   filesPath,
    //   "images",
    // );

    NetworkClass.multipartNetworkClassFiles(
            uploadTaskMediaUrl, this, uploadTaskMediaReq, map, filesPath)
        .callMultipartServiceSameParamMultiImage(true, "post", "files");
  }

  /// Get Listing
  void callGetManageTaskListingApi() {
    Map<String, String> map = {
      "room_id": widget.roomId,
      "type": "task_content"
    };

    NetworkClass.fromNetworkClass(
            getMediaTaskChatListUrl, this, getMediaTaskChatListReq, map)
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
        break;

      /// Get Chat Listing
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

        var dataModel = (data['videothubnail_path'] as List).map((item) {
          return {...item, 'address': address};
        }).toList();

        for (var item in dataModel) {
          debugPrint('Media Type: ${item['media_type']}');
          debugPrint('Media: ${item['media']}');
          debugPrint('Hopper ID: ${item['hopper_id']}');
        }

        debugPrint("uploadedMediaList length:::::$dataModel");

        // List<String>uploadedMediaList = [];
        //  uploadedMediaList = dataModeldataModel.toList();

        // imageId = data["data"] != null ? data["data"]["_id"] : "";
        //debugPrint("imageID=========> $imageId");
        var mediaMap = {
          /*  "attachment": data["image_name"] ?? "",
          "watermark": data["watermark"] ?? "",
          "attachment_name": data["attachme_name"] ?? "",
          "attachment_size": data["video_size"] ?? "",*/
          "thumbnail_url": dataModel,
          "recevier_id": widget.taskDetail!.mediaHouseId,
          "sender_id": sharedPreferences!.getString(hopperIdKey) ?? "",
          // "image_id": data["data"] != null ? data["data"]["_id"] : "",
        };
        debugPrint("mediaMap:::::${jsonEncode(mediaMap)}");
        socketEmitFunc(
          socketEvent: "media message",
          messageType: "media",
          dataMap: mediaMap,

          // mediaType: data["type"] ?? "image"
        );
/*
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

        uploadSuccess = true;*/
        setState(() {});
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
        selectMultipleMediaList.clear();
        debugPrint("chatList length::::: ${chatList.length}");
        isLoading = true;

        if (mounted) {
          setState(() {});
        }

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
                      pageType: PageType.CONTENT,
                      type: "received",
                      transactionData: earningTransactionDataList[0],
                    )));
        break;

      case getTaskTransactionDetailsReq:
        var data = jsonDecode(response);
        var dataList = data['response'] as List;
        earningTransactionDataList = dataList
            .map((e) => EarningTransactionDetail.taskFromJson(e))
            .toList();
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              pageType: PageType.TASK,
              type: "received",
              transactionData: earningTransactionDataList[0],
            ),
          ),
        );
        break;
    }
  }

  void showGallaryChooser() {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size.width * numD04),
                    topRight: Radius.circular(size.width * numD04))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: size.width * numD06,
                      right: size.width * numD03,
                      top: size.width * numD018),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Option",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * numD048,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close_rounded,
                              color: Colors.black, size: size.width * numD08)),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: size.width * numD06, right: size.width * numD06),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            selectMultipleMediaList.clear();
                            getMultipleImages("image");
                          },
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD02),
                              ),
                              height: size.width * numD25,
                              padding: EdgeInsets.all(size.width * numD02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload, size: size.width * numD08),
                                  SizedBox(
                                    height: size.width * numD03,
                                  ),
                                  Text(
                                    "My Gallery",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: size.width * numD035,
                                        fontFamily: "AirbnbCereal",
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            selectMultipleMediaList.clear();
                            getMultipleImages("file");
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD02),
                              ),
                              height: size.width * numD25,
                              padding: EdgeInsets.all(size.width * numD04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_copy_outlined,
                                    size: size.width * numD08,
                                  ),
                                  SizedBox(
                                    height: size.width * numD03,
                                  ),
                                  Text(
                                    "My Files",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: size.width * numD035,
                                        fontFamily: "AirbnbCereal",
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
              ],
            ),
          );
        });
  }

  // void showGallaryChooser() {
  //   var size = MediaQuery.of(context).size;
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           contentPadding: EdgeInsets.zero,
  //           insetPadding: EdgeInsets.symmetric(horizontal: size.width * numD02),
  //           content: StatefulBuilder(
  //               builder: (BuildContext context, StateSetter setState) {
  //             return Container(
  //               width: size.width * num1,
  //               height: size.height * numD18,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(size.width * numD025),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Padding(padding: EdgeInsets.only(top: size.width * 0.02)),
  //                   Row(
  //                     children: [
  //                       Spacer(),
  //                       Text(
  //                         "Please choose?",
  //                         style: TextStyle(
  //                           color: Colors.black,
  //                           fontSize:
  //                               MediaQuery.of(context).size.width * numD045,
  //                           fontWeight: FontWeight.w500,
  //                         ),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                       Spacer(),
  //                       Padding(
  //                         padding: const EdgeInsets.all(10.0),
  //                         child: GestureDetector(
  //                           onTap: () => Navigator.pop(context),
  //                           child: Icon(
  //                             Icons.highlight_remove,
  //                             color: colorThemePink,
  //                             size: size.width * numD07,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: size.height * 0.02,
  //                   ),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       SizedBox(
  //                         width: size.width * numD45,
  //                         height: size.height * numD055,
  //                         child: commonElevatedButton(
  //                             "Photo Gallery",
  //                             size,
  //                             commonButtonTextStyle(size),
  //                             commonButtonStyle(size, colorThemePink), () {
  //                           Navigator.pop(context);
  //                           selectMultipleMediaList.clear();
  //                           getMultipleImages("image");
  //                           // getMultipleImages();
  //                           // showGallaryChooser();
  //                         }),
  //                       ),
  //                       SizedBox(
  //                         width: size.width * 0.02,
  //                       ),
  //                       SizedBox(
  //                         width: size.width * numD45,
  //                         height: size.height * numD055,
  //                         child: commonElevatedButton(
  //                             "My File",
  //                             size,
  //                             commonButtonTextStyle(size),
  //                             commonButtonStyle(size, colorThemePink), () {
  //                           Navigator.pop(context);
  //                           selectMultipleMediaList.clear();
  //                           getMultipleImages("file");
  //                         }),
  //                       )
  //                     ],
  //                   )
  //                 ],
  //               ),
  //             );
  //           }),
  //         );
  //       });
  // }
}

class MediaModel {
  XFile? mediaFile;
  String mimetype = "";

  MediaModel({
    required this.mediaFile,
    required this.mimetype,
  });
}
