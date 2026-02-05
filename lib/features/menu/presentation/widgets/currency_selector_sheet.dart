import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';

class CurrencySelectorSheet extends StatelessWidget {
  const CurrencySelectorSheet({
    super.key,
    required this.selectedCurrency,
    required this.onSelected,
  });
  final String selectedCurrency;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Choose Currency",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Divider(),
          Column(
            children: [
              _buildCurrencyRow("AUD", "\$"),
              _buildCurrencyRow("INR", "₹"),
              _buildCurrencyRow("GBP", "£"),
              _buildCurrencyRow("USD", "\$"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String currency, String symbol) {
    bool isSelected = selectedCurrency == currency;
    return GestureDetector(
      onTap: () => onSelected(currency),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColorTheme.colorGreyChat : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          "$currency ($symbol)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColorTheme.colorThemePink : Colors.black,
          ),
        ),
      ),
    );
  }
}
