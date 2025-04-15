import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:presshop/view/myEarning/TransactionDetailScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

class _MyNotificationScreenState extends State<MyNotificationScreen> implements NetworkResponse {
  late Size size;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<NotificationData> notificationList = [];
  int limit = 10, offset = 0;
  bool showData = false, isLoading = false;
  bool uploadFirst = false, uploadSecond = false, showThird = false;
  int counting = 0;

  @override
  void initState() {
    debugPrint('class:::::::: $runtimeType');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => callNotificationList());

    Future.delayed(const Duration(seconds: 5), () {
      callUpdateNotification();
    });
    super.initState();
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
            content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                              borderRadius: BorderRadius.circular(size.width * 0.02),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: size.width * 0.03),
                              child: Text(
                                "Cancel",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width * numD037, color: Colors.white, fontWeight: FontWeight.bold),
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
                            decoration: BoxDecoration(color: colorThemePink, borderRadius: BorderRadius.circular(size.width * 0.02)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: size.width * 0.031),
                              child: Text(
                                "Delete",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width * numD037, color: Colors.white, fontWeight: FontWeight.bold),
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: size.width * appBarHeadingFontSize),
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
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade800, width: 2), borderRadius: BorderRadius.circular(size.width * numD02)),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(size.width * 0.002),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            Icons.circle,
                            color: colorThemePink,
                            size: size.width * numD04,
                          ),
                        ),
                        Text(
                          widget.count != 0 ? widget.count.toString() : counting.toString(),
                          style: commonTextStyle(size: size, fontSize: size.width * numD025, color: Colors.white, fontWeight: FontWeight.w500),
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
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
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
              padding: EdgeInsets.symmetric(horizontal: size.width * numD05, vertical: size.width * numD02),
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
                      footer: const CustomFooter(builder: commonRefresherFooter),
                      child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.symmetric(horizontal: size.width * numD045),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                debugPrint("Notification Type: ${notificationList[index].messageType}");

                                /// -- When content is Published or Offer Received --
                                if (notificationList[index].messageType == "publish_content" || notificationList[index].messageType == "offer_received") {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyContentDetailScreen(paymentStatus: notificationList[index].paymentStatus, exclusive: notificationList[index].exclusive, contentId: notificationList[index].contentId, offerCount: 0)));
                                } else if (notificationList[index].messageType == "offer_received") {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ManageTaskScreen(roomId: notificationList[index].contentId, contentId: notificationList[index].contentId, type: 'content', mediaHouseDetail: null, contentMedia: null, contentHeader: null, myContentData: null)));
                                } else if (notificationList[index].messageType == "content_sold") {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => TransactionDetailScreen(type: "received", transactionData: notificationList[index].transactionDetailData!)));
                                } else if (notificationList[index].messageType == "new_task_posted") {
                                  if (notificationList[index].broadcastId.isNotEmpty) {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyTaskScreen(hideLeading: false, broadCastId: notificationList[index].broadcastId)));
                                  }
                                } else if (notificationList[index].messageType == "task_accepted") {
                                  if (notificationList[index].broadcastId.isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TaskDetailNewScreen(
                                                  taskId: notificationList[index].broadcastId,
                                                  taskStatus: "accepted",
                                                  totalEarning: "0",
                                                )));
                                  }
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: size.width * numD02),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(size.width * numD03),
                                    topRight: Radius.circular(size.width * numD03),
                                  ),
                                  color: notificationList[index].unread ? Colors.white : colorLightGrey,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: size.width * numD02),
                                      padding: EdgeInsets.all(size.width * numD02),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(size.width * numD04), boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 2, blurRadius: 2)]),
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD07,
                                        width: size.width * numD07,
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * numD035,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notificationList[index].title,
                                                  style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * numD02,
                                              ),
                                              Text(
                                                dateTimeFormatter(dateTime: notificationList[index].time, format: "hh:mm a, dd MMM yyyy", utc: false),
                                                style: commonTextStyle(size: size, fontSize: size.width * numD025, color: colorGrey2, fontWeight: FontWeight.w300),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.width * numD02,
                                          ),
                                          Text(
                                            notificationList[index].description,
                                            style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.normal),
                                            maxLines: 5,
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
    setState(() {
      offset += 10;
      callNotificationList();
    });
    _refreshController.loadComplete();
  }

  /// Api Section
  callNotificationList() {
    NetworkClass("$notificationListAPI?limit=10&offset=$offset", this, reqNotificationListAPI).callRequestServiceHeader(isLoading ? false : true, 'get', null);
  }

  callUpdateNotification() {
    NetworkClass(notificationReadAPI, this, reqNotificationReadAPI).callRequestServiceHeader(false, 'patch', null);
  }

  callClearNotification() {
    NetworkClass(clearNotification, this, reqClearNotification).callRequestServiceHeader(true, 'patch', null);
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
        case reqNotificationListAPI:
          log("success response===> ${jsonDecode(response)}");
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
          debugPrint("success response===> ${jsonDecode(response)}");
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
