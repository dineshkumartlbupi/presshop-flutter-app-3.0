import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/view/myEarning/TransactionDetailScreen.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../myEarning/earningDataModel.dart';

class PublicationListScreen extends StatefulWidget {
  String contentId = "";
  String contentType = "";
  String publicationCount = "";

  PublicationListScreen(
      {super.key,
      required this.contentId,
      required this.publicationCount,
      required this.contentType});

  @override
  State<PublicationListScreen> createState() => _PublicationListScreenState();
}

class _PublicationListScreenState extends State<PublicationListScreen>
    implements NetworkResponse {
  late Size size;
  final currencyFormat = NumberFormat("#,##0.00", "en_US");

  String publicationCount = "";
  String totalEarning = "";
  String fromDate = "";
  String toDate = "";
  String totalPublicationAmount = "";

  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  List<EarningTransactionDetail> publicationTransactionList = [];
  EarningProfileDataModel? earningData;

  @override
  void initState() {
    initializeFilter();

    publicationCount = widget.publicationCount;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callGEtEarningDataAPI();
      callMediaHouseList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          publicationsListText,
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
              showBottomSheet(size);
            },
            child: commonFilterIcon(size),
          )
        ],
      ),
      body: earningData != null
          ? ListView(
              padding: EdgeInsets.only(
                left: size.width * numD06,
                right: size.width * numD06,
              ),
              children: [
                /// My Earnings
                Container(
                  padding: EdgeInsets.all(size.width * numD05),
                  decoration: BoxDecoration(
                      color: colorLightGrey,
                      borderRadius: BorderRadius.circular(size.width * numD05)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1.2, color: Colors.black),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      avatarImageUrl + earningData!.avatar,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    height: size.width * numD32,
                                    width: size.width * numD35,
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
                                    "${dummyImagePath}walk1.png",
                                    fit: BoxFit.cover,
                                    height: size.width * numD32,
                                    width: size.width * numD35,
                                  ),
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: size.width * numD06),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  publicationsText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  publicationCount.isNotEmpty
                                      ? publicationCount
                                      : '0',
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD08,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w800),
                                ),
                                SizedBox(
                                  height: size.width * numD01,
                                ),
                                Text(
                                  youHaveEarnedText,
                                  //"Total amount",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                                FittedBox(
                                  child: Text(
                                    totalPublicationAmount.isNotEmpty
                                        ? "£${formatDouble(double.parse(totalPublicationAmount))}"
                                        : '£0',
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD075,
                                        color: colorThemePink,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.width * numD03,
                      ),
                      widget.contentType == "exclusive"
                          ? Container()
                          : Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      fromDate = await commonDatePicker() ?? "";
                                      toDate = '';
                                      sortList[4].fromDate = fromDate;
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: size.width * numD02,
                                        horizontal: size.width * numD02,
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.2, color: Colors.black),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD02)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            fromDate.isNotEmpty
                                                ? dateTimeFormatter(
                                                    dateTime:
                                                        fromDate.toString())
                                                : "From date",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD035,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
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
                                  width: size.width * numD05,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      if (fromDate.isNotEmpty) {
                                        toDate = await commonDatePicker() ?? '';
                                        if (toDate.isNotEmpty) {
                                          DateTime parseFromDate =
                                              DateTime.parse(fromDate);
                                          DateTime parseToDate =
                                              DateTime.parse(toDate);
                                          debugPrint(
                                              "parseFromDate : $parseFromDate");
                                          debugPrint(
                                              "parseToDate : $parseToDate");

                                          if (parseToDate
                                                  .isAfter(parseFromDate) ||
                                              parseToDate.isAtSameMomentAs(
                                                  parseFromDate)) {
                                            sortList.indexWhere((element) =>
                                                element.isSelected = false);
                                            sortList[4].toDate = toDate;
                                            sortList[4].isSelected = true;
                                            callGetAllTransactionDetail();
                                          } else {
                                            showSnackBar(
                                                "Date Error",
                                                "Please select to date above from date",
                                                Colors.red);
                                          }
                                        }
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: size.width * numD02,
                                        horizontal: size.width * numD02,
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1.2, color: Colors.black),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD02)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            toDate.isNotEmpty
                                                ? dateTimeFormatter(
                                                    dateTime: toDate.toString())
                                                : "To date",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD035,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700),
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
                  height: size.width * numD04,
                ),

                Text(
                  publicationsListHeadingText,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),

                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.5,
                ),

                SizedBox(
                  height: size.width * numD04,
                ),

                paymentReceivedWidget(),

                SizedBox(
                  height: size.width * numD04,
                ),
              ],
            )
          : Container(),
    );
  }

  Widget paymentReceivedWidget() {
    return publicationTransactionList.isNotEmpty
        ? ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var item = publicationTransactionList[index];
              return item.paidStatus
                  ? Container(
                      padding: EdgeInsets.only(
                        top: size.width * numD05,
                        bottom: size.width * numD025,
                        left: size.width * numD05,
                        right: size.width * numD05,
                      ),
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius:
                              BorderRadius.circular(size.width * numD02)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * numD01,
                                    horizontal: size.width * numD04),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD015),
                                    border: Border.all(
                                        color: colorGrey3, width: 1)),
                                child: Text(
                                  item.payableT0Hopper.isNotEmpty
                                      ? "£${currencyFormat.format(double.parse(item.payableT0Hopper))}"
                                      : "£0",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD04,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    item.typesOfContent
                                        ? "${iconsPath}ic_exclusive.png"
                                        : "${iconsPath}ic_share.png",
                                    height: item.typesOfContent ? size.width * numD075 : size.width * numD07,
                                    width: size.width * numD09,
                                    color: colorTextFieldIcon,
                                  ),
                                  SizedBox(
                                    width: size.width * numD03,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(size.width * numD03),
                                    child: CachedNetworkImage(
                                      imageUrl: item.contentImage,
                                      height: size.width * numD11,
                                      width: size.width * numD12,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Image.asset(
                                        "assets/dummyImages/placeholderImage.png",
                                        fit: BoxFit.cover,
                                        height: size.width * numD11,
                                        width: size.width * numD12,
                                      ),
                                      errorWidget: (context, url, error) => Image.asset(
                                        "assets/commonImages/no_image.jpg",
                                        fit: BoxFit.cover,
                                        height: size.width * numD11,
                                        width: size.width * numD12,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * numD03,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD03),
                                    child: Image.network(item.companyLogo,
                                        height: size.width * numD11,
                                        width: size.width * numD12,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, i, b) =>
                                            Image.asset(
                                              "${dummyImagePath}news.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD11,
                                              width: size.width * numD12,
                                            )),
                                  )
                                ],
                              ),
                            ],
                          ),

                          /// Payment Detail
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  paymentDetailText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.createdAT,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Payment made time
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  paymentMadeTimeText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  dateTimeFormatter(
                                      dateTime: item.createdAT,
                                      time: true,
                                      format: "hh:mm a"),
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Transaction ID
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  transactionIdText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.id,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Divider
                          Padding(
                            padding: EdgeInsets.only(
                              top: size.width * numD01,
                            ),
                            child: const Divider(
                              color: Colors.white,
                              thickness: 1.5,
                            ),
                          ),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            type: "received",
                                            transactionData:
                                                publicationTransactionList[
                                                    index],
                                          )));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "View transaction details",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                  size: size.width * numD045,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(
                        top: size.width * numD05,
                        bottom: size.width * numD025,
                        left: size.width * numD05,
                        right: size.width * numD05,
                      ),
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius:
                              BorderRadius.circular(size.width * numD02)),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: size.width * numD01,
                                    horizontal: size.width * numD04),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorThemePink,
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD015),
                                ),
                                child: Text(
                                  item.amount.isNotEmpty
                                      ? "£${currencyFormat.format(double.parse(item.payableT0Hopper))}"
                                      : "",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD04,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    item.typesOfContent
                                        ? "${iconsPath}ic_exclusive.png"
                                        : "${iconsPath}ic_share.png",
                                    height: item.typesOfContent
                                        ? size.width * numD03
                                        : size.width * numD04,
                                    color: colorTextFieldIcon,
                                  ),
                                  SizedBox(
                                    width: size.width * numD03,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD03),
                                    child: Image.network(item.companyLogo,
                                        height: size.width * numD11,
                                        width: size.width * numD12,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, i, b) =>
                                            Image.asset(
                                              "${dummyImagePath}news.png",
                                              fit: BoxFit.cover,
                                              height: size.width * numD11,
                                              width: size.width * numD12,
                                            )),
                                  )
                                ],
                              ),
                            ],
                          ),

                          /// Your earnings
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD04),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Content Sold',
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.totalEarningAmt != "null"
                                      ? "£${formatDouble(double.parse(item.totalEarningAmt))}"
                                      : "0",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// PressHop fees
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  presshopCommissionText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.payableCommission.isNotEmpty
                                      ? "£${formatDouble(double.parse(item.percentage))}"
                                      : "",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  processingFeeText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.payableCommission.isNotEmpty
                                      ? "£${formatDouble(double.parse(item.stripefee))}"
                                      : "",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Amount pending
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  amountPendingText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  item.amount.isNotEmpty
                                      ? "£${formatDouble(double.parse(item.payableT0Hopper))}"
                                      : "",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Payment due date
                          Padding(
                            padding: EdgeInsets.only(top: size.width * numD02),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  paymentDueDateText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  dateTimeFormatter(
                                      dateTime: item.dueDate,
                                      format: "dd MMM yyyy"),
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),

                          /// Divider
                          Padding(
                            padding: EdgeInsets.only(
                              top: size.width * numD01,
                            ),
                            child: const Divider(
                              color: Colors.white,
                              thickness: 1.5,
                            ),
                          ),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            type: "pending",
                                            transactionData:
                                                publicationTransactionList[
                                                    index],
                                          )));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "View transaction details",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w700),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Colors.black,
                                  size: size.width * numD045,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: size.width * numD05,
              );
            },
            itemCount: publicationTransactionList.length)
        : Container();
  }

  initializeFilter() {
    sortList.addAll([
      FilterModel(
          name: "View first payment received",
          icon: "ic_up.png",
          isSelected: false),
      FilterModel(
          name: "View last payment received",
          icon: "ic_down.png",
          isSelected: false),
      FilterModel(
          name: "View highest payment received",
          icon: "ic_graph_up.png",
          isSelected: false),
      FilterModel(
          name: "View lowest payment received",
          icon: "ic_graph_down.png",
          isSelected: false),
      FilterModel(
          name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
    ]);
  }

  Future<void> showBottomSheet(Size size) async {
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
                            filterList.indexWhere(
                                (element) => element.isSelected = false);
                            fromDate = "";
                            toDate = "";
                            sortList.clear();
                            initializeFilter();
                            callGetAllTransactionDetail();
                            stateSetter(() {});
                            setState(() {});
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
                      height: size.width * numD05,
                    ),

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
                        callGetAllTransactionDetail();
                      }),
                    ),

                    SizedBox(
                      height: size.width * numD04,
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
    return SizedBox(
      height: size.height * numD30,
      child: ListView.separated(
        padding: EdgeInsets.only(top: size.width * numD03),
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
                filterList.indexWhere((element) => element.isSelected = false);
              }
              sortList.indexWhere((element) => element.isSelected = false);

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
              color: list[index].isSelected ? Colors.grey.shade400 : null,
              child: Row(
                children: [
                  list[index].icon.isNotEmpty
                      ? list[index].icon.contains('https')
                          ? Image.network(list[index].icon,
                              height: list[index].name == soldContentText
                                  ? size.width * numD06
                                  : size.width * numD05,
                              width: list[index].name == soldContentText
                                  ? size.width * numD06
                                  : size.width * numD05,
                              errorBuilder: (context, i, d) => Image.asset(
                                    "${dummyImagePath}news.png",
                                    height: list[index].name == soldContentText
                                        ? size.width * numD06
                                        : size.width * numD05,
                                    width: list[index].name == soldContentText
                                        ? size.width * numD06
                                        : size.width * numD05,
                                  ))
                          : Image.asset(
                              "$iconsPath${list[index].icon}",
                              color: Colors.black,
                              height: list[index].name == soldContentText
                                  ? size.width * numD06
                                  : size.width * numD05,
                              width: list[index].name == soldContentText
                                  ? size.width * numD06
                                  : size.width * numD05,
                              errorBuilder: (context, i, d) => Image.asset(
                                "${dummyImagePath}news.png",
                                height: list[index].name == soldContentText
                                    ? size.width * numD06
                                    : size.width * numD05,
                                width: list[index].name == soldContentText
                                    ? size.width * numD06
                                    : size.width * numD05,
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
                                int pos = list.indexWhere(
                                    (element) => element.isSelected);
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
                                  top: size.width * numD01,
                                  bottom: size.width * numD01,
                                  left: size.width * numD03,
                                  right: size.width * numD01,
                                ),
                                width: size.width * numD32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
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
                                              dateTime:
                                                  item.fromDate.toString())
                                          : fromText,
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

                                  if (pickedDate != null) {
                                    DateTime parseFromDate =
                                        DateTime.parse(item.fromDate!);
                                    DateTime parseToDate =
                                        DateTime.parse(pickedDate);

                                    debugPrint(
                                        "parseFromDate : $parseFromDate");
                                    debugPrint("parseToDate : $parseToDate");

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
                                  top: size.width * numD01,
                                  bottom: size.width * numD01,
                                  left: size.width * numD03,
                                  right: size.width * numD01,
                                ),
                                width: size.width * numD32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
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
                                          : toText,
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
      ),
    );
  }

/*
  void transactionShortByDate() {
    fromDate = DateTime.now().subtract(const Duration(days: 7)).toString();
    toDate = DateTime.now().toString();
    sortList[3].toDate = toDate;
    sortList[3].fromDate = fromDate;
    sortList[3].isSelected = true;
    callGetAllTransactionDetail();
    setState(() {});
  }
*/

  /// API Section
  callGEtEarningDataAPI() {
    Map<String, String> map = {'type': 'publication'};
    NetworkClass(getEarningDataAPI, this, reqGetEarningDataAPI)
        .callRequestServiceHeader(true, 'get', map);
  }

  callGetAllTransactionDetail() {
    Map<String, dynamic> map = {
      "content_id": widget.contentId,
/*      "limit": limit.toString(),
      "offset": offset.toString()*/
    };
    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      if (sortList[pos].fromDate != null) {
        map["startdate"] = sortList[pos].fromDate!.trim();
        map["endDate"] = sortList[pos].toDate!.trim();
      } else if (sortList[pos].name == 'View first payment received') {
        map["firstpaymentrecived"] = 'true';
      } else if (sortList[pos].name == 'View last payment received') {
        map["firstpaymentrecived"] = 'false';
      } else if (sortList[pos].name == 'View highest payment received') {
        map["highpaymentrecived"] = 'true';
      } else if (sortList[pos].name == 'View lowest payment received') {
        map["highpaymentrecived"] = 'false';
      }
    }

    /// Filter
    for (var element in filterList) {
      if (element.isSelected) {
        map['publication'] = element.id ?? "";
      }
    }

    debugPrint('map value ==> $map');
    NetworkClass(
            getPublicationTransactionAPI, this, reqGetPublicationTransactionReq)
        .callRequestServiceHeader(true, 'get', map);
  }

  /// Media House
  callMediaHouseList() {
    NetworkClass(getMediaHouseDetailAPI, this, reqGetMediaHouseDetailAPI)
        .callRequestServiceHeader(true, 'get', {});
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetEarningDataAPI:
          debugPrint(
              "reqGetEarningDataAPI_ErrorResponse==> ${jsonDecode(response)}");
          break;
        case reqGetPublicationTransactionReq:
          debugPrint(
              "reqGetPublicationTransactionReq_ErrorResponse==> ${jsonDecode(response)}");
          break;

        case reqGetMediaHouseDetailAPI:
          debugPrint("Error response===> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("Exception catch======> $e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqGetEarningDataAPI:
          debugPrint(
              "reqGetEarningDataAPI_SuccessResponse==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['resp'];
          earningData = EarningProfileDataModel.fromJson(dataList);
          callGetAllTransactionDetail();
          setState(() {});
          // transactionShortByDate();
          break;

        case reqGetPublicationTransactionReq:
          debugPrint(
              "reqGetPublicationTransactionReq_successResponse==> ${jsonDecode(response)}");
          var data = jsonDecode(response);

          var dataList = data['data'] as List;
          publicationCount = data['countofmediahouse'].toString();
          totalPublicationAmount = data['amount'].toString();
          publicationTransactionList = dataList
              .map((e) => EarningTransactionDetail.fromJson(e))
              .toList();
          if (earningData != null) {
            for (var item in publicationTransactionList) {item.hopperAvatar = earningData?.avatar ?? "";}
          }
          setState(() {});
          break;
        case reqGetMediaHouseDetailAPI:
          debugPrint("success response===> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['response'] as List;
          filterList.clear();
          var mediaHouseDataList =
              dataList.map((e) => PublicationDataModel.fromJson(e)).toList();
          for (var element in mediaHouseDataList) {
            filterList.add(FilterModel(
              name: element.companyName.isNotEmpty
                  ? element.companyName
                  : element.publicationName,
              icon: element.companyProfile,
              id: element.id,
              isSelected: false,
            ));
          }
          setState(() {});
      }
    } on Exception catch (e) {
      debugPrint("Exception catch======> $e");
    }
  }
}

class FilterModel {
  String name = "";
  String icon = "";
  String? fromDate;
  String? toDate;
  bool isSelected = false;
  String? id = "";

  FilterModel({
    this.fromDate,
    this.toDate,
    this.id,
    required this.name,
    required this.icon,
    required this.isSelected,
  });
}
