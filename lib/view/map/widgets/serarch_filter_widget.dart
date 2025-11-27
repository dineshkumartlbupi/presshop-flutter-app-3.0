import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class SearchAndFilterBar extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 6, top: 2, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBDBDBD)),
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
                          decoration: const InputDecoration(
                            hintText: "Search this area",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEC4E54),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    LucideIcons.corner_up_right,
                    color: Colors.white,
                  ),
                  onPressed: onPressedOnNavigation,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 6, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown(
                        items: const ['Alert', 'Info', 'Warning'],
                        selected: selectedAlertType ?? 'Alert',
                        onChanged: onAlertTypeChanged,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _FilterDropdown(
                        items: const ['1 mile', '2 miles', '5 miles'],
                        selected: selectedDistance ?? '2 miles',
                        onChanged: onDistanceChanged,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _FilterDropdown(
                        items: const ['Category', 'Latest', 'Crime', 'Event','Political','Celebrity','Sports'],
                        selected: selectedCategory ?? 'Category',
                        onChanged: onCategoryChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final List<String> items;
  final String selected;
  final Function(String?)? onChanged;

  const _FilterDropdown({
    required this.items,
    required this.selected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, width: 1.2),
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
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
