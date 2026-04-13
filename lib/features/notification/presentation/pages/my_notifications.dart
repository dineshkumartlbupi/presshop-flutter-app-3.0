import 'package:flutter/material.dart';
import 'package:presshop/core/widgets/common_widgets_new.dart';
import 'package:presshop/main.dart';
import 'package:presshop/features/earning/presentation/pages/tansaction_detail_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:presshop/features/notification/presentation/pages/Inline_flick_player.dart';
import 'package:presshop/core/di/injection_container.dart' as di;

class MyNotificationScreen extends StatefulWidget {
  const MyNotificationScreen({super.key, required this.count});
  final int count;

  @override
  State<MyNotificationScreen> createState() => _MyNotificationScreenState();
}

class _MyNotificationScreenState extends State<MyNotificationScreen> {
  late Size size;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  // Moved logic to Bloc

  @override
  void initState() {
    debugPrint('class::::::::sdfsdf $runtimeType');
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) => callNotificationList());
    // Handled by BlocProvider create

    // Check update logic - handled by CheckStudentBeansEvent
    super.initState();
  }

  void _showForceUpdateDialog(Size size,
      {String? sourceDataHeading,
      String? sourceDataDescription,
      required NotificationBloc bloc}) {
    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD04),
                          child: Row(
                            children: [
                              Text(
                                sourceDataHeading ??
                                    "Brains, beans, and breaking news!",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * AppDimensions.numD06,
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
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
                                    "assets/rabbits/student_beans_rabbit2.png",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                child: Text(
                                  sourceDataDescription ??
                                      "Please confirm your student status to continue",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Expanded(
                              //     child: SizedBox(
                              //   height: size.width * AppDimensions.numD12,
                              //   child: commonElevatedButton(
                              //       AppStrings.logoutText,
                              //       size,
                              //       commonButtonTextStyle(size),
                              //       commonButtonStyle(size, Colors.black), () {
                              //     Navigator.pop(context);
                              //     // callRemoveDeviceApi();
                              //   }),
                              // )),
                              // SizedBox(
                              //   width: size.width * AppDimensions.numD04,
                              // ),
                              Expanded(
                                child: SizedBox(
                                  height: size.width * AppDimensions.numD12,
                                  child: commonElevatedButton(
                                      "Confirm",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(
                                          size, AppColorTheme.colorThemePink),
                                      () async {
                                    try {
                                      bloc.add(StudentBeansActivationEvent());
                                      context.pop();
                                    } catch (e) {
                                      debugPrint("Error launching URL: $e");
                                    }
                                  }),
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
  }

  void deleteNotificationDialog(NotificationBloc bloc) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD02),
            content: StatefulBuilder(builder: (context, setState) {
              return Container(
                width: size.width * AppDimensions.num1,
                height: size.width * AppDimensions.numD52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD025),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(padding: EdgeInsets.only(top: size.width * 0.05)),
                    Image.asset(
                      "${iconsPath}delete.png",
                      width: size.width * AppDimensions.numD11,
                      height: size.width * AppDimensions.numD11,
                      fit: BoxFit.contain,
                      color: AppColorTheme.colorThemePink,
                    ),
                    Padding(padding: EdgeInsets.only(top: size.width * 0.02)),
                    Text(
                      "Are you sure you want to delete \nall the notifications?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width *
                            AppDimensions.numD04,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            context.pop();
                          },
                          child: Container(
                            width: size.width * AppDimensions.numD45,
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
                                            AppDimensions.numD037,
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
                            context.pop();
                            bloc.add(ClearAllNotificationsEvent());
                          },
                          child: Container(
                            width: size.width * AppDimensions.numD45,
                            margin: EdgeInsets.only(top: size.width * 0.05),
                            decoration: BoxDecoration(
                                color: AppColorTheme.colorThemePink,
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
                                            AppDimensions.numD037,
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
    return BlocProvider(
      create: (context) => di.sl<NotificationBloc>()
        ..add(const FetchNotificationsEvent(offset: 0))
        ..add(CheckStudentBeansEvent())
        ..add(MarkNotificationsAsReadEvent()),
      child: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) async {
          if (state.status == NotificationStatus.failure &&
              state.errorMessage.isNotEmpty) {
//             showSnackBar("Error", state.errorMessage, Colors.red);
          }
          if (state.shouldShowStudentBeansDialog) {
            _showForceUpdateDialog(size,
                sourceDataHeading: state.studentBeansHeading,
                sourceDataDescription: state.studentBeansDescription,
                bloc: context.read<NotificationBloc>());
          }
          if (state.studentBeansActivationUrl != null) {
            final uri = Uri.parse(state.studentBeansActivationUrl!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (context.mounted) {
                context
                    .read<NotificationBloc>()
                    .add(MarkStudentBeansVisitedEvent());
              }
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CommonBrandedAppBar(
              title: AppStrings.notificationText,
              size: size,
              notificationCount: state.unreadCount,
              showLogo: false,
            ),
            body: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD05),
                        child: Divider(
                          color: Colors.grey.shade200,
                          thickness: 1.5,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD05,
                            vertical: size.width * AppDimensions.numD02),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            deleteNotificationDialog(
                                context.read<NotificationBloc>());
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              AppStrings.clearAllText,
                              style: TextStyle(
                                fontSize: size.width * AppDimensions.numD038,
                                fontWeight: FontWeight.w500,
                                color: AppColorTheme.colorThemePink,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: state.status == NotificationStatus.loading ||
                                state.status == NotificationStatus.initial
                            ? CommonWidgetsNew.showAnimatedLoader(size)
                            : state.notifications.isNotEmpty
                                ? SmartRefresher(
                                    controller: _refreshController,
                                    enablePullDown: true,
                                    enablePullUp: true,
                                    onRefresh: () => _onRefresh(context),
                                    onLoading: () => _onLoading(context),
                                    footer: const CustomFooter(
                                        builder: commonRefresherFooter),
                                    child: ListView.separated(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width *
                                                AppDimensions.numD045),
                                        itemBuilder: (context, index) {
                                          if (index >=
                                              state.notifications.length) {
                                            return Container();
                                          }
                                          final item =
                                              state.notifications[index];
                                          return InkWell(
                                            onTap: () {
                                              // myProfileApi();
                                              debugPrint(
                                                  "Notification Type: ${item.messageType}");

                                              /// -- When content is Published or Offer Received --
                                              if (item.messageType ==
                                                      "publish_content" ||
                                                  item.messageType ==
                                                      "offer_received") {
                                                context.pushNamed(
                                                  AppRoutes.contentDetailName,
                                                  extra: {
                                                    'paymentStatus':
                                                        item.paymentStatus,
                                                    'exclusive': item.exclusive,
                                                    'contentId': item.contentId,
                                                    'offerCount': 0,
                                                    'purchasedMediahouseCount':
                                                        0,
                                                  },
                                                );
                                              } else if (item.messageType ==
                                                  "content_sold") {
                                                context.pushNamed(
                                                  AppRoutes
                                                      .transactionDetailName,
                                                  extra: {
                                                    'pageType':
                                                        PageType.CONTENT,
                                                    'type': "received",
                                                    'transactionData': item
                                                        .transactionDetailData!,
                                                  },
                                                );
                                              } else if (item.messageType ==
                                                      "new_task_posted" ||
                                                  item.messageType ==
                                                      "media_house_tasks") {
                                                debugPrint(
                                                    "Clicked media_house_tasks/new_task_posted");
                                                debugPrint(
                                                    "BroadcastID: '${item.broadcastId}'");
                                                if (item
                                                    .broadcastId.isNotEmpty) {
                                                  context.pushNamed(
                                                    AppRoutes.myTasksName,
                                                    extra: {
                                                      'hideLeading': false,
                                                      'broadCastId':
                                                          item.broadcastId,
                                                    },
                                                  );
                                                } else {
                                                  debugPrint(
                                                      "BroadcastID is empty");
                                                }
                                              } else if (item.messageType ==
                                                  "task_accepted") {
                                                if (item
                                                    .broadcastId.isNotEmpty) {
                                                  context.pushNamed(
                                                    AppRoutes.taskDetailNewName,
                                                    extra: {
                                                      'taskId':
                                                          item.broadcastId,
                                                      'taskStatus': "accepted",
                                                      'totalEarning': "0",
                                                    },
                                                  );
                                                }
                                              } else if (item.messageType ==
                                                  "initiate_admin_chat") {
                                                context.pushNamed(
                                                  AppRoutes.chatName,
                                                  extra: {
                                                    'hideLeading': false,
                                                    'message': '',
                                                  },
                                                );
                                              } else if (item.messageType ==
                                                  "studentbeans") {
                                                context
                                                    .read<NotificationBloc>()
                                                    .add(
                                                        CheckStudentBeansEvent());
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  top: size.width *
                                                      AppDimensions.numD02),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                      size.width *
                                                          AppDimensions.numD03),
                                                  topRight: Radius.circular(
                                                      size.width *
                                                          AppDimensions.numD03),
                                                ),
                                                color: item.unread
                                                    ? Colors.white
                                                    : AppColorTheme
                                                        .colorLightGrey,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                        top: size.width *
                                                            AppDimensions
                                                                .numD02,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: Colors.black,
                                                          shape:
                                                              BoxShape.circle,
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                spreadRadius: 2)
                                                          ]),
                                                      child: ClipOval(
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .all(size.width *
                                                                  AppDimensions
                                                                      .numD01),
                                                          child: Image.asset(
                                                            "${commonImagePath}ic_black_rabbit.png",
                                                            color: Colors.white,
                                                            width: size.width *
                                                                AppDimensions
                                                                    .numD07,
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD07,
                                                          ),
                                                        ),
                                                      )),
                                                  SizedBox(
                                                    width: size.width *
                                                        AppDimensions.numD035,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right:
                                                                        10.0),
                                                            child: Text(
                                                              dateTimeFormatter(
                                                                  dateTime:
                                                                      item.time,
                                                                  format:
                                                                      "hh:mm a, dd MMM yyyy",
                                                                  utc: false),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: commonTextStyle(
                                                                  size: size,
                                                                  fontSize: size
                                                                          .width *
                                                                      AppDimensions
                                                                          .numD025,
                                                                  color: AppColorTheme
                                                                      .colorGrey2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          item.title.isNotEmpty
                                                              ? item.title
                                                              : "No title",
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD035,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        if (item.imageUrl
                                                                .isNotEmpty &&
                                                            item.videoUrl
                                                                .isEmpty) ...[
                                                          SizedBox(
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD04,
                                                          ),
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            child:
                                                                Image.network(
                                                              item.imageUrl,
                                                              width: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .num1,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Container();
                                                              },
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: size.width *
                                                                AppDimensions
                                                                    .numD04,
                                                          ),
                                                        ],
                                                        if (item.videoUrl
                                                                .isNotEmpty ==
                                                            true) ...[
                                                          SizedBox(
                                                              height: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD02),
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(
                                                                vertical: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD02),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              child:
                                                                  InlineFlickPlayer(
                                                                videoUrl: item
                                                                        .videoUrl
                                                                        .isNotEmpty
                                                                    ? item
                                                                        .videoUrl
                                                                    : "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                                                                height: 220,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD02),
                                                        ],
                                                        Text(
                                                          item.description
                                                                  .isNotEmpty
                                                              ? item.description
                                                              : "No description",
                                                          style: commonTextStyle(
                                                              size: size,
                                                              fontSize: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD03,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                        SizedBox(
                                                          height: size.width *
                                                              AppDimensions
                                                                  .numD040,
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
                                                height: size.width *
                                                    AppDimensions.numD004,
                                                color: Colors.grey.shade200,
                                              ),
                                              SizedBox(
                                                height: size.width *
                                                    AppDimensions.numD038,
                                              ),
                                            ],
                                          );
                                        },
                                        itemCount: state.notifications.length),
                                  )
                                : (state.status == NotificationStatus.empty ||
                                        state.status ==
                                            NotificationStatus.success)
                                    ? errorMessageWidget("No new notifications")
                                    : state.status == NotificationStatus.failure
                                        ? errorMessageWidget(state.errorMessage)
                                        : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onRefresh(BuildContext context) {
    context
        .read<NotificationBloc>()
        .add(const FetchNotificationsEvent(offset: 0));
    _refreshController.refreshCompleted();
  }

  void _onLoading(BuildContext context) {
    final bloc = context.read<NotificationBloc>();
    if (!bloc.state.hasReachedMax) {
      bloc.add(
          FetchNotificationsEvent(offset: bloc.state.notifications.length));
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }
}
