import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../dashboard/Dashboard.dart';
import 'ChatScreen.dart';
import 'SqliteDataBase.dart';

class ChatListingScreen extends StatefulWidget {
  bool hideLeading = false;

  ChatListingScreen({super.key, required this.hideLeading});

  @override
  State<ChatListingScreen> createState() => _ChatListingScreenState();
}

class _ChatListingScreenState extends State<ChatListingScreen>
    implements NetworkResponse {
  late Size size;

  final TextEditingController _searchController = TextEditingController();
  List<String> roomNumberID = [];
  List<AdminDetailModel> adminList = [];
  List<AdminDetailModel> searchResult = [];
  List<String> adminIDList = [];
  String userId = "";
  String userName = "";
  String userProfileImage = "";
  bool isOnline = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callGetActiveAdmin());
    getPreferenceData();
  }

  getPreferenceData() {
    userName = sharedPreferences!.getString(userNameKey).toString();
    userProfileImage = sharedPreferences!.getString(avatarKey).toString();
    userId = sharedPreferences!.getString(hopperIdKey) ?? "";
    debugPrint("userName:::$userName");
    debugPrint("userId:::$userId");
    getOnlineUsersList();
    adminIDList = [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: widget.hideLeading,
        title: Padding(
          padding: EdgeInsets.only(
              left: widget.hideLeading ? size.width * numD04 : 0),
          child: Text(
            chatText,
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
                      builder: (context) => Dashboard(
                            initialPosition: 2,
                          )),
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
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * numD05,
          vertical: size.width * numD03,
        ),
        child: ListView(
          children: [
            searchWidget(),
            Padding(
              padding: EdgeInsets.only(top: size.width * numD05),
              child: Text(
                chatWithPRESSHOPText.toUpperCase(),
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: size.width * numD03,
            ),
            allChatList(context, size),
            chatListingWidget(presshopText),
            /*Padding(
              padding: EdgeInsets.only(top: size.width * numD05),
              child: Text(
                chatWithPublicationsText.toUpperCase(),
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: size.width * numD04,
            ),
            Row(
              children: [
                Expanded(
                    child: SizedBox(
                  height: size.width * numD12,
                  child: commonElevatedButton(
                      contentsText,
                      size,
                      commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: _chatPubIndex == 0 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500),
                      commonButtonStyle(size,
                          _chatPubIndex == 0 ? Colors.black : colorLightGrey),
                      () {
                    setState(() {
                      _chatPubIndex = 0;
                    });
                  }),
                )),
                SizedBox(
                  width: size.width * numD04,
                ),
                Expanded(
                    child: SizedBox(
                  height: size.width * numD12,
                  child: commonElevatedButton(
                      "${taskText}s",
                      size,
                      commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: _chatPubIndex == 1 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500),
                      commonButtonStyle(size,
                          _chatPubIndex == 1 ? Colors.black : colorLightGrey),
                      () {
                    setState(() {
                      _chatPubIndex = 1;
                    });
                  }),
                )),
              ],
            ),
            SizedBox(
              height: size.width * numD03,
            ),
            chatListingWidget("Publication"),*/
          ],
        ),
      ),
    );
  }

  Widget searchWidget() {
    return TextFormField(
      controller: _searchController,
      cursorColor: colorTextFieldIcon,
      onChanged: (value) {
        searchResult = adminList
            .where((element) =>
                element.name.toLowerCase().contains(value.toLowerCase()))
            .toList();

        debugPrint("searchResult :: ${searchResult.length}");
        setState(() {});
      },
      decoration: InputDecoration(
        fillColor: colorLightGrey,
        isDense: true,
        filled: true,
        hintText: searchHintText,
        hintStyle: TextStyle(color: colorHint, fontSize: size.width * numD04),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
            borderSide: const BorderSide(width: 0, color: colorLightGrey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
            borderSide: const BorderSide(width: 0, color: colorLightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
            borderSide: const BorderSide(width: 0, color: colorLightGrey)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
            borderSide: const BorderSide(width: 0, color: colorLightGrey)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
            borderSide: const BorderSide(width: 0, color: colorLightGrey)),
        suffixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * numD02),
          child: Image.asset(
            "${iconsPath}ic_search.png",
            color: Colors.black,
          ),
        ),
        suffixIconConstraints: BoxConstraints(maxHeight: size.width * numD06),
      ),
      textAlignVertical: TextAlignVertical.center,
    );
  }

  Widget chatListingWidget(String type) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _searchController.text.isNotEmpty
          ? searchResult.length
          : adminList.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var item = _searchController.text.isNotEmpty
            ? searchResult[index]
            : adminList[index];

        return InkWell(
          onTap: () {
            debugPrint("converstatio screen ======> ");
           /* Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => ConversationScreen(
                          receiverId:  item.id.isNotEmpty? item.id:'' ,
                          roomId: item.roomId.isNotEmpty?item.roomId: '',
                          receiverName:  item.name.isNotEmpty?item.name : '',
                          receiverImage: item.profilePic.isNotEmpty? item.profilePic : '',
                        )))
                .then((value) => callGetActiveAdmin());*/
          },
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      size.width * numD01,
                    ),
                    height: size.width * numD16,
                    width: size.width * numD16,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        adminProfileUrl + item.profilePic,
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return Image.asset(
                            "${commonImagePath}rabbitLogo.png",
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 0,
                    child: Container(
                        padding: EdgeInsets.all(size.width * 0.005),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          Icons.circle,
                          color: Colors.grey,
                          size: size.width * numD03,
                        )),
                  )
                ],
              ),
              SizedBox(
                width: size.width * numD02,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// User Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name.toCapitalized(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: size.width * numD038,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD15,
                          child: Text(
                            item.lastMessageTime,
                            style: TextStyle(
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),

                    /// Last Type Chat
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.lastMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: size.width * numD032,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        /*Container(
                              margin: EdgeInsets.only(
                                right: size.width * numD03,
                                left: size.width * numD03,
                              ),
                              alignment: Alignment.center,
                              height: size.width * numD055,
                              width: size.width * numD055,
                              decoration: const BoxDecoration(
                                  color: colorOnlineGreen,
                                  shape: BoxShape.circle),
                              child: Text(
                                "3",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD025,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              )),*/
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: size.width * numD05,
        );
      },
    );
  }

  Widget allChatList(BuildContext context, var size) {
    var size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Chat")
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot) {
        if (snapShot.hasError) {
          return const Center(child: Text("Something Wrong"));
        }
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(child: Container());
        }
        return snapShot.data!.docs.isNotEmpty
            ? ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: (_searchController.text.isNotEmpty
                        ? snapShot.data!.docs.where((element) => element
                                    .get('receiverId') !=
                                userId.toString()
                            ? element
                                .get("receiverName")
                                .toString()
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase())
                            : element
                                .get("senderName")
                                .toString()
                                .toLowerCase()
                                .contains(_searchController.text.toLowerCase()))
                        : snapShot.data!.docs)
                    .map((DocumentSnapshot document) {
                  debugPrint("document :::${snapShot.data!.docs.length}");

                  if (document.get('senderId').toString() ==
                          userId.toString() ||
                      document.get('receiverId').toString() ==
                          userId.toString()) {
                    debugPrint("roomId ${document.get('roomId')}");
                    if (document.get('receiverId') != userId) {
                      debugPrint(
                          "receiverId ____________ ${document.get('receiverId')}");
                      if (adminIDList.contains(document.get('receiverId'))) {
                        debugPrint(
                            "containerList=====> ${document.get('receiverId')}");
                      } else {
                        debugPrint(
                            "NotcontainerList=====> ${document.get('receiverId')}");
                        adminIDList.add(document.get('receiverId'));
                        debugPrint("adminIDList=====> ${adminIDList.length}");
                      }
                    }

                    return Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.width * numD02),
                      child: InkWell(
                          onTap: () {
                            /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConversationScreen(
                                    roomId: document.get('roomId'),
                                    receiverId: document.get('receiverId') !=
                                            userId.toString()
                                        ? document.get('receiverId')
                                        : document.get('senderId'),
                                    receiverImage: document.get('receiverId') !=
                                            userId.toString()
                                        ? document.get('receiverImage')
                                        : document.get('senderImage'),
                                    receiverName: document.get('receiverId') !=
                                            userId.toString()
                                        ? document.get('receiverName')
                                        : document.get('senderName'),
                                  ),
                                ));*/
                          },
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      size.width * numD01,
                                    ),
                                    height: size.width * numD16,
                                    width: size.width * numD16,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        shape: BoxShape.circle),
                                    child: ClipOval(
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        document.get('receiverId') !=
                                                userId.toString()
                                            ? adminProfileUrl +
                                                document.get('receiverImage')
                                            : avatarImageUrl +
                                                document.get('senderImage'),
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            height: size.width * numD12,
                                            width: size.width * numD12,
                                            fit: BoxFit.contain,
                                          );
                                        },
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 0,
                                    child:  checkOnlineOffline(
                                        context, size, document.get('receiverId')),
                                  )

                                ],
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// User Name
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(
                                          document.get('receiverId') !=
                                                  userId.toString()
                                              ? document.get('receiverName')
                                              : document.get('senderName'),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: size.width * numD038,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600),
                                        )),
                                        SizedBox(
                                            width: size.width * numD15,
                                            child: Text(
                                                DateFormat("hh:mm a").format(
                                                    DateTime.parse(
                                                        document.get('date'))),
                                                style: TextStyle(
                                                    fontSize:
                                                        size.width * numD03,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w400))),
                                      ],
                                    ),

                                    /// Last Type Chat
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                              document.get('messageType') ==
                                                      "text"
                                                  ? document.get('message')
                                                  : document.get('messageType'),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize:
                                                      size.width * numD032,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.normal)),
                                        ),
                                        document.get('receiverId') ==
                                                userId.toString()
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                  right: size.width * numD03,
                                                  left: size.width * numD03,
                                                ),
                                                alignment: Alignment.center,
                                                height: size.width * numD055,
                                                width: size.width * numD055,
                                                decoration: const BoxDecoration(
                                                    color: colorOnlineGreen,
                                                    shape: BoxShape.circle),
                                                child: Text(
                                                  document.get('unReadCount') ==
                                                          "0"
                                                      ? 0
                                                      : document
                                                          .get('unReadCount'),
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize:
                                                          size.width * numD025,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ))
                                            : Container()
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          )),
                    );
                  } else {
                    return Container();
                  }
                }).toList(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.height / 3,
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        color: Colors.white,
                      )),
                  SizedBox(
                    height: size.width * numD03,
                  ),
                  Text(
                    "No chat",
                    style: TextStyle(
                        fontSize: size.width * numD055,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              );
      },
    );
  }

  void getOnlineUsersList() {
    FirebaseFirestore.instance
        .collection('OnlineOffline')
        .get()
        .then((onlineUserList) {
      debugPrint("getOnlineUsersList :::${onlineUserList.size}");
      for (int i = 0; i < onlineUserList.docs.length; i++) {
        if (onlineUserList.docs[i].id != sharedPreferences?.getString(userId) &&
            onlineUserList.docs[i].get('isOnline')) {
          var onlineMap = {
            "senderImage": onlineUserList.docs[i].get('senderImage') ?? "",
            "userName": onlineUserList.docs[i].get('userName') ?? "",
            "isOnline": onlineUserList.docs[i].get('isOnline') ?? false
          };
        }
      }
    });

    setState(() {});
  }

  Widget checkOnlineOffline(BuildContext context, var size, String receiverId) {
    debugPrint("receiverId checkOnlineOffline: $receiverId");
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('OnlineOffline')
            .doc(receiverId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              "",
              style: TextStyle(
                  fontSize: size.width * numD03,
                  color: Colors.white,
                  fontWeight: FontWeight.w300),
            );
          }

          var userDocument = snapshot.data!.data();

          if (userDocument != null) {
            if (userDocument["isOnline"] == true) {
              isOnline = true;
            } else {
              isOnline = false;
            }
          } else {
            isOnline = false;
          }
          debugPrint("userDocument : $userDocument");
          debugPrint("isOnline : $isOnline");
          return Container(
            margin: EdgeInsets.only(left: size.width * numD028),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.7),
                borderRadius: BorderRadius.circular(size.width * numD028)),
            child: CircleAvatar(
              radius: size.width * numD014,
              backgroundColor: userDocument == null
                  ? Colors.grey
                  : userDocument["isOnline"]
                      ? Colors.green
                      : Colors.grey,
            ),
          );
        });
  }

  /* Widget oldWidget(index, type) {
    return InkWell(
      onTap: () async {
        */
  /*Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ConversationScreen(
              title: type == presshopText
                  ? chatWithPRESSHOPText
                  : chatWithPublicationsText,
            )));*/
  /*
      },
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(
                  size.width * numD01,
                ),
                height: size.width * numD16,
                width: size.width * numD16,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200, shape: BoxShape.circle),
                child: ClipOval(
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    "$dummyImagePath${type == "Publication" ? "news.png" : "image2.png"}",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 0,
                child: Container(
                    padding: EdgeInsets.all(size.width * 0.005),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      Icons.circle,
                      color: colorOnlineGreen,
                      size: size.width * numD03,
                    )),
              )
            ],
          ),
          SizedBox(
            width: size.width * numD02,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// User Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "John Doe",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: size.width * numD038,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD12,
                      child: Text(
                        "12:10 PM",
                        style: TextStyle(
                            fontSize: size.width * numD03,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),

                /// Last Type Chat
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Lorem ipsum dolor sit amet korem ipsum dolor sit amet",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: size.width * numD032,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(
                          right: size.width * numD03,
                          left: size.width * numD03,
                        ),
                        alignment: Alignment.center,
                        height: size.width * numD055,
                        width: size.width * numD055,
                        decoration: const BoxDecoration(
                            color: colorOnlineGreen, shape: BoxShape.circle),
                        child: Text(
                          "3",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD025,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        )),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }*/

  /*Future<void> callMessageFromLocalDataBase() async {
    debugPrint(":::: Inside Message Fuc ::::");
    SqliteDataBase sqliteDatabase = SqliteDataBase();
    final db = await sqliteDatabase.getDataBase();
    for (var element in adminList) {
      var result = await db
          .query('CHAT', where: 'receiverId = ?', whereArgs: [element.id]);

      if (result.isNotEmpty) {
        debugPrint("Get room Id : ${result.last["roomId"].toString()}");
        for (var element in result) {
          debugPrint("roomId w=====> ${element["roomId"].toString()}");
          roomNumberID.add(element["roomId"].toString());
        }

        if (result.last["roomId"] != null) {
          var result1 = await db.query('CHAT',
              where: 'roomId = ?', whereArgs: [result.last["roomId"]]);
          setState(() {});
          */
  /* if(result1.isNotEmpty){
            element.lastMessageTime = timeParse(result1.last['date'].toString());
            debugPrint("element.lastMessageTime:${element.lastMessageTime}");
            if(result1.last["messageType"].toString() == "text"){
              element.lastMessage = result1.last["message"].toString().toCapitalized();
              debugPrint(" element.lastMessage:${ element.lastMessage}");
            }else {
              element.lastMessage = result1.last["messageType"].toString().toCapitalized();
              debugPrint(" element.lastMessage:${ element.lastMessage}");
            }
            if(mounted){
              setState(() {});
            }
          }*/ /*
        }
      }
    }
  }*/

  void callGetActiveAdmin() {
    NetworkClass(getAdminListUrl, this, getAdminListReq)
        .callRequestServiceHeader(true, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    switch (requestCode) {
      case getAdminListReq:
        var data = jsonDecode(response);
        debugPrint("getAdminListReq Error: $data");
        break;
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    switch (requestCode) {
      case getAdminListReq:
        var data = jsonDecode(response);
        debugPrint("getAdminListReq Success: $data");
        var dataModel = data["data"] as List;

        adminList = dataModel.map((e) => AdminDetailModel.fromJson(e)).toList();

        for (var id in adminIDList) {
          adminList.removeWhere((element) => element.id == id);
        }
        debugPrint("adminListLengthResponse=========> ${adminList.length}");
        setState(() {});
        break;
    }
  }
}
