import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_filter_sheet.dart';

class FeedFilterBottomSheet extends StatefulWidget {
  const FeedFilterBottomSheet({
    super.key,
    required this.sortList,
    required this.filterList,
    required this.onApply,
    required this.onClearAll,
  });
  final List<FilterModel> sortList;
  final List<FilterModel> filterList;
  final Function(Map<String, dynamic>) onApply;
  final VoidCallback onClearAll;

  @override
  State<FeedFilterBottomSheet> createState() => _FeedFilterBottomSheetState();
}

class _FeedFilterBottomSheetState extends State<FeedFilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                  "Sort and Filter",
                  style: commonTextStyle(
                      size: size,
                      fontSize:
                          size.width * AppDimensions.appBarHeadingFontSizeNew,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    widget.onClearAll();
                    setState(() {});
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

            filterListWidget(context, widget.sortList, setState, size, true),

            /// Filter
            SizedBox(
              height: size.width * AppDimensions.numD05,
            ),

            SizedBox(
              height: size.width * AppDimensions.numD06,
            ),

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
                  commonButtonStyle(size, AppColorTheme.colorThemePink), () {
                Map<String, dynamic> map = {"limit": "10", "offset": "0"};

                int pos =
                    widget.sortList.indexWhere((element) => element.isSelected);

                if (pos >= 0) {
                  map["sort"] = widget.sortList[pos].value!;
                }

                for (var element in widget.filterList) {
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

                      case AppStrings.pendingPaymentsText:
                        map["paid_status"] = "un_paid";
                        break;
                    }
                  }
                }
                widget.onApply(map);
                context.pop();
              }),
            ),
            SizedBox(
              height: size.width * AppDimensions.numD04,
            )
          ],
        ),
      ),
    );
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
              }
              for (var f in widget.filterList) {
                f.isSelected = false;
              }
            }

            list[index].isSelected = !list[index].isSelected;
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
}
