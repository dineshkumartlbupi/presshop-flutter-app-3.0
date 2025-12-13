import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';

class FilterModel {
  
  String name = "";
  String icon = "";
  bool isSelected = false;
  String? fromDate;
  String? toDate;
  String? id;
  String? value;

  FilterModel({
    required this.name,
    required this.icon,
    required this.isSelected,
    this.fromDate,
    this.toDate, 
    this.id,
    this.value,
  });
}

class CommonFilterSheet extends StatefulWidget {
  final List<FilterModel> sortList;
  final List<FilterModel> filterList;
  final Function(List<FilterModel>, List<FilterModel>) onApply;
  final VoidCallback onClear;

  const CommonFilterSheet({
    super.key,
    required this.sortList,
    required this.filterList,
    required this.onApply,
    required this.onClear,
  });

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
          topLeft: Radius.circular(size.width * numD05),
          topRight: Radius.circular(size.width * numD05),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * numD05,
        vertical: size.width * numD05,
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
                  fontSize: size.width * numD05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          SizedBox(height: size.width * numD04),
          Text(
            "Sort By",
            style: TextStyle(
              fontSize: size.width * numD04,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: size.width * numD02),
          Wrap(
            spacing: size.width * numD02,
            runSpacing: size.width * numD02,
            children: widget.sortList.map((item) {
              return FilterChip(
                label: Text(item.name),
                selected: item.isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    for (var element in widget.sortList) {
                      element.isSelected = false;
                    }
                    item.isSelected = selected;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: colorThemePink,
                labelStyle: TextStyle(
                  color: item.isSelected ? Colors.white : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * numD02),
                  side: BorderSide(
                    color: item.isSelected ? colorThemePink : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: size.width * numD04),
          Text(
            "Filter By",
            style: TextStyle(
              fontSize: size.width * numD04,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: size.width * numD02),
          Wrap(
            spacing: size.width * numD02,
            runSpacing: size.width * numD02,
            children: widget.filterList.map((item) {
              return FilterChip(
                label: Text(item.name),
                selected: item.isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    // For radio-like behavior in filter list if needed, or multi-select
                     for (var element in widget.filterList) {
                      element.isSelected = false;
                    }
                    item.isSelected = selected;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: colorThemePink,
                labelStyle: TextStyle(
                  color: item.isSelected ? Colors.white : Colors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * numD02),
                  side: BorderSide(
                    color: item.isSelected ? colorThemePink : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: size.width * numD06),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: size.width * numD035),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * numD02),
                    ),
                  ),
                  child: Text(
                    "Clear",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * numD04,
                    ),
                  ),
                ),
              ),
              SizedBox(width: size.width * numD04),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(widget.sortList, widget.filterList);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: size.width * numD035),
                    backgroundColor: colorThemePink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * numD02),
                    ),
                  ),
                  child: Text(
                    "Apply",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * numD04,
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
