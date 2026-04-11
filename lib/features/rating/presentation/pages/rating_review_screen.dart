import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:presshop/features/publish/data/models/category_data_model.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/rating/presentation/bloc/rating/rating_bloc.dart';

import 'package:presshop/core/di/injection_container.dart' as di;
import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:presshop/features/dashboard/presentation/pages/dashboard.dart';
import 'package:presshop/features/rating/domain/entities/review.dart';

class FilterRatingData {
  FilterRatingData({required this.ratingValue, required this.selected});
  double ratingValue;
  bool selected;
}

class RatingReviewScreen extends StatefulWidget {
  const RatingReviewScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return RatingReviewScreenState();
  }
}

class RatingReviewScreenState extends State<RatingReviewScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String selectedType = AppStrings.receivedText;
  List<CategoryDataModel> priceTipsCategoryList = [];
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  List<FilterRatingData> filterRatingList = [];

  @override
  void initState() {
    initializeFilter();
    super.initState();
    priceTipsCategoryList.add(CategoryDataModel(
        name: AppStrings.receivedText,
        selected: true,
        id: '',
        type: '',
        percentage: ''));
    priceTipsCategoryList.add(CategoryDataModel(
        name: AppStrings.givenText,
        selected: false,
        id: '',
        type: '',
        percentage: ''));
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
          isSelected: false),
      FilterModel(
          name: AppStrings.viewYearlyText,
          icon: "ic_yearly_calendar.png",
          isSelected: false),
      FilterModel(
          name: AppStrings.filterDateText,
          icon: "ic_eye_outlined.png",
          isSelected: false),
    ]);
    filterRatingList.addAll([
      FilterRatingData(ratingValue: 5.0, selected: false),
      FilterRatingData(ratingValue: 4.0, selected: false),
      FilterRatingData(ratingValue: 3.0, selected: false),
      FilterRatingData(ratingValue: 2.0, selected: false),
      FilterRatingData(ratingValue: 1.0, selected: false),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (_) => di.sl<RatingBloc>()..add(RatingLoadInitial()),
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            "${AppStrings.ratingText} & ${AppStrings.reviewText}",
            style: TextStyle(
                color: Colors.black,
                fontSize: size.width * AppDimensions.appBarHeadingFontSize),
          ),
          centerTitle: false,
          titleSpacing: 0,
          size: size,
          showActions: true,
          leadingFxn: () {
            context.pop();
          },
          actionWidget: [
            InkWell(
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
            SizedBox(
              width: size.width * AppDimensions.numD04,
            )
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<RatingBloc, RatingState>(
            listener: (context, state) {
              if (state.status == RatingStatus.failure) {
                _refreshController.refreshFailed();
                _refreshController.loadFailed();
                // Show error snackbar if needed
              } else if (state.status == RatingStatus.success) {
                _refreshController.refreshCompleted();
                if (state.hasReachedMax) {
                  _refreshController.loadNoData();
                } else {
                  _refreshController.loadComplete();
                }
              }
            },
            builder: (context, state) {
              if (state.status == RatingStatus.initial ||
                  (state.status == RatingStatus.loading &&
                      state.reviews.isEmpty)) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD04),
                    child: Row(
                      children: [
                        Text(
                          "${AppStrings.ratingText} & ${AppStrings.reviewText} ${state.type}"
                              .toUpperCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD036,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              showBottomSheet(context, size, state);
                            },
                            child: Container(
                                padding: EdgeInsets.all(
                                    size.width * AppDimensions.numD04),
                                child: Image.asset(
                                  "${iconsPath}ic_filter.png",
                                  height: size.width * AppDimensions.numD05,
                                )))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD04,
                  ),
                  Flexible(
                      child: state.reviews.isNotEmpty
                          ? SmartRefresher(
                              controller: _refreshController,
                              enablePullDown: true,
                              enablePullUp: !state.hasReachedMax,
                              onRefresh: () {
                                context
                                    .read<RatingBloc>()
                                    .add(RatingLoadReviews(isRefresh: true));
                              },
                              onLoading: () {
                                context
                                    .read<RatingBloc>()
                                    .add(RatingLoadReviews(isLoadMore: true));
                              },
                              child: ListView.separated(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          size.width * AppDimensions.numD04,
                                      vertical:
                                          size.width * AppDimensions.numD02),
                                  itemBuilder: (context, index) {
                                    final review = state.reviews[index];
                                    return _buildReviewItem(size, review);
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      height: size.width * AppDimensions.numD06,
                                    );
                                  },
                                  itemCount: state.reviews.length),
                            )
                          : errorMessageWidget("Data Not Available")),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(Size size, Review review) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * AppDimensions.numD03,
          vertical: size.width * AppDimensions.numD04),
      decoration: BoxDecoration(
          color: AppColorTheme.colorLightGrey,
          borderRadius:
              BorderRadius.circular(size.width * AppDimensions.numD04)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                height: size.width * AppDimensions.numD20,
                width: size.width * AppDimensions.numD20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD04),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 1,
                      )
                    ]),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD04),
                  child: CachedNetworkImage(
                      imageUrl: review.hopperImage,
                      imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Container(
                            height: size.width * AppDimensions.numD20,
                            width: size.width * AppDimensions.numD20,
                            decoration: BoxDecoration(
                                color:
                                    AppColorTheme.colorGreyChat.withOpacity(.3),
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD03)),
                          )),
                ),
              ),
              SizedBox(
                height: size.width * 0.02,
              ),
              if (review.totalEarning.isNotEmpty)
                Container(
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD016,
                        horizontal: size.width * AppDimensions.numD016),
                    width: size.width * AppDimensions.numD20,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.1),
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD02),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Earning",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.02,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "$currencySymbol${formatDouble(double.tryParse(review.totalEarning) ?? 0.0)}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * 0.026,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              SizedBox(
                height: size.width * 0.02,
              ),
              if (review.time.isNotEmpty)
                Row(
                  children: [
                    Image.asset(
                      "${iconsPath}ic_clock.png",
                      height: size.width * AppDimensions.numD036,
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD01,
                    ),
                    Text(
                      dateTimeFormatter(
                          dateTime: review.time, format: "hh:mm a"),
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD028,
                          color: AppColorTheme.colorHint,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              SizedBox(
                height: size.width * 0.02,
              ),
              if (review.date.isNotEmpty)
                Row(
                  children: [
                    Image.asset(
                      "${iconsPath}calendar.png",
                      height: size.width * AppDimensions.numD035,
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD01,
                    ),
                    Text(
                      dateTimeFormatter(
                          dateTime: review.date, format: "dd MMM yyyy"),
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD028,
                          color: AppColorTheme.colorHint,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )
            ],
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.userName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          if (review.hopperCreatedAt.isNotEmpty)
                            Text(
                              "Hopper since ${dateTimeFormatter(dateTime: review.hopperCreatedAt, format: "MMM yyyy")}",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD028,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD02,
                        vertical: size.width * AppDimensions.numD02),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD025)),
                    child: Row(
                      children: [
                        Text(
                          review.ratingValue.toString(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: size.width * AppDimensions.numD01,
                        ),
                        RatingBar(
                          ratingWidget: RatingWidget(
                            empty: Image.asset("${iconsPath}ic_empty_star.png"),
                            full: Image.asset("${iconsPath}ic_full_star.png"),
                            half: Image.asset("${iconsPath}ic_half_star.png"),
                          ),
                          onRatingUpdate: (value) {},
                          itemSize: size.width * AppDimensions.numD04,
                          ignoreGestures: true,
                          itemCount: 5,
                          initialRating: review.ratingValue,
                          allowHalfRating: true,
                          itemPadding:
                              EdgeInsets.only(left: size.width * 0.003),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: size.width * AppDimensions.numD02,
              ),
              // Feature list is not in Review entity yet.
              // Assuming it's part of data model or entity.
              // If not present, I'll comment out or handle if existing.
              // The API response mapping might have 'featureList'.
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD02),
                child: Wrap(
                    children: List<Widget>.generate(review.featureList.length,
                        (idx) {
                  return Container(
                      margin: EdgeInsets.only(
                          right: size.width * 0.04, top: size.width * 0.014),
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorThemePink,
                          borderRadius:
                              BorderRadius.circular(size.width * 0.04)),
                      padding: EdgeInsets.symmetric(
                          vertical: size.width * 0.012,
                          horizontal: size.width * 0.018),
                      child: Text(
                        review.featureList[idx],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.025,
                            fontWeight: FontWeight.w600),
                      ));
                })),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD03,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD02),
                child: Text(
                  review.review,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: size.width * 0.033),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  Future<void> showBottomSheet(
      BuildContext parentContext, Size size, RatingState state) async {
    showModalBottomSheet(
        context: parentContext,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
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
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ListView(
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
                              for (var element in sortList) {
                                element.isSelected = false;
                              }
                              for (var element in filterRatingList) {
                                element.selected = false;
                              }
                              stateSetter(() {});
                              // Dispatch Clear Filter Event if needed
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

                      /// Sort Heading
                      Text(
                        AppStrings.sortText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD05,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),

                      // Using existing common widget logic for sortList
                      // Adapt filterListWidget or re-implement simple list
                      filterListWidget(
                          context, sortList, stateSetter, size, true),

                      SizedBox(
                        height: size.width * AppDimensions.numD05,
                      ),

                      Text(
                        "${AppStrings.average} ${AppStrings.ratingText}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD05,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),

                      ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                int pos = filterRatingList
                                    .indexWhere((element) => element.selected);

                                if (pos >= 0) {
                                  filterRatingList[pos].selected = false;
                                }

                                filterRatingList[index].selected = true;
                                stateSetter(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * AppDimensions.numD02,
                                    horizontal:
                                        size.width * AppDimensions.numD01),
                                decoration: BoxDecoration(
                                    color: filterRatingList[index].selected
                                        ? Colors.grey.shade400
                                        : Colors.transparent),
                                child: Row(
                                  children: [
                                    RatingBar(
                                      ratingWidget: RatingWidget(
                                        empty: Image.asset(
                                            "${iconsPath}ic_empty_star.png"),
                                        full: Image.asset(
                                            "${iconsPath}ic_full_star.png"),
                                        half: Image.asset(
                                            "${iconsPath}ic_half_star.png"),
                                      ),
                                      onRatingUpdate: (value) {},
                                      itemSize:
                                          size.width * AppDimensions.numD04,
                                      itemCount: 5,
                                      ignoreGestures: true,
                                      initialRating:
                                          filterRatingList[index].ratingValue,
                                      allowHalfRating: true,
                                      itemPadding: EdgeInsets.only(
                                          left: size.width * 0.008),
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD02,
                                    ),
                                    Text(
                                      "${AppStrings.andText} up",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize:
                                              size.width * AppDimensions.numD04,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: size.width * AppDimensions.numD04,
                            );
                          },
                          itemCount: filterRatingList.length),

                      /// Filter Media Houses
                      SizedBox(
                        height: size.width * AppDimensions.numD05,
                      ),

                      Text(
                        "${AppStrings.filterText} ${AppStrings.publicationsText}",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD05,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),

                      // Using mediaHouses from state to populate filterList if not already done
                      // Or just render mediaHouses directly here
                      SizedBox(height: size.width * AppDimensions.numD02),
                      Wrap(
                        spacing: size.width * AppDimensions.numD02,
                        runSpacing: size.width * AppDimensions.numD02,
                        children: state.mediaHouses.map((mediaHouse) {
                          bool isSelected = false; // Implement selection logic
                          return FilterChip(
                              label: Text(mediaHouse.name),
                              selected: isSelected,
                              onSelected: (val) {
                                stateSetter(() {});
                              });
                        }).toList(),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD02),
                    child: SizedBox(
                      width: double.infinity,
                      height: size.width * AppDimensions.numD14,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD02),
                          ),
                        ),
                        onPressed: () {
                          // Apply filters
                          // Construct filter map
                          Map<String, dynamic> filters = {};
                          // Add filter logic
                          parentContext
                              .read<RatingBloc>()
                              .add(RatingFilterUpdated(filters));
                          context.pop();
                        },
                        child: Text(
                          "Show Results",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * AppDimensions.numD045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  Widget filterListWidget(BuildContext context, List<FilterModel> list,
      StateSetter stateSetter, Size size, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: size.width * AppDimensions.numD02),
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
              } else {
                int pos = list.indexWhere((element) => element.isSelected);
                if (pos != -1) {
                  list[pos].isSelected = false;
                }
              }
              // Clear other lists selection if needed, or just manage current list
              // In FeedScreen it clears both, here we might want similar behavior or just single selection
              filterList.indexWhere((element) => element.isSelected = false);
            }
            sortList.indexWhere((element) => element.isSelected = false);

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
} // End of State class
