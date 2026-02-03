import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';

class ContentFilterSheet extends StatefulWidget {
  final Size size;
  final List<FilterModel> sortList;
  final List<FilterModel> filterList;
  final VoidCallback onApply;
  final VoidCallback onClear;

  const ContentFilterSheet({
    super.key,
    required this.size,
    required this.sortList,
    required this.filterList,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<ContentFilterSheet> createState() => _ContentFilterSheetState();
}

class _ContentFilterSheetState extends State<ContentFilterSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: widget.size.width * numD06,
        left: widget.size.width * numD05,
        right: widget.size.width * numD05,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: widget.size.width * numD085),
            _buildSection(sortText, widget.sortList, true),
            SizedBox(height: widget.size.width * numD05),
            _buildSection(filterText, widget.filterList, false),
            SizedBox(height: widget.size.width * numD06),
            _buildApplyButton(),
            SizedBox(height: widget.size.width * numD02),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          splashRadius: widget.size.width * numD07,
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close,
            color: Colors.black,
            size: widget.size.width * numD07,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              "Sort and Filter",
              overflow: TextOverflow.ellipsis,
              style: commonTextStyle(
                  size: widget.size,
                  fontSize: widget.size.width * appBarHeadingFontSizeNew,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onClear,
          child: Text(
            "Clear all",
            style: TextStyle(
                color: colorThemePink,
                fontWeight: FontWeight.w400,
                fontSize: widget.size.width * numD03),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<FilterModel> list, bool isSort) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: commonTextStyle(
              size: widget.size,
              fontSize: widget.size.width * numD05,
              color: Colors.black,
              fontWeight: FontWeight.w500),
        ),
        _buildFilterList(list, isSort),
      ],
    );
  }

  Widget _buildFilterList(List<FilterModel> list, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: widget.size.width * numD03),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return InkWell(
          onTap: () => _handleItemTap(list, index, isSort),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical:
                  item.name == filterDateText ? 0 : widget.size.width * numD025,
              horizontal: widget.size.width * numD02,
            ),
            color: item.isSelected ? Colors.grey.shade400 : null,
            child: Row(
              children: [
                _buildItemIcon(item),
                SizedBox(width: widget.size.width * numD03),
                item.name == filterDateText
                    ? _buildDateRow(item, list)
                    : Expanded(
                        child: Text(item.name,
                            style: TextStyle(
                                fontSize: widget.size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontFamily: "AirbnbCereal_W_Bk")),
                      )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: widget.size.width * numD01),
    );
  }

  Widget _buildItemIcon(FilterModel item) {
    return Image.asset(
      "$iconsPath${item.icon}",
      color: Colors.black,
      height: item.name == soldContentText
          ? widget.size.width * numD06
          : widget.size.width * numD05,
      width: item.name == soldContentText
          ? widget.size.width * numD06
          : widget.size.width * numD05,
    );
  }

  Widget _buildDateRow(FilterModel item, List<FilterModel> list) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildDatePicker(
              label: item.fromDate != null
                  ? dateTimeFormatter(dateTime: item.fromDate.toString())
                  : 'From Date',
              onTap: () async {
                item.fromDate = await commonDatePicker();
                item.toDate = null;
                _selectOnly(list, item);
              },
            ),
          ),
          SizedBox(width: widget.size.width * numD03),
          Expanded(
            child: _buildDatePicker(
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
                      showSnackBar("Date Error",
                          "Please select to date above from date", Colors.red);
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
      {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: widget.size.width * numD01,
          horizontal: widget.size.width * numD02,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.size.width * numD04),
          border: Border.all(width: 1, color: const Color(0xFFDEE7E6)),
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
                    fontSize: widget.size.width * numD035,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(width: widget.size.width * numD015),
            const Icon(Icons.arrow_drop_down_sharp, color: Colors.black)
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      width: widget.size.width,
      height: widget.size.width * numD13,
      margin: EdgeInsets.symmetric(horizontal: widget.size.width * numD04),
      padding: EdgeInsets.symmetric(horizontal: widget.size.width * numD04),
      child: commonElevatedButton(
        applyText,
        widget.size,
        commonTextStyle(
            size: widget.size,
            fontSize: widget.size.width * numD035,
            color: Colors.white,
            fontWeight: FontWeight.w700),
        commonButtonStyle(widget.size, colorThemePink),
        widget.onApply,
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
