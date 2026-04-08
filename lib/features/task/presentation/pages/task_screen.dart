import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/services/media_upload_service.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/core/di/injection_container.dart' as di;
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';

// ignore: must_be_immutable
class MyTaskScreen extends StatefulWidget {
  MyTaskScreen(
      {super.key,
      required this.hideLeading,
      this.broadCastId,
      this.showAppBar = false});
  bool hideLeading = false;
  String? broadCastId;
  bool showAppBar = false;

  @override
  State<StatefulWidget> createState() {
    return MyTaskScreenState();
  }
}

class MyTaskScreenState extends State<MyTaskScreen>
    with
        TickerProviderStateMixin,
        AnalyticsPageMixin,
        AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.myTasks;

  @override
  Map<String, Object>? get pageParameters => {
        'hide_leading': widget.hideLeading.toString(),
        'broadcast_id': widget.broadCastId ?? 'none',
      };

  final RefreshController _allRefreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _localRefreshController =
      RefreshController(initialRefresh: false);
  late AnimationController _blinkingController;
  late TabController _tabController;

  late Size size;

  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];

  // Data managed by Bloc now
  String myId = "";

  int _allTaskOffset = 0;

  final int allTaskLimit = 10;

  // bool _showData = false;

  // bool _isLocalLoading = false;

  String selectedSellType = AppStrings.sharedText;
  ScrollController listController = ScrollController();
  DateTime nowDate = DateTime.now();

  Position? _currentPosition;

  // Flags to track if we've initiated fetch for each tab
  bool _allTasksFetchInitiated = false;
  bool _localTasksFetchInitiated = false;

  Future<void> _fetchLocationAndLoadTasks(TaskBloc bloc) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 2),
              onTimeout: () => LocationPermission.denied);

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
            const Duration(seconds: 3),
            onTimeout: () => LocationPermission.denied);
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.medium)
            .timeout(const Duration(seconds: 5));
        _currentPosition = position;

        bloc.add(FetchAllTasksEvent(offset: 0, filterParams: {
          "latitude": position.latitude,
          "longitude": position.longitude
        }));
      } else {
        bloc.add(FetchAllTasksEvent(offset: 0));
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      bloc.add(FetchAllTasksEvent(offset: 0));
    }
  }

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
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _blinkingController.dispose();
    _tabController.dispose();
    _allRefreshController.dispose();
    _localRefreshController.dispose();
    listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) {
        final bloc = di.sl<TaskBloc>();
        if (widget.broadCastId != null) {
          bloc.add(FetchTaskDetailEvent(widget.broadCastId!));
        }
        return bloc;
      },
      child: BlocListener<TaskBloc, TaskState>(
        listenWhen: (previous, current) =>
            previous.taskDetail != current.taskDetail &&
            current.taskDetail != null,
        listener: (context, state) {
          debugPrint("🚀 UI: Showing Broadcast Dialog");
          context.pushNamed(
            AppRoutes.broadcastName,
            extra: {
              'taskId': state.taskDetail!.task.id,
              'mediaHouseId': state.taskDetail!.task.mediaHouse.id,
            },
          );
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   // broadcastDialog(
          //   //   size: size,
          //   //   taskDetail: state.taskDetail!,
          //   //   onTapViewDetails: () {
          //   //     context.pop();
          //   //     context.pushNamed(
          //   //       AppRoutes.broadcastName,
          //   //       extra: {
          //   //         'taskId': state.taskDetail!.task.id,
          //   //         'mediaHouseId': state.taskDetail!.task.mediaHouse.id,
          //   //       },
          //   //     );
          //   //   },
          //   // );
          // });
        },
        child: BlocListener<TaskBloc, TaskState>(
          listenWhen: (previous, current) =>
              previous.allTasksStatus != current.allTasksStatus ||
              previous.localTasksStatus != current.localTasksStatus,
          listener: (context, state) {
            if (state.allTasksStatus != TaskStatus.loading) {
              _allRefreshController.refreshCompleted();
              _allRefreshController.loadComplete();
            }
            if (state.localTasksStatus != TaskStatus.loading) {
              _localRefreshController.refreshCompleted();
              _localRefreshController.loadComplete();
            }
          },
          child: Builder(builder: (context) {
            return Scaffold(
              appBar: NewHomeAppBar(
                size: size,
                hideLeading: widget.hideLeading,
                onFilterTap: () {
                  showBottomSheet(size);
                },
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // SizedBox(height: size.width * AppDimensions.numD04),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD04),
                      child: TabBar(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        labelColor: Colors.white,
                        dividerColor: AppColorTheme.colorThemePink,
                        unselectedLabelColor: Colors.black,
                        indicator: BoxDecoration(
                          color: AppColorTheme.colorThemePink,
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD02),
                        ),
                        labelStyle: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD038,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          const Tab(
                            text: "All Tasks",
                          ),
                          const Tab(
                            text: "Local Tasks",
                          ),
                        ],
                        onTap: (index) {
                          setState(() {});
                        },
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFD8D8D8),
                      thickness: 1.5,
                    ),
                    Flexible(child: BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, state) {
                        // Check if we need to fetch tasks for All Tasks tab
                        if (_tabController.index == 0 &&
                            !_allTasksFetchInitiated &&
                            state.allTasks.isEmpty &&
                            state.allTasksStatus == TaskStatus.initial) {
                          _allTasksFetchInitiated = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _fetchLocationAndLoadTasks(
                                context.read<TaskBloc>());
                          });
                        }
                        // Check if we need to fetch tasks for Local Tasks tab
                        if (_tabController.index == 1 &&
                            !_localTasksFetchInitiated &&
                            state.localTasks.isEmpty &&
                            state.localTasksStatus == TaskStatus.initial) {
                          _localTasksFetchInitiated = true;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<TaskBloc>().add(FetchLocalTasksEvent(
                                filterParams: getFilterParams()));
                          });
                        }

                        List<Task> currentLocalTasks =
                            state.localTasks.where((item) {
                          if (item.status == "accepted" ||
                              item.status == "completed") return true;
                          if (item is TaskPending && item.taskDetail != null) {
                            return !item.taskDetail!.deadLine
                                .isBefore(DateTime.now());
                          } else if (item is TaskMy &&
                              item.taskDetail != null) {
                            return !item.taskDetail!.deadLine
                                .isBefore(DateTime.now());
                          }
                          return true;
                        }).toList();

                        List<TaskAll> currentAllTasks =
                            state.allTasks.where((item) {
                          if (item.status == "accepted" ||
                              item.status == "completed") return true;
                          if (item.deadlineDate != null) {
                            return !item.deadlineDate!.isBefore(DateTime.now());
                          }
                          return true;
                        }).toList();

                        return _tabController.index == 0
                            ? allTaskWidget(currentAllTasks, context)
                            : showLocalTasksDataWidget(
                                currentLocalTasks, context);
                      },
                    )),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget uploadingStatusWidget(Size size, int progress, String status) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: size.width * AppDimensions.numD04,
          vertical: size.width * AppDimensions.numD02),
      padding: EdgeInsets.all(size.width * AppDimensions.numD03),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(size.width * AppDimensions.numD02),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200, spreadRadius: 1, blurRadius: 2)
          ]),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * AppDimensions.numD02),
            decoration: BoxDecoration(
                color: AppColorTheme.colorThemePink.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: AppColorTheme.colorThemePink,
              size: size.width * AppDimensions.numD06,
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status == 'processing'
                      ? "Processing media..."
                      : "Uploading Task Media...",
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.width * AppDimensions.numD01),
                if (status != 'processing')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD01),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColorTheme.colorThemePink),
                      minHeight: size.width * AppDimensions.numD015,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD03),
          if (status == 'processing')
            SizedBox(
              height: size.width * AppDimensions.numD05,
              width: size.width * AppDimensions.numD05,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColorTheme.colorThemePink),
              ),
            )
          else
            Text(
              "$progress%",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD03,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  void initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: AppStrings.viewWeeklyText,
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.viewMonthlyText,
          icon: "ic_monthly_calendar.png",
          isSelected: true),
      FilterModel(
          name: AppStrings.viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.filterDateText,
          icon: "ic_eye_outlined.png",
          isSelected: false),
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
          name: AppStrings.liveContentText,
          icon: "ic_live_content.png",
          isSelected: false),
      // FilterModel(
      //     name: AppStrings.paymentsReceivedText,
      //     icon: "ic_payment_reviced.png",
      //     isSelected: false),
      // FilterModel(
      //     name: AppStrings.pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
    ]);
  }

  Widget showLocalTasksDataWidget(List<Task> taskList, BuildContext context) {
    final localTasksStatus =
        context.select((TaskBloc bloc) => bloc.state.localTasksStatus);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SmartRefresher(
          controller: _localRefreshController,
          enablePullDown: true,
          enablePullUp: taskList.isNotEmpty,
          onRefresh: () => _onLocalRefresh(context),
          onLoading: () => _onLocalLoading(context),
          footer: const CustomFooter(builder: commonRefresherFooter),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable: MediaUploadService.uploadStatus,
                  builder: (context, status, child) {
                    if (status != null &&
                        (status['status'] == 'uploading' ||
                            status['status'] == 'starting' ||
                            status['status'] == 'processing')) {
                      return uploadingStatusWidget(
                          size, status['progress'], status['status']);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              if (taskList.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD04,
                      vertical: size.width * AppDimensions.numD04),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      mainAxisSpacing: size.width * AppDimensions.numD04,
                      crossAxisSpacing: size.width * AppDimensions.numD04,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (taskList[index] is TaskPending) {
                          var item = taskList[index] as TaskPending;
                          return InkWell(
                            onTap: () {
                              context
                                  .read<TaskBloc>()
                                  .add(FetchTaskDetailEvent(item.broadCastId));
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: size.width * AppDimensions.numD03,
                                  right: size.width * AppDimensions.numD03,
                                  top: size.width * AppDimensions.numD03),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade200,
                                        spreadRadius: 2,
                                        blurRadius: 1)
                                  ],
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Image
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD04),
                                        child: item.taskDetail
                                                        ?.mediaHouseImage !=
                                                    null &&
                                                item.taskDetail!.mediaHouseImage
                                                    .isNotEmpty
                                            ? Image.network(
                                                item.taskDetail!
                                                    .mediaHouseImage,
                                                height: size.width *
                                                    AppDimensions.numD28,
                                                width: size.width,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Container(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Image.asset(
                                                      "${commonImagePath}rabbitLogo.png",
                                                      height: size.width *
                                                          AppDimensions.numD26,
                                                      width: size.width *
                                                          AppDimensions.numD26,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context,
                                                    exception, stackTrace) {
                                                  return Container(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Image.asset(
                                                      "${commonImagePath}rabbitLogo.png",
                                                      height: size.width *
                                                          AppDimensions.numD26,
                                                      width: size.width *
                                                          AppDimensions.numD26,
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                alignment: Alignment.topCenter,
                                                child: Image.asset(
                                                  "${commonImagePath}rabbitLogo.png",
                                                  height: size.width *
                                                      AppDimensions.numD26,
                                                  width: size.width *
                                                      AppDimensions.numD26,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD02,
                                  ),

                                  /// Title
                                  Text(
                                    item.taskDetail?.title ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
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
                                        height:
                                            size.width * AppDimensions.numD029,
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD01,
                                      ),
                                      Text(
                                        dateTimeFormatter(
                                            dateTime: item.taskDetail!.createdAt
                                                .toString(),
                                            format: "hh:mm a"),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD024,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD018,
                                      ),
                                      Image.asset(
                                        "${iconsPath}ic_yearly_calendar.png",
                                        height:
                                            size.width * AppDimensions.numD028,
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD01,
                                      ),
                                      Text(
                                        dateTimeFormatter(
                                            dateTime: item.taskDetail!.createdAt
                                                .toString(),
                                            format: "dd MMM yyyy"),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD024,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD013,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "TAP TO ACCEPT",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD025,
                                            color: AppColorTheme.colorThemePink,
                                            fontWeight: FontWeight.normal),
                                      ),

                                      // Animated blinking/highlight effect
                                      // Blinking "Available" badge with infinite animation
                                      FadeTransition(
                                        opacity: _blinkingController,
                                        child: Container(
                                          alignment: Alignment.center,
                                          height:
                                              size.width * AppDimensions.numD08,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width *
                                                  AppDimensions.numD025,
                                              vertical: size.width *
                                                  AppDimensions.numD01),
                                          decoration: BoxDecoration(
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              borderRadius:
                                                  BorderRadius.circular(size
                                                          .width *
                                                      AppDimensions.numD015)),
                                          child: Text(
                                            "Available",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD025,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),

                                  SizedBox(
                                    height: size.width * AppDimensions.numD02,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          var item = taskList[index] as TaskMy;
                          return InkWell(
                            onTap: () {
                              context.pushNamed(AppRoutes.taskDetailNewName,
                                  extra: {
                                    'taskStatus': item.status,
                                    'taskId': item.taskDetail?.id ?? "",
                                    'totalEarning': item.totalAmount,
                                  }).then((value) {
                                if (context.mounted) {
                                  context.read<TaskBloc>().add(
                                      FetchLocalTasksEvent(
                                          filterParams: getFilterParams(),
                                          showLoader: false));
                                }
                              });

                              //   Navigator.push(context, MaterialPageRoute(builder: (context)=> const TaskDetailNewScreen()));
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                  left: size.width * AppDimensions.numD03,
                                  right: size.width * AppDimensions.numD03,
                                  top: size.width * AppDimensions.numD03),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.shade200,
                                        spreadRadius: 2,
                                        blurRadius: 1)
                                  ],
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Image
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD04),
                                        child: Image.network(
                                          item.taskDetail!.mediaHouseImage,
                                          height:
                                              size.width * AppDimensions.numD28,
                                          width: size.width,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              alignment: Alignment.topCenter,
                                              child: Image.asset(
                                                "${commonImagePath}rabbitLogo.png",
                                                height: size.width *
                                                    AppDimensions.numD26,
                                                width: size.width *
                                                    AppDimensions.numD26,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, exception, stackTrace) {
                                            return Container(
                                              alignment: Alignment.topCenter,
                                              child: Image.asset(
                                                "${commonImagePath}rabbitLogo.png",
                                                height: size.width *
                                                    AppDimensions.numD26,
                                                width: size.width *
                                                    AppDimensions.numD26,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD02,
                                  ),

                                  /// Title
                                  Text(
                                    item.taskDetail?.title.toTitleCase() ?? "",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
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
                                        height:
                                            size.width * AppDimensions.numD029,
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD01,
                                      ),
                                      Text(
                                        dateTimeFormatter(
                                            dateTime: item.taskDetail!.createdAt
                                                .toString(),
                                            format: "hh:mm a"),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD024,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD018,
                                      ),
                                      Image.asset(
                                        "${iconsPath}ic_yearly_calendar.png",
                                        height:
                                            size.width * AppDimensions.numD028,
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD01,
                                      ),
                                      Text(
                                        dateTimeFormatter(
                                            dateTime: item.taskDetail!.createdAt
                                                .toString(),
                                            format: "dd MMM yyyy"),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD024,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD013,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          item.totalAmount == "0" &&
                                                  item.status == "accepted"
                                              ? item.status.toUpperCase()
                                              : "RECEIVED",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD025,
                                              color: item.status ==
                                                          "accepted" ||
                                                      item.status == "completed"
                                                  ? AppColorTheme.colorThemePink
                                                  : Colors.black,
                                              fontWeight: FontWeight.normal)),
                                      item.status == "accepted"
                                          ? Container(
                                              height: size.width *
                                                  AppDimensions.numD065,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width *
                                                      AppDimensions.numD04,
                                                  vertical: size.width *
                                                      AppDimensions.numD01),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: item.status ==
                                                              "accepted" &&
                                                          item.totalAmount ==
                                                              "0"
                                                      ? Colors.black
                                                      : AppColorTheme
                                                          .colorLightGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width *
                                                              AppDimensions
                                                                  .numD015)),
                                              child: Text(
                                                item.status == "accepted" &&
                                                        item.totalAmount == "0"
                                                    ? "Live"
                                                    : "$currencySymbol${item.totalAmount}",
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD025,
                                                    color: item.status ==
                                                                "accepted" &&
                                                            item.totalAmount ==
                                                                "0"
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            )
                                          : Container(
                                              alignment: Alignment.center,
                                              height: size.width *
                                                  AppDimensions.numD08,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: size.width *
                                                      AppDimensions.numD05,
                                                  vertical: size.width *
                                                      AppDimensions.numD01),
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width *
                                                              AppDimensions
                                                                  .numD015)),
                                              child: Text(
                                                "$currencySymbol${item.totalAmount}",
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD025,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            )
                                    ],
                                  ),

                                  SizedBox(
                                    height: size.width * AppDimensions.numD02,
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      childCount: taskList.length,
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  child: Center(
                    child: (localTasksStatus == TaskStatus.loading ||
                            localTasksStatus == TaskStatus.initial)
                        ? showAnimatedLoader(size)
                        : errorMessageWidget("No Task Available"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget allTaskWidget(List<TaskAll> allTaskList, BuildContext context) {
    final allTasksStatus =
        context.select((TaskBloc bloc) => bloc.state.allTasksStatus);
    return LayoutBuilder(builder: (context, constraints) {
      return SmartRefresher(
        controller: _allRefreshController,
        enablePullDown: true,
        enablePullUp: allTaskList.isNotEmpty,
        onRefresh: () => _onAllRefresh(context),
        onLoading: () => _onAllLoading(context),
        footer: const CustomFooter(builder: commonRefresherFooter),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: MediaUploadService.uploadStatus,
                builder: (context, status, child) {
                  if (status != null &&
                      (status['status'] == 'uploading' ||
                          status['status'] == 'starting' ||
                          status['status'] == 'processing')) {
                    return uploadingStatusWidget(
                        size, status['progress'], status['status']);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (allTaskList.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD04,
                    vertical: size.width * AppDimensions.numD04),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    mainAxisSpacing: size.width * AppDimensions.numD04,
                    crossAxisSpacing: size.width * AppDimensions.numD04,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var item = allTaskList[index];
                      return InkWell(
                        onTap: () {
                          if (item.isAvailableForAccept &&
                              item.status != "rejected" &&
                              item.status != "accepted") {
                            context.pushNamed(AppRoutes.broadcastName, extra: {
                              'taskId': item.id,
                              'mediaHouseId': item.mediaHouseDetails?.id ?? "",
                            }).then((value) {
                              if (context.mounted) {
                                _allTaskOffset = 0;
                                context.read<TaskBloc>().add(FetchAllTasksEvent(
                                    offset: 0,
                                    filterParams: {},
                                    showLoader: false));
                              }
                            });
                          } else {
                            context
                                .pushNamed(AppRoutes.taskDetailNewName, extra: {
                              'taskStatus': item.status,
                              'taskId': item.id,
                              'totalEarning': "0",
                            }).then((value) {
                              if (context.mounted) {
                                _allTaskOffset = 0;
                                context.read<TaskBloc>().add(FetchAllTasksEvent(
                                    offset: 0,
                                    filterParams: {},
                                    showLoader: false));
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD03,
                              right: size.width * AppDimensions.numD03,
                              top: size.width * AppDimensions.numD03),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    spreadRadius: 2,
                                    blurRadius: 1)
                              ],
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD04)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                    child: Image.network(
                                      // item.taskDetail!.mediaHouseImage,
                                      item.uploadContents?.videothubnail ?? "",
                                      height: size.width * AppDimensions.numD28,
                                      width: size.width,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          alignment: Alignment.topCenter,
                                          child: Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            height: size.width *
                                                AppDimensions.numD26,
                                            width: size.width *
                                                AppDimensions.numD26,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, exception, stackTrace) {
                                        return Container(
                                          alignment: Alignment.topCenter,
                                          child: Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            height: size.width *
                                                AppDimensions.numD26,
                                            width: size.width *
                                                AppDimensions.numD26,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD02,
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
                                    fontSize: size.width * AppDimensions.numD03,
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
                                    height: size.width * AppDimensions.numD029,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD01,
                                  ),
                                  Text(
                                    dateTimeFormatter(
                                        // dateTime:
                                        // item.taskDetail!.createdAt.toString(),
                                        dateTime: item.createdAt.toString(),
                                        format: "hh:mm a"),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD024,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD018,
                                  ),
                                  Image.asset(
                                    "${iconsPath}ic_yearly_calendar.png",
                                    height: size.width * AppDimensions.numD028,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD01,
                                  ),
                                  Text(
                                    dateTimeFormatter(
                                        // dateTime:
                                        //     item.taskDetail!.createdAt.toString(),
                                        dateTime: item.createdAt.toString(),
                                        format: "dd MMM yyyy"),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD024,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD013,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      item.isAvailableForAccept &&
                                              item.status == "accepted"
                                          ? "ACCEPTED"
                                          : item.isAvailableForAccept &&
                                                  item.status == "pending"
                                              ? "TAP TO ACCEPT"
                                              : "",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD025,
                                          color: AppColorTheme.colorThemePink,
                                          fontWeight: FontWeight.normal)),

                                  //////////////
                                  item.status == "accepted"
                                      ? Container(
                                          height: size.width *
                                              AppDimensions.numD065,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width *
                                                  AppDimensions.numD04,
                                              vertical: size.width *
                                                  AppDimensions.numD01),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(size
                                                          .width *
                                                      AppDimensions.numD015)),
                                          child: Text(
                                            "Live",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD025,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        )
                                      : FadeTransition(
                                          opacity: (item.isAvailableForAccept &&
                                                  item.status != "rejected")
                                              ? _blinkingController
                                              : const AlwaysStoppedAnimation(
                                                  1.0),
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: size.width *
                                                AppDimensions.numD06,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width *
                                                    AppDimensions.numD025,
                                                vertical: size.width *
                                                    AppDimensions.numD003),
                                            decoration: BoxDecoration(
                                                color: item.isAvailableForAccept
                                                    ? item.status == "rejected"
                                                        ? Colors.black
                                                        : AppColorTheme
                                                            .colorThemePink
                                                    : Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(size
                                                            .width *
                                                        AppDimensions.numD015)),
                                            child: Text(
                                              item.isAvailableForAccept
                                                  ? item.status == "rejected"
                                                      ? "Live"
                                                      : "Available"
                                                  : "Live",
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width *
                                                      AppDimensions.numD025,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        )
                                ],
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD02,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: allTaskList.length,
                  ),
                ),
              )
            else
              SliverFillRemaining(
                child: Center(
                  child: (allTasksStatus == TaskStatus.loading ||
                          allTasksStatus == TaskStatus.initial)
                      ? showAnimatedLoader(size)
                      : errorMessageWidget("No Task Available"),
                ),
              ),
          ],
        ),
      );
    });
  }

  Future<void> showBottomSheet(Size size) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * AppDimensions.numD085),
          topRight: Radius.circular(size.width * AppDimensions.numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, stateSetter) {
            return Padding(
              padding: EdgeInsets.only(
                top: size.width * AppDimensions.numD06,
                left: size.width * AppDimensions.numD05,
                right: size.width * AppDimensions.numD05,
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
                          splashRadius: size.width * AppDimensions.numD07,
                          onPressed: () {
                            context.pop();
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: size.width * AppDimensions.numD07,
                          ),
                        ),
                        Text(
                          "Filter",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width *
                                  AppDimensions.appBarHeadingFontSizeNew,
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
                                color: AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.w400,
                                fontSize: size.width * AppDimensions.numD035),
                          ),
                        ),
                      ],
                    ),

                    /// Sort
                    SizedBox(
                      height: size.width * AppDimensions.numD085,
                    ),

                    // /// Sort Heading
                    // Text(
                    //   AppStrings.sortText,
                    //   style: commonTextStyle(
                    //       size: size,
                    //       fontSize: size.width * AppDimensions.numD05,
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w500),
                    // ),

                    // filterListWidget(sortList, stateSetter, size, true),

                    /// Filter
                    // SizedBox(
                    //   height: size.width * AppDimensions.numD05,
                    // ),

                    /// Filter Heading
                    Text(
                      AppStrings.filterText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),

                    filterListWidget(filterList, stateSetter, size, false),

                    SizedBox(
                      height: size.width * AppDimensions.numD06,
                    ),

                    /// Button
                    Container(
                      width: size.width,
                      height: size.width * AppDimensions.numD13,
                      margin: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD04),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD04,
                      ),
                      child: commonElevatedButton(
                          AppStrings.applyText,
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, AppColorTheme.colorThemePink),
                          () {
                        context.pop();
                        context.pop();
                        context.read<TaskBloc>().add(FetchLocalTasksEvent(
                            filterParams: getFilterParams()));
                      }),
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD08,
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
      padding: EdgeInsets.only(top: size.width * AppDimensions.numD03),
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
              top: list[index].name == AppStrings.filterDateText
                  ? size.width * 0
                  : size.width * AppDimensions.numD025,
              bottom: list[index].name == AppStrings.filterDateText
                  ? size.width * 0
                  : size.width * AppDimensions.numD025,
              left: size.width * AppDimensions.numD02,
              right: size.width * AppDimensions.numD02,
            ),
            color: item.isSelected ? Colors.grey.shade400 : null,
            child: Row(
              children: [
                Image.asset(
                  "$iconsPath${list[index].icon}",
                  color: Colors.black,
                  height: list[index].name == AppStrings.soldContentText
                      ? size.width * AppDimensions.numD06
                      : size.width * AppDimensions.numD05,
                  width: list[index].name == AppStrings.soldContentText
                      ? size.width * AppDimensions.numD06
                      : size.width * AppDimensions.numD05,
                ),
                SizedBox(
                  width: size.width * AppDimensions.numD03,
                ),
                item.name == AppStrings.filterDateText
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
                                top: size.width * AppDimensions.numD01,
                                bottom: size.width * AppDimensions.numD01,
                                left: size.width * AppDimensions.numD03,
                                right: size.width * AppDimensions.numD01,
                              ),
                              width: size.width * AppDimensions.numD32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
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
                                        fontSize:
                                            size.width * AppDimensions.numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD015,
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
                            width: size.width * AppDimensions.numD03,
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
                                top: size.width * AppDimensions.numD01,
                                bottom: size.width * AppDimensions.numD01,
                                left: size.width * AppDimensions.numD03,
                                right: size.width * AppDimensions.numD01,
                              ),
                              width: size.width * AppDimensions.numD32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
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
                                        format: "dd/mm/yy"),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD032,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD02,
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
                            fontSize: size.width * AppDimensions.numD035,
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
          height: size.width * AppDimensions.numD01,
        );
      },
    );
  }

  Map<String, dynamic> getFilterParams() {
    Map<String, dynamic> params = {};

    List<FilterModel> selectedSort =
        sortList.where((element) => element.isSelected).toList();
    List<FilterModel> selectedFilter =
        filterList.where((element) => element.isSelected).toList();

    if (selectedSort.isNotEmpty) {
      if (selectedSort[0].name == AppStrings.filterDateText) {
        params["startdate"] = selectedSort[0].fromDate ?? "";
        params["endDate"] = selectedSort[0].toDate ?? "";
      } else if (selectedSort[0].name == AppStrings.viewMonthlyText) {
        params["posted_date"] = "31";
      } else if (selectedSort[0].name == AppStrings.viewYearlyText) {
        params["posted_date"] = "365";
      } else if (selectedSort[0].name == AppStrings.viewWeeklyText) {
        params["posted_date"] = "7";
      } else if (selectedSort[0].name == "View highest payment received") {
        params["hightolow"] = "-1";
      } else if (selectedSort[0].name == "View lowest payment received") {
        params["lowtohigh"] = "-1";
      }
    }

    for (var element in selectedFilter) {
      switch (element.name) {
        case AppStrings.paymentsReceivedText:
          params["paid_status"] = "paid";
          break;

        case AppStrings.liveTaskText:
          params["status"] = "live";
          break;

        case AppStrings.pendingPaymentsText:
          params["paid_status"] = "un_paid";
          break;
      }
    }
    return params;
  }

  void _onAllRefresh(BuildContext context) async {
    _allTaskOffset = 0;
    Map<String, dynamic> params = {};
    if (_currentPosition != null) {
      params["latitude"] = _currentPosition!.latitude;
      params["longitude"] = _currentPosition!.longitude;
    }
    context.read<TaskBloc>().add(
        FetchAllTasksEvent(offset: 0, filterParams: params, showLoader: false));
  }

  void _onAllLoading(BuildContext context) async {
    _allTaskOffset += allTaskLimit;
    Map<String, dynamic> params = {};
    if (_currentPosition != null) {
      params["latitude"] = _currentPosition!.latitude;
      params["longitude"] = _currentPosition!.longitude;
    }
    context.read<TaskBloc>().add(FetchAllTasksEvent(
        offset: _allTaskOffset, filterParams: params, showLoader: false));
  }

  void _onLocalRefresh(BuildContext context) async {
    context.read<TaskBloc>().add(FetchLocalTasksEvent(
        filterParams: getFilterParams(), showLoader: false));
  }

  void _onLocalLoading(BuildContext context) async {
    // Local tasks pagination if applicable
    _localRefreshController.loadComplete();
  }
}
