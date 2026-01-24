import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/utils/extensions.dart';
import 'package:presshop/core/utils/common_utils.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/content/domain/entities/content_item.dart';
import 'package:presshop/features/content/presentation/bloc/content_bloc.dart';
import 'package:presshop/features/content/presentation/bloc/content_event.dart';
import 'package:presshop/features/content/presentation/bloc/content_state.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/content/presentation/pages/my_content_detail_screen.dart';
import 'package:presshop/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/common_filter_sheet.dart';
import 'package:presshop/core/widgets/video_thumbnail_widget.dart';

class MyContentPage extends StatelessWidget {
  const MyContentPage({super.key, required this.hideLeading});
  final bool hideLeading;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ContentBloc>(),
      child: MyContentView(hideLeading: hideLeading),
    );
  }
}

class MyContentView extends StatefulWidget {
  const MyContentView({super.key, required this.hideLeading});
  final bool hideLeading;

  @override
  State<MyContentView> createState() => _MyContentViewState();
}

class _MyContentViewState extends State<MyContentView>
    with SingleTickerProviderStateMixin {
  late Size size;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _allRefreshController =
      RefreshController(initialRefresh: false);
  late TabController _tabController;
  int _selectedTabbar = 0;
  List<ContentItem> myContentList = [];
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  bool showData = false;
  int page = 1;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    initializeFilter();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabbar = _tabController.index;
        });
        if (_selectedTabbar == 0) {
          _loadAllContent(true);
        } else if (_selectedTabbar == 1) {
          _loadMyContent(true);
        }
      }
    });

    // Trigger initial load only if bloc doesn't have cached data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<ContentBloc>();
        // Only load if we don't have cached data (state is not MyContentLoaded or has empty content)
        if (bloc.state is! MyContentLoaded ||
            (bloc.state is MyContentLoaded &&
                (bloc.state as MyContentLoaded).content.isEmpty)) {
          bloc.add(const FetchMyContentEvent());
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _allRefreshController.dispose();
    super.dispose();
  }

  void initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: currentMontText,
          icon: "ic_monthly_calendar.png",
          isSelected: false),
      FilterModel(
          name: viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
    ]);

    filterList.addAll([
      FilterModel(
          name: soldContentText, icon: "ic_sold.png", isSelected: false),
      FilterModel(
          name: liveContentText, icon: "ic_live_content.png", isSelected: true),
      FilterModel(
          name: paymentsReceivedText,
          icon: "ic_payment_reviced.png",
          isSelected: false),
      FilterModel(
          name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
      FilterModel(
          name: allExclusiveContentText,
          icon: "ic_exclusive.png",
          isSelected: false),
      FilterModel(
          name: allSharedContentText, icon: "ic_share.png", isSelected: false),
    ]);
  }

  void _loadMyContent(bool isRefresh) {
    if (!mounted) return;

    if (isRefresh) {
      page = 1;
      myContentList.clear();
      _refreshController.resetNoData();
    } else {
      page++;
    }

    Map<String, dynamic> params = {"is_draft": 'false'};

    int pos = sortList.indexWhere((element) => element.isSelected);
    if (pos != -1) {
      if (sortList[pos].name == filterDateText &&
          sortList[pos].fromDate != null) {
        params["startdate"] = DateFormat("yyyy-MM-ddTHH:mm:ss")
            .format(DateTime.parse(sortList[pos].fromDate!));

        if (sortList[pos].toDate != null) {
          params["endDate"] = DateFormat("yyyy-MM-ddTHH:mm:ss")
              .format(DateTime.parse(sortList[pos].toDate!));
        }
      } else if (sortList[pos].name == viewMonthlyText) {
        params["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        params["posted_date"] = "365";
      }
    }

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case soldContentText:
            params["sale_status"] = "sold";
            break;
          case liveContentText:
            params["livecontent"] = "un_paid";
            break;
          case paymentsReceivedText:
            params["recieved"] = "recieved";
            break;
          case pendingPaymentsText:
            params["payment_pending"] = 'true';
            break;
          case allSharedContentText:
            params["sharedtype"] = "shared";
            break;
          case allExclusiveContentText:
            params["type"] = "exclusive";
            break;
        }
      }
    }

    try {
      final bloc = context.read<ContentBloc>();
      if (!bloc.isClosed) {
        bloc.add(FetchMyContentEvent(
            page: page, limit: limit, params: params, isRefresh: isRefresh));
      }
    } catch (e) {
      // Bloc is closed or context is no longer valid, silently handle
      debugPrint('Error adding event to ContentBloc: $e');
    }
  }

  void _loadAllContent(bool isRefresh) {
    if (!mounted) return;

    if (isRefresh) {
      page = 1;
      myContentList.clear();
      _allRefreshController.resetNoData();
    } else {
      page++;
    }

    // "All Content" - no filters, maybe exclude draft if desired, or show everything
    // Assuming "All Content" means all my content without specific filters
    Map<String, dynamic> params = {};

    try {
      final bloc = context.read<ContentBloc>();
      if (!bloc.isClosed) {
        bloc.add(FetchMyContentEvent(
            page: page, limit: limit, params: params, isRefresh: isRefresh));
      }
    } catch (e) {
      // Bloc is closed or context is no longer valid, silently handle
      debugPrint('Error adding event to ContentBloc: $e');
    }
  }

  void _onRefresh() {
    if (!mounted) return;

    if (_selectedTabbar == 0) {
      _loadAllContent(true);
    } else {
      _loadMyContent(true);
    }
  }

  void _onLoading() {
    if (!mounted) return;

    if (_selectedTabbar == 0) {
      _loadAllContent(false);
    } else {
      _loadMyContent(false);
    }
  }

  void _showFilterSheet() {
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
          return StatefulBuilder(builder: (context, stateSetter) {
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
                          "Sort and Filter",
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

                    /// Sort Heading
                    Text(
                      sortText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD05,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),

                    filterListWidget(sortList, stateSetter, size, true),

                    /// Filter
                    SizedBox(
                      height: size.width * numD05,
                    ),

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
                        setState(() {});
                        Navigator.pop(context);
                        _loadMyContent(true);
                      }),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
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
            } else {
              int pos = list.indexWhere((element) => element.isSelected);
              if (pos != -1) {
                list[pos].isSelected = false;
              }
            }
            list[index].isSelected = !list[index].isSelected;
            stateSetter(() {});
            setState(() {});
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
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: size.width * numD01,
                                horizontal: size.width * numD02,
                              ),
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
                                    item.fromDate != null
                                        ? dateTimeFormatter(
                                            dateTime: item.fromDate.toString())
                                        : 'From Date',
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
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
                                debugPrint("formData=====> ${item.fromDate}");
                                debugPrint("pickedDate=====> $pickedDate}");
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
                              stateSetter(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: size.width * numD01,
                                horizontal: size.width * numD02,
                              ),
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
                                    item.toDate != null
                                        ? dateTimeFormatter(
                                            dateTime: item.toDate.toString())
                                        : 'To Date',
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
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

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NewHomeAppBar(
        size: size,
        hideLeading: widget.hideLeading,
        onFilterTap: _showFilterSheet,
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
                  Tab(text: "All Content"),
                  Tab(
                    text: "My Content",
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFD8D8D8),
              thickness: 1.5,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // All Content Tab
                  _buildContentList(_allRefreshController, "No Content Found"),

                  // My Content Tab
                  _buildContentList(_refreshController, "No Content Published"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(RefreshController controller, String emptyMessage) {
    return BlocConsumer<ContentBloc, ContentState>(
      listener: (context, state) {
        if (state is MyContentLoaded) {
          controller.refreshCompleted();
          if (state.hasMore) {
            controller.loadComplete();
          } else {
            controller.loadNoData();
          }
          if (state.currentPage == 1) {
            myContentList = state.content;
          } else {
            myContentList.addAll(state.content);
          }
        } else if (state is ContentError) {
          controller.refreshFailed();
          controller.loadFailed();
        }
      },
      builder: (context, state) {
        // Populate myContentList from state if it's MyContentLoaded
        if (state is MyContentLoaded && myContentList.isEmpty) {
          myContentList = state.content;
        }

        if (state is ContentLoading && page == 1 && myContentList.isEmpty) {
          // return const Center(child: CircularProgressIndicator());
        }

        if (myContentList.isEmpty && state is! ContentLoading) {
          return errorMessageWidget(emptyMessage);
        }

        return SmartRefresher(
          controller: controller,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          footer: const CustomFooter(builder: commonRefresherFooter),
          child: GridView.builder(
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
                if (index >= myContentList.length) {
                  return const SizedBox.shrink();
                }
                return InkWell(
                    onTap: () {
                      var item = myContentList[index];
                      // Existing logic for tap
                      if (item.status.toLowerCase() == "pending" ||
                          item.status.toLowerCase() == "rejected") {
                        return;
                      }
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => MyContentDetailScreen(
                                    hopperID: "",
                                    paymentStatus: item.status,
                                    exclusive: item.isExclusive ?? false,
                                    contentId: item.id,
                                    purchasedMediahouseCount:
                                        item.purchasedMediahouseCount,
                                    offerCount: item.totalOffer,
                                  )))
                          .then((value) {
                        // Don't refresh on back navigation - just let cached data show
                        // _onRefresh();
                      });
                    },
                    child: _buildContentWidget(myContentList[index]));
              },
              itemCount: myContentList.length),
        );
      },
    );
  }

  Widget _buildContentWidget(ContentItem item) {
    return Container(
      padding: EdgeInsets.only(
          left: size.width * numD03,
          right: size.width * numD03,
          top: size.width * numD03),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200, spreadRadius: 2, blurRadius: 1)
          ],
          borderRadius: BorderRadius.circular(size.width * numD04)),
      child: Column(
        children: [
          _buildMediaWidget(item),
          SizedBox(
            height: size.width * numD02,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.status.toLowerCase() == "pending" ||
                          item.status.toLowerCase() == "rejected"
                      ? item.description // Using description as textValue
                      : item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD03,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                width: size.width * numD01,
              ),
              Image.asset(
                (item.isExclusive ?? false)
                    ? "${iconsPath}ic_exclusive.png"
                    : "${iconsPath}ic_share.png",
                height: (item.isExclusive ?? false)
                    ? size.width * numD03
                    : size.width * numD04,
                color: colorTextFieldIcon,
              )
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "${iconsPath}dollar1.png",
                        height: size.width * numD024,
                        width: size.width * numD025,
                        color: item.purchasedMediahouseCount == 0
                            ? Colors.grey
                            : colorThemePink,
                      ),
                      SizedBox(width: size.width * numD014),
                      Text(
                        '${item.purchasedMediahouseCount.toString()} $sold',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD026,
                            color: item.purchasedMediahouseCount == 0
                                ? Colors.grey
                                : colorThemePink,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        "${iconsPath}dollar1.png",
                        width: size.width * numD025,
                        height: size.width * numD025,
                        color:
                            item.totalOffer == 0 ? Colors.grey : colorThemePink,
                      ),
                      SizedBox(width: size.width * numD014),
                      Text(
                        '${item.totalOffer.toString()} ${item.totalOffer > 1 ? '${offerText}s' : offerText}',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD026,
                            color: item.totalOffer == 0
                                ? Colors.grey
                                : colorThemePink,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * numD01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "${iconsPath}ic_view.png",
                        height: size.width * numD026,
                        width: size.width * numD025,
                        color:
                            item.totalView == 0 ? Colors.grey : colorThemePink,
                      ),
                      SizedBox(width: size.width * numD013),
                      Text(
                        '${item.totalView.toString()} ${item.totalView > 1 ? '${viewsText}s' : viewsText}',
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD026,
                            color: item.totalView == 0
                                ? Colors.grey
                                : colorThemePink,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ],
              ),
              item.status.toLowerCase() == "pending" ||
                      item.status.toLowerCase() == "rejected"
                  ? Container(
                      height: size.height * numD036,
                      width: size.width * numD17,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              BorderRadius.circular(size.width * numD015)),
                      child: Center(
                        child: Text(
                          item.status.toLowerCase() == "pending"
                              ? "Under\nReview"
                              : "Not\nApproved",
                          textAlign: TextAlign.center,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD024,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ))
                  : Container(
                      height: size.width * numD08,
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD015,
                          vertical: size.width * numD01),
                      decoration: BoxDecoration(
                          color: item.paidStatus == unPaidText
                              ? colorThemePink
                              : colorLightGrey,
                          borderRadius:
                              BorderRadius.circular(size.width * numD015)),
                      child: Column(
                        children: [
                          Padding(
                            padding: item.paidStatus == paidText &&
                                    !item.isPaidStatusToHopper
                                ? EdgeInsets.symmetric(
                                    horizontal: size.width * numD028)
                                : EdgeInsets.zero,
                            child: Text(
                              item.paidStatus == unPaidText
                                  ? item.status.toCapitalized()
                                  : item.paidStatus == paidText &&
                                          item.isPaidStatusToHopper
                                      ? "Received"
                                      : "Sold",
                              textAlign: TextAlign.center,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD022,
                                  color: item.paidStatus == unPaidText
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          Text(
                            "$currencySymbol${formatDouble(double.tryParse(item.price ?? '0') ?? 0)}",
                            textAlign: TextAlign.center,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD022,
                                color: item.paidStatus == unPaidText
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
            ],
          ),
          SizedBox(
            height: size.width * numD02,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaWidget(ContentItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.width * numD04),
      child: Stack(
        children: [
          item.mediaUrls.isNotEmpty
              ? ((item.mediaType == 'video' ||
                          (item.mediaList.isNotEmpty &&
                              item.mediaList.first.mediaType == 'video')) &&
                      item.mediaList.isNotEmpty
                  ? VideoThumbnailWidget(
                      videoUrl:
                          getMediaImageUrl(item.mediaUrls.first, isVideo: true),
                      thumbnailUrl: item.mediaList.isNotEmpty &&
                              item.mediaList.first.thumbnailUrl != null
                          ? fixS3Url(item.mediaList.first.thumbnailUrl!)
                          : null,
                      width: size.width,
                      height: size.width * numD30,
                      fit: BoxFit.cover,
                    )
                  : _showImage(
                      item.mediaType ?? 'photo', // default
                      item.mediaUrls.first,
                    ))
              : Container(
                  decoration: const BoxDecoration(color: colorLightGrey),
                  padding: EdgeInsets.all(size.width * numD06),
                  child: Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * numD07,
                    width: size.width * numD07,
                  ),
                ),
          item.mediaUrls.isNotEmpty
              ? Image.asset(
                  "${commonImagePath}watermark1.png",
                  height: size.width * numD29,
                  width: size.width,
                  fit: BoxFit.cover,
                )
              : Container(),
          Positioned(
            right: size.width * numD02,
            top: size.width * numD02,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * numD015,
                vertical: size.width * 0.005,
              ),
              decoration: BoxDecoration(
                  color: colorLightGreen.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(size.width * numD015)),
              child: Center(
                child: Text(
                  "${item.mediaUrls.length} ",
                  textAlign: TextAlign.center,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD038,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showImage(String type, String url) {
    return type == "audio"
        ? Container(
            height: size.width * numD30,
            width: size.width,
            padding: EdgeInsets.all(size.width * numD04),
            decoration: BoxDecoration(
              color: colorThemePink,
              border: Border.all(color: colorHint),
              borderRadius: BorderRadius.circular(size.width * numD04),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size.width * numD04),
              child: Padding(
                  padding: EdgeInsets.all(size.width * numD03),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: size.width * numD18,
                    color: Colors.white,
                  )),
            ),
          )
        : type == "pdf"
            ? Container(
                height: size.width * numD30,
                width: size.width,
                padding: EdgeInsets.all(size.width * numD04),
                decoration: BoxDecoration(
                  border: Border.all(color: colorHint),
                  borderRadius: BorderRadius.circular(size.width * numD04),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * numD04),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * numD03),
                    child: Image.asset(
                      "${dummyImagePath}pngImage.png",
                      width: size.width * numD03,
                      height: size.height * numD03,
                    ),
                  ),
                ),
              )
            : type == "doc"
                ? Container(
                    height: size.width * numD30,
                    width: size.width,
                    padding: EdgeInsets.all(size.width * numD04),
                    decoration: BoxDecoration(
                      border: Border.all(color: colorHint),
                      borderRadius: BorderRadius.circular(size.width * numD04),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * numD04),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * numD03),
                        child: Image.asset(
                          "${dummyImagePath}doc_black_icon.png",
                          width: size.width * numD03,
                          height: size.height * numD03,
                        ),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: getMediaImageUrl(url, isVideo: type == 'video'),
                    height: size.width * numD30,
                    width: size.width,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      alignment: Alignment.topCenter,
                      height: size.width * numD30,
                      width: size.width,
                      child: Center(
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          height: size.width * numD15,
                          width: size.width * numD15,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      alignment: Alignment.topCenter,
                      height: size.width * numD30,
                      width: size.width,
                      child: Center(
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          height: size.width * numD15,
                          width: size.width * numD15,
                        ),
                      ),
                    ),
                  );
  }
}
