import 'package:presshop/core/services/media_upload_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/pages/PreviewScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/earning/presentation/pages/TransactionDetailScreen.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';

import 'package:presshop/core/constants/string_constants_new2.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:location/location.dart' as lc;
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';

import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/widgets/task_chat_bubbles.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/widgets/chat_action_bubbles.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/widgets/rating_review_bubble.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/widgets/task_chat_header.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/widgets/loading_dialog_content.dart';

class BroadCastChatTaskScreen extends StatefulWidget {
  const BroadCastChatTaskScreen({
    super.key,
    required this.taskDetail,
    required this.roomId,
  });
  final TaskAssignedEntity? taskDetail;
  final String roomId;

  @override
  State<BroadCastChatTaskScreen> createState() =>
      _BroadCastChatTaskScreenState();
}

class _BroadCastChatTaskScreenState extends State<BroadCastChatTaskScreen> {
  List<ManageTaskChatModel> chatList = [];
  late IO.Socket socket;
  final String _senderId =
      sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
  TextEditingController ratingReviewController1 = TextEditingController();
  List<String> intList = [
    "User experience",
    "Safe",
    "Easy to use",
    "Instant money",
    "Anonymity",
    "Secure Payment",
    "Hopper Support",
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
  String? _currentUploadingLocalTaskId; // Track current uploading task

  void showProgressDialog() {
    _shouldCloseDialog = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _dialogStateSetter = setState;
            if (_shouldCloseDialog) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && context.canPop()) {
                  context.pop();
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
    debugPrint("🔍 BroadCastChatTaskScreen initState:");
    debugPrint("🔍 roomId: ${widget.roomId}");
    debugPrint("🔍 taskDetail: ${widget.taskDetail?.task.id}");

    super.initState();
    socketConnectionFunc();
    // Only fetch if list is empty to avoid double fetch on rebuilds if any
    if (chatList.isEmpty) {
      isLoading = true;
      context.read<TaskBloc>().add(
            GetTaskChatEvent(
              roomId: widget.roomId,
              type: "task_content",
              contentId: widget.taskDetail?.task.id ?? "",
              showLoader: false,
            ),
          );
    }
    getCurrentLocation();

    // Listen to upload status changes to update local task progress
    MediaUploadService.uploadStatus.addListener(_onUploadStatusChanged);
  }

  void _onUploadStatusChanged() {
    final status = MediaUploadService.uploadStatus.value;
    if (status != null && mounted && _currentUploadingLocalTaskId != null) {
      // Update the local task with the stored ID
      context.read<TaskBloc>().add(
            UpdateLocalTaskProgressEvent(
              taskId: _currentUploadingLocalTaskId!,
              progress: status['progress'] ?? 0,
              status: status['status'] ?? '',
            ),
          );
    }
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
      context.pop();
      _dialogStateSetter = null;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      // Fetch current location using your custom LocationService
      locationData = await LocationService().getCurrentLocation(
        context,
        shouldShowSettingPopup: false,
      );

      debugPrint("GettingLocation ==> $locationData");

      if (locationData != null && locationData!.latitude != null) {
        latitude = locationData!.latitude!;
        longitude = locationData!.longitude!;

        List<Placemark> placemarks = await placemarkFromCoordinates(
          latitude,
          longitude,
        );
        Placemark place = placemarks.first;
        address =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";

        debugPrint("📍 Location Address resolved: $address");
        if (mounted) setState(() {});
      } else {
        debugPrint("Location data is null");
      }
    } catch (e) {
      debugPrint("PEx: $e");
    }
  }

  @override
  void dispose() {
    // Remove upload status listener
    MediaUploadService.uploadStatus.removeListener(_onUploadStatusChanged);
    socket.disconnect();
    socket.onDisconnect(
      (_) => socket.emit('room join', {"room_id": widget.roomId}),
    );
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
      mediaDetails.add(
        "$audioCount ${audioCount > 1 ? "interviews" : "interview"}",
      );
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
        if (state.allTasksStatus == TaskStatus.loading ||
            state.taskDetailStatus == TaskStatus.loading ||
            state.localTasksStatus == TaskStatus.loading ||
            state.actionStatus == TaskStatus.loading) {
          setState(() {
            isLoading = true;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }

        if (state.actionStatus == TaskStatus.success) {
          setState(() {
            chatList = state.chatList;
          });
        } else if (state.transactions.isNotEmpty) {
          earningTransactionDataList = state.transactions;
          if (earningTransactionDataList.isNotEmpty) {
            if (earningTransactionDataList.isNotEmpty) {
              context.pushNamed(
                AppRoutes.transactionDetailName,
                extra: {
                  'pageType': PageType.TASK,
                  'type': "received",
                  'transactionData':
                      earningTransactionDataList.first.toEntity(),
                },
              );
            }
          }
        } else if (state.actionStatus == TaskStatus.success) {
          showSnackBar("Success", "Media uploaded successfully", Colors.green);
          if (mounted) {
            context.read<TaskBloc>().add(
                  GetTaskChatEvent(
                    roomId: widget.roomId,
                    type: "task_content",
                    contentId: widget.taskDetail?.task.id ?? "",
                    showLoader: false,
                  ),
                );
          }
        } else if (state.errorMessage != null) {
          showSnackBar("Error", state.errorMessage!, Colors.red);
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
                fontSize: size.width * AppDimensions.appBarHeadingFontSize,
              ),
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
              SizedBox(width: size.width * AppDimensions.numD04),
            ],
          ),
          bottomNavigationBar: isLoading
              ? showLoader()
              : Padding(
                  padding: EdgeInsets.only(
                    bottom: size.height * AppDimensions.numD03,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04,
                            vertical: size.width * AppDimensions.numD02,
                          ),
                          height: size.width * AppDimensions.numD18,
                          child: commonElevatedButton(
                            AppStringsNew2.galleryText,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, Colors.black),
                            () {
                              showGallaryChooser();
                              // LocationService()
                              //     .getCurrentLocation(context)
                              //     .then((locationData) {
                              //   if (locationData != null) {
                              //     showGallaryChooser();
                              //   }
                              // });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04,
                            vertical: size.width * AppDimensions.numD02,
                          ),
                          height: size.width * AppDimensions.numD18,
                          child: commonElevatedButton(
                            AppStringsNew2.cameraText,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                              size,
                              AppColorTheme.colorThemePink,
                            ),
                            () {
                              context.pushNamed(
                                AppRoutes.cameraName,
                                extra: {
                                  'picAgain': true,
                                  'previousScreen':
                                      ScreenNameEnum.manageTaskScreen,
                                },
                              ).then((value) {
                                if (value != null &&
                                    value is List<CameraData>) {
                                  debugPrint(
                                    "value:::::$value::::::::${value.first.path}",
                                  );
                                  List<CameraData> temData = value;
                                  for (var element in temData) {
                                    selectMultipleMediaList.add(
                                      MediaData(
                                        isFromGallery: element.fromGallary,
                                        dateTime: "",
                                        latitude: latitude.toString(),
                                        location: address,
                                        longitude: longitude.toString(),
                                        country: "",
                                        state: "",
                                        city: "",
                                        mediaPath: element.path,
                                        mimeType: element.mimeType,
                                        thumbnail: "",
                                      ),
                                    );
                                  }
                                  previewBottomSheet();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * AppDimensions.numD04),
            child: Column(
              children: [
                TaskChatHeader(taskDetail: widget.taskDetail!),
                SizedBox(height: size.width * AppDimensions.numD04),
                SizedBox(height: size.width * AppDimensions.numD04),
                const UploadInfoBubble(uploadTextType: ''),
                SizedBox(height: size.width * AppDimensions.numD033),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var item = chatList[index];
                        debugPrint(
                          "📨 Rendering message $index: type=${item.messageType}, sender=${item.senderType}, message=${item.message}",
                        );
                        return _buildChatBubble(item, size);
                      },
                      itemCount: chatList.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: size.width * AppDimensions.numD035,
                        );
                      },
                    ),
                    widget.taskDetail!.task.paidStatus == "paid"
                        ? CongratulationsBubble(
                            roomId: widget.roomId,
                            mediaHouseName:
                                "${widget.taskDetail!.task.mediaHouse.firstName} ${widget.taskDetail!.task.mediaHouse.lastName}"
                                    .toCapitalized(),
                            mediaCount: "",
                            amount:
                                "-", // Or some actual amount if available in taskDetail
                            transactionId:
                                "", // Or some actual transactionId if available
                          )
                        : const SizedBox.shrink(),
                    if (widget.taskDetail!.task.paidStatus == "paid") ...[
                      SizedBox(height: size.width * AppDimensions.numD035),
                      EarningBubble(
                        amount: widget.taskDetail!.task.hopperTaskAmount,
                      ),
                      SizedBox(height: size.width * AppDimensions.numD035),
                      RatingReviewBubble(
                        likedFeatures: intList,
                        isAlreadyRated: isRatingGiven,
                        onSubmit: (rating, review, features) {
                          ratings = rating;
                          ratingReviewController1.text = review;
                          dataList = features;
                          _submitRating();
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitRating() {
    if (ratingReviewController1.text.isNotEmpty) {
      var map = {
        "rating": ratings,
        "review": ratingReviewController1.text,
        "features": dataList,
        "image_id": imageId,
        "type": "content",
        "sender_type": "hopper",
      };
      debugPrint("map function $map");
      socketEmitFunc(
        socketEvent: "rating",
        messageType: "rating_for_hopper",
        dataMap: map,
      );
      showSnackBar(
        "Rating & Review",
        "Thanks for the love! Your feedback makes all the difference ❤️",
        Colors.green,
      );
      setState(() {
        isRatingGiven = true;
        showCelebration = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showCelebration = false;
          });
        }
      });
    } else {
      showSnackBar(
        "Required *",
        "Please enter some review for mediahouse",
        Colors.red,
      );
    }
  }

  Widget _buildChatBubble(ManageTaskChatModel item, Size size) {
    if (item.messageType == "media" || item.messageType == "task_content") {
      if (item.mediaList.isEmpty) {
        if (item.message.isNotEmpty) {
          if (item.senderType == "MediaHouse") {
            return LeftTextChatBubble(item: item);
          } else {
            // For hopper messages with text but marked as media
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(size.width * AppDimensions.numD04),
                    decoration: BoxDecoration(
                      color: AppColorTheme.colorThemePink,
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(size.width * AppDimensions.numD04),
                        bottomLeft:
                            Radius.circular(size.width * AppDimensions.numD04),
                        bottomRight:
                            Radius.circular(size.width * AppDimensions.numD04),
                      ),
                    ),
                    child: Text(
                      item.message,
                      textAlign: TextAlign.right,
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD036,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * AppDimensions.numD04),
                const HopperAvatar(),
              ],
            );
          }
        }
        // If entirely empty (no media, no text), maybe show a placeholder "Media uploaded"
        if (item.senderType == "hopper") {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04,
                  vertical: size.width * AppDimensions.numD02,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(
                    size.width * AppDimensions.numD04,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.image_outlined,
                        size: size.width * AppDimensions.numD05),
                    SizedBox(width: size.width * AppDimensions.numD02),
                    Text(
                      "Media Uploaded",
                      style: TextStyle(
                        fontSize: size.width * AppDimensions.numD03,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * AppDimensions.numD04),
              const HopperAvatar(),
            ],
          );
        }
        return const SizedBox.shrink();
      }

      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            SizedBox(height: size.width * AppDimensions.numD035),
        shrinkWrap: true,
        itemCount: item.mediaList.length,
        itemBuilder: (context, idx) {
          var mediaItem = item.mediaList[idx];
          // Use media item's address, fallback to device's current address
          String displayAddress =
              mediaItem.address.isNotEmpty ? mediaItem.address : address;
          return RightMediaChatBubble(
            item: item,
            address: displayAddress,
            currentUploadingLocalTaskId: _currentUploadingLocalTaskId,
          );
        },
      );
    }

    switch (item.messageType) {
      case "text":
        if (item.senderType == "MediaHouse") {
          return LeftTextChatBubble(item: item);
        }
        return const SizedBox.shrink();
      case "initialoffer":
      case "updateOffer":
      case "Mediahouse_initial_offer":
        return MediaHouseOfferBubble(
          item: item,
          isMakeCounter: item.messageType == "Mediahouse_initial_offer",
        );
      case "PaymentIntent":
        return Column(
          children: [
            CongratulationsBubble(
              roomId: item.roomId,
              mediaHouseName: item.mediaHouseName.toCapitalized(),
              mediaCount: mediaInfo(item),
              amount: item.hopperPrice,
              transactionId: item.transactionId,
            ),
            SizedBox(height: size.width * AppDimensions.numD04),
            EarningBubble(amount: item.payableHopperPrice),
          ],
        );
      case "action_required":
        return ActionRequiredBubble(
          item: item,
          onEmit: (event, type, data) {
            socketEmitFunc(
              socketEvent: event,
              messageType: type,
              dataMap: data,
            );
          },
        );
      case "action_response":
        return ActionResponseBubble(message: item.message);
      case "request_more_content":
        return MoreContentRequestBubble(
          item: item,
          onEmit: (event, type, data) {
            socketEmitFunc(
              socketEvent: event,
              messageType: type,
              dataMap: data ?? {},
            );
          },
        );
      case "contentupload":
        return const UploadInfoBubble(uploadTextType: "request_more_content");
      case "NocontentUpload":
        return const UploadNoContentBubble();
      case "thanksToUploadMedia":
        return MediaUploadSuccessBubble(
          imgCount: item.imageCount,
          vidCount: item.videoCount,
          audioCount: item.audioCount,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void socketEmitFunc({
    required String socketEvent,
    required String messageType,
    Map<String, dynamic>? dataMap,
    String mediaType = "",
  }) {
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

    debugPrint("📤 [SOCKET EMIT] Event: $socketEvent");
    debugPrint("📤 [SOCKET DATA] $map");

    socket.emit(socketEvent, map);

    if (mounted) {
      context.read<TaskBloc>().add(
            GetTaskChatEvent(
              roomId: widget.roomId,
              type: "task_content",
              contentId: widget.taskDetail?.task.id ?? "",
              showLoader: false,
            ),
          );
    }
  }

  void socketConnectionFunc() {
    debugPrint(
      "🔌 Socket Initialize - URL: ${ApiConstantsNew.config.socketUrl2}",
    );
    socket = IO.io(
      ApiConstantsNew.config.socketUrl2,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.connect();

    socket.onConnect((_) {
      debugPrint("✅ SOCKET CONNECTED - Room: ${widget.roomId}");
      socket.emit('room join', {"room_id": widget.roomId});
    });

    socket.onDisconnect((_) {
      debugPrint("❌ SOCKET DISCONNECTED");
    });

    void refreshChatWithLog(String eventName, dynamic data) {
      debugPrint("📥 [SOCKET RECEIVED] Event: $eventName");
      debugPrint("📥 [SOCKET DATA] $data");

      if (mounted) {
        context.read<TaskBloc>().add(
              GetTaskChatEvent(
                roomId: widget.roomId,
                type: "task_content",
                contentId: widget.taskDetail?.task.id ?? "",
                showLoader: false,
              ),
            );
      }
    }

    socket.on(
      "chat message",
      (data) => refreshChatWithLog("chat message", data),
    );
    socket.on("getallchat", (data) => refreshChatWithLog("getallchat", data));
    socket.on("updatehide", (data) => refreshChatWithLog("updatehide", data));
    socket.on(
      "media message",
      (data) => refreshChatWithLog("media message", data),
    );
    socket.on(
      "offer message",
      (data) => refreshChatWithLog("offer message", data),
    );
    socket.on("rating", (data) => refreshChatWithLog("rating", data));
    socket.on(
      "initialoffer",
      (data) => refreshChatWithLog("initialoffer", data),
    );
    socket.on("updateOffer", (data) => refreshChatWithLog("updateOffer", data));
    socket.on("leave room", (data) => refreshChatWithLog("leave room", data));

    socket.onError((data) => debugPrint("⚠️ SOCKET ERROR: $data"));
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
            'webp',
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
            VideoPlayerController controller = VideoPlayerController.file(
              File(filePath),
            );
            try {
              await controller.initialize();
              if (controller.value.duration.inSeconds >
                  (sharedPreferences!
                          .getInt(SharedPreferencesKeys.videoLimitKey) ??
                      120)) {
                showToast(
                  "Videos can be up to 2 minutes long — keep it quick, punchy, and straight to the point🎥",
                );
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
                country: "",
                state: "",
                city: "",
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
    final result = await context.pushNamed(
      AppRoutes.mediaPreviewName,
      extra: {
        'mediaList': selectMultipleMediaList,
        'onMediaUpdated': (updatedList) {
          selectMultipleMediaList = updatedList;
          setState(() {});
        },
      },
    );
    debugPrint("previewBottomSheet: Popped with result: $result");

    if (result == "upload") {
      debugPrint("previewBottomSheet: Triggering upload");
      callUploadMediaApi();
    }
  }

  void callUploadMediaApi() async {
    // Ensure location is fetched before uploading
    if (address.isEmpty) {
      await getCurrentLocation();
    }

    List<String> mediaList =
        selectMultipleMediaList.map((e) => e.mediaPath).toList();

    Map<String, String> body = {
      'task_id': widget.taskDetail!.task.id,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "address": address,
    };

    if (mounted) {
      final localTaskId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      _currentUploadingLocalTaskId = localTaskId;

      final localTask = ManageTaskChatModel.forLocalUpload(
        id: localTaskId,
        roomId: widget.roomId,
        mediaList: selectMultipleMediaList
            .map(
              (e) => TaskVideoModel(
                imageVideoUrl: e.mediaPath,
                type: e.mimeType,
                thumbnail: e.thumbnail,
                address: address,
              ),
            )
            .toList(),
        messageType: 'media',
        uploadStatus: 'starting',
        uploadProgress: 0,
      );

      context.read<TaskBloc>().add(AddLocalTaskEvent(localTask));
      selectMultipleMediaList.clear();

      bool success = await MediaUploadService.uploadMedia(
        endUrl: ApiConstantsNew.tasks.uploadTaskMedia,
        jsonBody: body,
        filePathList: mediaList.map((e) => File(e)).toList(),
        imageParams: "files",
      );

      if (mounted) {
        _currentUploadingLocalTaskId = null;
        context.read<TaskBloc>().add(RemoveLocalTaskEvent(localTaskId));

        if (success) {
          context.read<TaskBloc>().add(
                GetTaskChatEvent(
                  roomId: widget.roomId,
                  type: "task_content",
                  contentId: widget.taskDetail?.task.id ?? "",
                  showLoader: false,
                ),
              );
          socketEmitFunc(socketEvent: "media message", messageType: "media");
        }
      }
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
              topRight: Radius.circular(size.width * AppDimensions.numD04),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(
                  left: size.width * AppDimensions.numD06,
                  right: size.width * AppDimensions.numD03,
                  top: size.width * AppDimensions.numD018,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Option",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * AppDimensions.numD048,
                        fontFamily: "AirbnbCereal",
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.black,
                        size: size.width * AppDimensions.numD08,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.width * AppDimensions.numD04),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD06,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.pop();
                          selectMultipleMediaList.clear();
                          getMultipleImages("image");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD02,
                            ),
                          ),
                          height: size.width * AppDimensions.numD25,
                          padding: EdgeInsets.all(
                            size.width * AppDimensions.numD02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload,
                                size: size.width * AppDimensions.numD08,
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD03,
                              ),
                              Text(
                                "My Gallery",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD035,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.pop();
                          selectMultipleMediaList.clear();
                          getMultipleImages("file");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD02,
                            ),
                          ),
                          height: size.width * AppDimensions.numD25,
                          padding: EdgeInsets.all(
                            size.width * AppDimensions.numD02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                size: size.width * AppDimensions.numD08,
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD03,
                              ),
                              Text(
                                "My Files",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD035,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.width * AppDimensions.numD08),
            ],
          ),
        );
      },
    );
  }
}

class MediaModel {
  MediaModel({required this.mediaFile, required this.mimetype});
  XFile? mediaFile;
  String mimetype = "";
}
