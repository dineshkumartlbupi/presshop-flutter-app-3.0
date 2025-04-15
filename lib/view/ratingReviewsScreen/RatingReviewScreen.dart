import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/view/ratingReviewsScreen/ratingReviewsDataModel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/CommonModel.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../dashboard/Dashboard.dart';
import '../menuScreen/PublicationListScreen.dart';
import '../publishContentScreen/TutorialsScreen.dart';

class RatingReviewScreen extends StatefulWidget {
  const RatingReviewScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return RatingReviewScreenState();
  }
}

class RatingReviewScreenState extends State<RatingReviewScreen> implements NetworkResponse {
  ScrollController listController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  int _offset = 0;
  String selectedType = receivedText;
  bool showData = false;
  List<CategoryDataModel> priceTipsCategoryList = [];
  List<RatingReviewData> ratingReviewList = [];
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  List<FilterRatingData> filterRatingList = [];

  @override
  void initState() {
    initializeFilter();
    super.initState();
    priceTipsCategoryList.add(CategoryDataModel(name: receivedText, selected: true, id: '', type: '', percentage: ''));
    priceTipsCategoryList.add(CategoryDataModel(name: givenText, selected: false, id: '', type: '', percentage: ''));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callGetAllRatingReview('');
      callMediaHouseList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "$ratingText & $reviewText",
          style: TextStyle(color: Colors.black, fontSize: size.width * appBarHeadingFontSize),
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
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
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
        child: showData
            ? Column(
                children: [
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
                    child: Row(
                      children: [
                        Text(
                          "$ratingText & $reviewText GIVEN".toUpperCase(),
                          style: commonTextStyle(size: size, fontSize: size.width * numD036, color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        // InkWell(
                        //     onTap: () {
                        //       showBottomSheet(size);
                        //     },
                        //     child: Container(
                        //         padding: EdgeInsets.all(size.width * numD04),
                        //         child: Image.asset(
                        //           "${iconsPath}ic_filter.png",
                        //           height: size.width * numD05,
                        //         )))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Flexible(
                      child: ratingReviewList.isNotEmpty
                          ? SmartRefresher(
                              controller: _refreshController,
                              enablePullDown: true,
                              enablePullUp: true,
                              onRefresh: _onRefresh,
                              onLoading: _onLoading,
                              child: ListView.separated(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD02),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: size.width * numD03, vertical: size.width * numD04),
                                      decoration: BoxDecoration(color: colorLightGrey, borderRadius: BorderRadius.circular(size.width * numD04)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                                                height: size.width * numD20,
                                                width: size.width * numD20,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(size.width * numD04), boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade200,
                                                    blurRadius: 1,
                                                  )
                                                ]),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(size.width * numD04),
                                                  child: CachedNetworkImage(
                                                      imageUrl: avatarImageUrl + ratingReviewList[index].hopperImage,
                                                      imageBuilder: (context, imageProvider) => Container(
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                image: imageProvider,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                                      errorWidget: (context, url, error) => Container(
                                                            height: size.width * numD20,
                                                            width: size.width * numD20,
                                                            decoration: BoxDecoration(color: colorGreyChat.withOpacity(.3), borderRadius: BorderRadius.circular(size.width * numD03)),
                                                          )),
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.width * 0.02,
                                              ),
                                              Container(
                                                  padding: EdgeInsets.symmetric(vertical: size.width * numD016, horizontal: size.width * numD016),
                                                  width: size.width * numD20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(.1),
                                                    borderRadius: BorderRadius.circular(size.width * numD02),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Total Earning",
                                                        style: TextStyle(color: Colors.black, fontSize: size.width * 0.02, fontWeight: FontWeight.w400),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      Text(
                                                        "£${formatDouble(double.parse(ratingReviewList[index].totalEarning))}",
                                                        style: TextStyle(color: Colors.black, fontSize: size.width * 0.026, fontWeight: FontWeight.w700),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: size.width * 0.02,
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "${iconsPath}ic_clock.png",
                                                    height: size.width * numD036,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * numD01,
                                                  ),
                                                  Text(
                                                    dateTimeFormatter(dateTime: ratingReviewList[index].time, format: "hh:mm a"),
                                                    style: commonTextStyle(size: size, fontSize: size.width * numD028, color: colorHint, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: size.width * 0.02,
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "${iconsPath}calendar.png",
                                                    height: size.width * numD035,
                                                  ),
                                                  SizedBox(
                                                    width: size.width * numD01,
                                                  ),
                                                  Text(
                                                    dateTimeFormatter(dateTime: ratingReviewList[index].date, format: "dd MMM yyyy"),
                                                    style: commonTextStyle(size: size, fontSize: size.width * numD028, color: colorHint, fontWeight: FontWeight.bold),
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
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: size.width * numD02),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          ratingReviewList[index].userName.toUpperCase(),
                                                          style: commonTextStyle(size: size, fontSize: size.width * numD04, color: Colors.black, fontWeight: FontWeight.bold),
                                                        ),
                                                        Text(
                                                          "Hopper since ${dateTimeFormatter(dateTime: ratingReviewList[index].hopperCreatedAt, format: "MMM yyyy")}",
                                                          style: commonTextStyle(size: size, fontSize: size.width * numD028, color: Colors.grey, fontWeight: FontWeight.w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: size.width * numD02, vertical: size.width * numD02),
                                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(size.width * numD025)),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          ratingReviewList[index].ratingValue.toString(),
                                                          style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.bold),
                                                        ),
                                                        SizedBox(
                                                          width: size.width * numD01,
                                                        ),
                                                        RatingBar(
                                                          ratingWidget: RatingWidget(
                                                            empty: Image.asset("${iconsPath}ic_empty_star.png"),
                                                            full: Image.asset("${iconsPath}ic_full_star.png"),
                                                            half: Image.asset("${iconsPath}ic_half_star.png"),
                                                          ),
                                                          onRatingUpdate: (value) {},
                                                          itemSize: size.width * numD04,
                                                          ignoreGestures: true,
                                                          itemCount: 5,
                                                          initialRating: ratingReviewList[index].ratingValue.isNotEmpty ? double.parse(ratingReviewList[index].ratingValue.toString()) : 0.0,
                                                          allowHalfRating: true,
                                                          itemPadding: EdgeInsets.only(left: size.width * 0.003),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: size.width * numD02,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: size.width * numD02),
                                                child: Wrap(
                                                    children: List<Widget>.generate(ratingReviewList[index].featureList.length, (int idx) {
                                                  return Container(
                                                      margin: EdgeInsets.only(right: size.width * 0.04, top: size.width * 0.014),
                                                      decoration: BoxDecoration(color: colorThemePink, borderRadius: BorderRadius.circular(size.width * 0.04)),
                                                      padding: EdgeInsets.symmetric(vertical: size.width * 0.012, horizontal: size.width * 0.018),
                                                      child: Text(
                                                        ratingReviewList[index].featureList[idx],
                                                        style: TextStyle(color: Colors.white, fontSize: size.width * 0.025, fontWeight: FontWeight.w600),
                                                      ));
                                                })),
                                              ),
                                              SizedBox(
                                                height: size.width * numD03,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: size.width * numD02),
                                                child: Text(
                                                  ratingReviewList[index].review,
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: size.width * 0.033),
                                                ),
                                              )
                                            ],
                                          ))
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      height: size.width * numD06,
                                    );
                                  },
                                  itemCount: ratingReviewList.length),
                            )
                          : errorMessageWidget("Data Not Available")),
                ],
              )
            : showLoader(),
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset = 0;
      showData = false;
      ratingReviewList.clear();
      callGetAllRatingReview(selectedType);
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset += 10;
      callGetAllRatingReview(selectedType);
    });
    _refreshController.loadComplete();
  }

  void initializeFilter() {
    sortList.addAll([
      FilterModel(name: viewWeeklyText, icon: "ic_weekly_calendar.png", isSelected: false),
      FilterModel(name: viewMonthlyText, icon: "ic_monthly_calendar.png", isSelected: false),
      FilterModel(name: viewYearlyText, icon: "ic_yearly_calendar.png", isSelected: false),
      FilterModel(name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
    ]);
    filterRatingList.addAll([
      FilterRatingData(ratingValue: 5.0, selected: false),
      FilterRatingData(ratingValue: 4.0, selected: false),
      FilterRatingData(ratingValue: 3.0, selected: false),
      FilterRatingData(ratingValue: 2.0, selected: false),
      FilterRatingData(ratingValue: 1.0, selected: false),
    ]);
    /*filterList.addAll([
            FilterModel(name: "Reuters", icon: "ic_sold.png", isSelected: false),
            FilterModel(
                name: "Daily Mail", icon: "ic_live_content.png", isSelected: false),
            FilterModel(
                name: "Daily Mirror",
                icon: "ic_payment_reviced.png",
                isSelected: false),
            FilterModel(name: "The Sun", icon: "ic_pending.png", isSelected: false),
            FilterModel(
                name: "The Times", icon: "ic_exclusive.png", isSelected: false),
          ]);*/
  }

  Future<void> showBottomSheet(size) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.white,
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
                            style: commonTextStyle(size: size, fontSize: size.width * appBarHeadingFontSizeNew, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              sortList.clear();
                              filterRatingList.indexWhere((element) => element.selected = false);
                              initializeFilter();
                              stateSetter(() {});
                            },
                            child: Text(
                              "Clear all",
                              style: TextStyle(color: colorThemePink, fontWeight: FontWeight.w400, fontSize: size.width * numD035),
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
                        style: commonTextStyle(size: size, fontSize: size.width * numD05, color: Colors.black, fontWeight: FontWeight.w500),
                      ),

                      filterListWidget(context, sortList, stateSetter, size, true),
                      SizedBox(
                        height: size.width * numD05,
                      ),

                      Text(
                        "$average $ratingText",
                        style: commonTextStyle(size: size, fontSize: size.width * numD05, color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: size.width * numD04,
                      ),

                      ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                int pos = filterRatingList.indexWhere((element) => element.selected);

                                if (pos >= 0) {
                                  filterRatingList[pos].selected = false;
                                }

                                filterRatingList[index].selected = true;
                                stateSetter(() {});
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: size.width * numD02, horizontal: size.width * numD01),
                                decoration: BoxDecoration(color: filterRatingList[index].selected ? Colors.grey.shade400 : Colors.transparent),
                                child: Row(
                                  children: [
                                    RatingBar(
                                      ratingWidget: RatingWidget(
                                        empty: Image.asset("${iconsPath}ic_empty_star.png"),
                                        full: Image.asset("${iconsPath}ic_full_star.png"),
                                        half: Image.asset("${iconsPath}ic_half_star.png"),
                                      ),
                                      onRatingUpdate: (value) {},
                                      itemSize: size.width * numD04,
                                      itemCount: 5,
                                      ignoreGestures: true,
                                      initialRating: filterRatingList[index].ratingValue,
                                      allowHalfRating: true,
                                      itemPadding: EdgeInsets.only(left: size.width * 0.008),
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Text(
                                      "$andText up",
                                      style: commonTextStyle(size: size, fontSize: size.width * numD04, color: Colors.black, fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: size.width * numD04,
                            );
                          },
                          itemCount: 5),

                      /// Filter
                      SizedBox(
                        height: size.width * numD05,
                      ),

                      /// Filter Heading
                      Text(
                        "$filterText $publicationsText",
                        style: commonTextStyle(size: size, fontSize: size.width * numD05, color: Colors.black, fontWeight: FontWeight.w500),
                      ),

                      filterListWidget(context, filterList, stateSetter, size, false),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: size.width * numD02),
                    child: Container(
                      width: size.width,
                      height: size.width * numD13,
                      margin: EdgeInsets.symmetric(horizontal: size.width * numD04),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: commonElevatedButton(applyText, size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () {
                        Navigator.pop(context);
                        callGetAllRatingReview(selectedType);
                      }),
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget filterListWidget(BuildContext context, List<FilterModel> list, StateSetter stateSetter, size, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: size.width * numD02),
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
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.only(
              top: list[index].name == filterDateText ? size.width * 0 : size.width * numD025,
              bottom: list[index].name == filterDateText ? size.width * 0 : size.width * numD025,
              left: size.width * numD02,
              right: size.width * numD02,
            ),
            color: list[index].isSelected ? Colors.grey.shade400 : null,
            child: Row(
              children: [
                list[index].icon.isNotEmpty
                    ? list[index].icon.contains('https')
                        ? Image.network(list[index].icon,
                            height: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                            width: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                            errorBuilder: (context, i, d) => Image.asset(
                                  "${dummyImagePath}news.png",
                                  height: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                                  width: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                                ))
                        : Image.asset(
                            "$iconsPath${list[index].icon}",
                            color: Colors.black,
                            height: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                            width: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                            errorBuilder: (context, i, d) => Image.asset(
                              "${dummyImagePath}news.png",
                              height: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                              width: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                            ),
                          )
                    : Container(),
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
                              int pos = list.indexWhere((element) => element.isSelected);
                              if (pos != -1) {
                                list[pos].isSelected = false;
                              }
                              item.isSelected = !item.isSelected;
                              stateSetter(() {});
                              setState(() {});
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
                                borderRadius: BorderRadius.circular(size.width * numD04),
                                border: Border.all(width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.fromDate != null ? dateTimeFormatter(dateTime: item.fromDate.toString()) : fromText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.w400),
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
                                  DateTime parseFromDate = DateTime.parse(item.fromDate!);
                                  DateTime parseToDate = DateTime.parse(pickedDate);

                                  debugPrint("parseFromDate : $parseFromDate");
                                  debugPrint("parseToDate : $parseToDate");

                                  if (parseToDate.isAfter(parseFromDate) || parseToDate.isAtSameMomentAs(parseFromDate)) {
                                    item.toDate = pickedDate;
                                  } else {
                                    showSnackBar("Date Error", "Please select to date above from date", Colors.red);
                                  }
                                }
                              }
                              stateSetter(() {});
                              setState(() {});
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
                                borderRadius: BorderRadius.circular(size.width * numD04),
                                border: Border.all(width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.toDate != null ? dateTimeFormatter(dateTime: item.toDate.toString()) : toText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.w400),
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
                    : Text(item.name,
                        style: TextStyle(
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ))
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

  /// API Section
  callGetAllRatingReview(String ratingType) {
    debugPrint("ratingType =====> $ratingType");
    Map<String, String> map = {
      "limit": "10",
      "offset": _offset.toString(),
      "type": ratingType,
    };

    /// Short
    int pos = sortList.indexWhere((element) => element.isSelected);
    if (pos != -1) {
      if (sortList[pos].name == filterDateText) {
        map["startdate"] = sortList[pos].fromDate!;
        map["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == viewMonthlyText) {
        map["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        map["posted_date"] = "365";
      } else if (sortList[pos].name == viewWeeklyText) {
        map["posted_date"] = "7";
      }
    }

    /// Filter
    for (var element in filterList) {
      if (element.isSelected) {
        map['publication'] = element.id ?? "";
      }
    }

    for (var element in filterRatingList) {
      if (element.selected) {
        switch (element.ratingValue.toString()) {
          case '5.0':
            map["rating"] = '5';
            break;

          case '4.0':
            map["startrating"] = '4';
            map["endrating"] = '5';
            break;

          case '3.0':
            map["startrating"] = '3';
            map["endrating"] = '4';
            break;
          case '2.0':
            map["startrating"] = '2';
            map["endrating"] = '3';
            break;
          case '1.0':
            map["startrating"] = '1';
            map["endrating"] = '2';
            break;
        }
      }
    }

    NetworkClass(getAllRatingAPI, this, reqGetAllRatingAPI).callRequestServiceHeader(false, 'get', map);
  }

  /// Media House
  callMediaHouseList() {
    NetworkClass(getMediaHouseDetailAPI, this, reqGetMediaHouseDetailAPI).callRequestServiceHeader(false, 'get', {});
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetAllRatingAPI:
          debugPrint("reqGetAllRatingAPI_errorResponse===> ${jsonDecode(response)}");
          break;
        case reqGetMediaHouseDetailAPI:
          debugPrint("Error response===> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("error Exception==> $e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetAllRatingAPI:
          debugPrint("reqGetAllRatingAPI_successResponse===> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var listModel = data["resp"] as List;
          ratingReviewList = listModel.map((e) => RatingReviewData.fromJson(e)).toList();

          /*       if (list.isNotEmpty) {
              _refreshController.loadComplete();
            } else if (list.isEmpty) {
              _refreshController.loadNoData();
            } else {
              _refreshController.loadFailed();
            }

            if (_offset == 0) {
              ratingReviewList.clear();
            }
*/

          showData = true;
          setState(() {});
          break;
        case reqGetMediaHouseDetailAPI:
          debugPrint("success response===> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['response'] as List;
          filterList.clear();
          var mediaHouseDataList = dataList.map((e) => PublicationDataModel.fromJson(e)).toList();
          for (var element in mediaHouseDataList) {
            filterList.add(FilterModel(
              name: element.companyName.isNotEmpty ? element.companyName.toCapitalized() : element.publicationName,
              icon: element.companyProfile,
              id: element.id,
              isSelected: false,
            ));
          }
          setState(() {});
      }
    } on Exception catch (e) {
      debugPrint("error Exception==> $e");
    }
  }

}
