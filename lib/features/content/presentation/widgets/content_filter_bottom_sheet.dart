import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/core_export.dart';

class ContentFilterSheet extends StatefulWidget {
  const ContentFilterSheet({
    super.key,
    required this.size,
    required this.sortList,
    required this.filterList,
    required this.onApply,
    required this.onClear,
  });
  final Size size;
  final List<FilterModel> sortList;
  final List<FilterModel> filterList;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  State<ContentFilterSheet> createState() => _ContentFilterSheetState();
}

class _ContentFilterSheetState extends State<ContentFilterSheet> {
  @override
  Widget build(BuildContext context) {
    final double scalingWidth = isIpad ? 550 : widget.size.width;

    return Padding(
      padding: EdgeInsets.only(
        top: scalingWidth * AppDimensions.numD06,
        left: scalingWidth * AppDimensions.numD05,
        right: scalingWidth * AppDimensions.numD05,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(scalingWidth),
            SizedBox(height: scalingWidth * AppDimensions.numD085),
            _buildSection(
                AppStrings.sortText, widget.sortList, true, scalingWidth),
            SizedBox(height: scalingWidth * AppDimensions.numD05),
            _buildSection(
                AppStrings.filterText, widget.filterList, false, scalingWidth),
            SizedBox(height: scalingWidth * AppDimensions.numD06),
            _buildApplyButton(scalingWidth),
            SizedBox(height: scalingWidth * AppDimensions.numD02),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double scalingWidth) {
    return Row(
      children: [
        IconButton(
          splashRadius: scalingWidth * AppDimensions.numD07,
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.close,
            color: Theme.of(context).iconTheme.color,
            size: scalingWidth * AppDimensions.numD07,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              "Sort and Filter",
              overflow: TextOverflow.ellipsis,
              style: commonTextStyle(
                  size: widget.size,
                  fontSize:
                      scalingWidth * AppDimensions.appBarHeadingFontSizeNew,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onClear,
          child: Text(
            "Clear all",
            style: TextStyle(
                color: AppColorTheme.colorThemePink,
                fontWeight: FontWeight.w400,
                fontSize: scalingWidth * AppDimensions.numD03),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      String title, List<FilterModel> list, bool isSort, double scalingWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: commonTextStyle(
              size: widget.size,
              fontSize: scalingWidth * AppDimensions.numD05,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500),
        ),
        _buildFilterList(list, isSort, scalingWidth),
      ],
    );
  }

  Widget _buildFilterList(
      List<FilterModel> list, bool isSort, double scalingWidth) {
    return ListView.separated(
      padding: EdgeInsets.only(top: scalingWidth * AppDimensions.numD03),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return InkWell(
          onTap: () => _handleItemTap(list, index, isSort),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: item.name == AppStrings.filterDateText
                  ? 0
                  : scalingWidth * AppDimensions.numD025,
              horizontal: scalingWidth * AppDimensions.numD02,
            ),
            color: item.isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade400)
                : null,
            child: Row(
              children: [
                _buildItemIcon(item, scalingWidth),
                SizedBox(width: scalingWidth * AppDimensions.numD03),
                item.name == AppStrings.filterDateText
                    ? _buildDateRow(item, list, scalingWidth)
                    : Expanded(
                        child: Text(item.name,
                            style: TextStyle(
                                fontSize:
                                    scalingWidth * AppDimensions.numD035,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.w400,
                                fontFamily: "AirbnbCereal_W_Bk")),
                      )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) =>
          SizedBox(height: scalingWidth * AppDimensions.numD01),
    );
  }

  Widget _buildItemIcon(FilterModel item, double scalingWidth) {
    return Image.asset(
      "$iconsPath${item.icon}",
      color: Theme.of(context).iconTheme.color,
      height: item.name == AppStrings.soldContentText
          ? scalingWidth * AppDimensions.numD06
          : scalingWidth * AppDimensions.numD05,
      width: item.name == AppStrings.soldContentText
          ? scalingWidth * AppDimensions.numD06
          : scalingWidth * AppDimensions.numD05,
    );
  }

  Widget _buildDateRow(
      FilterModel item, List<FilterModel> list, double scalingWidth) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDatePicker(
            scalingWidth: scalingWidth,
            label: item.fromDate != null
                ? dateTimeFormatter(dateTime: item.fromDate.toString())
                : 'From Date',
            onTap: () async {
              item.fromDate = await commonDatePicker();
              item.toDate = null;
              _selectOnly(list, item);
            },
          ),
          SizedBox(height: scalingWidth * AppDimensions.numD03),
          _buildDatePicker(
            scalingWidth: scalingWidth,
            label: item.toDate != null
                ? dateTimeFormatter(dateTime: item.toDate.toString())
                : 'To Date',
            onTap: () async {
              if (item.fromDate != null) {
                String? pickedDate = await commonDatePicker();
                if (pickedDate != null) {
                  DateTime parseFromDate = DateTime.parse(item.fromDate!);
                  DateTime parseToDate = DateTime.parse(pickedDate);
                  if (parseToDate.isAfter(parseFromDate) ||
                      parseToDate.isAtSameMomentAs(parseFromDate)) {
                    item.toDate = pickedDate;
                    setState(() {});
                  } else {
//                       showSnackBar("Date Error", "Please select to date above from date", Colors.red);
                  }
                }
              }
            },
          ),
          SizedBox(height: scalingWidth * AppDimensions.numD02),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
      {required double scalingWidth,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: scalingWidth * AppDimensions.numD01,
          horizontal: scalingWidth * AppDimensions.numD02,
        ),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(scalingWidth * AppDimensions.numD04),
          border: Border.all(width: 1, color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: commonTextStyle(
                    size: widget.size,
                    fontSize: scalingWidth * AppDimensions.numD035,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(width: scalingWidth * AppDimensions.numD015),
            Icon(
              Icons.arrow_drop_down_sharp,
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(double scalingWidth) {
    return SafeArea(
      child: Container(
        width: widget.size.width,
        height: scalingWidth * AppDimensions.numD13,
        margin: EdgeInsets.symmetric(
            horizontal: scalingWidth * AppDimensions.numD04),
        padding: EdgeInsets.symmetric(
            horizontal: scalingWidth * AppDimensions.numD04),
        child: commonElevatedButton(
          AppStrings.applyText,
          widget.size,
          commonTextStyle(
              size: widget.size,
              fontSize: scalingWidth * AppDimensions.numD035,
              color: Colors.white,
              fontWeight: FontWeight.w700),
          commonButtonStyle(widget.size, AppColorTheme.colorThemePink),
          widget.onApply,
        ),
      ),
    );
  }

  void _handleItemTap(List<FilterModel> list, int index, bool isSort) {
    setState(() {
      if (isSort) {
        for (var element in list) {
          element.isSelected = false;
          element.fromDate = null;
          element.toDate = null;
        }
      } else {
        for (var element in list) {
          element.isSelected = false;
        }
      }
      list[index].isSelected = !list[index].isSelected;
    });
  }

  void _selectOnly(List<FilterModel> list, FilterModel item) {
    setState(() {
      for (var element in list) {
        element.isSelected = false;
      }
      item.isSelected = true;
    });
  }
}
