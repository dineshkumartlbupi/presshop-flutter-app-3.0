import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/feed_bloc.dart';
import '../bloc/feed_event.dart';
import '../bloc/feed_state.dart';
import '../widgets/feed_item_widget.dart';
import '../widgets/feed_filter_bottom_sheet.dart';
import '../mixins/media_controller_mixin.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return FeedScreenState();
  }
}

class FeedScreenState extends State<FeedScreen> with MediaControllerMixin {
  PageController pageController = PageController();
  ScrollController listController = ScrollController();

  int feedIndex = 0;
  String contentId = "";
  String selectedSellType = sharedText;

  late FeedBloc _feedBloc;
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    debugPrint("class ====> $runtimeType");
    super.initState();
    _feedBloc = sl<FeedBloc>();
    _feedBloc.add(const FetchFeeds(isRefresh: true));
    initializeFilter();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Feed",
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
            onTap: () {
              showSortedBottomSheet();
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
        child: BlocProvider.value(
          value: _feedBloc,
          child: BlocConsumer<FeedBloc, FeedState>(
            listener: (context, state) {
              if (state.status == FeedStatus.failure) {
                _refreshController.refreshFailed();
              } else if (state.status == FeedStatus.success) {
                _refreshController.refreshCompleted();
                if (state.hasReachedMax) {
                  _refreshController.loadNoData();
                } else {
                  _refreshController.loadComplete();
                }
              }
            },
            builder: (context, state) {
              if (state.status == FeedStatus.initial ||
                  (state.status == FeedStatus.loading && state.feeds.isEmpty)) {
                return const SizedBox.shrink();
              }

              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: !state.hasReachedMax,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                footer: const CustomFooter(builder: commonRefresherFooter),
                child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD04),
                    itemBuilder: (context, index) {
                      return FeedItemWidget(
                        feed: state.feeds[index],
                        size: size,
                        pageController: pageController,
                        initialController: initialController,
                        openUrl: openUrl,
                        onFavouriteToggle: () {
                          _feedBloc.add(ToggleFavouriteFeed(
                              id: state.feeds[index].id,
                              isFavourite: !state.feeds[index].isFavourite));
                        },
                        onLikeToggle: () {
                          _feedBloc.add(ToggleLikeFeed(
                              id: state.feeds[index].id,
                              isLiked: !state.feeds[index].isLiked));
                        },
                        onEmojiToggle: () {
                          _feedBloc.add(ToggleEmojiFeed(
                              id: state.feeds[index].id,
                              isEmoji: !state.feeds[index].isEmoji));
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.width * numD04),
                        child: const Divider(
                          color: colorTextFieldIcon,
                        ),
                      );
                    },
                    itemCount: state.feeds.length),
              );
            },
          ),
        ),
      ),
    );
  }

  void showSortedBottomSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft:
                Radius.circular(MediaQuery.of(context).size.width * numD08),
            topRight:
                Radius.circular(MediaQuery.of(context).size.width * numD08),
          ),
        ),
        context: context,
        builder: (context) {
          return FeedFilterBottomSheet(
            sortList: sortList,
            filterList: filterList,
            onApply: (newFilters) {
              _feedBloc
                  .add(FetchFeeds(isRefresh: true, newFilters: newFilters));
            },
            onClearAll: () {
              filterList.clear();
              sortList.clear();
              initializeFilter();
            },
          );
        });
  }

  void _onRefresh() {
    _feedBloc.add(const FetchFeeds(isRefresh: true));
  }

  void _onLoading() {
    _feedBloc.add(LoadMoreFeeds());
  }

  void initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: "Latest content",
          value: "desc",
          icon: "ic_monthly_calendar.png",
          isSelected: true),
      FilterModel(
          name: "Oldest content ",
          value: "asc",
          icon: "ic_weekly_calendar.png",
          isSelected: false),
      FilterModel(
          name: "Highest earning content",
          value: "highest_earning",
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: "Lowest earning content",
          icon: "ic_eye_outlined.png",
          value: "lowest_earning",
          isSelected: false),
      FilterModel(
          name: "Most views",
          value: "most_views",
          icon: "ic_eye_outlined.png",
          isSelected: false),
      FilterModel(
          name: "Least views",
          value: "least_views",
          icon: "ic_eye_outlined.png",
          isSelected: false),
    ]);
    filterList.addAll([
      FilterModel(
          name: allExclusiveContentText,
          icon: "ic_exclusive.png",
          isSelected: false),
      FilterModel(
          name: allSharedContentText, icon: "ic_share.png", isSelected: false),
      FilterModel(
          name: paymentsReceivedText,
          icon: "ic_payment_reviced.png",
          isSelected: false),
      FilterModel(
          name: pendingPaymentsText, icon: "ic_pending.png", isSelected: false),
    ]);
  }

  openUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }
}
