import 'dart:convert';

import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/chatScreens/ChatScreen.dart';
import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/CommonTextField.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../dashboard/Dashboard.dart';
import 'package:flutter/src/services/text_input.dart' hide TextInput;

class ChatBotScreen extends StatefulWidget {
  bool hideLeading = true;
  ChatBotScreen({this.hideLeading = true, super.key});
  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    implements NetworkResponse {
  late DialogFlowtter dialogFlowtter;
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  dynamic response;
  List<ChatModel> chatList = [];
  bool isTyping = false;
  String searchValue = "";
  String senderPic =
      avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? "");
  bool hasShownFirstFailMsg = false;
  int failCount = 0;

  @override
  void initState() {
    initDialogFlow();
    callGetMessageApi();
    super.initState();
  }

  initDialogFlow() async {
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
  }

  dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: widget.hideLeading,
          title: Padding(
            padding: EdgeInsets.only(
                left: widget.hideLeading ? size.width * numD04 : 0),
            child: Text(
              "Emily",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * appBarHeadingFontSize),
            ),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            chatList.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: chatList.length,
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04,
                            vertical: size.width * numD02),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              chatList[index].isUser
                                  ? Align(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(
                                                    size.width * numD025),
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        size.width * numD60),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                          size.width * numD04),
                                                      bottomLeft:
                                                          Radius.circular(
                                                              size.width *
                                                                  numD04),
                                                      bottomRight:
                                                          Radius.circular(
                                                              size.width *
                                                                  numD04),
                                                    ),
                                                    color: colorGreyChat),
                                                child: Text(
                                                  chatList[index].message,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          size.width * numD035,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.width * numD01,
                                              ),
                                              Text(
                                                dateTimeFormatter(
                                                    dateTime:
                                                        chatList[index].time,
                                                    format:
                                                        "dd MMM yyyy hh:mm a"),
                                                style: TextStyle(
                                                    fontSize:
                                                        size.width * numD03,
                                                    color:
                                                        colorGoogleButtonBorder,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                              SizedBox(
                                                height: size.width * numD02,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(
                                                bottom: size.width * numD07,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD07),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color:
                                                          Colors.grey.shade300,
                                                      spreadRadius: 2)
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD07),
                                                child: Image.network(
                                                  senderPic,
                                                  width: size.width * numD085,
                                                  height: size.width * numD085,
                                                  fit: BoxFit.cover,
                                                ),
                                              )),
                                        ],
                                      ),
                                    )
                                  : Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(
                                                bottom: size.width * numD04,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        spreadRadius: 2)
                                                  ]),
                                              child: ClipOval(
                                                clipBehavior: Clip.antiAlias,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      size.width * numD01),
                                                  child: Image.asset(
                                                    "${commonImagePath}ic_black_rabbit.png",
                                                    color: Colors.white,
                                                    width: size.width * numD07,
                                                    height: size.width * numD07,
                                                  ),
                                                ),
                                              )),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: size.width * numD03,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(
                                                        size.width * numD025),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  size.width *
                                                                      numD04),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  size.width *
                                                                      numD04),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  size.width *
                                                                      numD04),
                                                        ),
                                                        border: Border.all(
                                                            width: 1.5,
                                                            color:
                                                                colorSwitchBack)),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          chatList[index]
                                                              .message,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize:
                                                                  size.width *
                                                                      numD035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              chatList[index]
                                                                  .isNavigate,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8),
                                                            child: Row(
                                                              children: [
                                                                // Expanded(
                                                                //   child: Text(
                                                                //     "Please chat with HUMAN !!",
                                                                //     style: TextStyle(
                                                                //         color: Colors.black,
                                                                //         fontSize: size.width *
                                                                //             numD035,
                                                                //         fontWeight:
                                                                //         FontWeight.w400),
                                                                //   ),
                                                                // ),
                                                                commonElevatedButton(
                                                                  "Chat",
                                                                  size,
                                                                  commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD035,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  commonButtonStyle(
                                                                      size,
                                                                      colorThemePink),
                                                                  () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => ConversationScreen(
                                                                                  hideLeading: false,
                                                                                  message: '',
                                                                                )));
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: chatList[
                                                                  index]
                                                              .hasShownFirstFailMsg,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 8),
                                                            child: Row(
                                                              children: [
                                                                commonElevatedButton(
                                                                  "Yes",
                                                                  size,
                                                                  commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD035,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  commonButtonStyle(
                                                                      size,
                                                                      colorThemePink),
                                                                  () {
                                                                    sendLocalMessage(
                                                                        true,
                                                                        "Loved our chat! Now handing you over to a real person for extra support.");
                                                                    resetFailCount();
                                                                    chatList
                                                                        .removeAt(
                                                                            index);
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                commonElevatedButton(
                                                                  "No",
                                                                  size,
                                                                  commonTextStyle(
                                                                      size:
                                                                          size,
                                                                      fontSize:
                                                                          size.width *
                                                                              numD035,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                  commonButtonStyle(
                                                                      size,
                                                                      colorThemePink),
                                                                  () {
                                                                    resetFailCount();
                                                                    chatList
                                                                        .removeAt(
                                                                            index);
                                                                    chatList.add(ChatModel(
                                                                        message:
                                                                            "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
                                                                        isUser:
                                                                            false,
                                                                        isNavigate:
                                                                            false,
                                                                        time: DateTime.now()
                                                                            .toString()));
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: size.width * numD01,
                                                  ),
                                                  Text(
                                                    dateTimeFormatter(
                                                        dateTime:
                                                            chatList[index]
                                                                .time,
                                                        format:
                                                            "dd MMM yyyy hh:mm a"),
                                                    style: TextStyle(
                                                        fontSize:
                                                            size.width * numD03,
                                                        color:
                                                            colorGoogleButtonBorder,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  SizedBox(
                                                    height: size.width * numD02,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              Visibility(
                                visible:
                                    isTyping && (chatList.length - 1 == index),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(
                                          top: size.width * numD02,
                                        ),
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey.shade300,
                                                  spreadRadius: 2)
                                            ]),
                                        child: ClipOval(
                                          clipBehavior: Clip.antiAlias,
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                                size.width * numD01),
                                            child: Image.asset(
                                              "${commonImagePath}ic_black_rabbit.png",
                                              color: Colors.white,
                                              width: size.width * numD07,
                                              height: size.width * numD07,
                                            ),
                                          ),
                                        )),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: size.width * numD02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(
                                                size.width * numD04),
                                            bottomLeft: Radius.circular(
                                                size.width * numD04),
                                            bottomRight: Radius.circular(
                                                size.width * numD04),
                                          ),
                                          border: Border.all(
                                              width: 1.5,
                                              color: colorSwitchBack)),
                                      child: Lottie.asset(
                                          "assets/lottieFiles/typing.json",
                                          height: size.width * numD10,
                                          width: size.width * numD16),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.width * numD06,
                              ),
                            ],
                          );
                        }),
                  )
                : Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * numD03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsets.only(
                                top: size.width * numD04,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade300,
                                        spreadRadius: 2)
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
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                left: size.width * numD02,
                                top: size.width * numD03,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.all(size.width * numD025),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                              size.width * numD04),
                                          bottomLeft: Radius.circular(
                                              size.width * numD04),
                                          bottomRight: Radius.circular(
                                              size.width * numD04),
                                        ),
                                        border: Border.all(
                                            width: 1.5,
                                            color: colorSwitchBack)),
                                    child: Text(
                                      "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          height: 1.3,
                                          fontSize: size.width * numD035,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.width * numD01,
                                  ),
                                  Text(
                                    dateTimeFormatter(
                                        dateTime: DateTime.now().toString(),
                                        format: "dd MMM yyyy hh:mm a"),
                                    style: TextStyle(
                                        fontSize: size.width * numD03,
                                        color: colorGoogleButtonBorder,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    height: size.width * numD02,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            SizedBox(
              height: size.width * numD03,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD02),
              margin: EdgeInsets.symmetric(horizontal: size.width * numD04),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(size.width * numD03)),
              child: Row(
                children: [
                  Expanded(
                    child: CommonTextField(
                      size: size,
                      controller: messageController,
                      hintText: "Type here ...",
                      prefixIcon: null,
                      autofocus: false,
                      borderColor: Colors.transparent,
                      prefixIconHeight: 0,
                      suffixIconIconHeight: size.width * numD045,
                      textInputFormatters: null,
                      hidePassword: false,
                      keyboardType: TextInputType.text,
                      validator: null,
                      suffixIcon: null,
                      enableValidations: false,
                      filled: false,
                      filledColor: Colors.transparent,
                      maxLines: 3,
                    ),
                  ),
                  IconButton(
                    splashRadius: size.width * numD07,
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        isTyping = true;
                        searchValue = messageController.text;
                        chatList.add(ChatModel(
                            message: messageController.text,
                            isUser: true,
                            isNavigate: false,
                            time: DateTime.now().toString()));
                        scrollController.animateTo(
                            scrollController.position.maxScrollExtent + 100,
                            duration: const Duration(microseconds: 500),
                            curve: Curves.bounceIn);
                        callAddMessageApi(messageController.text,
                            DateTime.now().toString(), "true");
                        messageController.clear();
                        setState(() {});

                        getResponse();
                      }
                    },
                    icon: Container(
                      width: size.width * numD07,
                      height: size.width * numD07,
                      alignment: Alignment.center,
                      child: Image.asset(
                        "${iconsPath}ic_arrow_right.png",
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.width * numD02,
            ),
          ],
        ));
  }

  void resetFailCount() {
    failCount = 0;
    hasShownFirstFailMsg = false;
  }

  callAddMessageApi(String message, String time, String isUser) {
    debugPrint("isUser:::::$isUser");
    try {
      Map<String, String> map = {
        "message": message,
        "time": time,
        "is_user": isUser,
      };
      debugPrint("map::::$map");

      NetworkClass.fromNetworkClass(
              addMessageApiUrl, this, addMessageApiReq, map)
          .callRequestServiceHeader(false, "post", null);
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    }
  }

  callGetMessageApi() {
    try {
      NetworkClass(getMessageApiUrl, this, getMessageApiReq)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    }
  }

  void sendLocalMessage(bool isHumanAssistanceRequested, String msg) {
    chatList.add(ChatModel(
        message: msg,
        isUser: false,
        isNavigate: isHumanAssistanceRequested,
        time: DateTime.now().toString()));
    setState(() {});
    scrollController.animateTo(scrollController.position.maxScrollExtent + 80,
        duration: const Duration(microseconds: 500), curve: Curves.bounceIn);
  }

  void getResponse() async {
    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(
          text: TextInput(
        text: searchValue,
        languageCode: "en",
      )),
    );
    debugPrint("dialogdlow.AIResponse->> ${jsonEncode(response)}");

    if (response.message != null) {
      if (response.queryResult!.action == "input.unknown") {
        failCount++;
        chatList.add(
          ChatModel(
              message: failCount < 3
                  ? "I’m sorry, I didn’t quite get that! Can you repeat or rephrase your question? I’m eager to help."
                  : "Hmm... I’m not quite sure about that one! Shall I grab a human from the PressHop team to assist you?",
              isUser: false,
              isNavigate: false,
              time: DateTime.now().toString(),
              hasShownFirstFailMsg: failCount > 2),
        );
        if (failCount < 3) {
          callAddMessageApi(
              "I’m sorry, I didn’t quite get that! Can you repeat or rephrase your question? I’m eager to help.",
              DateTime.now().toString(),
              "false");
        }
      } else {
        resetFailCount();
        chatList.add(ChatModel(
            message: response.message!.text!.text![0],
            isUser: false,
            isNavigate: false,
            time: DateTime.now().toString()));
        callAddMessageApi(response.message!.text!.text![0],
            DateTime.now().toString(), "false");
      }

      // var intentList =
      //     isKeyEmptyMap(response.queryResult.t, "response_text:response_text")
      //         ? null
      //         : response['entities']['response_text:response_text'] as List;

      // if (intentList == null ||
      //     intentList.isEmpty ||
      //     isKeyEmptyMap(response, "entities")) {
      //   failCount++;
      //   final isHumanAssistanceRequested = isHuman(response["text"]);
      //   chatList.add(
      //     ChatModel(
      //         message: (isHumanAssistanceRequested || failCount > 1)
      //             ? "Hmm... I’m not quite sure about that one! Shall I grab a human from the PressHop team to assist you?"
      //             : "I’m sorry, I didn’t quite get that! Can you repeat or rephrase your question? I’m eager to help.",
      //         isUser: false,
      //         isNavigate: isHumanAssistanceRequested,
      //         time: DateTime.now().toString(),
      //         hasShownFirstFailMsg: failCount > 1),
      //   );

      //   if (!isHumanAssistanceRequested && failCount == 0) {
      //     callAddMessageApi(
      //         isHumanAssistanceRequested
      //             ? "Hmm... I’m not quite sure about that one! Shall I grab a human from the PressHop team to assist you?"
      //             : "I’m sorry, I didn’t quite get that! Can you repeat or rephrase your question? I’m eager to help.",
      //         DateTime.now().toString(),
      //         "false");
      //   }
      // } else {
      // response['traits'].forEach((key, valueList) {
      //   for (var item in valueList) {
      //     String botReply = item['value'];
      //     chatList.add(ChatModel(
      //         message: botReply,
      //         isUser: false,
      //         isNavigate: key == "request_human_assistance",
      //         time: DateTime.now().toString()));
      //     callAddMessageApi(botReply, DateTime.now().toString(), "false");
      //   }
      // });
      //}
    } else {
      debugPrint(":::: Response is Null ::::");
    }

    isTyping = false;
    scrollController.animateTo(scrollController.position.maxScrollExtent + 80,
        duration: const Duration(microseconds: 500), curve: Curves.bounceIn);
    setState(() {});
  }

  bool isHuman(String msg) {
    if (msg.toLowerCase().endsWith("human")) return true;
    if (msg.toLowerCase().endsWith("human.")) return true;
    if (msg.toLowerCase().endsWith("human?")) return true;
    return false;
  }

  @override
  void onError({Key? key, required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case addMessageApiReq:
          debugPrint("addMessageApiReq error:::$response");
          break;
        case getMessageApiReq:
          debugPrint("getMessageApiReq error :::: $response");
      }
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    }
  }

  @override
  void onResponse(
      {Key? key, required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case addMessageApiReq:
          debugPrint("addMessageApiReq success:::$response");
          break;
        case getMessageApiReq:
          debugPrint("getMessageApiReq success :::: $response");
          var data = jsonDecode(response);
          var list = data['data'] as List;
          chatList = list.map((e) => ChatModel.fromJson(e)).toList();
          chatList.add(ChatModel(
              message:
                  "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
              isUser: false,
              isNavigate: false,
              time: DateTime.now().toString()));
          debugPrint("ChatListLength : ${chatList.length}");

          setState(() {});

          Future.delayed(const Duration(milliseconds: 500), () {
            scrollController.animateTo(
                scrollController.position.maxScrollExtent + 100,
                duration: const Duration(microseconds: 500),
                curve: Curves.bounceIn);
            setState(() {});
          });
      }
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    }
  }
}

class ChatModel {
  String message = "";
  String time = "";
  bool isUser = false;
  bool isNavigate = true;
  bool hasShownFirstFailMsg = false;

  ChatModel(
      {required this.message,
      required this.isUser,
      required this.time,
      required this.isNavigate,
      this.hasShownFirstFailMsg = false});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
        message: json['message'] ?? "",
        isUser: json['is_user'] == true ? true : false,
        // isNavigate: json['message']!=null ? json['message']=="Hmm... I’m not quite sure about that one! Shall I grab a human from the PressHop team to assist you?":false,
        isNavigate: false,
        time: json['time']);
  }
}
