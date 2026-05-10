import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/utils/ui_utils.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({
    super.key,
    this.onPressedOnNavigation,
    this.onChange,
    this.searchController,
    this.searchFocusNode,
    this.selectedAlertType,
    this.selectedDistance,
    this.selectedCategory,
    this.onAlertTypeChanged,
    this.onDistanceChanged,
    this.onCategoryChanged,
    this.showNavigationIcon = true,
    this.showFilters = true,
  });
  final VoidCallback? onPressedOnNavigation;
  final Function(String)? onChange;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String? selectedAlertType;
  final String? selectedDistance;
  final String? selectedCategory;
  final Function(String?)? onAlertTypeChanged;
  final Function(String?)? onDistanceChanged;
  final Function(String?)? onCategoryChanged;
  final bool showNavigationIcon;
  final bool showFilters;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    final double scalingWidth = isIpad ? 550 : size.width;

    return Padding(
      padding: EdgeInsets.only(
          left: scalingWidth * AppDimensions.numD04,
          right: scalingWidth * AppDimensions.numD04,
          top: 2,
          bottom: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: scalingWidth * 0.11,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.grey.shade400,
                        width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          focusNode: searchFocusNode,
                          onChanged: onChange,
                          style: TextStyle(
                            fontSize: scalingWidth * 0.035,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search any location",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: scalingWidth * 0.02,
                              horizontal: scalingWidth * 0.03,
                            ),
                            isDense: true,
                            hintStyle: TextStyle(
                              fontSize: scalingWidth * 0.035,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: scalingWidth * 0.09,
                        height: scalingWidth * 0.09,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4E54),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.search,
                          size: scalingWidth * 0.05,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: scalingWidth * 0.003),
                    ],
                  ),
                ),
              ),
              if (showNavigationIcon) SizedBox(width: scalingWidth * 0.02),
              if (showNavigationIcon)
                Container(
                  width: scalingWidth * 0.11,
                  height: scalingWidth * 0.11,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.grey.shade400,
                        width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      LucideIcons.corner_up_right,
                      size: scalingWidth * 0.055,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFEC4E54)
                          : Colors.black,
                    ),
                    onPressed: onPressedOnNavigation,
                  ),
                ),
            ],
          ),
          if (showFilters)
            SizedBox(
              height: size.height * 0.01,
            ),
          if (showFilters)
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          items: alertTypeFilter,
                          selected: selectedAlertType ?? 'Alerts',
                          onChanged: onAlertTypeChanged,
                          scalingWidth: scalingWidth,
                        ),
                      ),
                      SizedBox(width: scalingWidth * 0.015),
                      Expanded(
                        child: _FilterDropdown(
                          items: distanceFilter,
                          selected: selectedDistance ?? '5 miles',
                          onChanged: onDistanceChanged,
                          scalingWidth: scalingWidth,
                        ),
                      ),
                      SizedBox(width: scalingWidth * 0.015),
                      Expanded(
                        child: _FilterDropdown(
                          items: categoryFilter,
                          selected: selectedCategory ?? 'Category',
                          onChanged: onCategoryChanged,
                          scalingWidth: scalingWidth,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.items,
    required this.selected,
    this.onChanged,
    required this.scalingWidth,
  });
  final List<String> items;
  final String selected;
  final Function(String?)? onChanged;
  final double scalingWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: scalingWidth * 0.09,
      padding: EdgeInsets.symmetric(horizontal: scalingWidth * 0.02),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white24
                : Colors.grey.shade400,
            width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, size: scalingWidth * 0.05),
          selectedItemBuilder: (context) {
            return items.map((String item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: scalingWidth * 0.033,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }).toList();
          },
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: scalingWidth * 0.035,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
