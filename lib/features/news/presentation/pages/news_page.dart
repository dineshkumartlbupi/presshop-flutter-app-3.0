import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/features/map/domain/usecases/get_place_details.dart';
import 'package:presshop/features/map/domain/usecases/search_places.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/news/domain/entities/news.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';
import 'package:presshop/features/news/presentation/bloc/news_event.dart';
import 'package:presshop/features/news/presentation/bloc/news_state.dart';
import 'package:go_router/go_router.dart';

import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/features/map/presentation/widgets/serarch_filter_widget.dart';
import 'package:presshop/features/feed/presentation/pages/feed_screen.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({
    super.key,
    this.hideLeading = false,
    this.latitude,
    this.longitude,
    this.hideFilters = false,
    this.prioritizedContentId,
    this.appBarTitle,
    this.showAppBar = false,
    this.fromMap = false,
  });
  final bool hideLeading;
  final bool showAppBar;
  final double? latitude;
  final double? longitude;
  final bool hideFilters;
  final String? prioritizedContentId;
  final String? appBarTitle;
  final bool fromMap;

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with
        AnalyticsPageMixin,
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  late TabController _tabController;
  Function()? _showFeedBottomSheet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
        if (_tabController.index == 1) {
          final newsBloc = context.read<NewsBloc>();
          if (newsBloc.state.newsList.isEmpty && !newsBloc.state.isLoading) {
            debugPrint("NewsPage: Tab switched to Local News and empty, reloading...");
            _applyFilters();
          }
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final newsBloc = context.read<NewsBloc>();

      // If the bloc is already loading (e.g. from the router), don't trigger another load
      if (newsBloc.state.isLoading && newsBloc.state.newsList.isEmpty) {
        debugPrint("NewsPage: Already loading, skipping initial event");
        return;
      }

      if (widget.prioritizedContentId != null &&
          widget.prioritizedContentId!.isNotEmpty) {
        newsBloc.add(GetAggregatedNewsEvent(
          lat: widget.latitude ?? 0.0,
          lng: widget.longitude ?? 0.0,
          km: 50,
          prioritizedContentId: widget.prioritizedContentId,
        ));
      } else {
        if (widget.latitude != null && widget.longitude != null) {
          _applyFilters();
        } else {
          newsBloc.add(const GetAllNewsEvent());
        }
      }
    });
  }

  @override
  String get pageName => PageNames.newsPage;

  String selectedAlertType = 'Alert';
  String selectedDistance = '2 miles';
  String selectedCategory = 'Category';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _predictions = [];

  void _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final result = await sl<SearchPlaces>()(value);
    result.fold(
      (failure) => null,
      (predictions) {
        setState(() {
          _predictions = predictions;
        });
      },
    );
  }

  void _selectPrediction(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'];
    final result = await sl<GetPlaceDetails>()(placeId);

    result.fold(
      (failure) => null,
      (latLng) {
        setState(() {
          _predictions = [];
          _searchController.text = prediction['description'];
          _searchFocusNode.unfocus();
        });

        // Fetch news for the new location
        context.read<NewsBloc>().add(GetAggregatedNewsEvent(
              lat: latLng.latitude,
              lng: latLng.longitude,
              km: _convertDistanceToKm(selectedDistance),
              category:
                  selectedCategory == 'Category' ? 'all' : selectedCategory,
              alertType:
                  selectedAlertType == 'Alert' ? null : selectedAlertType,
            ));
      },
    );
  }

  void _onRefresh() async {
    if (widget.latitude == null &&
        widget.longitude == null &&
        widget.prioritizedContentId == null) {
      context.read<NewsBloc>().add(GetAllNewsEvent(
            km: _convertDistanceToKm(selectedDistance),
            category: selectedCategory == 'Category' ? 'all' : selectedCategory,
            alertType: selectedAlertType == 'Alert' ? null : selectedAlertType,
          ));
    } else {
      _applyFilters();
    }
  }

  void _onLoading() async {
    final newsList = context.read<NewsBloc>().state.newsList;
    if (widget.latitude == null &&
        widget.longitude == null &&
        widget.prioritizedContentId == null) {
      context.read<NewsBloc>().add(GetAllNewsEvent(
            km: _convertDistanceToKm(selectedDistance),
            category: selectedCategory == 'Category' ? 'all' : selectedCategory,
            alertType: selectedAlertType == 'Alert' ? null : selectedAlertType,
            offset: newsList.length,
          ));
    } else {
      context.read<NewsBloc>().add(GetAggregatedNewsEvent(
            lat: widget.latitude ?? 0.0,
            lng: widget.longitude ?? 0.0,
            km: _convertDistanceToKm(selectedDistance),
            category: selectedCategory == 'Category' ? 'all' : selectedCategory,
            alertType: selectedAlertType == 'Alert' ? null : selectedAlertType,
            prioritizedContentId: widget.prioritizedContentId,
            offset: newsList.length,
          ));
    }
  }

  void _applyFilters() {
    double km = _convertDistanceToKm(selectedDistance);
    if (widget.latitude == null &&
        widget.longitude == null &&
        widget.prioritizedContentId == null) {
      context.read<NewsBloc>().add(GetAllNewsEvent(
            km: km,
            category: selectedCategory == 'Category' ? 'all' : selectedCategory,
            alertType: selectedAlertType == 'Alert' ? null : selectedAlertType,
          ));
    } else {
      context.read<NewsBloc>().add(GetAggregatedNewsEvent(
            lat: widget.latitude ?? 0.0,
            lng: widget.longitude ?? 0.0,
            km: km,
            category: selectedCategory == 'Category' ? 'all' : selectedCategory,
            alertType: selectedAlertType == 'Alert' ? null : selectedAlertType,
            prioritizedContentId: widget.prioritizedContentId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: NewHomeAppBar(
        size: size,
        hideLeading: widget.hideLeading,
        hideHamburger: true,
        showLogo: false,
        showFilter: false, // !widget.fromMap && _tabController.index == 0,
        onFilterTap: () {
          if (_tabController.index == 0 && _showFeedBottomSheet != null) {
            _showFeedBottomSheet!();
          }
        },
        appBarTitle: widget.appBarTitle,

        // hideHamburger: widget.appBarTitle != null,
        bottom: widget.fromMap
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD04),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
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
                        unselectedLabelStyle: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD038,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
                          Tab(text: "PressHop News"),
                          Tab(text: "Local News"),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFD8D8D8),
                      thickness: 1.5,
                    ),
                  ],
                ),
              ),
      ),
      body: widget.fromMap
          ? _buildLocalNewsContent(context, size)
          : TabBarView(
              controller: _tabController,
              children: [
                FeedScreen(
                  showAppBar: false,
                  onShowFilter: (fn) => _showFeedBottomSheet = fn,
                ),
                _buildLocalNewsContent(context, size),
              ],
            ),
    );
  }

  Widget _buildLocalNewsContent(BuildContext context, Size size) {
    return BlocConsumer<NewsBloc, NewsState>(
      listener: (context, state) {
        if (!state.isLoading) {
          _refreshController.refreshCompleted();
          _refreshController.loadComplete();
        }
        if (!state.hasMoreNews) {
          _refreshController.loadNoData();
        }
        if (state.errorMessage != null) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(state.errorMessage!)),
          // );
        }
      },
      builder: (context, state) {
        final newsList = state.newsList;
        return Stack(
          children: [
            SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: state.hasMoreNews,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: const WaterDropHeader(),
              footer: const CustomFooter(builder: commonRefresherFooter),
              child: newsList.isEmpty &&
                      !state.isLoading &&
                      (state.isProcessing || !state.hasMoreNews)
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD05),
                        child: Text(
                          state.isProcessing
                              ? "News is being aggregated for your location. Please pull down to refresh in a few moments."
                              : "No data found",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: size.width * AppDimensions.numD04,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(
                        top: widget.hideFilters
                            ? size.width * AppDimensions.numD04
                            : 80, // Adjusted for SearchAndFilterBar
                        left: size.width * AppDimensions.numD04,
                        right: size.width * AppDimensions.numD04,
                        bottom: size.width * AppDimensions.numD04,
                      ),
                      itemCount: newsList.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: size.width * AppDimensions.numD06),
                      itemBuilder: (context, index) {
                        return _buildNewsCard(context, newsList[index], size);
                      },
                    ),
            ),
            if (!widget.hideFilters)
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                child: SearchAndFilterBar(
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  selectedAlertType: selectedAlertType,
                  selectedDistance: selectedDistance,
                  selectedCategory: selectedCategory,
                  onChange: _onSearchChanged,
                  showFilters: false, // "only search" for news tab
                  onAlertTypeChanged: (val) {
                    if (val != null) {
                      setState(() => selectedAlertType = val);
                      _applyFilters();
                    }
                  },
                  onDistanceChanged: (val) {
                    if (val != null) {
                      setState(() => selectedDistance = val);
                      _applyFilters();
                    }
                  },
                  onCategoryChanged: (val) {
                    if (val != null) {
                      setState(() => selectedCategory = val);
                      _applyFilters();
                    }
                  },
                  showNavigationIcon: false,
                ),
              ),
            if (_predictions.isNotEmpty)
              Positioned(
                top: 60,
                left: 12,
                right: 60,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _predictions.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = _predictions[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          p['description'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => _selectPrediction(p),
                      );
                    },
                  ),
                ),
              ),
            if (state.isLoading ||
                (newsList.isEmpty && state.hasMoreNews && !state.isProcessing))
              Container(
                color: Colors.transparent,
                child: Center(
                  child: showAnimatedLoader(size),
                ),
              ),
          ],
        );
      },
    );
  }

  void _toggleLike(String id) {
    context.read<NewsBloc>().add(ToggleNewsLikeEvent(contentId: id));
  }

  Future<void> _handleShare(BuildContext context, News item) async {
    context.read<NewsBloc>().add(ShareNewsEvent(contentId: item.id));
    await shareLink(
      title: item.title,
      description: item.description,
      taskName: "News",
    );
  }

  Widget _buildNewsCard(BuildContext context, News item, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section
        Stack(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(size.width * AppDimensions.numD04),
              child: CachedNetworkImage(
                imageUrl: item.mediaUrl ?? "",
                height: size.width * AppDimensions.numD50,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: size.width * AppDimensions.numD50,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: size.width * AppDimensions.numD50,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            // Most Viewed Badge
            if (item.isMostViewed ?? false)
              Positioned(
                left: size.width * AppDimensions.numD03,
                bottom: size.width * AppDimensions.numD03,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD03,
                      vertical: size.width * AppDimensions.numD015),
                  decoration: BoxDecoration(
                    color: AppColorTheme.colorThemePink,
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD05),
                  ),
                  child: Text(
                    "Most viewed",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * AppDimensions.numD03,
                      fontWeight: FontWeight.w600,
                      fontFamily: "AirbnbCereal",
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: size.width * AppDimensions.numD03),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: size.width * AppDimensions.numD035,
                    backgroundImage: (item.userImage != null &&
                            item.userImage!.isNotEmpty)
                        ? NetworkImage(item.userImage!)
                        : const NetworkImage(
                            "https://i.pravatar.cc/150?u=a042581f4e29026704d"),
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(width: size.width * AppDimensions.numD02),
                  Flexible(
                    child: Text(
                      item.userName ?? "Unknown",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: size.width * AppDimensions.numD035,
                        fontFamily: "AirbnbCereal",
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.width * AppDimensions.numD03),

        // Title
        Text(item.title,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD04,
                color: Colors.black,
                lineHeight: 1.5,
                fontWeight: FontWeight.w700)),
        SizedBox(height: size.width * AppDimensions.numD02),

        // Description
        Text(
          item.description,
          textAlign: TextAlign.justify,
          style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD03,
              color: Colors.black,
              lineHeight: 2,
              fontWeight: FontWeight.normal),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: size.width * AppDimensions.numD04),

        Row(
          children: [
            _buildStatItem(
              Image.asset(
                (item.isLiked ?? false)
                    ? "assets/icons/new_heartfill.png"
                    : "assets/icons/news_heart.png",
                width: size.width * AppDimensions.numD03,
                height: size.width * AppDimensions.numD03,
                color: Colors.grey[600],
              ),
              "${item.likesCount ?? 0}",
              item.likesCount == 1 || item.likesCount == 0 ? 'like' : 'likes',
              size,
              color: Colors.grey[500],
            ),

            SizedBox(width: size.width * AppDimensions.numD02),
            _buildStatItem(
              Image.asset(
                "assets/icons/news_eye.png",
                width: size.width * AppDimensions.numD04,
                height: size.width * AppDimensions.numD04,
                color: Colors.grey[500],
              ),
              "${item.viewCount ?? 0}",
              item.viewCount == 1 || item.viewCount == 0 ? 'view' : 'views',
              size,
              color: Colors.grey[500],
            ),
            SizedBox(width: size.width * AppDimensions.numD02),

            // Time
            Row(
              children: [
                Image.asset(
                  "${iconsPath}ic_clock.png",
                  height: size.width * AppDimensions.numD03,
                  color: Colors.grey[500],
                ),
                SizedBox(width: size.width * AppDimensions.numD01),
                Builder(builder: (context) {
                  final timeStr = item.createdAt;
                  if (timeStr == null) return const SizedBox();

                  DateTime? parsed = DateTime.tryParse(timeStr);
                  if (parsed != null) {
                    return Text(
                      DateFormat('hh:mm a').format(parsed),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                        fontSize: size.width * AppDimensions.numD032,
                        fontFamily: "AirbnbCereal",
                      ),
                    );
                  }
                  return Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      fontSize: size.width * AppDimensions.numD032,
                      fontFamily: "AirbnbCereal",
                    ),
                  );
                }),
              ],
            ),
            SizedBox(width: size.width * AppDimensions.numD02),

            // Date
            Row(
              children: [
                Image.asset(
                  "${iconsPath}ic_yearly_calendar.png",
                  height: size.width * AppDimensions.numD03,
                  color: Colors.grey[500],
                ),
                SizedBox(width: size.width * AppDimensions.numD01),
                Builder(builder: (context) {
                  DateTime? parsedDate;
                  if (item.createdAt != null) {
                    parsedDate = DateTime.tryParse(item.createdAt!);
                  }

                  return Text(
                    parsedDate != null
                        ? DateFormat("dd MMM yyyy").format(parsedDate)
                        : (item.createdAt ?? ""),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                      fontSize: size.width * AppDimensions.numD032,
                      fontFamily: "AirbnbCereal",
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
        SizedBox(height: size.width * AppDimensions.numD02),

        // Date and Location
        Row(
          children: [
            Image.asset("assets/icons/news_location.png",
                height: size.width * AppDimensions.numD04,
                color: Colors.grey[500]),
            SizedBox(width: size.width * AppDimensions.numD01),
            Expanded(
              child: Text(
                item.location ?? "Unknown Location",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: size.width * AppDimensions.numD03,
                    color: Colors.grey[500],
                    fontFamily: "AirbnbCereal"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: size.width * AppDimensions.numD04),

        // Action Buttons Row
        Row(
          children: [
            InkWell(
              onTap: () => _toggleLike(item.id),
              child: Image.asset(
                  (item.isLiked ?? false)
                      ? "assets/icons/new_heartfill.png"
                      : "assets/icons/news_heart.png",
                  width: size.width * AppDimensions.numD06,
                  height: size.width * AppDimensions.numD05),
            ),
            SizedBox(width: size.width * AppDimensions.numD04),
            Builder(builder: (context) {
              return InkWell(
                onTap: () {
                  _handleShare(context, item);
                },
                child: Image.asset("assets/icons/news_send.png",
                    width: size.width * AppDimensions.numD06,
                    height: size.width * AppDimensions.numD05),
              );
            }),
            SizedBox(width: size.width * AppDimensions.numD04),
            InkWell(
              onTap: () {
                _navigateToDetails(context, item, scrollToComments: true);
              },
              child: Image.asset("assets/icons/news_message.png",
                  width: size.width * AppDimensions.numD06,
                  height: size.width * AppDimensions.numD05),
            ),

            const Spacer(),

            // Read More Button
            InkWell(
              onTap: () {
                _navigateToDetails(context, item);
              },
              child: Text(
                "Read More",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * AppDimensions.numD035,
                  // decoration: TextDecoration.underline,
                  fontFamily: "AirbnbCereal",
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: size.width * AppDimensions.numD02),
        const Divider(),
      ],
    );
  }

  Widget _buildStatItem(Image icon, String value, String label, Size size,
      {Color? color}) {
    return Row(
      children: [
        icon,
        SizedBox(width: size.width * AppDimensions.numD01),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$value ",
                style: TextStyle(
                  color: color ?? Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: size.width * AppDimensions.numD032,
                  fontFamily: "AirbnbCereal",
                ),
              ),
              TextSpan(
                text: label,
                style: TextStyle(
                  color: color ?? Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: size.width * AppDimensions.numD032,
                  fontFamily: "AirbnbCereal",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context, News item,
      {bool scrollToComments = false}) {
    context.pushNamed(
      AppRoutes.newsDetailsName,
      extra: {
        'newsId': item.id,
        'initialNews': item,
        'scrollToComments': scrollToComments,
      },
    );
  }

  // void _showFilterBottomSheet(BuildContext context, Size size) {
  //   final newsBloc = context.read<NewsBloc>();
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return BlocProvider.value(
  //         value: newsBloc,
  //         child: _FilterBottomSheetContent(
  //           size: size,
  //           initialAlertType: 'Alert',
  //           initialDistance: '2 miles',
  //           initialCategory: 'Category',
  //           onApply: (alertType, distance, category) {
  //             double km = _convertDistanceToKm(distance);
  //             newsBloc.add(GetAggregatedNewsEvent(
  //               lat: widget.latitude ?? 0.0,
  //               lng: widget.longitude ?? 0.0,
  //               km: km,
  //               category: category == 'Category' ? 'all' : category,
  //               alertType: alertType == 'Alert' ? null : alertType,
  //             ));
  //             context.pop();
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  double _convertDistanceToKm(String distance) {
    switch (distance) {
      case '1 mile':
        return 1.60934;
      case '2 miles':
        return 3.21869;
      case '5 miles':
        return 8.04672;
      case '10 miles':
        return 16.0934;
      case '15 miles':
        return 24.1402;
      case '20 miles':
        return 32.1869;
      case '25 miles':
        return 40.2336;
      case '30 miles':
        return 48.2803;
      case '50 miles':
        return 80.4672;
      default:
        return 50.0;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _FilterBottomSheetContent extends StatefulWidget {
  const _FilterBottomSheetContent({
    required this.size,
    required this.initialAlertType,
    required this.initialDistance,
    required this.initialCategory,
    required this.onApply,
  });
  final Size size;
  final String initialAlertType;
  final String initialDistance;
  final String initialCategory;
  final Function(String, String, String) onApply;

  @override
  _FilterBottomSheetContentState createState() =>
      _FilterBottomSheetContentState();
}

class _FilterBottomSheetContentState extends State<_FilterBottomSheetContent> {
  late String selectedAlertType;
  late String selectedDistance;
  late String selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _predictions = [];

  void _onSearchChanged(String value) async {
    if (value.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    final result = await sl<SearchPlaces>()(value);
    result.fold(
      (failure) => null,
      (predictions) {
        setState(() {
          _predictions = predictions;
        });
      },
    );
  }

  void _selectPrediction(Map<String, dynamic> prediction) async {
    final placeId = prediction['place_id'];
    final result = await sl<GetPlaceDetails>()(placeId);

    result.fold(
      (failure) => null,
      (latLng) {
        setState(() {
          _predictions = [];
          _searchController.text = prediction['description'];
          _searchFocusNode.unfocus();
        });

        // Fetch news for the new location
        context.read<NewsBloc>().add(GetAggregatedNewsEvent(
              lat: latLng.latitude,
              lng: latLng.longitude,
              km: _convertDistanceToKm(selectedDistance),
              category:
                  selectedCategory == 'Category' ? 'all' : selectedCategory,
              alertType:
                  selectedAlertType == 'Alert' ? null : selectedAlertType,
            ));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectedAlertType = widget.initialAlertType;
    selectedDistance = widget.initialDistance;
    selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  double _convertDistanceToKm(String distance) {
    switch (distance) {
      case '1 mile':
        return 1.60934;
      case '2 miles':
        return 3.21869;
      case '5 miles':
        return 8.04672;
      case '10 miles':
        return 16.0934;
      case '15 miles':
        return 24.1402;
      case '20 miles':
        return 32.1869;
      case '25 miles':
        return 40.2336;
      case '30 miles':
        return 48.2803;
      case '50 miles':
        return 80.4672;
      default:
        return 50.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: widget.size.width * AppDimensions.numD05,
        right: widget.size.width * AppDimensions.numD05,
        top: widget.size.width * AppDimensions.numD05,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            widget.size.width * AppDimensions.numD05,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.size.width * AppDimensions.numD05),
          topRight: Radius.circular(widget.size.width * AppDimensions.numD05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                splashRadius: widget.size.width * AppDimensions.numD07,
                onPressed: () {
                  context.pop();
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                  size: widget.size.width * AppDimensions.numD07,
                ),
              ),
              Text(
                "Sort and Filter",
                style: commonTextStyle(
                    size: widget.size,
                    fontSize: widget.size.width *
                        AppDimensions.appBarHeadingFontSizeNew,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedAlertType = 'Alert';
                    selectedDistance = '2 miles';
                    selectedCategory = 'Category';
                    _searchController.clear();
                    _predictions = [];
                  });
                },
                child: Text(
                  "Clear all",
                  style: TextStyle(
                      color: AppColorTheme.colorThemePink,
                      fontWeight: FontWeight.w400,
                      fontSize: widget.size.width * AppDimensions.numD035),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.size.width * AppDimensions.numD05),

          // Search And Filters
          Stack(
            children: [
              SearchAndFilterBar(
                searchController: _searchController,
                searchFocusNode: _searchFocusNode,
                selectedAlertType: selectedAlertType,
                selectedDistance: selectedDistance,
                selectedCategory: selectedCategory,
                onChange: _onSearchChanged,
                onAlertTypeChanged: (val) {
                  if (val != null) {
                    setState(() => selectedAlertType = val);
                  }
                },
                onDistanceChanged: (val) {
                  if (val != null) {
                    setState(() => selectedDistance = val);
                  }
                },
                onCategoryChanged: (val) {
                  if (val != null) {
                    setState(() => selectedCategory = val);
                  }
                },
                onPressedOnNavigation: () {},
                showNavigationIcon: false,
              ),
              if (_predictions.isNotEmpty)
                Positioned(
                  top: 60,
                  left: 12,
                  right: 60,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: widget.size.height * 0.4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _predictions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = _predictions[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            p['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _selectPrediction(p),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: widget.size.width * AppDimensions.numD08),

          // Apply Button
          Container(
            width: widget.size.width,
            height: widget.size.width * AppDimensions.numD13,
            margin: EdgeInsets.symmetric(
                horizontal: widget.size.width * AppDimensions.numD04),
            padding: EdgeInsets.symmetric(
              horizontal: widget.size.width * AppDimensions.numD04,
            ),
            child: commonElevatedButton(
                "Apply",
                widget.size,
                commonTextStyle(
                    size: widget.size,
                    fontSize: widget.size.width * AppDimensions.numD035,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
                commonButtonStyle(widget.size, AppColorTheme.colorThemePink),
                () {
              widget.onApply(
                  selectedAlertType, selectedDistance, selectedCategory);
            }),
          ),
          SizedBox(height: widget.size.width * AppDimensions.numD02),
        ],
      ),
    );
  }
}
