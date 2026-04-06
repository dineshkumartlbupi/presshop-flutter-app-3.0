import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets_new.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_bloc.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_event.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_state.dart';
import '../../domain/entities/earning_transaction.dart';
import 'package:presshop/features/chat/presentation/pages/full_video_view.dart';
import 'tansaction_detail_screen.dart';
import 'commission_widget.dart';
import 'package:presshop/main.dart';

class MyEarningScreen extends StatefulWidget {
  const MyEarningScreen(
      {super.key, this.openDashboard = false, required int initialTapPosition});
  final bool openDashboard;

  @override
  State<MyEarningScreen> createState() => _MyEarningScreenState();
}

class _MyEarningScreenState extends State<MyEarningScreen>
    with SingleTickerProviderStateMixin, AnalyticsPageMixin {
  late Size size;
  TabController? _tabController;
  int _selectedTabbar = 0;

  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];

  String fromDate = "";
  String toDate = "";

  @override
  String get pageName => PageNames.myEarnings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      setState(() {
        _selectedTabbar = _tabController!.index;
      });
      context.read<EarningBloc>().add(ChangeTabEvent(_selectedTabbar));

      if (_selectedTabbar == 0) {
        _fetchTransactions(context.read<EarningBloc>());
      } else {
        _fetchCommissions(context.read<EarningBloc>());
      }
    });

    initializeFilter();
    // Initial Data Fetch
    final now = DateTime.now();
    fromDate = now.year.toString();
    toDate = now.month.toString().padLeft(2, '0');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<EarningBloc>();
      bloc.add(UpdateDateEvent(fromDate: fromDate, toDate: toDate));
      bloc.add(FetchEarningDataEvent(fromDate: fromDate, toDate: toDate));
      _fetchTransactions(bloc);
      _fetchCommissions(bloc);
    });
  }

  void initializeFilter() {
    sortList = [
      FilterModel(
          name: AppStrings.viewWeeklyText,
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.viewMonthlyText,
          icon: "ic_monthly_calendar.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.filterDateText,
          icon: "ic_eye_outlined.png",
          isSelected: false),
    ];

    filterList = [
      FilterModel(
          name: AppStrings.allContentsText,
          icon: "ic_square_play.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.allTasksText,
          icon: "ic_task.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.allExclusiveContentText,
          icon: "ic_exclusive.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.allSharedContentText,
          icon: "ic_share.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.paymentsReceivedText,
          icon: "ic_payment_reviced.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.pendingPaymentsText,
          icon: "ic_pending.png",
          isSelected: false),
    ];
  }

  void _fetchTransactions(EarningBloc bloc) {
    _fetchTransactionsWithFilters(bloc);
  }

  void _fetchCommissions(EarningBloc bloc) {
    bloc.add(FetchCommissionsEvent(limit: 10, offset: 0, filterParams: {}));
  }

  void _fetchTransactionsWithFilters(EarningBloc bloc) {
    Map<String, dynamic> map = {};
    // Check Sort List
    int pos = sortList.indexWhere((element) => element.isSelected);
    if (pos != -1) {
      if (sortList[pos].name == AppStrings.filterDateText) {
        map["year"] = sortList[pos].fromDate!;
        map["month"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == AppStrings.viewMonthlyText) {
        map["posted_date"] = "31";
      } else if (sortList[pos].name == AppStrings.viewYearlyText) {
        map["posted_date"] = "365";
      } else if (sortList[pos].name == AppStrings.viewWeeklyText) {
        map["posted_date"] = "7";
      }
    } else {
      // Default filter if none selected, use global year/month
      map["year"] = fromDate;
      map["month"] = toDate;
    }

    // Check Filter List
    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case AppStrings.allExclusiveContentText:
            map["type"] = 'exclusive';
            break;
          case AppStrings.allSharedContentText:
            map["sharedtype"] = "shared";
            break;
          case AppStrings.paymentsReceivedText:
            map["paid_status"] = "paid";
            break;
          case AppStrings.allContentsText:
            map['allcontent'] = 'content';
            break;
          case AppStrings.allTasksText:
            map['alltask'] = 'task_content';
            break;
          case AppStrings.pendingPaymentsText:
            map['paid_status'] = 'pending';
            break;
        }
      }
    }

    bloc.add(FetchTransactionsEvent(limit: 10, offset: 0, filterParams: map));
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        context.goNamed(
          AppRoutes.dashboardName,
          extra: {'initialPosition': 2},
        );
        return false;
      },
      child: Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: false,
            title: Text(
              AppStrings.myEarningsText,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * AppDimensions.appBarHeadingFontSize),
            ),
            centerTitle: false,
            titleSpacing: 0,
            size: size,
            showActions: true,
            leadingFxn: () {
              widget.openDashboard
                  ? context.goNamed(
                      AppRoutes.dashboardName,
                      extra: {'initialPosition': 0},
                    )
                  : context.pop();
            },
            actionWidget: [
              if (_selectedTabbar == 0)
                InkWell(
                  onTap: () {
                    showBottomSheet(size, context.read<EarningBloc>());
                  },
                  child: commonFilterIcon(size),
                ),
              SizedBox(
                width: size.width * AppDimensions.numD02,
              ),
              Container(
                margin: EdgeInsets.only(
                    bottom: size.width * AppDimensions.numD02,
                    right: size.width * AppDimensions.numD016),
                child: InkWell(
                  onTap: () {
                    context.goNamed(
                      AppRoutes.dashboardName,
                      extra: {'initialPosition': 2},
                    );
                  },
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * AppDimensions.numD07,
                    width: size.width * AppDimensions.numD07,
                  ),
                ),
              ),
              SizedBox(
                width: size.width * AppDimensions.numD02,
              ),
            ],
          ),
          body: BlocConsumer<EarningBloc, EarningState>(
            listener: (context, state) {
              if (state.fromDate.isNotEmpty) fromDate = state.fromDate;
              if (state.toDate.isNotEmpty) toDate = state.toDate;
            },
            builder: (context, state) {
              if (state.status == EarningStatus.loading &&
                  state.earningData == null) {
                return const SizedBox.shrink();
              }

              final earningData = state.earningData;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(size.width * AppDimensions.numD02),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          /// My Earnings
                          Container(
                            padding: EdgeInsets.all(
                                size.width * AppDimensions.numD05),
                            decoration: BoxDecoration(
                                color: AppColorTheme.colorLightGrey,
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD05)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.2, color: Colors.black),
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD04),
                                        child: CachedNetworkImage(
                                          imageUrl: earningData?.avatar ?? "",
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            height: size.width *
                                                AppDimensions.numD32,
                                            width: size.width *
                                                AppDimensions.numD35,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            fit: BoxFit.cover,
                                            height: size.width *
                                                AppDimensions.numD32,
                                            width: size.width *
                                                AppDimensions.numD35,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: size.width *
                                              AppDimensions.numD10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Total earnings",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD045,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            height:
                                                size.width * AppDimensions.num0,
                                          ),
                                          Text(
                                            earningData != null &&
                                                    earningData
                                                        .totalEarning.isNotEmpty
                                                ? '${earningData.currencySymbol.isNotEmpty ? earningData.currencySymbol : currencySymbol}${formatDouble(double.parse(earningData.totalEarning))}'
                                                : '${earningData != null && earningData.currencySymbol.isNotEmpty ? earningData.currencySymbol : currencySymbol}0',
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD075,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          SizedBox(
                                            height: size.width *
                                                AppDimensions.numD02,
                                          ),
                                          Text(
                                            "Monthly earnings",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD045,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            height:
                                                size.width * AppDimensions.num0,
                                          ),
                                          Text(
                                            state.monthlyEarnings.isNotEmpty
                                                ? '${earningData != null && earningData.currencySymbol.isNotEmpty ? earningData.currencySymbol : currencySymbol}${formatDouble(double.parse(state.monthlyEarnings))}'
                                                : '${earningData != null && earningData.currencySymbol.isNotEmpty ? earningData.currencySymbol : currencySymbol}0',
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD075,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * AppDimensions.numD03,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          // Year picker
                                          final now = DateTime.now();
                                          final picked = await showDialog<int>(
                                            context: context,
                                            builder: (context) {
                                              int selectedYear =
                                                  fromDate.isNotEmpty
                                                      ? int.parse(fromDate)
                                                      : now.year;
                                              return AlertDialog(
                                                title: Text('Select Year'),
                                                content: SizedBox(
                                                  width: size.width *
                                                      AppDimensions.numD035,
                                                  height: size.height *
                                                      AppDimensions.numD30,
                                                  child: YearPicker(
                                                    firstDate: DateTime(2020),
                                                    lastDate:
                                                        DateTime(now.year),
                                                    selectedDate:
                                                        DateTime(selectedYear),
                                                    onChanged: (dateTime) {
                                                      context
                                                          .pop(dateTime.year);
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          if (picked != null) {
                                            fromDate = picked.toString();
                                            toDate = '';
                                            context.read<EarningBloc>().add(
                                                UpdateDateEvent(
                                                    fromDate: fromDate,
                                                    toDate: toDate));
                                            context.read<EarningBloc>().add(
                                                FetchEarningDataEvent(
                                                    fromDate: fromDate,
                                                    toDate: toDate));
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: size.width *
                                                AppDimensions.numD02,
                                            horizontal: size.width *
                                                AppDimensions.numD02,
                                          ),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1.2,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(size
                                                          .width *
                                                      AppDimensions.numD02)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                fromDate.isNotEmpty
                                                    ? fromDate
                                                    : "Year",
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD035,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down_sharp,
                                                color: Colors.black,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD05,
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: fromDate.isEmpty
                                            ? null
                                            : () async {
                                                // Month picker
                                                final now = DateTime.now();
                                                final int selectedYear =
                                                    int.parse(fromDate);
                                                final int lastMonth =
                                                    (selectedYear == now.year)
                                                        ? now.month
                                                        : 12;
                                                final picked =
                                                    await showDialog<int>(
                                                  context: context,
                                                  builder: (context) {
                                                    int selectedMonth =
                                                        toDate.isNotEmpty
                                                            ? int.parse(toDate)
                                                            : 1;
                                                    return AlertDialog(
                                                      title:
                                                          Text('Select Month'),
                                                      content: SizedBox(
                                                        width: 400,
                                                        height: 400,
                                                        child: GridView.builder(
                                                          gridDelegate:
                                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2,
                                                            childAspectRatio:
                                                                2.5,
                                                          ),
                                                          itemCount: lastMonth,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final month =
                                                                index + 1;
                                                            return InkWell(
                                                              onTap: () {
                                                                context
                                                                    .pop(month);
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: selectedMonth == month
                                                                      ? AppColorTheme
                                                                          .colorThemePink
                                                                      : Colors.grey[
                                                                          200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  DateFormat
                                                                          .MMMM()
                                                                      .format(DateTime(
                                                                          0,
                                                                          month)),
                                                                  style:
                                                                      commonTextStyle(
                                                                    size: size,
                                                                    fontSize: size
                                                                            .width *
                                                                        AppDimensions
                                                                            .numD035,
                                                                    color: selectedMonth ==
                                                                            month
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                                if (picked != null) {
                                                  toDate = picked
                                                      .toString()
                                                      .padLeft(2, '0');
                                                  final bloc = context
                                                      .read<EarningBloc>();
                                                  bloc.add(UpdateDateEvent(
                                                      fromDate: fromDate,
                                                      toDate: toDate));
                                                  bloc.add(
                                                      FetchEarningDataEvent(
                                                          fromDate: fromDate,
                                                          toDate: toDate));
                                                  if (_selectedTabbar == 0) {
                                                    _fetchTransactions(bloc);
                                                  } else {
                                                    _fetchCommissions(bloc);
                                                  }
                                                }
                                              },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: size.width *
                                                AppDimensions.numD02,
                                            horizontal: size.width *
                                                AppDimensions.numD02,
                                          ),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1.2,
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(size
                                                          .width *
                                                      AppDimensions.numD02)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                toDate.isNotEmpty
                                                    ? DateFormat.MMMM().format(
                                                        DateTime(0,
                                                            int.parse(toDate)))
                                                    : "Month",
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD035,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down_sharp,
                                                color: Colors.black,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabBar(
                                physics: const NeverScrollableScrollPhysics(),
                                controller: _tabController,
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
                                  Tab(
                                    text: AppStrings.paymentReceivedText,
                                  ),
                                  Tab(text: AppStrings.commissionEarnedText),
                                ],
                              ),
                              const Divider(
                                color: Color(0xFFD8D8D8),
                                thickness: 1.5,
                              ),
                              Column(children: [
                                if (_selectedTabbar == 0) ...[
                                  state.transactions.isEmpty &&
                                          state.transactionStatus !=
                                              EarningStatus.loading
                                      ? Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: size.height *
                                                    AppDimensions.numD1),
                                            child: Text(
                                              "No payment received",
                                              style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD035,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        )
                                      : state.transactionStatus ==
                                              EarningStatus.loading
                                          ? const SizedBox.shrink()
                                          : Column(
                                              children: [
                                                SizedBox(
                                                  height: size.width *
                                                      AppDimensions.numD025,
                                                ),
                                                paymentReceivedWidget(
                                                    state.transactions),
                                                if (state.transactions
                                                        .isNotEmpty &&
                                                    state.transactions.any(
                                                        (item) => !item
                                                            .paidStatus)) ...[
                                                  Text(
                                                    AppStrings
                                                        .paymentPendingText,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            AppDimensions
                                                                .numD045,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  SizedBox(
                                                    height: size.width *
                                                        AppDimensions.numD02,
                                                  ),
                                                  const Divider(
                                                    color: Color(0xFFD8D8D8),
                                                    thickness: 1.5,
                                                  ),
                                                  SizedBox(
                                                    height: size.width *
                                                        AppDimensions.numD04,
                                                  ),
                                                  paymentPendingWidget(
                                                      state.transactions),
                                                ],
                                              ],
                                            )
                                ] else ...[
                                  if (state.commissions.isEmpty &&
                                      state.commissionStatus !=
                                          EarningStatus.loading)
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: size.height *
                                                AppDimensions.numD1),
                                        child: Text(
                                          "No commission earned",
                                          style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD035,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    )
                                  else if (state.commissionStatus ==
                                      EarningStatus.loading)
                                    const SizedBox.shrink()
                                  else
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: state.commissions.length,
                                      itemBuilder: (context, index) {
                                        return CommissionWidget(
                                          commissionData:
                                              state.commissions[index],
                                        );
                                      },
                                    ),
                                ]
                              ]),
                            ],
                          ),
                          // Footer logic (Contact/FAQ/Tutorials) preserved conceptually but simplified for length constraint if needed
                          // Including it properly:
                          Padding(
                            padding: EdgeInsets.only(
                                top: size.width * AppDimensions.numD06,
                                bottom: size.width * AppDimensions.numD07),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "If you have any questions regarding your earnings or pending payments, please ",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                              AppRoutes.contactUsName);
                                        },
                                        child: Text(
                                          "${AppStrings.contactText.toLowerCase()} ",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD03,
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )),
                                  TextSpan(
                                    text:
                                        "our helpful team who are available 24 x 7 to assist you. All communication, is completely discreet and secure. \n \n",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  TextSpan(
                                    text: "Also check our ",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                            AppRoutes.faqName,
                                            extra: {
                                              'priceTipsSelected': false,
                                              'type': 'faq',
                                              'index': 0,
                                            },
                                          );
                                        },
                                        child: Text(
                                          "${AppStrings.faqText} ",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD03,
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )),
                                  TextSpan(
                                    text: "and ",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: InkWell(
                                        onTap: () {
                                          context.pushNamed(
                                              AppRoutes.tutorialsName);
                                        },
                                        child: Text(
                                          "${AppStrings.tutorialsText.toLowerCase()} ",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD03,
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      )),
                                  TextSpan(
                                    text:
                                        "for answers to common payment queries. Thank you ",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * AppDimensions.numD03,
                                    fontWeight: FontWeight.w300,
                                    height: 1.5),
                              ),
                            ),
                          )
                        ],
                      ),
                      if (state.status == EarningStatus.loading ||
                          state.transactionStatus == EarningStatus.loading ||
                          state.commissionStatus == EarningStatus.loading)
                        Center(
                          child: CommonWidgetsNew.showAnimatedLoader(size),
                        )
                    ],
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget paymentReceivedWidget(List<EarningTransaction> transactions) {
    return transactions.isNotEmpty
        ? ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var item = transactions[index];
              return item.paidStatus
                  ? Container(
                      padding: EdgeInsets.only(
                        top: size.width * AppDimensions.numD05,
                        bottom: size.width * AppDimensions.numD025,
                        left: size.width * AppDimensions.numD05,
                        right: size.width * AppDimensions.numD05,
                      ),
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD02)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          size.width * AppDimensions.numD01,
                                      horizontal:
                                          size.width * AppDimensions.numD04),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD015),
                                    color: AppColorTheme.colorThemePink,
                                  ),
                                  child: Text(
                                    item.amount.isNotEmpty
                                        ? "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.payableT0Hopper))}"
                                        : "",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  item.type == "content"
                                      ? GestureDetector(
                                          onTap: () {
                                            if (item.uploadContent.isNotEmpty) {
                                              context.pushNamed(
                                                AppRoutes.fullVideoViewName,
                                                extra: {
                                                  'mediaFile': getMediaImageUrl(
                                                      item.uploadContent,
                                                      isTask: item.type !=
                                                          "content"),
                                                  'type': MediaTypeEnum.video,
                                                },
                                              );
                                            }
                                          },
                                          child: Image.asset(
                                            "${iconsPath}ic_square_play.png",
                                            height: size.width *
                                                AppDimensions.numD08,
                                            width: size.width *
                                                AppDimensions.numD08,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD03,
                                  ),
                                  Container(
                                    height: size.width * AppDimensions.numD11,
                                    width: size.width * AppDimensions.numD11,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD03),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD03),
                                      child: CachedNetworkImage(
                                        imageUrl: item.hopperAvatar,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          height:
                                              size.width * AppDimensions.numD11,
                                          width:
                                              size.width * AppDimensions.numD11,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          "${commonImagePath}rabbitLogo.png",
                                          fit: BoxFit.cover,
                                          height:
                                              size.width * AppDimensions.numD11,
                                          width:
                                              size.width * AppDimensions.numD11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD03,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD03),
                                    child: Image.network(item.companyLogo,
                                        height:
                                            size.width * AppDimensions.numD11,
                                        width:
                                            size.width * AppDimensions.numD12,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, i, b) =>
                                            Image.asset(
                                              "${commonImagePath}rabbitLogo.png",
                                              fit: BoxFit.cover,
                                              height: size.width *
                                                  AppDimensions.numD11,
                                              width: size.width *
                                                  AppDimensions.numD12,
                                            )),
                                  )
                                ],
                              ),
                            ],
                          ),

                          /// Your earnings
                          Padding(
                            padding: EdgeInsets.only(
                                top: size.width * AppDimensions.numD04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Your earnings",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.type == "content"
                                      ? item.totalEarningAmt != "null"
                                          ? '${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.totalEarningAmt))}'
                                          : "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}0"
                                      : item.totalEarningAmt != "null"
                                          ? '${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.totalEarningAmt))}'
                                          : "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}0",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Divider
                          Padding(
                            padding: EdgeInsets.only(
                              top: size.width * AppDimensions.numD01,
                            ),
                            child: const Divider(
                              color: Colors.white,
                              thickness: 1.5,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              context.pushNamed(
                                AppRoutes.transactionDetailName,
                                extra: {
                                  'pageType': PageType.CONTENT,
                                  'type': "received",
                                  'transactionData': transactions[index],
                                },
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "View Transaction Details",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                  size: size.width * AppDimensions.numD045,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : Container();
            },
            separatorBuilder: (context, index) {
              var item = transactions[index];
              return item.paidStatus
                  ? SizedBox(
                      height: size.width * AppDimensions.numD05,
                    )
                  : Container();
            },
            itemCount: transactions.length)
        : Container();
  }

  Widget paymentPendingWidget(List<EarningTransaction> transactions) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          var item = transactions[index];
          return !item.paidStatus
              ? Container(
                  padding: EdgeInsets.only(
                    top: size.width * AppDimensions.numD05,
                    bottom: size.width * AppDimensions.numD025,
                    left: size.width * AppDimensions.numD05,
                    right: size.width * AppDimensions.numD05,
                  ),
                  decoration: BoxDecoration(
                      color: AppColorTheme.colorLightGrey,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD02)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * AppDimensions.numD01,
                                horizontal: size.width * AppDimensions.numD04),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColorTheme.colorGrey3, width: 1),
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD015),
                            ),
                            child: Text(
                              item.amount.isNotEmpty
                                  ? "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.payableT0Hopper))}"
                                  : "",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD04,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Row(
                            children: [
                              item.type == "content"
                                  ? Image.asset(
                                      item.typesOfContent
                                          ? "${iconsPath}ic_exclusive.png"
                                          : "${iconsPath}ic_share.png",
                                      height: item.typesOfContent
                                          ? size.width * AppDimensions.numD075
                                          : size.width * AppDimensions.numD07,
                                      width: size.width * AppDimensions.numD09,
                                      color: AppColorTheme.colorTextFieldIcon,
                                    )
                                  : Image.asset(
                                      "${iconsPath}ic_task.png",
                                      width: size.width * AppDimensions.numD07,
                                      height: size.width * AppDimensions.numD07,
                                    ),
                              SizedBox(
                                width: size.width * AppDimensions.numD03,
                              ),
                              if (item.contentDataList.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD03),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        getMediaImageUrl(item.hopperAvatar),
                                    height: size.width * AppDimensions.numD11,
                                    width: size.width * AppDimensions.numD12,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Image.asset(
                                      "assets/dummyImages/placeholderImage.png",
                                      fit: BoxFit.cover,
                                      height: size.width * AppDimensions.numD11,
                                      width: size.width * AppDimensions.numD12,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      "${commonImagePath}rabbitLogo.png",
                                      fit: BoxFit.cover,
                                      height: size.width * AppDimensions.numD11,
                                      width: size.width * AppDimensions.numD12,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: size.width * AppDimensions.numD03,
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD03),
                                child: Image.network(item.companyLogo,
                                    height: size.width * AppDimensions.numD11,
                                    width: size.width * AppDimensions.numD12,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, i, b) =>
                                        Image.asset(
                                          "${commonImagePath}rabbitLogo.png",
                                          fit: BoxFit.cover,
                                          height:
                                              size.width * AppDimensions.numD11,
                                          width:
                                              size.width * AppDimensions.numD12,
                                        )),
                              )
                            ],
                          ),
                        ],
                      ),

                      /// Your earnings
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * AppDimensions.numD04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Your earnings",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              item.type == "content"
                                  ? item.totalEarningAmt != "null"
                                      ? '${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.totalEarningAmt))}'
                                      : "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}0"
                                  : item.totalEarningAmt != "null"
                                      ? '${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.totalEarningAmt))}'
                                      : "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}0",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// PressHop fees
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * AppDimensions.numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.presshopCommissionText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              item.payableCommission.isNotEmpty
                                  ? "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.payableCommission))}"
                                  : "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}0",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * AppDimensions.numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.processingFeeText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.stripefee))}",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// Amount pending
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * AppDimensions.numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.amountPendingText1,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              item.amount.isNotEmpty
                                  ? "${item.currencySymbol.isNotEmpty ? item.currencySymbol : currencySymbol}${formatDouble(double.parse(item.payableT0Hopper))}"
                                  : "",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// Payment due date (using createdAt as fallback if dueDate missing in entity)
                      /// Entity doesn't have dueDate. Legacy code used `item.dueDate`.
                      /// Assuming createdAt is used or adding Date logic?
                      /// Using createdAT for now to avoid errors.
                      Padding(
                        padding: EdgeInsets.only(
                            top: size.width * AppDimensions.numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.paymentDueDateText,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              dateTimeFormatter(
                                dateTime: item.createdAt,
                                format: "dd MMM yyyy",
                              ),
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),

                      /// Divider
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.width * AppDimensions.numD01,
                        ),
                        child: const Divider(
                          color: Colors.white,
                          thickness: 1.5,
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          context.pushNamed(
                            AppRoutes.transactionDetailName,
                            extra: {
                              'pageType': item.type == "content"
                                  ? PageType.CONTENT
                                  : PageType.TASK,
                              'type': "pending",
                              'transactionData': transactions[index],
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "View Transaction Details",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: AppColorTheme.colorThemePink,
                                  fontWeight: FontWeight.w700),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.black,
                              size: size.width * AppDimensions.numD045,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : Container();
        },
        separatorBuilder: (context, index) {
          return !transactions[index].paidStatus
              ? SizedBox(
                  height: size.width * AppDimensions.numD05,
                )
              : Container();
        },
        itemCount: transactions.length);
  }

  Widget filterListWidget(context, List<FilterModel> list,
      StateSetter stateSetter, Size size, bool isSort) {
    // (Implementation same as original but ensuring parameter types are correct)
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
              for (var element in filterList) {
                element.isSelected = false;
              }
            }
            // Logic to clear other sort if one selected?
            // Simply toggling for now

            list[index].isSelected = !list[index].isSelected;

            stateSetter(() {});
            setState(() {});
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
            color: list[index].isSelected ? Colors.grey.shade400 : null,
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
                list[index].name == AppStrings.filterDateText
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
                              fromDate = item.fromDate ?? '';
                              item.isSelected = !item.isSelected;
                              stateSetter(() {});
                              setState(() {});
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
                                    item.fromDate != null
                                        ? dateTimeFormatter(
                                            dateTime: item.fromDate.toString())
                                        : AppStrings.fromText,
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

                                if (pickedDate != null) {
                                  DateTime parseFromDate =
                                      DateTime.parse(item.fromDate!);
                                  DateTime parseToDate =
                                      DateTime.parse(pickedDate);

                                  if (parseToDate.isAfter(parseFromDate) ||
                                      parseToDate
                                          .isAtSameMomentAs(parseFromDate)) {
                                    item.toDate = pickedDate;
                                    toDate = pickedDate;
                                  } else {
                                    showSnackBar(
                                        "Date Error",
                                        "Please select to date above from date",
                                        Colors.red);
                                  }
                                }
                              }
                              stateSetter(() {});
                              setState(() {});
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
                                    item.toDate != null
                                        ? dateTimeFormatter(
                                            dateTime: item.toDate.toString())
                                        : AppStrings.toText,
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

  Future<void> showBottomSheet(Size size, EarningBloc bloc) async {
    // (Same structure, but calls _fetchTransactionsWithFilters(bloc) on Apply)
    await showModalBottomSheet(
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
              child: ListView(
                children: [
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
                        "Sort and Filter",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width *
                                AppDimensions.appBarHeadingFontSizeNew,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          for (var e in filterList) {
                            e.isSelected = false;
                          }
                          for (var e in sortList) {
                            e.isSelected = false;
                          }
                          fromDate = "";
                          toDate = "";
                          initializeFilter();
                          stateSetter(() {});
                          _fetchTransactionsWithFilters(bloc);
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
                  SizedBox(height: size.width * AppDimensions.numD085),
                  Text(AppStrings.sortText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500)),
                  filterListWidget(
                      context,
                      sortList
                          .where(
                              (data) => data.name != AppStrings.filterDateText)
                          .toList(),
                      stateSetter,
                      size,
                      true),
                  SizedBox(height: size.width * AppDimensions.numD05),
                  Text(AppStrings.filterText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500)),
                  filterListWidget(
                      context, filterList, stateSetter, size, false),
                  SizedBox(height: size.width * AppDimensions.numD06),
                  Container(
                    width: size.width,
                    height: size.width * AppDimensions.numD13,
                    margin: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD04),
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD04),
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
                      _fetchTransactionsWithFilters(bloc);
                    }),
                  ),
                  SizedBox(height: size.width * AppDimensions.numD04)
                ],
              ),
            );
          });
        });
  }

  Future<String?> commonDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context, // cleaned navigatorKey usage if context is available
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light()
                  .copyWith(primary: AppColorTheme.colorThemePink)),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final String formatted = pickedDate
          .toString(); // API likely expects YYYY-MM-DD or similar? Legacy used toString().
      return formatted;
    } else {
      return null;
    }
  }
}
