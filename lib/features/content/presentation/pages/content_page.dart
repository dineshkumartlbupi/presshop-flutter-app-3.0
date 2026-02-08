import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/content/domain/entities/content_item.dart';
import 'package:presshop/features/content/presentation/bloc/content_bloc.dart';
import 'package:presshop/features/content/presentation/bloc/content_event.dart';
import 'package:presshop/features/content/presentation/bloc/content_state.dart';

import 'package:presshop/features/content/presentation/widgets/content_filter_bottom_sheet.dart';
import 'package:presshop/features/content/presentation/widgets/content_item_widget.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';

class MyContentPage extends StatelessWidget {
  const MyContentPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const MyContentView();
  }
}

class MyContentView extends StatefulWidget {
  const MyContentView({super.key});

  @override
  State<MyContentView> createState() => _MyContentViewState();
}

class _MyContentViewState extends State<MyContentView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late TabController _tabController;
  final RefreshController _allController = RefreshController();
  final RefreshController _myController = RefreshController();

  int allPage = 1;
  int myPage = 1;

  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];

  // Local constants for missing strings
  static const String newestText = "Newest";
  static const String oldestText = "Oldest";
  static const String lowToHighText = "Price: Low to High";
  static const String highToLowText = "Price: High to Low";
  static const String photosText = "Photos";
  static const String videosText = "Videos";
  static const String allText = "All";
  static const String noAllContentFound = "No Content Found";
  static const String noMyContentFound = "No Content Published";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initializeFilter();
    _loadAllContent(false);
    _loadMyContent(true);
  }

  void initializeFilter() {
    sortList = [
      FilterModel(
          name: newestText, icon: "ic_yearly_calendar.png", isSelected: true),
      FilterModel(
          name: oldestText, icon: "ic_yearly_calendar.png", isSelected: false),
      FilterModel(
          name: lowToHighText, icon: "ic_graph_down.png", isSelected: false),
      FilterModel(
          name: highToLowText, icon: "ic_graph_up.png", isSelected: false),
    ];

    filterList = [
      FilterModel(name: allText, icon: "ic_content.png", isSelected: true),
      FilterModel(
          name: photosText, icon: "ic_camera_publish.png", isSelected: false),
      FilterModel(name: videosText, icon: "ic_v_cam.png", isSelected: false),
      FilterModel(
          name: AppStrings.soldContentText,
          icon: "dollar1.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.filterDateText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
    ];
  }

  void _loadAllContent(bool isRefresh) {
    if (isRefresh) allPage = 1;
    context.read<ContentBloc>().add(FetchMyContentEvent(
          page: allPage,
          limit: 10,
          isRefresh: isRefresh,
          type: 'all',
        ));
  }

  void _loadMyContent(bool isRefresh) {
    if (isRefresh) myPage = 1;

    Map<String, dynamic> params = {};

    final selectedSort = sortList.firstWhere((e) => e.isSelected,
        orElse: () => FilterModel(name: "", icon: "", isSelected: false));
    if (selectedSort.name == newestText) {
      params['sortBy'] = "createdAt";
      params['sortOrder'] = "desc";
    } else if (selectedSort.name == oldestText) {
      params['sortBy'] = "createdAt";
      params['sortOrder'] = "asc";
    } else if (selectedSort.name == lowToHighText) {
      params['sortBy'] = "price";
      params['sortOrder'] = "asc";
    } else if (selectedSort.name == highToLowText) {
      params['sortBy'] = "price";
      params['sortOrder'] = "desc";
    }

    final selectedFilter = filterList.firstWhere((e) => e.isSelected,
        orElse: () => FilterModel(name: "", icon: "", isSelected: false));
    if (selectedFilter.name == photosText) {
      params['type'] = "photo";
    } else if (selectedFilter.name == videosText) {
      params['type'] = "video";
    } else if (selectedFilter.name == AppStrings.soldContentText) {
      params['isSold'] = true;
    }

    if (selectedFilter.fromDate != null) {
      params['fromDate'] = selectedFilter.fromDate;
    }
    if (selectedFilter.toDate != null) {
      params['toDate'] = selectedFilter.toDate;
    }

    context.read<ContentBloc>().add(FetchMyContentEvent(
          page: myPage,
          limit: 10,
          isRefresh: isRefresh,
          type: 'my',
          params: params,
        ));
  }

  void _onAllRefresh() {
    _loadAllContent(true);
  }

  void _onMyRefresh() {
    _loadMyContent(true);
  }

  void _onAllLoading() {
    allPage++;
    _loadAllContent(false);
  }

  void _onMyLoading() {
    myPage++;
    _loadMyContent(false);
  }

  void _onItemTap(ContentItem item) {
    if (item.status.toLowerCase() == "pending" ||
        item.status.toLowerCase() == "rejected") {
      return;
    }
    context.pushNamed(
      AppRoutes.contentDetailName,
      extra: {
        'contentId': item.id,
        'paymentStatus':
            item.paidStatus ? AppStrings.paidText : AppStrings.unPaidText,
        'exclusive': item.isExclusive ?? false,
        'offerCount': item.totalOffer,
        'purchasedMediahouseCount': item.purchasedMediahouseCount,
        'hopperID': "", // Assuming empty or null based on previous context
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: NewHomeAppBar(
        size: size,
        hideLeading: true,
        onFilterTap: _showFilterSheet,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: size.width * AppDimensions.numD04),
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
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD02),
                ),
                labelStyle: commonTextStyle(
                  size: size,
                  fontSize: size.width * AppDimensions.numD038,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(text: "All Content"),
                  Tab(text: "My Content"),
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
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildContentList(_allController, 'all', noAllContentFound),
                  _buildContentList(_myController, 'my', noMyContentFound),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentList(
      RefreshController controller, String type, String emptyMessage) {
    bool isAll = type == 'all';
    var size = MediaQuery.of(context).size;

    return BlocConsumer<ContentBloc, ContentState>(
      listener: (context, state) {
        if (state is MyContentLoaded) {
          bool isLoading = isAll ? state.isLoadingAll : state.isLoadingMy;
          if (isLoading) return;
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            controller.refreshFailed();
            controller.loadFailed();
          } else {
            controller.refreshCompleted();
            controller.loadComplete();

            bool hasMore = isAll ? state.hasMoreAll : state.hasMoreMy;
            if (!hasMore) {
              controller.loadNoData();
            }

            if (isAll) {
              allPage = state.allPage;
            } else {
              myPage = state.myPage;
            }
          }
        } else if (state is ContentError) {
          controller.refreshFailed();
          controller.loadFailed();
        }
      },
      builder: (context, state) {
        bool isLoading = false;
        List<ContentItem> currentList = [];
        if (state is MyContentLoaded) {
          currentList = isAll ? state.allContent : state.myContent;
          isLoading = isAll ? state.isLoadingAll : state.isLoadingMy;
        }

        return SmartRefresher(
          controller: controller,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: isAll ? _onAllRefresh : _onMyRefresh,
          onLoading: isAll ? _onAllLoading : _onMyLoading,
          header: const WaterDropHeader(),
          footer: const CustomFooter(builder: commonRefresherFooter),
          child: currentList.isEmpty &&
                  (state is ContentLoading ||
                      isLoading ||
                      state is ContentInitial)
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: size.height * 0.3),
                    showLoader(),
                  ],
                )
              : currentList.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: size.height * 0.3),
                        errorMessageWidget(emptyMessage),
                      ],
                    )
                  : GridView.builder(
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD04),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: size.width * AppDimensions.numD04,
                        crossAxisSpacing: size.width * AppDimensions.numD04,
                      ),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final item = currentList[index];
                        return ContentItemWidget(
                          key: ValueKey(
                              item.id), // Add key for better widget recycling
                          item: item,
                          size: size,
                          onTap: () => _onItemTap(item),
                        );
                      },
                    ),
        );
      },
    );
  }

  void _showFilterSheet() {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * AppDimensions.numD085),
          topRight: Radius.circular(size.width * AppDimensions.numD085),
        ),
      ),
      builder: (context) {
        return ContentFilterSheet(
          size: size,
          sortList: sortList,
          filterList: filterList,
          onApply: () {
            context.pop();
            if (_tabController.index == 0) {
              _loadAllContent(true);
            } else {
              _loadMyContent(true);
            }
          },
          onClear: () {
            context.pop();
            initializeFilter();
            if (_tabController.index == 0) {
              _loadAllContent(true);
            } else {
              _loadMyContent(true);
            }
          },
        );
      },
    );
  }
}
