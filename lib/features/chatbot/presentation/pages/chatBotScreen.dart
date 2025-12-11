
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/chat/presentation/pages/ChatScreen.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/chatbot/presentation/bloc/chatbot_bloc.dart';
import 'package:presshop/features/chatbot/data/models/chat_model.dart';
import 'package:presshop/core/di/injection_container.dart';

class ChatBotScreen extends StatefulWidget {
  final bool hideLeading;
  const ChatBotScreen({this.hideLeading = true, super.key});
  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with AnalyticsPageMixin {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  String senderPic =
      avatarImageUrl + (sharedPreferences!.getString(avatarKey) ?? "");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
      if (scrollController.hasClients) {
          scrollController.animateTo(
              scrollController.position.maxScrollExtent + 100,
              duration: const Duration(milliseconds: 500),
              curve: Curves.bounceIn);
      }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => sl<ChatbotBloc>()..add(InitChatbotEvent()),
      child: BlocConsumer<ChatbotBloc, ChatbotState>(
        listener: (context, state) {
           if (state is ChatbotLoaded) {
             Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
           }
        },
        builder: (context, state) {
          List<ChatModel> chatList = [];
          bool isTyping = false;
          
          if (state is ChatbotLoaded) {
              chatList = state.chatList;
              isTyping = state.isTyping;
          }

          return Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: false,
            title: Padding(
              padding: EdgeInsets.only(
                  left: widget.hideLeading ? size.width * numD04 : 0),
              child: Text(
                "Chat",
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
          body: (state is ChatbotLoading) 
            ? const Center(child: CircularProgressIndicator(color: colorThemePink))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                top: size.width * numD01,
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
                                                  errorBuilder: (context, error, stackTrace) =>
                                                    Image.asset(
                                                      "${commonImagePath}rabbitLogo.png", // Fallback
                                                      width: size.width * numD085,
                                                      height: size.width * numD085,
                                                      fit: BoxFit.cover,
                                                    )
                                                ),
                                              )),
                                        ],
                                      ),
                                    )
                                  : Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(
                                                bottom: size.width * numD04,
                                                top: size.width * numD03,
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
                                                                      context.read<ChatbotBloc>().add(RequestHumanAssistanceEvent(request: true, index: index));
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
                                                                      context.read<ChatbotBloc>().add(RequestHumanAssistanceEvent(request: false, index: index));
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
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        IconButton(
                          splashRadius: size.width * numD07,
                          onPressed: () {
                            if (messageController.text.isNotEmpty) {
                               context.read<ChatbotBloc>().add(SendMessageEvent(
                                  message: messageController.text, 
                                  time: DateTime.now().toString()
                               ));
                              messageController.clear();
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
                    height: size.width * numD10,
                  ),
                ],
              ),
        );
      }),
     );
  }

  @override
  // TODO: implement pageName
  String get pageName => PageNames.chatBot;
}
