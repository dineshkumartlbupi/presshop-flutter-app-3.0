import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';
import 'package:presshop/core/api/api_constant.dart';

import 'package:presshop/features/account_settings/presentation/pages/contact_us_screen.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/pages/PreviewScreen.dart';
import 'package:presshop/features/chat/presentation/pages/FullVideoView.dart';
import 'package:video_player/video_player.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/earning/presentation/pages/MyEarningScreen.dart';
import 'package:presshop/features/earning/presentation/pages/TransactionDetailScreen.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/MediaPreviewScreen.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';

import 'package:presshop/features/authentication/presentation/pages/TermCheckScreen.dart';
import 'package:presshop/features/camera/presentation/pages/CameraScreen.dart';
import 'package:presshop/core/constants/string_constants_new2.dart';

import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:location/location.dart' as lc;

import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';

class BroadCastChatTaskScreen extends StatefulWidget {
  const BroadCastChatTaskScreen(
      {super.key, required this.taskDetail, required this.roomId});
  final TaskAssignedEntity? taskDetail;
  final String roomId;

  @override
  State<BroadCastChatTaskScreen> createState() =>
      _BroadCastChatTaskScreenState();
}

class _BroadCastChatTaskScreenState extends State<BroadCastChatTaskScreen> {
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
  lc.LocationData? locationData;
  lc.Location location = lc.Location();
  double latitude = 0, longitude = 0;
  String address = "";
  double uploadProgress = 0.0;
  StateSetter? _dialogStateSetter;
  bool _shouldCloseDialog = false;

  void showProgressDialog() {
    _shouldCloseDialog = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _dialogStateSetter = setState;
            if (_shouldCloseDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && Navigator.canPop(context)) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              });
            }
            return LoadingDialogContent(progress: uploadProgress);
          },
        );
      },
    ).then((_) {
      _dialogStateSetter = null;
    });
  }

  @override
  void initState() {
    debugPrint("class name :::$runtimeType");
    super.initState();
    socketConnectionFunc();
    // Only fetch if list is empty to avoid double fetch on rebuilds if any
    if (chatList.isEmpty) {
      isLoading = true;
      context.read<TaskBloc>().add(GetTaskChatEvent(
          roomId: widget.roomId,
          type: "task_content",
          contentId: widget.taskDetail?.task.id ?? "",
          showLoader: false));
    }
    getCurrentLocation();
  }

  // void getCurrentLocation() async {
  //   try {
  //     locationData = await LocationService()
  //         .getCurrentLocation(context, shouldShowSettingPopup: false);
  //     debugPrint("GettingLocation ==> $locationData");
  //     if (locationData != null) {
  //       debugPrint("NotNull");
  //       if (locationData!.latitude != null) {
  //         latitude = locationData!.latitude!;
  //         longitude = locationData!.longitude!;
  //         GeoData data = await Geocoder2.getDataFromCoordinates(
  //             latitude: latitude,
  //             longitude: longitude,
  //             googleMapApiKey:
  //                 Platform.isIOS ? appleMapAPiKey : googleMapAPiKey);
  //         address = data.address;
  //       }
  //       debugPrint("Address:> $address");
  //     }
  //   } on Exception catch (e) {
  //     debugPrint("PEx: $e");
  //   }
  // }
  void dismissProgressDialog() {
    _shouldCloseDialog = true;
    if (_dialogStateSetter != null) {
      Navigator.of(context, rootNavigator: true).pop();
      _dialogStateSetter = null;
    }
  }

  void getCurrentLocation() async {
    try {
      // Fetch current location using your custom LocationService
      locationData = await LocationService()
          .getCurrentLocation(context, shouldShowSettingPopup: false);

      debugPrint("GettingLocation ==> $locationData");

      if (locationData != null && locationData!.latitude != null) {
        latitude = locationData!.latitude!;
        longitude = locationData!.longitude!;

        // ✅ Reverse geocode without needing an API key
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        Placemark place = placemarks.first;

        // ✅ Create readable address string
        address =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";

        debugPrint("Address:> $address");
      } else {
        debugPrint("Location data is null");
      }
    } catch (e) {
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
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskLoading) {
          setState(() {
            isLoading = true;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }

        if (state is TaskChatLoaded) {
          setState(() {
            chatList = state.chatList;
          });
        } else if (state is TransactionDetailsLoaded) {
          earningTransactionDataList = state.transactions;
          if (earningTransactionDataList.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailScreen(
                  pageType: PageType.TASK,
                  type: "received",
                  transactionData: earningTransactionDataList.first.toEntity(),
                ),
              ),
            );
          }
        } else if (state is TaskMediaUploaded) {
          showSnackBar("Success", "Media uploaded successfully", Colors.green);
          if (mounted) {
            context.read<TaskBloc>().add(GetTaskChatEvent(
                roomId: widget.roomId,
                type: "task_content",
                contentId: widget.taskDetail?.task.id ?? "",
                showLoader: false));
          }
        } else if (state is TaskError) {
          showSnackBar("Error", state.message, Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: false,
            title: Text(
              AppStringsNew2.manageTaskText,
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
                  height: size.width * AppDimensions.numD07,
                  width: size.width * AppDimensions.numD07,
                ),
              ),
              SizedBox(
                width: size.width * AppDimensions.numD04,
              )
            ],
          ),
          bottomNavigationBar: isLoading
              ? showLoader()
              : Padding(
                  padding: EdgeInsets.only(
                      bottom: size.height * AppDimensions.numD03),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD02),
                          height: size.width * AppDimensions.numD18,
                          child: commonElevatedButton(
                              AppStringsNew2.galleryText,
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(size, Colors.black), () {
                            showGallaryChooser();
                            // LocationService()
                            //     .getCurrentLocation(context)
                            //     .then((locationData) {
                            //   if (locationData != null) {
                            //     showGallaryChooser();
                            //   }
                            // });
                          }),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD02),
                          height: size.width * AppDimensions.numD18,
                          child: commonElevatedButton(
                              AppStringsNew2.cameraText,
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(
                                  size, AppColorTheme.colorThemePink), () {
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
                                for (var element in temData) {
                                  selectMultipleMediaList.add(
                                    MediaData(
                                      isFromGallery: element.fromGallary,
                                      dateTime: "",
                                      latitude: latitude.toString(),
                                      location: address,
                                      longitude: longitude.toString(),
                                      mediaPath: element.path,
                                      mimeType: element.mimeType,
                                      thumbnail: "",
                                    ),
                                  );
                                }
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
            padding: EdgeInsets.all(size.width * AppDimensions.numD04),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD055),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD03,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
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
                            height: size.width * AppDimensions.numD025,
                          ),
                          Row(
                            children: [
                              Text(
                                // "${AppStringsNew2.taskText} ${widget.taskDetail?.status}",
                                "TASK ACCEPTED",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
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
                                    widget.taskDetail!.task.mediaHouse
                                        .profileImage
                                        .toString(),
                                    height: size.width * AppDimensions.numD10,
                                    width: size.width * AppDimensions.numD10,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "${commonImagePath}rabbitLogo.png", // Fallback image
                                        height:
                                            size.width * AppDimensions.numD10,
                                        width:
                                            size.width * AppDimensions.numD10,
                                        fit: BoxFit.contain,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD03,
                          ),
                          Text(
                            "${widget.taskDetail?.task.heading}",
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
                                      false
                                          ? "$currencySymbol${formatDouble(double.tryParse("0") ?? 0.0)}"
                                          : "-",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD055,
                                          color: AppColorTheme.colorThemePink,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      AppStringsNew2.offeredText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD03,
                                    ),
                                    Container(
                                      width: size.width * AppDimensions.numD24,
                                      padding: EdgeInsets.symmetric(
                                          // horizontal: size.width * AppDimensions.numD05,
                                          vertical: size.width *
                                              AppDimensions.numD02),
                                      decoration: BoxDecoration(
                                          color: AppColorTheme.colorThemePink,
                                          // color: AppColorTheme.colorThemePink,
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD02)),
                                      child: Center(
                                        child: Text(
                                          AppStringsNew2.photoText
                                              .toUpperCase(),
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD033,
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
                                      false
                                          ? "$currencySymbol${formatDouble(double.tryParse("0") ?? 0.0)}"
                                          : "-",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD055,
                                          color: AppColorTheme.colorThemePink,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      AppStringsNew2.offeredText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD03,
                                    ),
                                    Container(
                                      // alignment: Alignment.center,
                                      width: size.width * AppDimensions.numD24,
                                      padding: EdgeInsets.symmetric(
                                          // horizontal: size.width * AppDimensions.numD05,
                                          vertical: size.width *
                                              AppDimensions.numD02),
                                      decoration: BoxDecoration(
                                          color: AppColorTheme.colorThemePink,
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD02)),
                                      child: Center(
                                        child: Text(
                                          AppStringsNew2.interviewText
                                              .toUpperCase(),
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD033,
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
                                      false
                                          ? "$currencySymbol${formatDouble(double.tryParse("0") ?? 0.0)}"
                                          : "-",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD055,
                                          color: AppColorTheme.colorThemePink,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      AppStringsNew2.offeredText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD03,
                                    ),
                                    Container(
                                      width: size.width * AppDimensions.numD24,
                                      padding: EdgeInsets.symmetric(
                                          // horizontal: size.width * AppDimensions.numD05,
                                          vertical: size.width *
                                              AppDimensions.numD02),
                                      decoration: BoxDecoration(
                                          color: AppColorTheme.colorThemePink,
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD02)),
                                      child: Center(
                                        child: Text(
                                          AppStringsNew2.videoText
                                              .toUpperCase(),
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD033,
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
                            height: size.width * AppDimensions.numD03,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding:
                            EdgeInsets.all(size.width * AppDimensions.numD025),
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
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD04,
                ),
                uploadMediaInfoWidget('', size),
                SizedBox(
                  height: size.width * AppDimensions.numD033,
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
                            visible: item.messageType == "media" ||
                                item.messageType == "task_content",
                            child: ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    height: size.width * AppDimensions.numD035,
                                  );
                                },
                                shrinkWrap: true,
                                itemBuilder: (context, idx) {
                                  var item1 = item.mediaList[idx];
                                  if (item.messageType == "media" ||
                                      item.messageType == "task_content") {
                                    if (item1.type.contains("video")) {
                                      return rightVideoChatWidget(
                                          item1.thumbnail,
                                          item1.imageVideoUrl,
                                          item.createdAtTime,
                                          size,
                                          item1.address);
                                    } else if (item1.type.contains("audio")) {
                                      return rightAudioChatWidget(
                                          item1.imageVideoUrl,
                                          item.createdAtTime,
                                          size,
                                          item1.address);
                                    } else {
                                      return rightImageChatWidget(
                                          getMediaImageUrl(item1.imageVideoUrl,
                                              isTask: true),
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
                                  height: size.width * AppDimensions.numD035,
                                ),
                                thanksToUploadMediaWidget(
                                    "",
                                    size,
                                    item.imageCount,
                                    item.videoCount,
                                    item.audioCount),
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
                                  height: size.width * AppDimensions.numD04,
                                ),
                                myEarningWidget(
                                    item.mediaHouseName,
                                    mediaInfo(item),
                                    item.payableHopperPrice,
                                    size)
                              ],
                            ),
                          ),
                          Visibility(
                            visible: item.messageType == "request_more_content",
                            child: moreContentReqWidget(item, size),
                          ),
                          Visibility(
                            visible: item.messageType == "contentupload",
                            child: uploadMediaInfoWidget(
                                "request_more_content", size),
                          ),
                          Visibility(
                              visible: item.messageType == "NocontentUpload",
                              child: uploadNoContentWidget(size))
                        ],
                      );
                    },
                    itemCount: chatList.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: size.width * AppDimensions.numD035,
                      );
                    },
                  ),
                  widget.taskDetail!.task.paidStatus == "paid"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: size.width * AppDimensions.numD013),
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
                                  padding: EdgeInsets.all(
                                      size.width * AppDimensions.numD01),
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
                                    horizontal:
                                        size.width * AppDimensions.numD05,
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                width: size.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(
                                          size.width * AppDimensions.numD04),
                                      bottomLeft: Radius.circular(
                                          size.width * AppDimensions.numD04),
                                      bottomRight: Radius.circular(
                                          size.width * AppDimensions.numD04),
                                    )),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.width * AppDimensions.numD01,
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
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          TextSpan(
                                            text:
                                                "${widget.taskDetail!.task.mediaHouse.firstName} ${widget.taskDetail!.task.mediaHouse.lastName}",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                            text:
                                                " has purchased your content for ",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          TextSpan(
                                            text: true
                                                ? "$currencySymbol${formatDouble(double.tryParse("0") ?? 0.0)}"
                                                : "-",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ])),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD03,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height:
                                              size.width * AppDimensions.numD13,
                                          width: size.width,
                                          child: commonElevatedButton(
                                              "View Transaction Details",
                                              size,
                                              commonButtonTextStyle(size),
                                              commonButtonStyle(size,
                                                  AppColorTheme.colorThemePink),
                                              () {
                                            context.read<TaskBloc>().add(
                                                GetContentTransactionDetailsEvent(
                                                    roomId: widget.roomId,
                                                    mediaHouseId: widget
                                                        .taskDetail!
                                                        .task
                                                        .mediaHouse
                                                        .id));
                                          }),
                                        ),
                                        SizedBox(
                                          height:
                                              size.width * AppDimensions.numD01,
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
                    height: widget.taskDetail!.task.paidStatus == "paid"
                        ? size.width * AppDimensions.numD035
                        : 0,
                  ),
                  widget.taskDetail!.task.paidStatus == "paid"
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: size.width * AppDimensions.numD013),
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
                                  padding: EdgeInsets.all(
                                      size.width * AppDimensions.numD01),
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
                                    horizontal:
                                        size.width * AppDimensions.numD05,
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                width: size.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: AppColorTheme
                                            .colorGoogleButtonBorder),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(
                                          size.width * AppDimensions.numD04),
                                      bottomLeft: Radius.circular(
                                          size.width * AppDimensions.numD04),
                                      bottomRight: Radius.circular(
                                          size.width * AppDimensions.numD04),
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
                                              fontSize: size.width *
                                                  AppDimensions.numD037,
                                              fontFamily: "AirbnbCereal",
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                          TextSpan(
                                            text: "Woohoo! We have paid ",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          TextSpan(
                                            text:
                                                "$currencySymbol${formatDouble(double.tryParse("0") ?? 0.0)}",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                            text:
                                                " into your bank account. Please visit ",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          TextSpan(
                                            text: "My Earnings",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                            text: " to view your transaction ",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD036,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          )
                                        ])),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD03,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height:
                                              size.width * AppDimensions.numD13,
                                          width: size.width,
                                          child: commonElevatedButton(
                                              "View My Earnings",
                                              size,
                                              commonButtonTextStyle(size),
                                              commonButtonStyle(size,
                                                  AppColorTheme.colorThemePink),
                                              () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyEarningScreen(
                                                          openDashboard: false,
                                                          initialTapPosition: 0,
                                                        )));
                                          }),
                                        ),
                                        SizedBox(
                                          height:
                                              size.width * AppDimensions.numD01,
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
                  widget.taskDetail!.task.paidStatus == "paid"
                      ? ratingReview(size, widget.taskDetail!)
                      : Container()
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget uploadMediaInfoWidget(String uploadTextType, var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // margin: EdgeInsets.only(top: uploadTextType == "request_more_content" ? size.width * AppDimensions.numD04 : 0),
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
            // margin: EdgeInsets.only(top: uploadTextType == "request_more_content" ? size.width * AppDimensions.numD05 : 0),
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
                          thumbnail.isNotEmpty
                              ? thumbnail
                              : getMediaImageUrl(videoUrl,
                                  isVideo: true, isTask: true),
                          height: size.height / 3,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, s, o) {
                            return Image.asset(
                              "${commonImagePath}rabbitLogo.png",
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
                      top: size.width * AppDimensions.numD02,
                      left: size.width * AppDimensions.numD02,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD006,
                            vertical: size.width * AppDimensions.numD002),
                        decoration: BoxDecoration(
                            color:
                                AppColorTheme.colorLightGreen.withOpacity(0.8),
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
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => MediaViewScreen(
                                mediaFile: videoUrl,
                                type: MediaTypeEnum.video,
                              )));
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
            (sharedPreferences!.getString(avatarKey) ?? "").isNotEmpty
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
                          sharedPreferences!.getString(avatarKey) ?? "",
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
              "${dateTimeFormatter(dateTime: time, format: 'hh:mm a')}, ${dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy')}",
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
              "${iconsPath}ic_location.png",
              height: size.width * AppDimensions.numD035,
              color: Colors.black,
            ),
            SizedBox(
              width: size.width * AppDimensions.numD01,
            ),
            Flexible(
              child: Padding(
                padding:
                    EdgeInsets.only(right: size.width * AppDimensions.numD13),
                child: Text(
                  address.isNotEmpty ? address : "N/A",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD028,
                      color: AppColorTheme.colorHint,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: size.width * AppDimensions.numD018,
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
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD04),
                      child: Container(
                        color: AppColorTheme.colorThemePink,
                        height: size.height / 3,
                        width: double.infinity,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
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
                              color: AppColorTheme.colorLightGreen
                                  .withOpacity(0.8),
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
              (sharedPreferences!.getString(avatarKey) ?? "").isNotEmpty
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
                            sharedPreferences!.getString(avatarKey) ?? "",
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
                "${dateTimeFormatter(dateTime: time, format: 'hh:mm a')}, ${dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy')}",
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
                "${iconsPath}ic_location.png",
                height: size.width * AppDimensions.numD035,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * AppDimensions.numD01,
              ),
              Flexible(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: size.width * AppDimensions.numD13),
                  child: Text(
                    address.isNotEmpty ? address : "N/A",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD028,
                        color: AppColorTheme.colorHint,
                        fontWeight: FontWeight.normal),
                  ),
                ),
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
                            horizontal: size.width * AppDimensions.numD01,
                          ),
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
              sharedPreferences!.getString(avatarKey).toString().isNotEmpty
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
                                  .getString(avatarKey)
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
                "${dateTimeFormatter(dateTime: time, format: 'hh:mm a')}, ${dateTimeFormatter(dateTime: time, format: 'dd MMM yyyy')}",
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
                "${iconsPath}ic_location.png",
                height: size.width * AppDimensions.numD035,
                color: Colors.black,
              ),
              SizedBox(
                width: size.width * AppDimensions.numD01,
              ),
              Flexible(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: size.width * AppDimensions.numD13),
                  child: Text(
                    address.isNotEmpty ? address : "N/A",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD028,
                        color: AppColorTheme.colorHint,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: size.width * AppDimensions.numD018,
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
                        text: "Thanks, you've uploaded ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
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
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ])),
                // SizedBox(
                //   height: size.width * AppDimensions.numD008,
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
                  topRight: Radius.circular(size.width * AppDimensions.numD04),
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
                        text: "Congratulations,",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: ' $mediaHouseName',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " have purchased ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: mediaCount,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " for ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: "$currencySymbol$amount",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
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
                    commonButtonStyle(size, AppColorTheme.colorThemePink), () {
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
    context.read<TaskBloc>().add(GetTaskTransactionDetailsEvent(id));
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
                  topRight: Radius.circular(size.width * AppDimensions.numD04),
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
                        text: "Woohoo! We have paid",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: " $currencySymbol$amount",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: AppColorTheme.colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: " into your bank account. Please visit  ",
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
                        text: " to view your transaction",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD036,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ]),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              SizedBox(
                height: size.width * AppDimensions.numD13,
                width: size.width,
                child: commonElevatedButton(
                    "View My Earnings",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, AppColorTheme.colorThemePink), () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MyEarningScreen(
                            openDashboard: false,
                            initialTapPosition: 0,
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
                "Congrats, you’ve received $currencySymbol$amount from Reuters Media ",
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
    );
  }

  Widget profilePicWidget(var size) {
    return Container(
        //margin: EdgeInsets.only(top: size.width * AppDimensions.numD03),
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400)),
        child: ClipOval(
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            widget.taskDetail?.task.mediaHouse.profileImage ?? "",
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

  Widget moreContentReqWidget(ManageTaskChatModel item, var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        profilePicWidget(size),
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
                                  : Colors.black,
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
                                : Colors.white,
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

  Widget uploadNoContentWidget(var size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // margin: EdgeInsets.only(top: size.width * AppDimensions.numD03),
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
            // margin: EdgeInsets.only(top: size.width * AppDimensions.numD03),
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

  Widget mediaHouseOfferWidget(
      ManageTaskChatModel item, bool isMakeCounter, var size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.width * AppDimensions.numD026,
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
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
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
                    border: Border.all(
                        color: AppColorTheme.colorGoogleButtonBorder),
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
                      height: size.width * AppDimensions.numD009,
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
                                      fontSize:
                                          size.width * AppDimensions.numD036,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                TextSpan(
                                  text: " ${item.mediaHouseName}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD036,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w600),
                                ),
                              ])),
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                left: size.width * AppDimensions.numD01),
                            width: size.width * AppDimensions.numD13,
                            height: size.width * AppDimensions.numD13,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD03),
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
                                height: size.width * AppDimensions.numD20,
                                width: size.width * AppDimensions.numD20,
                                errorBuilder: (context, exception, stackTrace) {
                                  return Image.asset(
                                    "${commonImagePath}rabbitLogo.png",
                                    fit: BoxFit.contain,
                                    width: size.width * AppDimensions.numD20,
                                    height: size.width * AppDimensions.numD20,
                                  );
                                },
                              ),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD03,
                    ),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD012),
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD03),
                          border: Border.all(
                              color: const Color(0xFFd4dedd), width: 2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Offered Price",
                            style: TextStyle(
                                fontSize: size.width * AppDimensions.numD035,
                                color: AppColorTheme.colorLightGreen,
                                fontFamily: 'AirbnbCereal'),
                          ),
                          Text(
                            item.hopperPrice.isEmpty
                                ? ""
                                : "$currencySymbol${formatDouble(double.tryParse(item.hopperPrice) ?? 0.0)}",
                            style: TextStyle(
                                fontSize: size.width * AppDimensions.numD045,
                                color: AppColorTheme.colorLightGreen,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'AirbnbCereal'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD01,
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
                  margin:
                      EdgeInsets.only(top: size.width * AppDimensions.numD06),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                      ]),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
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
                margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD05,
                    vertical: size.width * AppDimensions.numD02),
                width: size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: AppColorTheme.colorGoogleButtonBorder),
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
                            style: const TextStyle(
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                          TextSpan(
                            text: "Congratulations, ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD036,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: item.mediaHouseName,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD036,
                                color: AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: " has purchased your content for ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD036,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          ),
                          TextSpan(
                            text: item.hopperPrice.isEmpty
                                ? ""
                                : "$currencySymbol${formatDouble(double.tryParse(item.hopperPrice) ?? 0.0)}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD036,
                                color: AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                        ])),
                    SizedBox(
                      height: size.width * AppDimensions.numD03,
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD03,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * AppDimensions.numD13,
                          width: size.width,
                          child: commonElevatedButton(
                              "View Transaction Details ",
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(
                                  size, AppColorTheme.colorThemePink), () {
                            context.read<TaskBloc>().add(
                                GetContentTransactionDetailsEvent(
                                    roomId: widget.roomId,
                                    mediaHouseId: item.mediaHouseId));
                            // Assuming navigation or dialog is handled by BLoC Listener
                          }),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD01,
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
                  margin:
                      EdgeInsets.only(top: size.width * AppDimensions.numD06),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, spreadRadius: 2)
                      ]),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
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
                margin: EdgeInsets.only(top: size.width * AppDimensions.numD06),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD05,
                    vertical: size.width * AppDimensions.numD02),
                width: size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: AppColorTheme.colorGoogleButtonBorder),
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
                            text: item.payableHopperPrice.isEmpty
                                ? ""
                                : "$currencySymbol${formatDouble(double.tryParse(item.payableHopperPrice) ?? 0.0)}",
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
                      height: size.width * AppDimensions.numD03,
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MyEarningScreen(
                                      openDashboard: false,
                                      initialTapPosition: 2,
                                    )));
                          }),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD01,
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

  Widget ratingReview(Size size, TaskAssignedEntity taskDetail) {
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
              margin:
                  EdgeInsets.only(bottom: size.width * AppDimensions.numD06),
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
                      text: TextSpan(children: [
                    TextSpan(
                      text: "Rate your experience with PressHop",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD036,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                    ),
                  ])),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
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
                    itemSize: size.width * AppDimensions.numD09,
                    itemCount: 5,
                    initialRating: ratings,
                    allowHalfRating: true,
                    itemPadding: EdgeInsets.only(
                        left: size.width * AppDimensions.numD03),
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
                    height: size.width * AppDimensions.numD018,
                  ),
                  Wrap(
                      children: List<Widget>.generate(intList.length, (index) {
                    return Container(
                      margin: EdgeInsets.only(
                          left: size.width * 0.02, right: size.width * 0.02),
                      child: ChoiceChip(
                        label: Text(intList[index]),
                        labelStyle: TextStyle(
                            color: dataList.contains(intList[index])
                                ? Colors.white
                                : AppColorTheme.colorGrey6),
                        onSelected: (selected) {
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
                        selectedColor: AppColorTheme.colorThemePink,
                        disabledColor:
                            AppColorTheme.colorGreyChat.withOpacity(.3),
                        selected:
                            dataList.contains(intList[index]) ? true : false,
                      ),
                    );
                  })),
                  SizedBox(
                    height: size.width * AppDimensions.numD02,
                  ),
                  Stack(
                    children: [
                      TextFormField(
                        controller: ratingReviewController1,
                        cursorColor: AppColorTheme.colorTextFieldIcon,
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        readOnly: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * AppDimensions.numD035,
                        ),
                        onChanged: (v) {
                          onTextChanged();
                        },
                        decoration: InputDecoration(
                          hintText: AppStringsNew2.textData,
                          contentPadding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD08,
                              right: size.width * AppDimensions.numD02,
                              top: size.width * AppDimensions.numD075),
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              wordSpacing: 2,
                              fontSize: size.width * AppDimensions.numD035),
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
                            top: size.width * AppDimensions.numD038,
                            left: size.width * AppDimensions.numD014),
                        child: Image.asset(
                          "${iconsPath}docs.png",
                          width: size.width * 0.06,
                          height: size.width * 0.07,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.width * AppDimensions.numD017),
                  ratingReviewController1.text.isEmpty
                      ? const Text(
                          "Required",
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w400),
                        )
                      : Container(),
                  SizedBox(height: size.width * AppDimensions.numD04),
                  SizedBox(
                    height: size.width * AppDimensions.numD13,
                    width: size.width,
                    child: commonElevatedButton(
                        isRatingGiven
                            ? "Thanks a Ton"
                            : AppStringsNew2.submitText,
                        size,
                        isRatingGiven
                            ? TextStyle(
                                color: Colors.black,
                                fontSize: size.width * AppDimensions.numD037,
                                fontFamily: "AirbnbCereal",
                                fontWeight: FontWeight.bold)
                            : commonButtonTextStyle(size),
                        commonButtonStyle(
                            size,
                            isRatingGiven
                                ? Colors.grey
                                : AppColorTheme.colorThemePink),
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
                                      "Please enter some review for mediahouse",
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
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              lineHeight: 1.2,
                              fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                            text: "Terms & Conditions. ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: AppColorTheme.colorThemePink,
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
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                            text: "contact ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: AppColorTheme.colorThemePink,
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
                              fontSize: size.width * AppDimensions.numD035,
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

  void socketEmitFunc({
    required String socketEvent,
    required String messageType,
    Map<String, dynamic>? dataMap,
    String mediaType = "",
  }) {
    debugPrint(":::: Inside Socket Emit :::::");

    Map<String, dynamic> map = {
      "message_type": messageType,
      "receiver_id": widget.taskDetail?.task.mediaHouse.id ?? "5",
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
    if (mounted) {
      context.read<TaskBloc>().add(GetTaskChatEvent(
          roomId: widget.roomId,
          type: "task_content",
          contentId: widget.taskDetail?.task.id ?? "",
          showLoader: false));
    }
  }

  void socketConnectionFunc() {
    debugPrint(":::: Inside Socket Func :::::");
    debugPrint("socketUrl:::::$socketUrl");
    socket = IO.io(
        socketUrl, IO.OptionBuilder().setTransports(['websocket']).build());

    debugPrint("Socket Disconnect : ${socket.connected}");
    debugPrint("Socket Disconnect : ${widget.taskDetail?.task.mediaHouse.id}");

    socket.connect();

    socket.onConnect((_) {
      socket.emit('room join', {"room_id": widget.roomId});
    });

    debugPrint("Socket connected : ${socket.connected}");

    void refreshChat(data) {
      if (mounted) {
        context.read<TaskBloc>().add(GetTaskChatEvent(
            roomId: widget.roomId,
            type: "task_content",
            contentId: widget.taskDetail?.task.id ?? "",
            showLoader: false));
      }
    }

    socket.on("chat message", refreshChat);
    socket.on("getallchat", refreshChat);
    socket.on("updatehide", refreshChat);
    socket.on("media message", refreshChat);
    socket.on("offer message", refreshChat);
    socket.on("rating", refreshChat);
    // socket.on("room join", refreshChat);
    socket.on("initialoffer", refreshChat);
    socket.on("updateOffer", refreshChat);
    socket.on("leave room", refreshChat);

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

          var validationVideoLenght = true;
          if (mimeType?.contains("video") ?? false) {
            VideoPlayerController controller =
                VideoPlayerController.file(File(filePath));
            try {
              await controller.initialize();
              if (controller.value.duration.inSeconds >
                  (sharedPreferences!.getInt(videoLimitKey) ?? 120)) {
                showToast(
                    "Videos can be up to 2 minutes long — keep it quick, punchy, and straight to the point🎥");
                validationVideoLenght = false;
                return;
              }
            } finally {
              await controller.dispose();
            }
          }

          if (validationVideoLenght) {
            selectMultipleMediaList.add(
              MediaData(
                isFromGallery: true,
                dateTime: "",
                latitude: latitude.toString(),
                location: address,
                longitude: longitude.toString(),
                mediaPath: filePath,
                mimeType: mimeType!,
                thumbnail: "",
              ),
            );
          }
        }
        await previewBottomSheet();
        if (mounted) {
          setState(() {});
        }
      } else {
        debugPrint("No videos selected.");
      }
    } catch (e) {
      debugPrint("Error picking videos: $e");
    }
  }

  Future<void> previewBottomSheet() async {
    debugPrint("previewBottomSheet: Pushing MediaPreviewScreen");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPreviewScreen(
          mediaList: selectMultipleMediaList,
          onMediaUpdated: (updatedList) {
            selectMultipleMediaList = updatedList;
            setState(() {});
          },
        ),
      ),
    );
    debugPrint("previewBottomSheet: Popped with result: $result");

    if (result == "upload") {
      debugPrint("previewBottomSheet: Triggering upload");
      callUploadMediaApi();
    }
  }

  /// Upload media
  void callUploadMediaApi() async {
    List<String> mediaList =
        selectMultipleMediaList.map((e) => e.mediaPath).toList();

    FormData formData = FormData.fromMap({
      'task_id': widget.taskDetail!.task.id,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "address": address,
    });

    for (String path in mediaList) {
      formData.files.add(MapEntry(
        "files",
        await MultipartFile.fromFile(path),
      ));
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
      context
          .read<TaskBloc>()
          .add(UploadTaskMediaEvent(formData, showLoader: false));
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
                    topLeft: Radius.circular(size.width * AppDimensions.numD04),
                    topRight:
                        Radius.circular(size.width * AppDimensions.numD04))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: size.width * AppDimensions.numD06,
                      right: size.width * AppDimensions.numD03,
                      top: size.width * AppDimensions.numD018),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Option",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: size.width * AppDimensions.numD048,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close_rounded,
                              color: Colors.black,
                              size: size.width * AppDimensions.numD08)),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD04,
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: size.width * AppDimensions.numD06,
                      right: size.width * AppDimensions.numD06),
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
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD02),
                              ),
                              height: size.width * AppDimensions.numD25,
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload,
                                      size: size.width * AppDimensions.numD08),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD03,
                                  ),
                                  Text(
                                    "My Gallery",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
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
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD02),
                              ),
                              height: size.width * AppDimensions.numD25,
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD04),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_copy_outlined,
                                    size: size.width * AppDimensions.numD08,
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD03,
                                  ),
                                  Text(
                                    "My Files",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
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
                  height: size.width * AppDimensions.numD06,
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
  //           insetPadding: EdgeInsets.symmetric(horizontal: size.width * AppDimensions.numD02),
  //           content: StatefulBuilder(
  //               builder: (BuildContext context, StateSetter setState) {
  //             return Container(
  //               width: size.width * AppDimensions.num1,
  //               height: size.height * AppDimensions.numD18,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(size.width * AppDimensions.numD025),
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
  //                               MediaQuery.of(context).size.width * AppDimensions.numD045,
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
  //                             color: AppColorTheme.colorThemePink,
  //                             size: size.width * AppDimensions.numD07,
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
  //                         width: size.width * AppDimensions.numD45,
  //                         height: size.height * AppDimensions.numD055,
  //                         child: commonElevatedButton(
  //                             "Photo Gallery",
  //                             size,
  //                             commonButtonTextStyle(size),
  //                             commonButtonStyle(size, AppColorTheme.colorThemePink), () {
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
  //                         width: size.width * AppDimensions.numD45,
  //                         height: size.height * AppDimensions.numD055,
  //                         child: commonElevatedButton(
  //                             "My File",
  //                             size,
  //                             commonButtonTextStyle(size),
  //                             commonButtonStyle(size, AppColorTheme.colorThemePink), () {
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
  MediaModel({
    required this.mediaFile,
    required this.mimetype,
  });
  XFile? mediaFile;
  String mimetype = "";
}

class LoadingDialogContent extends StatefulWidget {
  const LoadingDialogContent({super.key, required this.progress});
  final double progress;

  @override
  State<LoadingDialogContent> createState() => _LoadingDialogContentState();
}

class _LoadingDialogContentState extends State<LoadingDialogContent> {
  int _dotCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    String dots = "." * _dotCount;
    String text;
    if (widget.progress >= 1.0) {
      text = "Processing$dots";
    } else {
      text = "Uploading$dots ${(widget.progress * 100).toStringAsFixed(0)}%";
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              "assets/lottieFiles/loader_new.json",
              height: 100,
              width: 100,
            ),
            // const SizedBox(height: 0),
            Text(
              text,
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD035,
                  color: const Color.fromARGB(255, 204, 208, 208),
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
