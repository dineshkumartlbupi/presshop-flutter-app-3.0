import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/core_export.dart';

class FilterModel {
  FilterModel({
    required this.name,
    required this.icon,
    required this.isSelected,
    this.fromDate,
    this.toDate,
    this.id,
    this.value,
  });

  String name = "";
  String icon = "";
  bool isSelected = false;
  String? fromDate;
  String? toDate;
  String? id;
  String? value;
}

class CommonFilterSheet extends StatefulWidget {
  const CommonFilterSheet({
    super.key,
    required this.sortList,
    required this.filterList,
    required this.onApply,
    required this.onClear,
  });
  final List<FilterModel> sortList;
  final List<FilterModel> filterList;
  final Function(List<FilterModel>, List<FilterModel>) onApply;
  final VoidCallback onClear;

  @override
  State<CommonFilterSheet> createState() => _CommonFilterSheetState();
}

class _CommonFilterSheetState extends State<CommonFilterSheet> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * AppDimensions.numD05),
          topRight: Radius.circular(size.width * AppDimensions.numD05),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * AppDimensions.numD05,
        vertical: size.width * AppDimensions.numD05,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sort & Filter",
                style: TextStyle(
                  fontSize: size.width * AppDimensions.numD05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          SizedBox(height: size.width * AppDimensions.numD04),
          Text(
            "Sort By",
            style: TextStyle(
              fontSize: size.width * AppDimensions.numD04,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: size.width * AppDimensions.numD02),
          Wrap(
            spacing: size.width * AppDimensions.numD02,
            runSpacing: size.width * AppDimensions.numD02,
            children: widget.sortList.map((item) {
              return FilterChip(
                label: Text(item.name),
                selected: item.isSelected,
                onSelected: (selected) {
                  setState(() {
                    for (var element in widget.sortList) {
                      element.isSelected = false;
                    }
                    item.isSelected = selected;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColorTheme.colorThemePink,
                labelStyle: TextStyle(
                  color: item.isSelected ? Colors.white : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD02),
                  side: BorderSide(
                    color: item.isSelected
                        ? AppColorTheme.colorThemePink
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: size.width * AppDimensions.numD04),
          Text(
            "Filter By",
            style: TextStyle(
              fontSize: size.width * AppDimensions.numD04,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: size.width * AppDimensions.numD02),
          Wrap(
            spacing: size.width * AppDimensions.numD02,
            runSpacing: size.width * AppDimensions.numD02,
            children: widget.filterList.map((item) {
              return FilterChip(
                label: Text(item.name),
                selected: item.isSelected,
                onSelected: (selected) {
                  setState(() {
                    // For radio-like behavior in filter list if needed, or multi-select
                    for (var element in widget.filterList) {
                      element.isSelected = false;
                    }
                    item.isSelected = selected;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColorTheme.colorThemePink,
                labelStyle: TextStyle(
                  color: item.isSelected ? Colors.white : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD02),
                  side: BorderSide(
                    color: item.isSelected
                        ? AppColorTheme.colorThemePink
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: size.width * AppDimensions.numD06),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClear();
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD035),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD02),
                    ),
                  ),
                  child: Text(
                    "Clear",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * AppDimensions.numD04,
                    ),
                  ),
                ),
              ),
              SizedBox(width: size.width * AppDimensions.numD04),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(widget.sortList, widget.filterList);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD035),
                    backgroundColor: AppColorTheme.colorThemePink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD02),
                    ),
                  ),
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * AppDimensions.numD04,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
