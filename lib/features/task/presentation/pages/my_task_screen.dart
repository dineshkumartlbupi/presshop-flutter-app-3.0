
import 'package:flutter/material.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/main.dart'; // For currencySymbol
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/presentation/pages/broadcast/BroardcastScreen.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/task/presentation/pages/detail_new/task_details_new_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/core/di/injection_container.dart' as di;
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';

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
    with TickerProviderStateMixin, AnalyticsPageMixin {
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

  // Data managed by Bloc now
  String myId = "";

  int _allTaskOffset = 0;
  int _localTaskOffset = 0;
  final int allTaskLimit = 10;

  bool _showData = false;

  bool _isLocalLoading = false;

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
      // Initial Fetch via Bloc
      // Assuming handled by BlocProvider creation or explicit add here if Bloc is provided from above.
      // But we will ensure BlocProvider is in build.
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
         // Logic to trigger fetch if needed handled in UI/Bloc
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _blinkingController.dispose();
    _tabController.dispose();
    _refreshController.dispose();
    listController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<TaskBloc>();
        bloc.add(FetchAllTasksEvent(offset: 0));
        if (widget.broadCastId != null) {
           bloc.add(FetchTaskDetailEvent(widget.broadCastId!));
        }
        return bloc;
      },
      child: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
           if(state.taskDetail != null) {
              // Handle broadcast dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                broadcastDialog(
                  size: size,
                  taskDetail: state.taskDetail!,
                  onTapView: () {
                    if (widget.broadCastId != null) {
                      Navigator.pop(context);
                    }
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => BroadCastScreen(
                              taskId: state.taskDetail!.id,
                              mediaHouseId: state.taskDetail!.mediaHouseId,
                            )));
                  },
                );
              });
           }
           
           if(state.allTasksStatus == TaskStatus.success || state.localTasksStatus == TaskStatus.success) {
               _refreshController.refreshCompleted();
               _refreshController.loadComplete();
           } else if (state.allTasksStatus == TaskStatus.failure || state.localTasksStatus == TaskStatus.failure) {
               _refreshController.refreshFailed();
               _refreshController.loadFailed();
           }
        },
        child: Builder(
          builder: (context) {
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
                onTap: (index) {
                   if(index == 1) {
                      // Trigger local task fetch if empty, but accessing bloc context here is tricky if not wrapping body.
                      // Since we wrapped Scaffold, we can access using Context if we split widgets or Use Builder.
                      // Or just let _tabController listener handle it but it needs context.
                      // Better: use Builder below BlocProvider. I included BlocProvider in key changes.
                   }
                },
              ),
            ),
            const Divider(
              color: Color(0xFFD8D8D8),
              thickness: 1.5,
            ),
            Flexible(
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                     // Check if we need to fetch local tasks
                     if(_tabController.index == 1 && state.localTasks.isEmpty && state.localTasksStatus == TaskStatus.initial) {
                         context.read<TaskBloc>().add(FetchLocalTasksEvent(filterParams: getFilterParams()));
                     }
                    
                     return _tabController.index == 0
                        ? allTaskWidget(state.allTasks, context)
                        : showLocalTasksDataWidget(state.localTasks, context);
                  },
                )),
          ],
        ),
      ),
            );
          }
        ),
      ),
    );
  }

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

  Widget showLocalTasksDataWidget(List<Task> taskList, BuildContext context) {
    if (taskList.isEmpty) { // Simplified check, loading handled by BlocBuilder state if needed, or overlay. 
      // Actually BlocBuilder handles loading state too if we want to show full page loader.
      // But typically SmartRefresher handles list updates. 
      // If initial load and empty, we might want to show loader.
      // Let's rely on passed list.
      // If list is empty and state is loading, return loader?
      // Since specific logic was removed from build, we rely on _onRefresh calling events.
      // We can check state in build.
    }
    if (taskList.isEmpty) {
      final state = context.read<TaskBloc>().state;
      if (state.localTasksStatus == TaskStatus.loading) {
         return showLoader();
      }
    }
    return taskList.isNotEmpty
        ? SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: () => _onRefresh(context),
            onLoading: () => _onLoading(context),
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
                if (taskList[index] is TaskPending) {
                  var item = taskList[index] as TaskPending;
                  return InkWell(
                    onTap: () {
                      context.read<TaskBloc>().add(FetchTaskDetailEvent(item.broadCastId));
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
                            item.taskDetail?.title ?? "",
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
                  var item = taskList[index] as TaskMy;
                  return InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => TaskDetailNewScreen(
                                  taskStatus: item.status,
                                  taskId: item.taskDetail?.id ?? "",
                                  totalEarning: item.totalAmount)))
                          .then((value) => context.read<TaskBloc>().add(FetchLocalTasksEvent(filterParams: getFilterParams())));

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
                            item.taskDetail?.title.toTitleCase() ?? "",
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

  Widget allTaskWidget(List<TaskAll> allTaskList, BuildContext context) {
    return allTaskList.isNotEmpty
        ? SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: () => _onRefresh(context),
            onLoading: () => _onLoading(context),
            footer: const CustomFooter(builder: commonRefresherFooter),
            child: GridView.builder(
                itemCount: allTaskList.length,
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
                  var item = allTaskList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => TaskDetailNewScreen(
                                  taskStatus: item.status,
                                  taskId: item.id,
                                  totalEarning: "0")))
                          .then((value) => context.read<TaskBloc>().add(FetchLocalTasksEvent(filterParams: getFilterParams())));

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             const TaskDetailNewScreen()));
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
                                      : "",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD025,
                                      color: item.status == "accepted" ||
                                              item.status == "completed"
                                          ? colorThemePink
                                          : Colors.black,
                                      fontWeight: FontWeight.normal)),

                              //////////////
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
                                  : Container(
                                      alignment: Alignment.center,
                                      height: size.width * numD06,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * numD025,
                                          vertical: size.width * numD003),
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
                        Navigator.pop(context);
                        context.read<TaskBloc>().add(FetchLocalTasksEvent(filterParams: getFilterParams()));
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

                                DateTime parseFromDate =
                                    DateTime.parse(item.fromDate!);
                                DateTime parseToDate =
                                    DateTime.parse(pickedDate!);

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

  void _onRefresh(BuildContext context) {
    if (_tabController.index == 0) {
      _allTaskOffset = 0;
      context.read<TaskBloc>().add(FetchAllTasksEvent(offset: 0));
    } else {
      _localTaskOffset = 0;
      context.read<TaskBloc>().add(FetchLocalTasksEvent(offset: 0, filterParams: getFilterParams()));
    }
  }

  void _onLoading(BuildContext context) {
    if (_tabController.index == 0) {
       final state = context.read<TaskBloc>().state;
       _allTaskOffset = state.allTasks.length;
       context.read<TaskBloc>().add(FetchAllTasksEvent(offset: _allTaskOffset));
    } else {
       final state = context.read<TaskBloc>().state;
       _localTaskOffset = state.localTasks.length;
       context.read<TaskBloc>().add(FetchLocalTasksEvent(offset: _localTaskOffset, filterParams: getFilterParams()));
    }
  }

  Map<String, String> getFilterParams() {
    Map<String, String> params = {};

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        params["startdate"] = sortList[pos].fromDate ?? "";
        params["endDate"] = sortList[pos].toDate ?? "";
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
    return params;
  }
}
