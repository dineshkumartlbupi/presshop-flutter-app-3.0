import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/view/task_details_new_screen/task_details_new_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../utils/AnalyticsConstants.dart';
import '../../utils/AnalyticsMixin.dart';
import '../../utils/CommonModel.dart';
import '../../utils/AllTaskModel.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../boardcastScreen/BroardcastScreen.dart';
import '../dashboard/Dashboard.dart';
import '../myEarning/MyEarningScreen.dart';

class MyTaskScreen extends StatefulWidget {
  bool hideLeading = false;
  String? broadCastId;

  MyTaskScreen({super.key, required this.hideLeading, this.broadCastId});

  @override
  State<StatefulWidget> createState() {
    return MyTaskScreenState();
  }
}

class MyTaskScreenState extends State<MyTaskScreen>
    with TickerProviderStateMixin, AnalyticsPageMixin
    implements NetworkResponse {
  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.myTasks;

  @override
  Map<String, Object>? get pageParameters => {
        'hide_leading': widget.hideLeading.toString(),
        'broadcast_id': widget.broadCastId ?? 'none',
      };

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late AnimationController _blinkingController;
  late TabController _tabController;

  late Size size;

  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];

  List<TaskParentClass> taskList = [];
  List<AllTaskModel> allTaskList = [];
  //List<MyTaskModel> pendingTaskList = [];

  bool _showData = false;
  String myId = "";

  int _offset = 0;

  String selectedSellType = sharedText;
  ScrollController listController = ScrollController();
  DateTime nowDate = DateTime.now();

  @override
  void initState() {
    debugPrint("class:::::::$runtimeType");
    initializeFilter();
    _blinkingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SharedPreferences.getInstance().then((value) {
        setState(() {
          myId = value.getString("_id") ?? "";
        });
      });
      callAllTaskApi();
      if (widget.broadCastId != null) {
        callTaskDetailApi(widget.broadCastId!);
      }
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (_tabController.index == 1 && taskList.isEmpty) {
          callAllLocalGetTaskApi();
        }
        setState(() {});
      }
    });
  }

  void callAllTaskApi() {
    NetworkClass(getAllTaskUrl, this, getAllTaskReq)
        .callRequestServiceHeader(false, "post", null);
  }

  void callTaskDetailApi(String id) {
    NetworkClass("$taskDetailUrl$id", this, taskDetailUrlRequest)
        .callRequestServiceHeader(false, "get", null);
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
            // "$myText ${taskText}s",
            "${taskText}s",
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
              showBottomSheet(size);
            },
            child: commonFilterIcon(size),
          ),
          SizedBox(
            width: size.width * numD02,
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.width * numD04),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
              child: TabBar(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                labelColor: Colors.white,
                dividerColor: colorThemePink,
                unselectedLabelColor: Colors.black,
                indicator: BoxDecoration(
                  color: colorThemePink,
                  borderRadius: BorderRadius.circular(size.width * numD02),
                ),
                labelStyle: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD038,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(
                    text: "All Tasks",
                  ),
                  Tab(
                    text: "Local Tasks", // as
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFD8D8D8),
              thickness: 1.5,
            ),
            Flexible(
                child: _showData
                    ? _tabController.index == 0
                        ? allTaskWidget()
                        : showLocalTasksDataWidget()
                    : showLoader()),
          ],
        ),
      ),
    );
  }

  /*Widget oldData(){
    return GridView.builder(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * numD04,
            vertical: size.width * numD04),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          mainAxisSpacing: size.width * numD04,
          crossAxisSpacing: size.width * numD04,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(
                    taskStatus: myTaskList[index].taskStatus,taskId: "",)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD04,
                  vertical: size.width * numD02),
              decoration: BoxDecoration(
                  border: Border.all(color: colorGoogleButtonBorder),
                  borderRadius:
                  BorderRadius.circular(size.width * numD04)),
              child: Column(
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  InkWell(
                    onTap: () {
                      broadcastDialog(
                          "REUTERS",
                          "${dummyImagePath}news.png",
                          "Vivamus sit amet commodo risus. Ut dictum rutrum lacinia. Ut at nunc a mi facilisis ornare...",
                          "3 miles away",
                          "2h:30m:00s",
                          "${currencySymbol}150 to ${currencySymbol}500",
                          size,
                              () {},"");
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 1, horizontal: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              size.width * numD04),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 1,
                                spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            size.width * numD04),
                        child: Image.asset(
                          myTaskList[index].image,
                          height: size.width * numD20,
                          width: size.width,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Text(
                    myTaskList[index].textValue,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD03,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "${iconsPath}ic_clock.png",
                        height: size.width * numD03,
                      ),
                      SizedBox(
                        width: size.width * numD01,
                      ),
                      Text(
                        myTaskList[index].time,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD025,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        myTaskList[index].status,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD025,
                            color: myTaskList[index].status ==
                                "Accepted" ||
                                myTaskList[index].status ==
                                    "Completed"
                                ? colorThemePink
                                : Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                      myTaskList[index].status == "Accepted" ||
                          myTaskList[index].status == "Completed"
                          ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            myTaskList[index].taskStatus ==
                                "Live"
                                ? size.width * numD03
                                : size.width * numD01,
                            vertical: size.width * numD01),
                        decoration: BoxDecoration(
                            color:
                            myTaskList[index].taskStatus ==
                                "Live"
                                ? colorThemePink
                                : colorLightGrey,
                            borderRadius: BorderRadius.circular(
                                size.width * numD015)),
                        child: Text(
                          myTaskList[index].taskStatus == "Live"
                              ? myTaskList[index].taskStatus
                              : "$currencySymbol${myTaskList[index].amountStatus} ${receivedText.toTitleCase()}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD025,
                              color: myTaskList[index]
                                  .taskStatus ==
                                  "Live"
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                          : Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD05,
                            vertical: size.width * numD01),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(
                                size.width * numD015)),
                        child: Text(
                          "$currencySymbol${myTaskList[index].amountStatus}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD025,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
        itemCount: myTaskList.length);
  }*/

  /// Load Filter And Sort
  void initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: viewWeeklyText,
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: viewMonthlyText,
          icon: "ic_monthly_calendar.png",
          isSelected: true),
      FilterModel(
          name: viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
      FilterModel(
          name: "View highest payment received",
          icon: "ic_graph_up.png",
          isSelected: false),
      FilterModel(
          name: "View lowest payment received",
          icon: "ic_graph_down.png",
          isSelected: false),
    ]);

    filterList.addAll([
      FilterModel(
          name: liveContentText,
          icon: "ic_live_content.png",
          isSelected: false),
      // FilterModel(
      //     name: paymentsReceivedText,
      //     icon: "ic_payment_reviced.png",
      //     isSelected: false),
      // FilterModel(
      //     name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
    ]);
  }

  Widget showLocalTasksDataWidget() {
    return taskList.isNotEmpty
        ? SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            footer: const CustomFooter(builder: commonRefresherFooter),
            child: GridView.builder(
              itemCount: taskList.length,
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD04,
                  vertical: size.width * numD04),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: size.width * numD04,
                crossAxisSpacing: size.width * numD04,
              ),
              itemBuilder: (context, index) {
                if (taskList[index] is PendingTask) {
                  var item = taskList[index] as PendingTask;
                  return InkWell(
                    onTap: () {
                      //showToast("Please wait...");
                      callTaskDetailApi(item.broadCastId);
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: size.width * numD03,
                          right: size.width * numD03,
                          top: size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ],
                          borderRadius:
                              BorderRadius.circular(size.width * numD04)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Image
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                child: Image.network(
                                  item.taskDetail!.mediaHouseImage,
                                  height: size.width * numD28,
                                  width: size.width,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD26,
                                        width: size.width * numD26,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, exception, stackTrace) {
                                    return Container(
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD26,
                                        width: size.width * numD26,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD02,
                          ),

                          /// Title
                          Text(
                            item.taskDetail!.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),

                          const Spacer(),

                          /// Dead Line
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "${iconsPath}ic_clock.png",
                                height: size.width * numD029,
                              ),
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              Text(
                                dateTimeFormatter(
                                    dateTime:
                                        item.taskDetail!.createdAt.toString(),
                                    format: "hh:mm a"),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD024,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                width: size.width * numD018,
                              ),
                              Image.asset(
                                "${iconsPath}ic_yearly_calendar.png",
                                height: size.width * numD028,
                              ),
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              Text(
                                dateTimeFormatter(
                                    dateTime:
                                        item.taskDetail!.createdAt.toString(),
                                    format: "dd MMM yyyy"),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD024,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD013,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "TAP TO ACCEPT",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD025,
                                    color: colorThemePink,
                                    fontWeight: FontWeight.normal),
                              ),

                              // Animated blinking/highlight effect
                              // Blinking "Available" badge with infinite animation
                              Container(
                                alignment: Alignment.center,
                                height: size.width * numD08,
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD025,
                                    vertical: size.width * numD01),
                                decoration: BoxDecoration(
                                    color: colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD015)),
                                child: Text(
                                  "Available",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD025,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          ),

                          SizedBox(
                            height: size.width * numD02,
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  var item = taskList[index] as MyTaskModel;
                  return InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => TaskDetailNewScreen(
                                  taskStatus: item.status,
                                  taskId: item.taskDetail!.id,
                                  totalEarning: item.totalAmount)))
                          .then((value) => callAllLocalGetTaskApi());

                      //   Navigator.push(context, MaterialPageRoute(builder: (context)=> const TaskDetailNewScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: size.width * numD03,
                          right: size.width * numD03,
                          top: size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ],
                          borderRadius:
                              BorderRadius.circular(size.width * numD04)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Image
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                child: Image.network(
                                  item.taskDetail!.mediaHouseImage,
                                  height: size.width * numD28,
                                  width: size.width,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD26,
                                        width: size.width * numD26,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, exception, stackTrace) {
                                    return Container(
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD26,
                                        width: size.width * numD26,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD02,
                          ),

                          /// Title
                          Text(
                            item.taskDetail!.title.toTitleCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),

                          const Spacer(),

                          /// Dead Line
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "${iconsPath}ic_clock.png",
                                height: size.width * numD029,
                              ),
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              Text(
                                dateTimeFormatter(
                                    dateTime:
                                        item.taskDetail!.createdAt.toString(),
                                    format: "hh:mm a"),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD024,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                width: size.width * numD018,
                              ),
                              Image.asset(
                                "${iconsPath}ic_yearly_calendar.png",
                                height: size.width * numD028,
                              ),
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              Text(
                                dateTimeFormatter(
                                    dateTime:
                                        item.taskDetail!.createdAt.toString(),
                                    format: "dd MMM yyyy"),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD024,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD013,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  item.totalAmount == "0" &&
                                          item.status == "accepted"
                                      ? item.status.toUpperCase()
                                      : "RECEIVED",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD025,
                                      color: item.status == "accepted" ||
                                              item.status == "completed"
                                          ? colorThemePink
                                          : Colors.black,
                                      fontWeight: FontWeight.normal)),
                              item.status == "accepted"
                                  ? Container(
                                      height: size.width * numD065,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD04,
                                          vertical: size.width * numD01),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: item.status == "accepted" &&
                                                  item.totalAmount == "0"
                                              ? Colors.black
                                              : colorLightGrey,
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD015)),
                                      child: Text(
                                        item.status == "accepted" &&
                                                item.totalAmount == "0"
                                            ? "Live"
                                            : "$currencySymbol${item.totalAmount}",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD025,
                                            color: item.status == "accepted" &&
                                                    item.totalAmount == "0"
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      height: size.width * numD08,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD05,
                                          vertical: size.width * numD01),
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD015)),
                                      child: Text(
                                        "$currencySymbol${item.totalAmount}",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD025,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                            ],
                          ),

                          SizedBox(
                            height: size.width * numD02,
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          )
        : errorMessageWidget("No Task Available");
  }

  Widget allTaskWidget() {
    return allTaskList.isNotEmpty
        ? SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            footer: const CustomFooter(builder: commonRefresherFooter),
            child: GridView.builder(
                itemCount: taskList.length,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD04,
                    vertical: size.width * numD04),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: size.width * numD04,
                  crossAxisSpacing: size.width * numD04,
                ),
                itemBuilder: (context, index) {
                  // if (allTaskList[index] is PendingTask) {
                  // if (allTaskList[index].status == "pending") {
                  //   var item = allTaskList[index] as PendingTask;
                  //   return InkWell(
                  //     onTap: () {
                  //       //showToast("Please wait...");
                  //       callTaskDetailApi(item.broadCastId);
                  //     },
                  //     child: Container(
                  //       padding: EdgeInsets.only(
                  //           left: size.width * numD03,
                  //           right: size.width * numD03,
                  //           top: size.width * numD03),
                  //       decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           boxShadow: [
                  //             BoxShadow(
                  //                 color: Colors.grey.shade200,
                  //                 spreadRadius: 2,
                  //                 blurRadius: 1)
                  //           ],
                  //           borderRadius:
                  //               BorderRadius.circular(size.width * numD04)),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           /// Image
                  //           Stack(
                  //             children: [
                  //               ClipRRect(
                  //                 borderRadius:
                  //                     BorderRadius.circular(size.width * numD04),
                  //                 child: Image.network(
                  //                   item.taskDetail!.mediaHouseImage,
                  //                   height: size.width * numD28,
                  //                   width: size.width,
                  //                   fit: BoxFit.cover,
                  //                   loadingBuilder:
                  //                       (context, child, loadingProgress) {
                  //                     if (loadingProgress == null) return child;
                  //                     return Container(
                  //                       alignment: Alignment.topCenter,
                  //                       child: Image.asset(
                  //                         "${commonImagePath}rabbitLogo.png",
                  //                         height: size.width * numD26,
                  //                         width: size.width * numD26,
                  //                       ),
                  //                     );
                  //                   },
                  //                   errorBuilder:
                  //                       (context, exception, stackTrace) {
                  //                     return Container(
                  //                       alignment: Alignment.topCenter,
                  //                       child: Image.asset(
                  //                         "${commonImagePath}rabbitLogo.png",
                  //                         height: size.width * numD26,
                  //                         width: size.width * numD26,
                  //                       ),
                  //                     );
                  //                   },
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //           SizedBox(
                  //             height: size.width * numD02,
                  //           ),

                  //           /// Title
                  //           Text(
                  //             item.taskDetail!.title,
                  //             maxLines: 2,
                  //             overflow: TextOverflow.ellipsis,
                  //             textAlign: TextAlign.start,
                  //             style: commonTextStyle(
                  //                 size: size,
                  //                 fontSize: size.width * numD03,
                  //                 color: Colors.black,
                  //                 fontWeight: FontWeight.w500),
                  //           ),

                  //           const Spacer(),

                  //           /// Dead Line
                  //           Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               Image.asset(
                  //                 "${iconsPath}ic_clock.png",
                  //                 height: size.width * numD029,
                  //               ),
                  //               SizedBox(
                  //                 width: size.width * numD01,
                  //               ),
                  //               Text(
                  //                 dateTimeFormatter(
                  //                     dateTime:
                  //                         item.taskDetail!.createdAt.toString(),
                  //                     format: "hh:mm a"),
                  //                 style: commonTextStyle(
                  //                     size: size,
                  //                     fontSize: size.width * numD024,
                  //                     color: Colors.black,
                  //                     fontWeight: FontWeight.normal),
                  //               ),
                  //               SizedBox(
                  //                 width: size.width * numD018,
                  //               ),
                  //               Image.asset(
                  //                 "${iconsPath}ic_yearly_calendar.png",
                  //                 height: size.width * numD028,
                  //               ),
                  //               SizedBox(
                  //                 width: size.width * numD01,
                  //               ),
                  //               Text(
                  //                 dateTimeFormatter(
                  //                     dateTime:
                  //                         item.taskDetail!.createdAt.toString(),
                  //                     format: "dd MMM yyyy"),
                  //                 style: commonTextStyle(
                  //                     size: size,
                  //                     fontSize: size.width * numD024,
                  //                     color: Colors.black,
                  //                     fontWeight: FontWeight.normal),
                  //               ),
                  //             ],
                  //           ),
                  //           SizedBox(
                  //             height: size.width * numD013,
                  //           ),
                  //           Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text(
                  //                 "TAP TO ACCEPT",
                  //                 style: commonTextStyle(
                  //                     size: size,
                  //                     fontSize: size.width * numD025,
                  //                     color: colorThemePink,
                  //                     fontWeight: FontWeight.normal),
                  //               ),

                  //               // Animated blinking/highlight effect
                  //               // Blinking "Available" badge with infinite animation
                  //               Container(
                  //                 alignment: Alignment.center,
                  //                 height: size.width * numD08,
                  //                 padding: EdgeInsets.symmetric(
                  //                     horizontal: size.width * numD025,
                  //                     vertical: size.width * numD01),
                  //                 decoration: BoxDecoration(
                  //                     color: colorThemePink,
                  //                     borderRadius: BorderRadius.circular(
                  //                         size.width * numD015)),
                  //                 child: Text(
                  //                   "Available",
                  //                   style: commonTextStyle(
                  //                       size: size,
                  //                       fontSize: size.width * numD025,
                  //                       color: Colors.white,
                  //                       fontWeight: FontWeight.w600),
                  //                 ),
                  //               )
                  //             ],
                  //           ),

                  //           SizedBox(
                  //             height: size.width * numD02,
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   );
                  // } else {
                  var item = taskList[index] as AllTaskModel;
                  return InkWell(
                    onTap: () {
                      // Navigator.of(context)
                      //     .push(MaterialPageRoute(
                      //         builder: (context) => TaskDetailNewScreen(
                      //             taskStatus: item.status,
                      //             taskId: item.taskDetail!.id,
                      //             totalEarning: item.totalAmount)))
                      //     .then((value) => callAllLocalGetTaskApi());

                      //   Navigator.push(context, MaterialPageRoute(builder: (context)=> const TaskDetailNewScreen()));
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          left: size.width * numD03,
                          right: size.width * numD03,
                          top: size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                spreadRadius: 2,
                                blurRadius: 1)
                          ],
                          borderRadius:
                              BorderRadius.circular(size.width * numD04)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Image
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                child: Image.network(
                                  // item.taskDetail!.mediaHouseImage,
                                  item.uploadContents?.videothubnail ?? "",
                                  height: size.width * numD28,
                                  width: size.width,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD26,
                                        width: size.width * numD26,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, exception, stackTrace) {
                                    return Container(
                                      alignment: Alignment.topCenter,
                                      child: Image.asset(
                                        "${commonImagePath}rabbitLogo.png",
                                        height: size.width * numD26,
                                        width: size.width * numD26,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD02,
                          ),

                          /// Title
                          Text(
                            // item.taskDetail!.title.toTitleCase(),
                            item.heading.toTitleCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),

                          const Spacer(),

                          /// Dead Line
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "${iconsPath}ic_clock.png",
                                height: size.width * numD029,
                              ),
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              Text(
                                dateTimeFormatter(
                                    // dateTime:
                                    // item.taskDetail!.createdAt.toString(),
                                    dateTime: item.createdAt.toString(),
                                    format: "hh:mm a"),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD024,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                              SizedBox(
                                width: size.width * numD018,
                              ),
                              Image.asset(
                                "${iconsPath}ic_yearly_calendar.png",
                                height: size.width * numD028,
                              ),
                              SizedBox(
                                width: size.width * numD01,
                              ),
                              Text(
                                dateTimeFormatter(
                                    // dateTime:
                                    //     item.taskDetail!.createdAt.toString(),
                                    dateTime: item.createdAt.toString(),
                                    format: "dd MMM yyyy"),
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD024,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD013,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  // item.totalAmount == "0" &&
                                  item.status == "accepted"
                                      ? item.status.toUpperCase()
                                      : "RECEIVED",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD025,
                                      color: item.status == "accepted" ||
                                              item.status == "completed"
                                          ? colorThemePink
                                          : Colors.black,
                                      fontWeight: FontWeight.normal)),
                              item.status == "accepted"
                                  ? Container(
                                      height: size.width * numD065,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD04,
                                          vertical: size.width * numD01),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: item.status == "accepted"
                                              // && item.totalAmount == "0"
                                              ? Colors.black
                                              : colorLightGrey,
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD015)),
                                      child: Text(
                                        item.status == "accepted"
                                            //  &&   item.totalAmount == "0"
                                            ? "Live"
                                            : "Amount",
                                        // : "$currencySymbol${item.totalAmount}",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD025,
                                            color: item.status == "accepted"
                                                // && item.totalAmount == "0"
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  : Container(),
                              // : Container(
                              //     alignment: Alignment.center,
                              //     height: size.width * numD08,
                              //     padding: EdgeInsets.symmetric(
                              //         horizontal: size.width * numD05,
                              //         vertical: size.width * numD01),
                              //     decoration: BoxDecoration(
                              //         color: Colors.black,
                              //         borderRadius: BorderRadius.circular(
                              //             size.width * numD015)),
                              //     child: Text(
                              //       "$currencySymbol${item.totalAmount}",
                              //       style: commonTextStyle(
                              //           size: size,
                              //           fontSize: size.width * numD025,
                              //           color: Colors.white,
                              //           fontWeight: FontWeight.w600),
                              //     ),
                              //   )
                            ],
                          ),

                          SizedBox(
                            height: size.width * numD02,
                          )
                        ],
                      ),
                    ),
                  );
                }
                // },
                ),
          )
        : errorMessageWidget("No Task Available");
  }

  Future<void> showBottomSheet(Size size) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD085),
          topRight: Radius.circular(size.width * numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter stateSetter) {
            return Padding(
              padding: EdgeInsets.only(
                top: size.width * numD06,
                left: size.width * numD05,
                right: size.width * numD05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          splashRadius: size.width * numD07,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: size.width * numD07,
                          ),
                        ),
                        Text(
                          "Filter",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * appBarHeadingFontSizeNew,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            filterList.clear();
                            sortList.clear();
                            initializeFilter();
                            stateSetter(() {});
                          },
                          child: Text(
                            "Clear all",
                            style: TextStyle(
                                color: colorThemePink,
                                fontWeight: FontWeight.w400,
                                fontSize: size.width * numD035),
                          ),
                        ),
                      ],
                    ),

                    /// Sort
                    SizedBox(
                      height: size.width * numD085,
                    ),

                    // /// Sort Heading
                    // Text(
                    //   sortText,
                    //   style: commonTextStyle(
                    //       size: size,
                    //       fontSize: size.width * numD05,
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w500),
                    // ),

                    // filterListWidget(sortList, stateSetter, size, true),

                    /// Filter
                    // SizedBox(
                    //   height: size.width * numD05,
                    // ),

                    /// Filter Heading
                    Text(
                      filterText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),

                    filterListWidget(filterList, stateSetter, size, false),

                    SizedBox(
                      height: size.width * numD06,
                    ),

                    /// Button
                    Container(
                      width: size.width,
                      height: size.width * numD13,
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * numD04),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: commonElevatedButton(
                          applyText,
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        Navigator.pop(context);
                        callAllLocalGetTaskApi();
                      }),
                    ),
                    SizedBox(
                      height: size.width * numD08,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget filterListWidget(
      List<FilterModel> list, StateSetter stateSetter, Size size, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: size.width * numD03),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return InkWell(
          onTap: () {
            if (isSort) {
              int pos = list.indexWhere((element) => element.isSelected);
              if (pos != -1) {
                list[pos].isSelected = false;
                list[pos].fromDate = null;
                list[pos].toDate = null;
              }
            }
            item.isSelected = !item.isSelected;
            stateSetter(() {});
          },
          child: Container(
            padding: EdgeInsets.only(
              top: list[index].name == filterDateText
                  ? size.width * 0
                  : size.width * numD025,
              bottom: list[index].name == filterDateText
                  ? size.width * 0
                  : size.width * numD025,
              left: size.width * numD02,
              right: size.width * numD02,
            ),
            color: item.isSelected ? Colors.grey.shade400 : null,
            child: Row(
              children: [
                Image.asset(
                  "$iconsPath${list[index].icon}",
                  color: Colors.black,
                  height: list[index].name == soldContentText
                      ? size.width * numD06
                      : size.width * numD05,
                  width: list[index].name == soldContentText
                      ? size.width * numD06
                      : size.width * numD05,
                ),
                SizedBox(
                  width: size.width * numD03,
                ),
                item.name == filterDateText
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              item.fromDate = await commonDatePicker();
                              item.toDate = null;
                              int pos = list
                                  .indexWhere((element) => element.isSelected);
                              if (pos != -1) {
                                list[pos].isSelected = false;
                              }
                              item.isSelected = !item.isSelected;
                              stateSetter(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                border: Border.all(
                                    width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateTimeFormatter(
                                        dateTime: item.fromDate.toString(),
                                        format: "dd/mm/yy"),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD015,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD03,
                          ),
                          InkWell(
                            onTap: () async {
                              if (item.fromDate != null) {
                                String? pickedDate = await commonDatePicker();

                                if (pickedDate != null) {
                                  DateTime parseFromDate =
                                      DateTime.parse(item.fromDate!);
                                  DateTime parseToDate =
                                      DateTime.parse(pickedDate);

                                  debugPrint("parseFromDate : $parseFromDate");
                                  debugPrint("parseToDate : $parseToDate");

                                  if (parseToDate.isAfter(parseFromDate) ||
                                      parseToDate
                                          .isAtSameMomentAs(parseFromDate)) {
                                    item.toDate = pickedDate;
                                  } else {
                                    showSnackBar(
                                        "Date Error",
                                        "Please select to date above from date",
                                        Colors.red);
                                  }
                                }
                              }

                              setState(() {});
                              stateSetter(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                border: Border.all(
                                    width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateTimeFormatter(
                                            dateTime: item.toDate.toString(),
                                            format: "dd/mm/yy") ??
                                        toText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD02,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(list[index].name,
                        style: TextStyle(
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: "AirbnbCereal_W_Bk"))
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: size.width * numD01,
        );
      },
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return; // FIX
    setState(() {
      _showData = false;
      _offset = 0;
      if (_tabController.index == 0) {
        callAllTaskApi();
      } else {
        taskList.clear();
        callAllLocalGetTaskApi();
      }
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() {
      _offset += 10;
      if (_tabController.index == 0) {
        callAllTaskApi();
      } else {
        callAllLocalGetTaskApi();
      }
    });
    _refreshController.loadComplete();
  }

  void getAllTaskApi() {
    Map<String, String> params = {"limit": "10", "offset": _offset.toString()};

    NetworkClass("/hopper/getAllTask", this, getAllTaskReq)
        .callRequestServiceHeader(false, "post", params);
  }

  void callAllLocalGetTaskApi() {
    Map<String, String> params = {"limit": "10", "offset": _offset.toString()};

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        params["startdate"] = sortList[pos].fromDate!;
        params["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == viewMonthlyText) {
        params["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        params["posted_date"] = "365";
      } else if (sortList[pos].name == viewWeeklyText) {
        params["posted_date"] = "7";
      } else if (sortList[pos].name == "View highest payment received") {
        params["hightolow"] = "-1";
      } else if (sortList[pos].name == "View lowest payment received") {
        params["lowtohigh"] = "-1";
      }
    }

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case paymentsReceivedText:
            params["paid_status"] = "paid";
            break;

          case liveTaskText:
            params["status"] = "live";
            break;

          case pendingPaymentsText:
            params["paid_status"] = "un_paid";
            break;
        }
      }
    }

    print("Params Params =======>$params");
    // print(params);

    NetworkClass(getAllMyTaskUrl, this, getAllMyTaskReq)
        .callRequestServiceHeader(false, "get", params);
  }

  @override
  void onError({required int requestCode, required String response}) {
    switch (requestCode) {
      case getAllMyTaskReq:
        {
          Map<String, dynamic>? data;

          try {
            if (response.isNotEmpty &&
                response.trim().startsWith("{") &&
                response.trim().endsWith("}")) {
              data = jsonDecode(response);
            } else {
              debugPrint(
                  "getAllMyTaskReq Error: NON-JSON response → $response");
              return;
            }
          } catch (e) {
            debugPrint("JSON Parsing Failed in onError: $e");
            return;
          }

          debugPrint("getAllMyTaskReq Error Parsed: $data");
          break;
        }

      case getAllTaskReq:
        debugPrint("getAllTaskReq Error: $response");
        break;

      /// Get BroadCast task Detail
      case taskDetailUrlRequest:
        debugPrint("BroadcastData::::Error");
        break;
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    switch (requestCode) {
      case getAllMyTaskReq:
        {
          var data = jsonDecode(response);
          debugPrint("getAllMyTaskReq Success : $data");

          var dataModel = data["data"] as List;

          var pendingTaskList = data["pending_unaccepted"] as List;
          var list = dataModel.map((e) => MyTaskModel.fromJson(e)).toList();
          var pendingList = pendingTaskList.isNotEmpty
              ? pendingTaskList.map((e) => PendingTask.fromJson(e)).toList()
              : <PendingTask>[];

          if (list.isNotEmpty) {
            _refreshController.loadComplete();
          } else if (list.isEmpty) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadFailed();
          }

          if (_offset == 0) {
            taskList.clear();
          }

          taskList.addAll(list);
          taskList.addAll(pendingList);
          debugPrint("taskList Length : ${taskList.length}");
          _showData = true;

          if (mounted) {
            setState(() {});
          }
          break;
        }

      case getAllTaskReq:
        {
          var data = jsonDecode(response);
          debugPrint("getAllTaskReq Success : $data");
          var list = (data['data'] as List)
              .map((e) => AllTaskModel.fromJson(e))
              .toList();

          if (list.isNotEmpty) {
            _refreshController.loadComplete();
          } else if (list.isEmpty) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadFailed();
          }

          if (_offset == 0) {
            allTaskList.clear();
          }

          allTaskList.addAll(list);
          _showData = true;
          setState(() {});
          break;
        }

      /// Get BroadCast task Detail
      case taskDetailUrlRequest:
        debugPrint("taskDetailUrlRequest: 1  $response");
        var map = jsonDecode(response);
        if (map["code"] == 200 && map["task"] != null) {
          var broadCastedData = TaskDetailModel.fromJson(map["task"]);
          debugPrint("taskDetailUrlRequest: 2 $broadCastedData");
          broadcastDialog(
            size: MediaQuery.of(context).size,
            taskDetail: broadCastedData,
            onTapView: () {
              if (widget.broadCastId != null) {
                Navigator.pop(context);
              }
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BroadCastScreen(
                        taskId: broadCastedData.id,
                        mediaHouseId: broadCastedData.mediaHouseId,
                      )));
            },
          );
        }
        setState(() {});
        break;
    }
  }
}

class TaskParentClass {
  String status = "";
  String totalAmount = "";
}

class PendingTask extends TaskParentClass {
  TaskDetailModel? taskDetail;
  String title = "";
  String body = "";
  String broadCastId = "";
  PendingTask.fromJson(Map<String, dynamic> json) {
    taskDetail = TaskDetailModel.fromJson(json["task"] ?? {});
    status = "pending";
    totalAmount = '0';
    broadCastId = (json["broadCast_id"] ?? "").toString();
    title = (json["title"] ?? "").toString();
    body = (json["body"] ?? "").toString();
  }
}

class MyTaskModel extends TaskParentClass {
  TaskDetailModel? taskDetail;

  MyTaskModel.fromJson(Map<String, dynamic> json) {
    taskDetail = TaskDetailModel.fromJson(json["task_id"] ?? {});
    status = (json["task_status"] ?? "").toString();
    totalAmount = json['total_payment'].toString() ?? '0';
  }
}
