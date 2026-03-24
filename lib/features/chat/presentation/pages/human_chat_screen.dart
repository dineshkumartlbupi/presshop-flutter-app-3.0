import 'dart:async';
// import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/widgets/common_widgets.dart' hide Config;
import 'package:presshop/features/chat/presentation/pages/FullVideoView.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart' hide Config;
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/features/chat/data/models/chat_models.dart';

// ignore: must_be_immutable
class ConversationScreen extends StatefulWidget {
  ConversationScreen({
    super.key,
    required this.hideLeading,
    required this.message,
  });
  bool hideLeading = false;
  final String message;

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        AnalyticsPageMixin {
  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.conversationScreen;

  late Size size;

  final ApiClient _apiClient = sl<ApiClient>();

  final swipeLeftKey = GlobalKey<ScaffoldState>();
  TextEditingController messageController = TextEditingController();
  TextEditingController messageReplyController = TextEditingController();
  ScrollController chatScrollController = ScrollController();
  PlayerController controller = PlayerController();

  Timer? timer;

  String lastSeen = "";

  ///Predictive Message List
  bool isRecordingLongPress = false;
  bool isShowSendButton = false;
  bool showPredictiveMsg = false;
  bool _isInitialMessageSent = false;

  bool isChatEmpty = false;
  late ChatBloc _chatBloc;

  /// Sender Information
  final String _senderId =
      sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
  final String _senderProfilePic =
      sharedPreferences!.getString(SharedPreferencesKeys.avatarKey) ?? "";

  /// Receiver Information
  String _receiverId = "";
  String _receiverName = "";
  String _receiverProfilePic = "";
  String roomId = "";
  String typingCheckSenderID = "";
  double uploadPercent = 0.0;
  String audioPath = "", audioDuration = "";

  List<AttachIconModel> attachIconList = [
    AttachIconModel(icon: "$chatIconsPath/cameraIcon.png", iconName: 'Photo'),
    AttachIconModel(
      icon: "$chatIconsPath/galleryIcon.png",
      iconName: 'Gallery',
    ),
    AttachIconModel(icon: "$chatIconsPath/videoIcon.png", iconName: 'Video'),
  ];

  ///audio

  String recordText = "";
  int _recordDuration = 0;
  Timer? _timer;
  Timer? _ampTimer;
  final _audioRecorder = AudioRecorder();
  AudioCache? audioCache;
  bool isPlaying = false;
  String collectionId = "";
  DateTime? currentTime;
  bool isFirstTime = true;

  @override
  void initState() {
    _chatBloc = context.read<ChatBloc>();
    isFirstTime = true;
    debugPrint('Class Name: $runtimeType');

    _receiverId =
        sharedPreferences!.getString(SharedPreferencesKeys.adminIdKey) ?? '';
    _receiverName =
        sharedPreferences!.getString(SharedPreferencesKeys.adminNameKey) ?? '';
    _receiverProfilePic =
        sharedPreferences!.getString(SharedPreferencesKeys.adminImageKey) ?? '';
    roomId =
        sharedPreferences!.getString(SharedPreferencesKeys.adminRoomIdKey) ??
            '';

    WidgetsBinding.instance.addObserver(this);
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _initializeData();
      }
    });
  }

  @override
  void dispose() {
    _chatBloc.add(LeaveChatRoomEvent());
    chatScrollController.dispose();
    super.dispose();
    controller.dispose();
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("AppLifecycleState ::: $state");
    switch (state) {
      case AppLifecycleState.paused:
        _chatBloc.add(UpdateAppLifecycleEvent(isOnline: false, roomId: roomId));
        break;

      case AppLifecycleState.resumed:
        _chatBloc.add(UpdateAppLifecycleEvent(isOnline: true, roomId: roomId));
        break;
      case AppLifecycleState.inactive:
        _chatBloc.add(UpdateAppLifecycleEvent(isOnline: false, roomId: roomId));
        break;
      case AppLifecycleState.detached:
        _chatBloc.add(UpdateAppLifecycleEvent(isOnline: false, roomId: roomId));
        break;
      case AppLifecycleState.hidden:
        _chatBloc.add(UpdateAppLifecycleEvent(isOnline: false, roomId: roomId));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _chatBloc,
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: widget.hideLeading,
              title: Padding(
                padding: EdgeInsets.only(
                  left: widget.hideLeading
                      ? size.width * AppDimensions.numD04
                      : 0,
                ),
                child: Row(
                  children: [
                    _receiverProfilePic.isEmpty
                        ? CircleAvatar(
                            radius: size.width * AppDimensions.numD05,
                            backgroundColor: Colors.transparent,
                            child: Image.asset(
                              "${commonImagePath}rabbitLogo.png",
                            ),
                          )
                        : CircleAvatar(
                            radius: size.width * AppDimensions.numD05,
                            backgroundImage: NetworkImage(_receiverProfilePic),
                          ),
                    SizedBox(width: size.width * AppDimensions.numD02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _receiverName.toCapitalized(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width *
                                AppDimensions.appBarHeadingFontSize,
                          ),
                        ),
                        Text(
                          state.isTyping
                              ? "Typing..."
                              : (state.isOnline ? "Online" : "Offline"),
                          style: TextStyle(
                            fontSize: size.width * AppDimensions.numD03,
                            color: state.isTyping
                                ? AppColorTheme.colorOnlineGreen
                                : (state.isOnline
                                    ? AppColorTheme.colorOnlineGreen
                                    : Colors.grey),
                            fontWeight: FontWeight.w300,
                            fontStyle: state.isTyping
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              titleSpacing: 0,
              size: size,
              showActions: true,
              leadingFxn: () => context.pop(),
              actionWidget: [
                InkWell(
                  onTap: () => settingsDialog(),
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: size.width * AppDimensions.numD07,
                  ),
                ),
                SizedBox(width: size.width * AppDimensions.numD04),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.messages.isNotEmpty &&
                    (state.status == ChatStatus.loading ||
                        state.status == ChatStatus.sending ||
                        state.isFetchingMore))
                  const LinearProgressIndicator(
                    backgroundColor: AppColorTheme.colorLightGrey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColorTheme.colorThemePink,
                    ),
                  ),
                Expanded(
                  child: state.status == ChatStatus.loading &&
                          state.messages.isEmpty
                      ? showLoader()
                      : state.messages.isNotEmpty
                          ? ListView.separated(
                              controller: chatScrollController,
                              padding: EdgeInsets.all(
                                size.width * AppDimensions.numD018,
                              ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                if (index == state.messages.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                var document = state.messages[index];
                                final isMe = document.isSender;

                                try {
                                  return Container(
                                    alignment: isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          size.width * AppDimensions.numD03,
                                      vertical:
                                          size.width * AppDimensions.numD015,
                                    ),
                                    child: messageWidget(
                                      document,
                                      isMe ? "sender" : "receiver",
                                      size,
                                    ),
                                  );
                                } catch (e, stack) {
                                  debugPrint(
                                      "Error rendering message $index: $e\n$stack");
                                  return Container(
                                    color: Colors.red,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      "Error: $e",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }
                              },
                              reverse: true,
                              shrinkWrap: false,
                              itemCount: state.hasMore
                                  ? state.messages.length + 1
                                  : state.messages.length,
                            )
                          : Container(),
                ),
                if (state.isTyping)
                  Padding(
                    padding: EdgeInsets.only(
                      left: size.width * AppDimensions.numD05,
                      bottom: size.width * AppDimensions.numD02,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: size.width * AppDimensions.numD04,
                          backgroundColor: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Image.asset(
                              "${commonImagePath}ic_black_rabbit.png",
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * AppDimensions.numD02),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppColorTheme.colorSwitchBack,
                            ),
                          ),
                          child: Lottie.asset(
                            "assets/lottieFiles/typing.json",
                            height: 20,
                            width: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                bottomButton("sender", size, state),
              ],
            ),
          );
        },
      ),
    );
  }

  /*  /// For checking person is Online Or OffLine
  Widget checkOnline(BuildContext context, size) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('OnlineOffline')
            .doc(_receiverId)
            .snapshots(),
        builder: (context, snapshot) {
          debugPrint("snapshot :$snapshot");
          if (!snapshot.hasData) {
            return Text(
              "Loading..",
              style: TextStyle(fontSize: size.width * AppDimensions.numD03),
            );
          }
          var value = snapshot.data!.data();

          debugPrint("value :$value");
          if (value != null) {
            debugPrint("OnlineStatus :${value['isOnline']}");
            return Text(
              value['isOnline'] == false ? 'Offline'.toString() : 'Online',
              style: TextStyle(fontSize: size.width * AppDimensions.numD03),
            );
          } else {
            return Text(
              "Offline",
              style: TextStyle(fontSize: size.width * AppDimensions.numD03),
            );
          }
        });
  }*/

  Future<void> imagePickerOptions(BuildContext context, size) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: size.width * AppDimensions.numD02,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    size.width * AppDimensions.numD04,
                  ),
                  color: Colors.white,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      minLeadingWidth: 10,
                      minVerticalPadding: 5,
                      leading: Image.asset(
                        attachIconList[index].icon,
                        height: size.width * AppDimensions.numD06,
                        width: size.width * AppDimensions.numD06,
                        color: Colors.black,
                      ),
                      title: Text(attachIconList[index].iconName),
                      onTap: () {
                        if (attachIconList[index].iconName == "Photo") {
                          getImage(ImageSource.camera);
                        } else if (attachIconList[index].iconName ==
                            "Gallery") {
                          getImage(ImageSource.gallery);
                        } else {
                          getVideo();
                        }
                        setState(() {});
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(thickness: 1, color: Colors.grey.shade200);
                  },
                  itemCount: attachIconList.length,
                ),
              ),
              SizedBox(height: size.width * AppDimensions.numD02),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: size.width * AppDimensions.numD13,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD04,
                            ),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.width * AppDimensions.numD03),
            ],
          ),
        );
      },
    );
  }

  void settingsDialog() {
    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, stateSetter) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Dialog(
                    backgroundColor: Colors.transparent,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: const Text(
                                  "More Options",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.pop();
                                  //callReportListApi();
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: const Text(
                                    "Report Profile",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.pop();
                                  //callBlockProfileApi(senderId, widget.otherUserId);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: const Text(
                                    "Block Profile",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  context.pop();
                                  // callUnMatchApi(senderId,widget.otherUserId);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                  ),
                                  child: const Text(
                                    "Unmatch the profile",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              /* privateImageAccess == "yes"
                                  ? InkWell(
                                      onTap: () {
                                        stateSetter(() {
                                          isGrantPics = !isGrantPics;
                                        });

                                        if (isGrantPics) {
                                          // callGrantAccessApi(senderId, widget.otherUserId,'images');
                                        } else {
                                          // callRevokeAccessApi(senderId, widget.otherUserId,'images');
                                        }
                                      },
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        width: double.infinity,
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Grant Access to Pics",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16),
                                            ),
                                            Image.asset(
                                              isGrantPics
                                                  ? "assets/toggle_active.png"
                                                  : "assets/toggle_inactive.png",
                                              height: 20,
                                              width: 30,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              InkWell(
                                onTap: () {
                                  stateSetter(() {
                                    isGrantInsta = !isGrantInsta;
                                  });

                                  if (isGrantInsta) {
                                    //callGrantAccessApi(senderId, widget.otherUserId,'instagram');
                                  } else {
                                    //callRevokeAccessApi(senderId, widget.otherUserId,'instagram');
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Grant Access to Instagram",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      Image.asset(
                                        isGrantInsta
                                            ? "assets/toggle_active.png"
                                            : "assets/toggle_inactive.png",
                                        height: 20,
                                        width: 30,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  stateSetter(() {
                                    isGrantLinkedIn = !isGrantLinkedIn;
                                  });

                                  if (isGrantLinkedIn) {
                                    //  callGrantAccessApi(senderId, widget.otherUserId,'linkedin');
                                  } else {
                                    // callRevokeAccessApi(senderId, widget.otherUserId,'linkedin');
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Grant Access to LinkedIn",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      Image.asset(
                                        isGrantLinkedIn
                                            ? "assets/toggle_active.png"
                                            : "assets/toggle_inactive.png",
                                        height: 20,
                                        width: 30,
                                      )
                                    ],
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            context.pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey.shade200,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> onBackPress() {
    context.pop();
    return Future.value(false);
  }

  //Emoji---keyboard--->
  Widget buildStickerKeyboard() {
    return Offstage(
      offstage: false,
      child: SizedBox(
        height: 250,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            _onEmojiSelected(emoji);
          },
          onBackspacePressed: onBackPress,
          config: Config(
            emojiViewConfig: EmojiViewConfig(
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              // initCategory: Category.recent,
              recentsLimit: 28,
              // categoryIcons: const CategoryIcons(),
            ),
            // theme: EmojiPickerTheme(
            //   bgColor: const Color(0xFFF2F2F2),
            //   indicatorColor: Colors.blue,
            //   iconColor: Colors.grey,
            //   iconColorSelected: Colors.blue,
            //   backspaceColor: Colors.blue,
            // ),
            // buttonMode: ButtonMode.material,
          ),
        ),
      ),
    );
  }

  void _onEmojiSelected(Emoji emoji) {
    if (mounted) {
      setState(() {
        // messageController.text = messageController.text + emoji.emoji;
        messageController
          ..text += emoji.emoji
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: messageController.text.length),
          );
      });
    }

    /*..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));*/
  }

  Widget bottomButton(String type, Size size, ChatState state) {
    return Container(
      alignment: Alignment.bottomCenter,
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.only(top: size.width * AppDimensions.numD03),
        padding: EdgeInsets.only(right: size.width * AppDimensions.numD035),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      SizedBox(width: size.width * AppDimensions.numD01),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(
                            navigatorKey.currentState!.context,
                          ).requestFocus(FocusNode());
                          if (mounted) {
                            imagePickerOptions(
                              navigatorKey.currentState!.context,
                              size,
                            );
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: size.width * AppDimensions.numD06,
                          child: Image.asset(
                            "${iconsPath}ic_attachment.png",
                            height: size.width * AppDimensions.numD048,
                            width: size.width * AppDimensions.numD048,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * AppDimensions.numD02),
                      Expanded(
                        child: Stack(
                          children: [
                            CommonTextField(
                              size: size,
                              controller: messageController,
                              hintText: "Type here ...",
                              prefixIcon: null,
                              autofocus: true,
                              borderColor: Colors.grey.shade300,
                              prefixIconHeight:
                                  size.width * AppDimensions.numD06,
                              suffixIconIconHeight:
                                  size.width * AppDimensions.numD06,
                              textInputFormatters: null,
                              suffixIcon: InkWell(
                                onTap: () async {
                                  /// To Reply

                                  if (messageController.text
                                      .trim()
                                      .isNotEmpty) {
                                    debugPrint(
                                      "::::: Inside Send Text Message With Not Reply :::::",
                                    );

                                    commonValues(
                                      messageType: "text",
                                      messageInput:
                                          messageController.text.trim(),
                                      duration: '',
                                      isAudioSelected: false,
                                    );

                                    messageController.clear();

                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }

                                  /*if (await isInternetConnected()) {
                                      callCustomNotificationApi('text');
                                    }*/
                                },
                                child: Image.asset(
                                  "${iconsPath}ic_arrow_right.png",
                                  color: Colors.black,
                                  width: size.width * AppDimensions.numD07,
                                ),
                              ),
                              hidePassword: false,
                              keyboardType: TextInputType.text,
                              validator: null,
                              enableValidations: true,
                              filled: false,
                              filledColor: Colors.transparent,
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            isRecordingLongPress
                                ? Positioned.fill(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * AppDimensions.numD04,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD03,
                                        ),
                                        color: AppColorTheme.colorLightGrey,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.mic_none_outlined,
                                            color: AppColorTheme.colorThemePink,
                                          ),
                                          SizedBox(
                                            width: size.width *
                                                AppDimensions.numD02,
                                          ),
                                          Text(
                                            Duration(
                                              seconds: _recordDuration,
                                            ).toString().split('.').first,
                                            style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD05,
                                              color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      SizedBox(width: size.width * AppDimensions.numD02),
                      isRecordingLongPress
                          ? InkWell(
                              onTap: () {
                                debugPrint("tazb::::::::");
                                isRecordingLongPress = false;
                                _stop();
                                setState(() {});
                              },
                              child: CircleAvatar(
                                backgroundColor: isRecordingLongPress
                                    ? AppColorTheme.colorThemePink
                                    : Colors.transparent,
                                radius: size.width * AppDimensions.numD06,
                                child: Icon(
                                  Icons.send,
                                  color: isRecordingLongPress
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                recordText = "Recording...";
                                debugPrint('onLongPress-Start');
                                isRecordingLongPress = true;
                                _start();
                                setState(() {});
                              },
                              onLongPressEnd: (value) {
                                debugPrint('onLongPress-End');
                                isRecordingLongPress = false;
                                _stop();
                                setState(() {});
                              },
                              child: CircleAvatar(
                                backgroundColor: isRecordingLongPress
                                    ? AppColorTheme.colorThemePink
                                    : Colors.transparent,
                                radius: size.width * AppDimensions.numD06,
                                child: Icon(
                                  Icons.mic_none_sharp,
                                  color: isRecordingLongPress
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                    ],
                  ),
                  SizedBox(height: size.width * AppDimensions.numD08),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget leftChatWidget(ChatMessageModel document) {
    return Padding(
      padding: EdgeInsets.only(right: size.width * AppDimensions.numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: size.width * AppDimensions.numD02),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2),
              ],
            ),
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
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD02),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: size.width * AppDimensions.numD02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                      bottomLeft: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                      bottomRight: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                    ),
                    border: Border.all(
                      width: 1.5,
                      color: AppColorTheme.colorSwitchBack,
                    ),
                  ),
                  /* padding: EdgeInsets.all(size.width * AppDimensions.numD05),*/
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD05,
                    vertical: size.width * AppDimensions.numD025,
                  ),
                  child: Text(
                    document.message,
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: "AirbnbCereal",
                    ),
                  ),
                ),
                Container(
                  // width: size.width / 1.5,
                  padding: EdgeInsets.only(
                    right: size.width * AppDimensions.numD02,
                    top: size.width * AppDimensions.numD01,
                  ),
                  child: Text(
                    timeParse(document['createdAt']),
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD03,
                      color: AppColorTheme.colorGoogleButtonBorder,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rightChatWidget(ChatMessageModel document) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColorTheme.colorGreyChat,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(
                      size.width * AppDimensions.numD04,
                    ),
                    bottomLeft: Radius.circular(
                      size.width * AppDimensions.numD04,
                    ),
                    topLeft: Radius.circular(size.width * AppDimensions.numD04),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD05,
                  vertical: size.width * AppDimensions.numD025,
                ),
                child: Text(
                  document["message"].toString(),
                  style: TextStyle(
                    fontSize: size.width * AppDimensions.numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontFamily: "AirbnbCereal",
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      right: size.width * AppDimensions.numD02,
                      top: size.width * AppDimensions.numD01,
                    ),
                    child: Text(
                      timeParse(document['createdAt']),
                      style: TextStyle(
                        fontSize: size.width * AppDimensions.numD028,
                        color: AppColorTheme.colorGoogleButtonBorder,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  document["readStatus"] == "read"
                      ? Container(
                          margin: EdgeInsets.only(
                            left: size.width * AppDimensions.numD004,
                          ),
                          child: Icon(
                            Icons.done_all,
                            color: Colors.green.shade400,
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(
                            left: size.width * AppDimensions.numD004,
                          ),
                          child: Icon(Icons.check, color: Colors.grey.shade400),
                        ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: size.width * AppDimensions.numD02),
        _senderProfilePic.isNotEmpty
            ? Container(
                margin: EdgeInsets.only(
                  bottom: size.width * AppDimensions.numD018,
                ),
                padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                height: size.width * AppDimensions.numD11,
                width: size.width * AppDimensions.numD11,
                decoration: const BoxDecoration(
                  color: AppColorTheme.colorLightGrey,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(_senderProfilePic, fit: BoxFit.cover),
                ),
              )
            : Container(
                margin: EdgeInsets.only(
                  bottom: size.width * AppDimensions.numD018,
                ),
                padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                height: size.width * AppDimensions.numD11,
                width: size.width * AppDimensions.numD11,
                decoration: const BoxDecoration(
                  color: AppColorTheme.colorSwitchBack,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * AppDimensions.numD07,
                    width: size.width * AppDimensions.numD07,
                  ),
                ),
              ),
      ],
    );
  }

  ///Message widgets-->
  Widget messageWidget(ChatMessageModel document, String type, size) {
    //callCustomNotificationApi(document['message_type'] == 'text' ?document["message"].toString():document['message_type']);
    return Slidable(
      key: ValueKey(document["messageId"].toString()),
      startActionPane: ActionPane(
        extentRatio: 0.2,
        key: ValueKey(document["messageId"].toString()),
        motion: const BehindMotion(),
        children: [
          type == 'sender'
              ? Container()
              : SlidableAction(
                  onPressed: (_) {
                    debugPrint("deleteMessage====>  ${document["message"]}");
                  },
                  icon: Icons.delete,
                  spacing: 4,
                ),
        ],
      ),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        key: ValueKey(document["messageId"].toString()),
        motion: const BehindMotion(),
        children: [
          type == 'sender'
              ? SlidableAction(
                  onPressed: (_) {
                    debugPrint("deleteMessage====>  ${document["message"]}");
                  },
                  icon: Icons.delete,
                  spacing: 4,
                )
              : Container(),
        ],
      ),
      child: Column(
        crossAxisAlignment: type == 'sender'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          document.messageType == 'text'
              ? type == 'sender'
                  ? rightChatWidget(document)
                  : leftChatWidget(document)
              : Container(),

          /// To Send Image
          document.messageType == 'image'
              ? type == 'sender'
                  ? rightImageChatWidget(document)
                  : leftImageChatWidget(document)
              : Container(),

          /// To Send Document
          document['message_type'] == 'doc' ||
                  document['message_type'] == 'docFile'
              ? Container(
                  decoration: type == 'sender'
                      ? BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            topLeft: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomLeft: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomRight: Radius.circular(
                              size.width * AppDimensions.numD1,
                            ),
                          ),
                          color: Colors.white,
                        )
                      : BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              size.width * AppDimensions.numD1,
                            ),
                            topRight: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomRight: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomLeft: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                          ),
                          color: Colors.pink,
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(
                                navigatorKey.currentState!.context,
                              ).size.width /
                              2.5,
                          maxWidth: MediaQuery.of(
                                navigatorKey.currentState!.context,
                              ).size.width /
                              2,
                        ),
                        margin: const EdgeInsets.all(8.0),
                        child: (document['uploadPercent'] ?? 100) < 100
                            ? Container(
                                margin: const EdgeInsets.all(20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: double.parse(
                                        (document['uploadPercent'] ?? 0)
                                            .toString(),
                                      ),
                                      strokeWidth: 4,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    document['uploadPercent'] == 100
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  FocusScope.of(
                                    navigatorKey.currentState!.context,
                                  ).requestFocus(FocusNode());
                                  /*Navigator.push(
                          navigatorKey.currentState!.context,
                          MaterialPageRoute(
                              builder: (context) => PdfViewScreen(
                                pdfPath: mapData['message'],
                                isFile:
                                mapData["messageType"] ==
                                    "docFile"
                                    ? true
                                    : false,
                              )));*/
                                  //  launch(document['message']);
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  color: type == 'sender'
                                      ? Colors.white
                                      : Colors.pink,
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.file_copy_outlined,
                                          size:
                                              size.width * AppDimensions.numD1,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        height: 60,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Document".toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      type == 'sender'
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    timeParse(
                                                      document['createdAt'],
                                                    ),
                                                    //timeParse(document['createdAt']).toString().split('.').first.toString(),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  document['isLocal'] == 1
                                                      ? const Icon(
                                                          Icons.history,
                                                          color: Colors.white,
                                                          size: 15,
                                                        )
                                                      : Container(
                                                          height: 15.0,
                                                          width: 15.0,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 5,
                                                          ),
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Image.asset(
                                                            "$chatIconsPath/double_tick_active.png",
                                                            color: document[
                                                                        'readStatus'] ==
                                                                    "unread"
                                                                ? Colors.white
                                                                : Colors.blue,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    timeParse(
                                                      document['createdAt'],
                                                    ),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              : Container(),

          /// To Send Music
          document['message_type'] == 'music' ||
                  document['message_type'] == 'musicFile'
              ? Container(
                  decoration: type == 'sender'
                      ? BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            topLeft: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomLeft: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomRight: Radius.circular(
                              size.width * AppDimensions.numD1,
                            ),
                          ),
                          color: Colors.white,
                        )
                      : BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                              size.width * AppDimensions.numD1,
                            ),
                            topRight: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomRight: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                            bottomLeft: Radius.circular(
                              size.width * AppDimensions.numD03,
                            ),
                          ),
                          color: Colors.pink,
                        ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(
                                navigatorKey.currentState!.context,
                              ).size.width /
                              2.5,
                          maxWidth: MediaQuery.of(
                                navigatorKey.currentState!.context,
                              ).size.width /
                              2,
                        ),
                        margin: const EdgeInsets.all(8.0),
                        child: (document['uploadPercent'] ?? 100) < 100
                            ? Container(
                                margin: const EdgeInsets.all(20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      value: double.parse(
                                        (document['uploadPercent'] ?? 0)
                                            .toString(),
                                      ),
                                      strokeWidth: 4,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    document['uploadPercent'] == 100
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  /* FocusScope.of(
                          navigatorKey.currentState!.context)
                          .requestFocus(FocusNode());
                      Navigator.push(
                          navigatorKey.currentState!.context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PlayAudio(mapData['message'])));*/
                                },
                                child: Container(
                                  color: type == 'sender'
                                      ? Colors.white
                                      : Colors.pink,
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(
                                        Icons.library_music,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        height: 60,
                                        child: Text(
                                          "Music".toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      type == 'sender'
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                top: 15,
                                                right: 10,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    timeParse(
                                                      document['createdAt'],
                                                    ),
                                                    //timeParse(mapData['date')).toString().split('.').first.toString(),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  document['isLocal'] == 1
                                                      ? const Icon(
                                                          Icons.history,
                                                          color: Colors.white,
                                                          size: 15,
                                                        )
                                                      : Container(
                                                          height: 15.0,
                                                          width: 15.0,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 5,
                                                          ),
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Image.asset(
                                                            "$chatIconsPath/double_tick_active.png",
                                                            color: document[
                                                                        'readStatus'] ==
                                                                    "unread"
                                                                ? Colors.white
                                                                : Colors.blue,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.only(
                                                top: 15,
                                                right: 10,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    timeParse(
                                                      document['createdAt'],
                                                    ),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              : Container(),

          /// To Send Video
          document['message_type'] == 'video' ||
                  document['message_type'] == 'videoFile'
              ? type == 'sender'
                  ? rightVideoChatWidget(document)
                  : leftVideoChatWidget(document)
              : Container(),

          /// CSV
          document['message_type'] == 'csv'
              ? Container(
                  margin: EdgeInsets.only(
                    right: size.width * AppDimensions.numD20,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD02,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: EdgeInsets.all(
                              size.width * AppDimensions.numD01,
                            ),
                            child: Image.asset(
                              "${commonImagePath}ic_black_rabbit.png",
                              color: Colors.white,
                              width: size.width * AppDimensions.numD07,
                              height: size.width * AppDimensions.numD07,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * AppDimensions.numD02),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                openUrl(document['message']);
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: size.width * AppDimensions.numD02,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                      size.width * AppDimensions.numD04,
                                    ),
                                    bottomLeft: Radius.circular(
                                      size.width * AppDimensions.numD04,
                                    ),
                                    bottomRight: Radius.circular(
                                      size.width * AppDimensions.numD04,
                                    ),
                                  ),
                                  border: Border.all(
                                    width: 1.5,
                                    color: AppColorTheme.colorSwitchBack,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD01,
                                    ),
                                    child: Image.asset(
                                      "assets/chatIcons/csv_image.png",
                                      fit: BoxFit.contain,
                                      height: size.width * AppDimensions.numD30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              width: size.width / 1.5,
                              padding: EdgeInsets.only(
                                right: size.width * AppDimensions.numD02,
                                top: size.width * AppDimensions.numD01,
                              ),
                              child: Text(
                                timeParse(document['createdAt']),
                                style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD03,
                                  color: const Color(0xFF979797),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),

          document.messageType == 'recording'
              ? type == 'sender'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: size.width * AppDimensions.numD60,
                              decoration: BoxDecoration(
                                color: AppColorTheme.colorLightGrey,
                                borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD06,
                                ),
                              ),
                              child: (document['uploadPercent'] ?? 100) < 100
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColorTheme.colorThemePink,
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (document['isAudioSelected'] ==
                                                true) {
                                              controller.pausePlayer();
                                              setState(() {
                                                document['isAudioSelected'] =
                                                    false;
                                              });
                                            } else {
                                              downloadAudioFromUrl(
                                                document.message,
                                              ).then((path) {
                                                initWave(path, true);
                                                setState(() {
                                                  document['isAudioSelected'] =
                                                      true;
                                                });
                                              });
                                            }
                                          },
                                          child: SizedBox(
                                            height: size.width *
                                                AppDimensions.numD06,
                                            child: Icon(
                                              (document['isAudioSelected'] ??
                                                      false)
                                                  ? Icons.pause_circle
                                                  : Icons.play_circle,
                                              color: Colors.black,
                                              size: size.width *
                                                  AppDimensions.numD06,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              size.width * AppDimensions.numD02,
                                        ),
                                        (document['isAudioSelected'] ?? false)
                                            ? Expanded(
                                                child: AudioFileWaveforms(
                                                  size: Size(
                                                    size.width,
                                                    size.width *
                                                        AppDimensions.numD04,
                                                  ),
                                                  playerController: controller,
                                                  enableSeekGesture: false,
                                                  animationCurve:
                                                      Curves.bounceIn,
                                                  waveformType:
                                                      WaveformType.long,
                                                  continuousWaveform: true,
                                                  playerWaveStyle:
                                                      PlayerWaveStyle(
                                                    fixedWaveColor:
                                                        Colors.black,
                                                    liveWaveColor: AppColorTheme
                                                        .colorThemePink,
                                                    spacing: 6,
                                                    liveWaveGradient:
                                                        ui.Gradient.linear(
                                                      const Offset(
                                                        70,
                                                        50,
                                                      ),
                                                      Offset(
                                                        MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            2,
                                                        0,
                                                      ),
                                                      [
                                                        Colors.green,
                                                        Colors.white70,
                                                      ],
                                                    ),
                                                    fixedWaveGradient:
                                                        ui.Gradient.linear(
                                                      const Offset(
                                                        70,
                                                        50,
                                                      ),
                                                      Offset(
                                                        MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            2,
                                                        0,
                                                      ),
                                                      [
                                                        Colors.green,
                                                        Colors.white70,
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
                                            : Container(),
                                      ],
                                    ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                    right: size.width * AppDimensions.numD02,
                                    top: size.width * AppDimensions.numD01,
                                  ),
                                  child: Text(
                                    timeParse(document['createdAt']),
                                    style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD028,
                                      color:
                                          AppColorTheme.colorGoogleButtonBorder,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                document["readStatus"] == "read"
                                    ? Container(
                                        margin: EdgeInsets.only(
                                          left: size.width *
                                              AppDimensions.numD004,
                                        ),
                                        child: Icon(
                                          Icons.done_all,
                                          color: Colors.green.shade400,
                                        ),
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(
                                          left: size.width *
                                              AppDimensions.numD004,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                              ],
                            ),
                            /*   Row(
                              children: [
                                Containerb(
                                  alignment: Alignment.centerRight,
                                  width: size.width / 1.5,
                                  padding: EdgeInsets.only(
                                    right: size.width * AppDimensions.numD02,
                                    top: size.width * AppDimensions.numD01,
                                  ),
                                  child: Text(
                                    timeParse(document['createdAt']),
                                    style: TextStyle(
                                        fontSize: size.width * AppDimensions.numD03,
                                        color: const Color(0xFF979797),
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),

                              ],
                            ),*/
                          ],
                        ),
                        SizedBox(width: size.width * AppDimensions.numD02),
                        _senderProfilePic.isNotEmpty
                            ? Container(
                                margin: EdgeInsets.only(
                                  bottom: size.width * AppDimensions.numD065,
                                ),
                                padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD01,
                                ),
                                height: size.width * AppDimensions.numD12,
                                width: size.width * AppDimensions.numD12,
                                decoration: const BoxDecoration(
                                  color: AppColorTheme.colorLightGrey,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.network(
                                    _senderProfilePic,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(
                                  top: size.width * AppDimensions.numD02,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade300,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  clipBehavior: Clip.antiAlias,
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      size.width * AppDimensions.numD01,
                                    ),
                                    child: Image.asset(
                                      "${commonImagePath}ic_black_rabbit.png",
                                      color: Colors.white,
                                      width: size.width * AppDimensions.numD07,
                                      height: size.width * AppDimensions.numD07,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD02,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding: EdgeInsets.all(
                                size.width * AppDimensions.numD01,
                              ),
                              child: Image.asset(
                                "${commonImagePath}ic_black_rabbit.png",
                                color: Colors.white,
                                width: size.width * AppDimensions.numD07,
                                height: size.width * AppDimensions.numD07,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * AppDimensions.numD02),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * AppDimensions.numD40,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: size.width * AppDimensions.numD03,
                                  horizontal: size.width * AppDimensions.numD03,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorTheme.colorLightGrey,
                                  borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD06,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if ((document['isAudioSelected'] ??
                                                false) ==
                                            true) {
                                          controller.pausePlayer();
                                          setState(() {
                                            document['isAudioSelected'] = false;
                                          });
                                        } else {
                                          downloadAudioFromUrl(
                                            document['message'],
                                          ).then((path) {
                                            initWave(path, true);
                                            setState(() {
                                              document['isAudioSelected'] =
                                                  true;
                                            });
                                          });
                                        }
                                      },
                                      child: SizedBox(
                                        height:
                                            size.width * AppDimensions.numD06,
                                        child: Icon(
                                          (document['isAudioSelected'] ?? false)
                                              ? Icons.pause_circle
                                              : Icons.play_circle,
                                          color: Colors.black,
                                          size:
                                              size.width * AppDimensions.numD06,
                                        ),
                                      ),
                                    ),
                                    (document['isAudioSelected'] ?? false)
                                        ? Expanded(
                                            child: AudioFileWaveforms(
                                              size: Size(
                                                size.width,
                                                size.width *
                                                    AppDimensions.numD04,
                                              ),
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
                                                  const Offset(
                                                    70,
                                                    50,
                                                  ),
                                                  Offset(
                                                    MediaQuery.of(
                                                          context,
                                                        ).size.width /
                                                        2,
                                                    0,
                                                  ),
                                                  [
                                                    Colors.green,
                                                    Colors.white70,
                                                  ],
                                                ),
                                                fixedWaveGradient:
                                                    ui.Gradient.linear(
                                                  const Offset(
                                                    70,
                                                    50,
                                                  ),
                                                  Offset(
                                                    MediaQuery.of(
                                                          context,
                                                        ).size.width /
                                                        2,
                                                    0,
                                                  ),
                                                  [
                                                    Colors.green,
                                                    Colors.white70,
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
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              width: size.width / 1.5,
                              padding: EdgeInsets.only(
                                right: size.width * AppDimensions.numD02,
                                top: size.width * AppDimensions.numD01,
                              ),
                              child: Text(
                                timeParse(document['createdAt']),
                                style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD03,
                                  color: const Color(0xFF979797),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
              : Container(),
        ],
      ),
    );
  }

  Future<String> downloadAudioFromUrl(String url) async {
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path;
    var file = File('$path/file.m4a');
    var response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    debugPrint("file path=====> ${file.path}");
    debugPrint("file exist=====> ${await file.exists()}");
    return file.path;
  }

  /*Future<String> downloadAndSaveMP3(String url) async {
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path;
    file = File('$path/file.mp3');
    var response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    debugPrint("file path=====> ${file.path}");
    debugPrint("file exist=====> ${ await file.exists()}");

    return file.path;
  }*/

  Future<void> initWave(String path, bool audioPlaying) async {
    debugPrint("path=========> $path");
    await controller.preparePlayer(
      path: path,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );
    if (audioPlaying) {
      controller.startPlayer();
      debugPrint("Play=======>");
    } else {
      controller.pausePlayer();
    }
    controller.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        setState(() {});
      }
    });
  }

  ///Record--audio-->
  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationCacheDirectory();
        final filePath =
            '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: filePath);

        setState(() {
          _recordDuration = 0;
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final path = await _audioRecorder.stop();
    debugPrint("stop========>");
    var file = File(path!);
    debugPrint("recordingPath====>Exist ${await file.exists()}");
    Uri uri = Uri.parse(file.path);
    String filePath = uri.path;

    debugPrint("recordingPath====> $filePath");
    commonValues(
      messageType: 'recording',
      messageInput: filePath,
      duration: '',
      isAudioSelected: false,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _recordDuration++);
    });
    _ampTimer = Timer.periodic(const Duration(milliseconds: 200), (t) async {
      setState(() {});
    });
  }

  Widget rightVideoChatWidget(ChatMessageModel document) {
    return Container(
      margin: EdgeInsets.only(left: size.width * AppDimensions.numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColorTheme.colorGreyChat,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                      bottomLeft: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                      topLeft: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(size.width * AppDimensions.numD03),
                  child: (document['uploadPercent'] ?? 100) < 100
                      ? SizedBox(
                          height: size.width * AppDimensions.numD55,
                          width: size.width,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColorTheme.colorThemePink,
                              strokeWidth: 3.5,
                            ),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.fullVideoViewName,
                                  extra: {
                                    'mediaFile': document['videoThumbnail'],
                                    'type': MediaTypeEnum.video,
                                  },
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD01,
                                ),
                                child: Image.network(
                                  document['videoThumbnail'],
                                  fit: BoxFit.cover,
                                  height: size.width * AppDimensions.numD55,
                                  width: size.width,
                                  errorBuilder: (context, strace, object) {
                                    return SizedBox(
                                      height: size.width * AppDimensions.numD55,
                                      width: size.width,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColorTheme.colorThemePink,
                                          strokeWidth: 3.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Icon(
                              Icons.play_circle,
                              color: Colors.white,
                              size: size.width * AppDimensions.numD07,
                            ),
                          ],
                        ),
                ),
                /* Container(
                  padding: EdgeInsets.only(
                    right: size.width * AppDimensions.numD02,
                    top: size.width * AppDimensions.numD01,
                  ),
                  child: Text(
                    timeParse(document['createdAt']),
                    style: TextStyle(
                        fontSize: size.width * AppDimensions.numD03,
                        color: AppColorTheme.colorGoogleButtonBorder,
                        fontWeight: FontWeight.w400),
                  ),
                ),*/
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        right: size.width * AppDimensions.numD02,
                        top: size.width * AppDimensions.numD01,
                      ),
                      child: Text(
                        timeParse(document['createdAt']),
                        style: TextStyle(
                          fontSize: size.width * AppDimensions.numD028,
                          color: AppColorTheme.colorGoogleButtonBorder,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    document["readStatus"] == "read"
                        ? Container(
                            margin: EdgeInsets.only(
                              left: size.width * AppDimensions.numD004,
                            ),
                            child: Icon(
                              Icons.done_all,
                              color: Colors.green.shade400,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(
                              left: size.width * AppDimensions.numD004,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD02),
          _senderProfilePic.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                  height: size.width * AppDimensions.numD12,
                  width: size.width * AppDimensions.numD12,
                  decoration: const BoxDecoration(
                    color: AppColorTheme.colorLightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(_senderProfilePic, fit: BoxFit.cover),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(
                    top: size.width * AppDimensions.numD02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, spreadRadius: 2),
                    ],
                  ),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: EdgeInsets.all(
                        size.width * AppDimensions.numD01,
                      ),
                      child: Image.asset(
                        "${commonImagePath}ic_black_rabbit.png",
                        color: Colors.white,
                        width: size.width * AppDimensions.numD07,
                        height: size.width * AppDimensions.numD07,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget leftVideoChatWidget(ChatMessageModel document) {
    return Container(
      margin: EdgeInsets.only(right: size.width * AppDimensions.numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: size.width * AppDimensions.numD02),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2),
              ],
            ),
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
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD02),
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: size.width * AppDimensions.numD02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                      bottomLeft: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                      bottomRight: Radius.circular(
                        size.width * AppDimensions.numD04,
                      ),
                    ),
                    border: Border.all(
                      width: 1.5,
                      color: AppColorTheme.colorSwitchBack,
                    ),
                  ),
                  padding: EdgeInsets.all(size.width * AppDimensions.numD03),
                  child: InkWell(
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.fullVideoViewName,
                        extra: {
                          'mediaFile': document['message_type']["message"],
                          'type': MediaTypeEnum.video,
                        },
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD01,
                          ),
                          child: Image.network(
                            // document['message_type']["videoThumbnail"],
                            document['videoThumbnail'],
                            fit: BoxFit.cover,
                            height: size.width * AppDimensions.numD55,
                            width: size.width,
                            errorBuilder: (context, strace, object) {
                              return SizedBox(
                                height: size.width * AppDimensions.numD55,
                                width: size.width,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColorTheme.colorThemePink,
                                    strokeWidth: 3.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(
                          Icons.play_circle,
                          color: Colors.white,
                          size: size.width * AppDimensions.numD07,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: size.width / 1.5,
                  padding: EdgeInsets.only(
                    right: size.width * AppDimensions.numD02,
                    top: size.width * AppDimensions.numD01,
                  ),
                  child: Text(
                    timeParse(document['createdAt']),
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD03,
                      color: const Color(0xFF979797),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget rightImageChatWidget(ChatMessageModel document) {
    return Container(
      margin: EdgeInsets.only(left: size.width * AppDimensions.numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.fullVideoViewName,
                      extra: {
                        'mediaFile': document['message'],
                        'type': MediaTypeEnum.image,
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(size.width * AppDimensions.numD03),
                    decoration: BoxDecoration(
                      color: AppColorTheme.colorGreyChat,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          size.width * AppDimensions.numD04,
                        ),
                        bottomLeft: Radius.circular(
                          size.width * AppDimensions.numD04,
                        ),
                        topLeft: Radius.circular(
                          size.width * AppDimensions.numD04,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD01,
                      ),
                      child: (document['uploadPercent'] ?? 100) > 100
                          ? Container(
                              padding: EdgeInsets.all(
                                size.width * AppDimensions.numD03,
                              ),
                              decoration: BoxDecoration(
                                color: AppColorTheme.colorGreyChat,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(
                                    size.width * AppDimensions.numD04,
                                  ),
                                  bottomLeft: Radius.circular(
                                    size.width * AppDimensions.numD04,
                                  ),
                                  topLeft: Radius.circular(
                                    size.width * AppDimensions.numD04,
                                  ),
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColorTheme.colorThemePink,
                                ),
                              ),
                            )
                          : document['message_type'] == "imageFile" &&
                                  File(document['message']).existsSync()
                              ? Image.network(
                                  document['message'],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, strace, object) {
                                    return SizedBox(
                                      height: size.width * AppDimensions.numD55,
                                      width: size.width,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColorTheme.colorThemePink,
                                          strokeWidth: 3.5,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.network(
                                  document['message'],
                                  fit: BoxFit.cover,
                                  height: size.width * AppDimensions.numD55,
                                  width: size.width,
                                  errorBuilder: (context, strace, object) {
                                    return SizedBox(
                                      height: size.width * AppDimensions.numD55,
                                      width: size.width,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColorTheme.colorThemePink,
                                          strokeWidth: 3.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        right: size.width * AppDimensions.numD02,
                        top: size.width * AppDimensions.numD01,
                      ),
                      child: Text(
                        timeParse(document['createdAt']),
                        style: TextStyle(
                          fontSize: size.width * AppDimensions.numD028,
                          color: AppColorTheme.colorGoogleButtonBorder,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    document["readStatus"] == "read"
                        ? Container(
                            margin: EdgeInsets.only(
                              left: size.width * AppDimensions.numD004,
                            ),
                            child: Icon(
                              Icons.done_all,
                              color: Colors.green.shade400,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(
                              left: size.width * AppDimensions.numD004,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.grey.shade400,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD02),
          _senderProfilePic.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                  height: size.width * AppDimensions.numD12,
                  width: size.width * AppDimensions.numD12,
                  decoration: const BoxDecoration(
                    color: AppColorTheme.colorLightGrey,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(_senderProfilePic, fit: BoxFit.cover),
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(
                    top: size.width * AppDimensions.numD02,
                  ),
                  padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                  height: size.width * AppDimensions.numD11,
                  width: size.width * AppDimensions.numD11,
                  decoration: const BoxDecoration(
                    color: AppColorTheme.colorSwitchBack,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      "${commonImagePath}rabbitLogo.png",
                      height: size.width * AppDimensions.numD07,
                      width: size.width * AppDimensions.numD07,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget leftImageChatWidget(ChatMessageModel document) {
    debugPrint("image::::::${document['message'].toString()}");
    return Container(
      margin: EdgeInsets.only(right: size.width * AppDimensions.numD20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: size.width * AppDimensions.numD02),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade300, spreadRadius: 2),
              ],
            ),
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
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD02),
          Expanded(
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.fullVideoViewName,
                      extra: {
                        'mediaFile': document['message'],
                        'type': MediaTypeEnum.image,
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      top: size.width * AppDimensions.numD02,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          size.width * AppDimensions.numD04,
                        ),
                        bottomLeft: Radius.circular(
                          size.width * AppDimensions.numD04,
                        ),
                        bottomRight: Radius.circular(
                          size.width * AppDimensions.numD04,
                        ),
                      ),
                      border: Border.all(
                        width: 1.5,
                        color: AppColorTheme.colorSwitchBack,
                      ),
                    ),
                    padding: EdgeInsets.all(size.width * AppDimensions.numD03),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD01,
                      ),
                      child: Image.network(
                        document['message'],
                        fit: BoxFit.cover,
                        height: size.width * AppDimensions.numD55,
                        width: size.width,
                        errorBuilder: (context, strace, object) {
                          return SizedBox(
                            height: size.width * AppDimensions.numD55,
                            width: size.width,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColorTheme.colorThemePink,
                                strokeWidth: 3.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: size.width / 1.5,
                  padding: EdgeInsets.only(
                    right: size.width * AppDimensions.numD02,
                    top: size.width * AppDimensions.numD01,
                  ),
                  child: Text(
                    timeParse(document['createdAt']),
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD03,
                      color: AppColorTheme.colorGoogleButtonBorder,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget commonUploadLoader(String per, Size size) {
    return const CircularProgressIndicator(color: AppColorTheme.colorThemePink);
  }

  Future<void> openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }

  Widget errorImage() {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        '${commonImagePath}rabbitLogo.png',
        height: size.width * AppDimensions.numD55,
        width: size.width,
      ),
    );
  }

  /* ///Emoji text layout-->
  Widget _buildMessageContent(String content, String type) {
    var size = MediaQuery.of(navigatorKey.currentState!.context).size;
    // final Iterable<Match> matches = REG_EMOJI.allMatches(content);

    if (matches.isEmpty) {
      debugPrint("messageContentBox====> $matches<=====> $type<==== $content");
      return Text(
        content,
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * AppDimensions.numD04,
        ),
      );
    }

    return RichText(
        text: TextSpan(children: [
      for (var t in content.characters)
        TextSpan(
            text: t,
            style: TextStyle(
              fontSize: REG_EMOJI.allMatches(t).isNotEmpty
                  ? (Platform.isIOS ? 28.0 : 25.0)
                  : 16.0,
              color: Colors.white,
            )),
    ]));
  }*/

  Widget replyMessageWidget(Map<String, dynamic> document, String type, size) {
    debugPrint("enterInsideReplyWidget======>$document  $type");
    return Container();
  }

  Widget dateWidget(Map<String, dynamic> document, String type, size) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0, right: 5.0),
      child: type == "sender"
          ? Wrap(
              alignment: WrapAlignment.end,
              children: [
                Text(
                  timeParse(document['createdAt']),
                  //timeParse(document['createdAt']).toString().split('.').first.toString(),
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  height: 15.0,
                  width: 15.0,
                  margin: const EdgeInsets.only(left: 5),
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    "$chatIconsPath/double_tick_active.png",
                    color: document['read_status'] == "unread"
                        ? Colors.white
                        : Colors.blue,
                  ),
                ),
              ],
            )
          : Wrap(
              alignment: WrapAlignment.start,
              children: [
                Text(
                  timeParse(document['createdAt']),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  /// Initialize Data
  Future<void> _initializeData() async {
    _receiverId =
        sharedPreferences!.getString(SharedPreferencesKeys.adminIdKey) ?? '';
    _receiverName =
        sharedPreferences!.getString(SharedPreferencesKeys.adminNameKey) ?? '';
    _receiverProfilePic =
        sharedPreferences!.getString(SharedPreferencesKeys.adminImageKey) ?? '';
    roomId =
        sharedPreferences!.getString(SharedPreferencesKeys.adminRoomIdKey) ??
            '';

    debugPrint(":::: ChatScreen _initializeData :::::");
    debugPrint("receiverId: $_receiverId");
    debugPrint("room_id: $roomId");

    // Step 1: Make sure we have admin data
    if (_receiverId.isEmpty) {
      debugPrint(":::: receiverId is empty, fetching admins first :::::");
      try {
        final response = await _apiClient.get(ApiConstantsNew.misc.adminList);
        debugPrint(":::: Admin list response: ${response.data} :::::");

        List dataModel = [];
        if (response.data is Map && response.data["data"] != null) {
          dataModel =
              response.data["data"] is List ? response.data["data"] : [];
        } else if (response.data is List) {
          dataModel = response.data;
        }

        if (dataModel.isNotEmpty) {
          var firstAdmin = AdminDetailModel.fromJson(dataModel.first);
          _receiverId = firstAdmin.id;
          _receiverName = firstAdmin.name;
          _receiverProfilePic = firstAdmin.profilePic;

          // Also get roomId from admin data if available
          if (firstAdmin.roomId.isNotEmpty && roomId.isEmpty) {
            roomId = firstAdmin.roomId;
            sharedPreferences!
                .setString(SharedPreferencesKeys.adminRoomIdKey, roomId);
          }

          sharedPreferences!
              .setString(SharedPreferencesKeys.adminIdKey, _receiverId);
          sharedPreferences!
              .setString(SharedPreferencesKeys.adminNameKey, _receiverName);
          sharedPreferences!.setString(
              SharedPreferencesKeys.adminImageKey, _receiverProfilePic);

          debugPrint(
              ":::: Fetched Admin: id=$_receiverId, name=$_receiverName, roomId=$roomId :::::");

          if (mounted) setState(() {});
        } else {
          debugPrint(":::: No admins found in API response :::::");
        }
      } catch (e) {
        debugPrint(":::: Error fetching admins: $e :::::");
      }
    }

    // Step 2: Create room if we have admin but no room
    if (roomId.isEmpty && _receiverId.isNotEmpty) {
      await callGetRoomIdApi();
    } else if (roomId.isNotEmpty && _receiverId.isNotEmpty) {
      _enterChat();
    } else {
      debugPrint(
          ":::: Cannot initialize chat: receiverId=$_receiverId, roomId=$roomId :::::");
    }
  }

  void _enterChat() {
    debugPrint(
        ":::: _enterChat called with roomId=$roomId, receiverId=$_receiverId :::::");
    _chatBloc.add(
      EnterChatRoomEvent(
        roomId: roomId,
        receiverId: _receiverId,
        receiverName: _receiverName,
        receiverImage: _receiverProfilePic,
      ),
    );

    // Add scroll listener for pagination
    chatScrollController
        .removeListener(_scrollListener); // Remove if already added
    chatScrollController.addListener(_scrollListener);

    // Check online status
    _chatBloc.add(CheckOnlineStatusEvent(_receiverId));

    if (widget.message.isNotEmpty && !_isInitialMessageSent) {
      _isInitialMessageSent = true;
      commonValues(
        messageType: "text",
        messageInput: widget.message.trim(),
        duration: '',
        isAudioSelected: false,
      );
    }

    messageController.addListener(() {
      if (mounted) {
        setState(() {
          isShowSendButton = messageController.text.isNotEmpty;
          showPredictiveMsg = messageController.text.isNotEmpty;
        });
        if (roomId.isNotEmpty) {
          debugPrint(
              "ConversationScreen: Adding UpdateTypingStatusEvent for room: $roomId, isTyping: ${messageController.text.isNotEmpty}");
          _chatBloc.add(
            UpdateTypingStatusEvent(
              roomId: roomId,
              isTyping: messageController.text.isNotEmpty,
              typedValue: messageController.text,
            ),
          );
        } else {
          debugPrint(
              "ConversationScreen: Cannot send typing status, roomId is EMPTY");
        }
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  void _scrollListener() {
    if (chatScrollController.hasClients) {
      if (chatScrollController.position.pixels >=
          chatScrollController.position.maxScrollExtent - 200) {
        if (!_chatBloc.state.isFetchingMore && _chatBloc.state.hasMore) {
          debugPrint(":::: Fetching More Messages ::::");
          _chatBloc.add(const FetchMoreMessagesEvent());
        }
      }
    }
  }

  /// **************************
  void commonValues({
    required String messageType,
    required String messageInput,
    required String duration,
    required bool isAudioSelected,
    String thumbnailPath = "",
    int isReply = 0,
  }) {
    debugPrint("::::: Inside Common Values ::::::::::");

    if (isFirstTime) {
      isFirstTime = false;
      _apiClient.post(ApiConstantsNew.chat.sendChatInitToAdmin, data: {});
    }

    _chatBloc.add(
      SendMessageEvent(
        message: messageType == 'text' ? messageInput : '',
        messageType: messageType,
        filePath: messageType != 'text' ? messageInput : null,
        audioDuration: duration,
        thumbnailPath: thumbnailPath,
        replyMessageContent: "Empty Coming Soon",
        replyToMessageId: isReply == 1 ? "REPLY_ID_TODO" : null,
      ),
    );

    callCustomNotificationApi(
      messageType == "text" ? messageInput : messageType,
    );
  }

  /// To get Videos From the Gallery
  Future getVideo() async {
    debugPrint("isVideoPicked=====> yes");
    context.pop();
    final pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (mounted) {
      var file = File(pickedFile!.path);

      File videoPickedPath = file;
      debugPrint('videoEdited mFile :::::::: ${videoPickedPath.path}');

      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPickedPath.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 300,
        quality: 100,
      );

      commonValues(
        messageType: "video",
        messageInput: videoPickedPath.path,
        thumbnailPath: thumbnail!,
        duration: '',
        isAudioSelected: false,
      );
    }
  }

  /// Get Image
  Future<void> getImage(ImageSource source) async {
    context.pop();
    bool cameraValue = await cameraPermission();
    bool storageValue = await storagePermission();

    if (cameraValue && storageValue) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      debugPrint("image=======> $image");
      if (image != null) {
        commonValues(
          messageType: "image",
          messageInput: image.path,
          duration: '',
          isAudioSelected: false,
        );

        /* if (await isInternetConnected()) {
          callCustomNotificationApi('Image');
        }*/
      }
    } else {
      context.pushNamed(
        AppRoutes.permissionErrorName,
        extra: {
          'permissionsStatus': {Permission.camera: false},
        },
      );
    }
  }

  ///custom
  ///custom
  Future<void> callCustomNotificationApi(String type) async {
    debugPrint(":::: callCustomNotificationApi :::::");
    debugPrint("receiverId: $_receiverId");
    Map<String, String> map = {
      'sender_id': _senderId,
      'receiver_id': _receiverId,
      'title': 'PRESSHOP',
      'body': type == 'text' ? messageController.text : type,
    };
    debugPrint('map: $map');

    try {
      final response = await _apiClient.post(
        ApiConstantsNew.chat.sendPushNotification,
        data: map,
      );
      debugPrint("sendNotification success : ${response.data}");
    } catch (e) {
      debugPrint("sendNotification Error : $e");
    }
  }

  /// Get Room Id
  Future<void> callGetRoomIdApi() async {
    debugPrint(":::: callGetRoomIdApi Started :::::");
    _receiverId =
        sharedPreferences!.getString(SharedPreferencesKeys.adminIdKey) ?? '';

    if (_receiverId.isEmpty) {
      debugPrint(
          ":::: ERROR: Cannot call getRoomId because receiverId is empty :::::");
      return;
    }

    Map<String, String> map = {
      "receiver_id": _receiverId,
      "room_type": "HoppertoAdmin",
    };

    debugPrint("Map : $map");

    try {
      final response = await _apiClient.post(
        ApiConstantsNew.chat.createRoom,
        data: map,
      );
      debugPrint("getRoomIdReq Success : ${response.data}");
      var data = response.data;

      // Handle multiple response formats
      if (data["data"] != null && data["data"]["details"] != null) {
        roomId = data["data"]["details"]["room_id"] ?? "";
      } else if (data["data"] != null && data["data"]["_id"] != null) {
        roomId = data["data"]["_id"] ?? "";
      } else if (data["data"] != null && data["data"]["room_id"] != null) {
        roomId = data["data"]["room_id"] ?? "";
      } else if (data["details"] != null) {
        roomId = data["details"]["room_id"] ?? "";
      } else if (data["room_id"] != null) {
        roomId = data["room_id"] ?? "";
      }

      if (roomId.isNotEmpty) {
        sharedPreferences!
            .setString(SharedPreferencesKeys.adminRoomIdKey, roomId);
        debugPrint("Room Id : $roomId");
        // Directly enter chat instead of recursive _initializeData
        _enterChat();
      } else {
        debugPrint(":::: ERROR: Could not extract room_id from response :::::");
      }
    } catch (e) {
      debugPrint("getRoomIdReq Error : $e");
    }
  }
}

class AttachIconModel {
  AttachIconModel({required this.icon, required this.iconName});
  String iconName = "";
  String icon = "";
}

Future<bool> isInternetConnected() async {
  bool connected = false;
  if (await InternetConnectionChecker().hasConnection) {
    connected = true;
  }
  debugPrint("isInternetConnectionWorking====> $connected");
  return connected;
}

///time parse with AM-PM -- Utc to Local ---->
/*
String timeParse(String time) {
  debugPrint("Time Before parse Value : $time");

  var utc = DateTime.parse(time).toLocal();

  debugPrint("Time parse Value : ${utc.toUtc().toLocal()}");
  debugPrint("Time parse Value : $utc");

  utc = utc.add(DateTime.parse(time).timeZoneOffset);

  String finalDate = DateFormat('hh:mm a').format(utc).toString();

  return finalDate;
}
*/
String timeParse(String time) {
  // debugPrint("Time Before parse Value : $time");

  var utc = DateTime.parse(time).toLocal();

  // debugPrint("Time parse Value : ${utc.toUtc().toLocal()}");
  // debugPrint("Time parse Value : $utc");

  //utc = utc.add(DateTime.parse(time).timeZoneOffset);

  String finalDate = DateFormat('hh:mm a, dd MMM yyyy').format(utc).toString();

  return finalDate;
}
