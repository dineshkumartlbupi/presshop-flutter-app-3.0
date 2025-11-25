import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/view/chatScreens/ChatScreen.dart';
import 'package:presshop/view/myEarning/TransactionDetailScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/Common.dart';
import '../../../utils/CommonAppBar.dart';
import '../../../utils/CommonWigdets.dart';
import '../../../utils/networkOperations/NetworkClass.dart';
import '../../../utils/networkOperations/NetworkResponse.dart';
import '../../dashboard/Dashboard.dart';
import '../../task_details_new_screen/task_details_new_screen.dart';
import '../ManageTaskScreen.dart';
import '../MyContentDetailScreen.dart';
import '../MyTaskScreen.dart';
import 'notiticationDataModel.dart';

class MyNotificationScreen extends StatefulWidget {
  int count = 0;

  MyNotificationScreen({Key? key, required this.count}) : super(key: key);

  @override
  State<MyNotificationScreen> createState() => _MyNotificationScreenState();
}

class _MyNotificationScreenState extends State<MyNotificationScreen>
    implements NetworkResponse {
  late Size size;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<NotificationData> notificationList = [];
  int limit = 10, offset = 0;
  bool showData = false, isLoading = false;
  bool uploadFirst = false, uploadSecond = false, showThird = false;
  int counting = 0;
  Completer<String?>? _studentBeansCompleter;
  final String? savedSourceDataHeading = "";
  bool isGetLatLong = false;
  String? studentBeansResponseUrlGlobal = "";
  String? savedSourceDataDescription = "";

  @override
  void initState() {
    debugPrint('class::::::::sdfsdf $runtimeType');
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callNotificationList());
    Future.delayed(const Duration(seconds: 5), () {
      callUpdateNotification();
    });
    super.initState();
  }

  Future<void> setIsClickForBeansActivation() async {
    NetworkClass.fromNetworkClass(studentBeansActivationUrl, this,
            studentBeansActivationRequest, null)
        .callRequestServiceHeader(false, "post", null);
    // return;
  }

  void _checkUpdateAndShowPopup() async {
    final String? savedSourceDataType =
        sharedPreferences?.getString(sourceDataTypeKey);
    // final String? savedSourceDataUrl =
    //     sharedPreferences?.getString(sourceDataUrlKey);
    final String? savedSourceDataHeading =
        sharedPreferences?.getString(sourceDataHeadingKey);
    final String? savedSourceDataDescription =
        sharedPreferences?.getString(sourceDataDescriptionKey);
    final bool? savedSourceDataIsOpened =
        sharedPreferences?.getBool(sourceDataIsOpenedKey);
    final bool? savedSourceDataIsClickKey =
        sharedPreferences?.getBool(sourceDataIsClickKey);

    print("saved source data from notification");
    print(savedSourceDataHeading);
    print(savedSourceDataDescription);
    print(savedSourceDataIsOpened);
    print(savedSourceDataIsClickKey);
    print(savedSourceDataType);

    if ((savedSourceDataType ?? '').toLowerCase() == 'studentbeans' &&
        (savedSourceDataIsOpened == false) &&
        savedSourceDataIsClickKey == false) {
      // if (true) {
      final size = MediaQuery.of(navigatorKey.currentState!.context).size;
      _showForceUpdateDialog(size);
    }
  }

  void _showForceUpdateDialog(Size size) {
    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding:
                  EdgeInsets.symmetric(horizontal: size.width * numD04),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(size.width * numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width * numD04),
                          child: Row(
                            children: [
                              Text(
                                studentBeansResponseUrlGlobal ??
                                    "Brains, beans, and breaking news!",
                                // "Brains, beans, and breaking news!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD04,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * numD06,
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120, // fixed width
                                height: 120, // fixed height
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "${commonImagePath}dog2.jpg",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                child: Text(
                                  savedSourceDataDescription ??
                                      "Please confirm your student status to continue",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * numD035,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Expanded(
                              //     child: SizedBox(
                              //   height: size.width * numD12,
                              //   child: commonElevatedButton(
                              //       logoutText,
                              //       size,
                              //       commonButtonTextStyle(size),
                              //       commonButtonStyle(size, Colors.black), () {
                              //     Navigator.pop(context);
                              //     // callRemoveDeviceApi();
                              //   }),
                              // )),
                              // SizedBox(
                              //   width: size.width * numD04,
                              // ),
                              Expanded(
                                child: SizedBox(
                                  height: size.width * numD12,
                                  child: commonElevatedButton(
                                    "Confirm",
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, colorThemePink),
                                    () async {
                                      try {
                                        await setIsClickForBeansActivation();

                                        // print(studentBeansResponseUrlGlobal);
                                        final url = studentBeansResponseUrlGlobal ??
                                            "https://www.studentbeans.com/en-gb/uk/beansid-connect/hosted-app/presshop/student/b150bab7-1e1d-4bb6-98e9-50acd2b44011";

                                        if (url.isEmpty) {
                                          debugPrint("URL is empty");
                                          return;
                                        }

                                        final uri = Uri.parse(url);
                                        final launched = await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                        sharedPreferences!.setBool(
                                            sourceDataIsClickKey, true);
                                        sharedPreferences!.setBool(
                                            sourceDataIsOpenedKey, true);
                                        Navigator.pop(context);

                                        if (!launched) {
                                          debugPrint(
                                              "Could not launch URL: $url");
                                        }
                                      } catch (e) {
                                        debugPrint("Error launching URL: $e");
                                      }
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        });
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: const Text(
    //         "Update Required",
    //         style: TextStyle(fontWeight: FontWeight.bold),
    //       ),
    //       content: const Text(
    //         "A new version of the app is available.\nPlease update to continue.",
    //       ),
    //       actions: [
    //         TextButton(
    // onPressed: () {
    //   launchUrl(
    //     Uri.parse(
    //       "https://play.google.com/store/apps/details?id=com.your.app",
    //     ),
    //   );
    // },
    //           child: const Text("UPDATE NOW"),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  void deleteNotificationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(horizontal: size.width * numD02),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: size.width * num1,
                height: size.width * numD52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * numD025),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(top: size.width * 0.05)),
                    Image.asset(
                      "${iconsPath}delete.png",
                      width: size.width * numD11,
                      height: size.width * numD11,
                      fit: BoxFit.contain,
                      color: colorThemePink,
                    ),
                    Padding(padding: EdgeInsets.only(top: size.width * 0.02)),
                    Text(
                      "Are you sure you want to delete \nall the notifications?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * numD04,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: size.width * numD45,
                            margin: EdgeInsets.only(top: size.width * 0.05),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.02),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * 0.03),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            numD037,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            callClearNotification();
                          },
                          child: Container(
                            width: size.width * numD45,
                            margin: EdgeInsets.only(top: size.width * 0.05),
                            decoration: BoxDecoration(
                                color: colorThemePink,
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.02)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * 0.031),
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            numD037,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        elevation: 0,
        title: Text(
          notificationText,
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
            child: Container(
              margin: EdgeInsets.only(top: size.width * numD048),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: size.width * numD06,
                    width: size.width * numD06,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade800, width: 2),
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(size.width * 0.002),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            Icons.circle,
                            color: colorThemePink,
                            size: size.width * numD04,
                          ),
                        ),
                        Text(
                          widget.count != 0
                              ? widget.count.toString()
                              : counting.toString(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD025,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          ),
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
        hideLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD05),
              child: Divider(
                color: Colors.grey.shade200,
                thickness: 1.5,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD05,
                  vertical: size.width * numD02),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  deleteNotificationDialog();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    clearAllText,
                    style: TextStyle(
                      fontSize: size.width * numD038,
                      fontWeight: FontWeight.w500,
                      color: colorThemePink,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              child: notificationList.isNotEmpty
                  ? SmartRefresher(
                      controller: _refreshController,
                      enablePullDown: true,
                      enablePullUp: true,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      footer:
                          const CustomFooter(builder: commonRefresherFooter),
                      child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD045),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                // _checkUpdateAndShowPopup();

                                debugPrint(
                                    "Notification Type: ${notificationList[index].messageType}");

                                /// -- When content is Published or Offer Received --
                                if (notificationList[index].messageType ==
                                        "publish_content" ||
                                    notificationList[index].messageType ==
                                        "offer_received") {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          MyContentDetailScreen(
                                            paymentStatus:
                                                notificationList[index]
                                                    .paymentStatus,
                                            exclusive: notificationList[index]
                                                .exclusive,
                                            contentId: notificationList[index]
                                                .contentId,
                                            offerCount: 0,
                                            purchasedMediahouseCount: 0,
                                          )));
                                } else if (notificationList[index]
                                        .messageType ==
                                    "offer_received") {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ManageTaskScreen(
                                          roomId:
                                              notificationList[index].contentId,
                                          contentId:
                                              notificationList[index].contentId,
                                          type: 'content',
                                          mediaHouseDetail: null,
                                          contentMedia: null,
                                          contentHeader: null,
                                          myContentData: null)));
                                } else if (notificationList[index]
                                        .messageType ==
                                    "content_sold") {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                              pageType: PageType.CONTENT,
                                              type: "received",
                                              transactionData: notificationList[
                                                      index]
                                                  .transactionDetailData!)));
                                } else if (notificationList[index]
                                        .messageType ==
                                    "new_task_posted") {
                                  if (notificationList[index]
                                      .broadcastId
                                      .isNotEmpty) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => MyTaskScreen(
                                                hideLeading: false,
                                                broadCastId:
                                                    notificationList[index]
                                                        .broadcastId)));
                                  }
                                } else if (notificationList[index]
                                        .messageType ==
                                    "task_accepted") {
                                  if (notificationList[index]
                                      .broadcastId
                                      .isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TaskDetailNewScreen(
                                                  taskId:
                                                      notificationList[index]
                                                          .broadcastId,
                                                  taskStatus: "accepted",
                                                  totalEarning: "0",
                                                )));
                                  }
                                } else if (notificationList[index]
                                        .messageType ==
                                    "initiate_admin_chat") {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ConversationScreen(
                                            hideLeading: false,
                                            message: '',
                                          )));
                                } else if (notificationList[index]
                                        .messageType ==
                                    "studentbeans") {
                                  print("sldkfsdfsd");
                                  _checkUpdateAndShowPopup();
                                }
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.only(top: size.width * numD02),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft:
                                        Radius.circular(size.width * numD03),
                                    topRight:
                                        Radius.circular(size.width * numD03),
                                  ),
                                  color: notificationList[index].unread
                                      ? Colors.white
                                      : colorLightGrey,
                                ),
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
                                      width: size.width * numD035,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10.0),
                                              child: Text(
                                                dateTimeFormatter(
                                                    dateTime:
                                                        notificationList[index]
                                                            .time,
                                                    format:
                                                        "hh:mm a, dd MMM yyyy",
                                                    utc: false),
                                                textAlign: TextAlign.right,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD025,
                                                    color: colorGrey2,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            notificationList[index].title,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD035,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          if (notificationList[index]
                                              .imageUrl
                                              .isNotEmpty) ...[
                                            SizedBox(
                                              height: size.width * numD04,
                                            ),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                notificationList[index]
                                                    .imageUrl,
                                                width: size.width * num1,
                                                fit: BoxFit.fitHeight,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Container();
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.width * numD04,
                                            ),
                                          ],
                                          Text(
                                            notificationList[index].description,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          SizedBox(
                                            height: size.width * numD040,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Column(
                              children: [
                                Container(
                                  height: size.width * numD004,
                                  color: Colors.grey.shade200,
                                ),
                                SizedBox(
                                  height: size.width * numD038,
                                ),
                              ],
                            );
                          },
                          itemCount: notificationList.length),
                    )
                  : showData
                      ? errorMessageWidget("No new notifications")
                      : Container(),
            ),
          ],
        ),
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      offset = 0;
      showData = false;
      notificationList.clear();
      callNotificationList();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      offset += 10;
      callNotificationList();
    });
    _refreshController.loadComplete();
  }

  callNotificationList() {
    NetworkClass("$notificationListAPI?limit=10&offset=$offset", this,
            reqNotificationListAPI)
        .callRequestServiceHeader(isLoading ? false : true, 'get', null);
  }

  callUpdateNotification() {
    NetworkClass(notificationReadAPI, this, reqNotificationReadAPI)
        .callRequestServiceHeader(false, 'patch', null);
  }

  callClearNotification() {
    NetworkClass(clearNotification, this, reqClearNotification)
        .callRequestServiceHeader(true, 'patch', null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      debugPrint("Error response===> ${jsonDecode(response)}");
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case studentBeansActivationRequest:
          debugPrint("studentBeansActivationRequest32434: $response");
          try {
            var map = jsonDecode(response);
            var studentBeansResponseUrl = map["url"];
            studentBeansResponseUrlGlobal = studentBeansResponseUrl;

            // Complete the completer if someone is waiting
            if (_studentBeansCompleter != null &&
                !_studentBeansCompleter!.isCompleted) {
              _studentBeansCompleter!.complete(studentBeansResponseUrlGlobal);
            }
          } catch (e) {
            debugPrint("Error parsing studentBeans response: $e");
            if (_studentBeansCompleter != null &&
                !_studentBeansCompleter!.isCompleted) {
              _studentBeansCompleter!.complete(null);
            }
          }
          break;
        case reqNotificationListAPI:
          log("success response123NOT===> ${jsonDecode(response)}");
          print("success response123NOTwewe===> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['data'] as List;
          counting = data['unreadCount'];
          widget.count = 0;

          var list = dataList.map((e) => NotificationData.fromJson(e)).toList();
          if (list.isNotEmpty) {
            _refreshController.loadComplete();
          } else if (list.isEmpty) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadFailed();
          }
          if (offset == 0) {
            notificationList.clear();
          }

          notificationList.addAll(list);
          debugPrint("notificationList length::::: ${notificationList.length}");
          showData = true;
          isLoading = true;
          setState(() {});

          break;
        case reqNotificationReadAPI:
          debugPrint("success responseREAD===> ${jsonDecode(response)}");
          callNotificationList();
          break;

        case reqClearNotification:
          debugPrint("Gagn success  ${jsonDecode(response)}");
          notificationList.clear();
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }
}
