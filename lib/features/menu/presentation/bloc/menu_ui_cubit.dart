import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/main.dart';

class MenuUiState {
  const MenuUiState({required this.currency});
  final String currency;

  MenuUiState copyWith({String? currency}) {
    return MenuUiState(currency: currency ?? this.currency);
  }
}

class MenuUiCubit extends Cubit<MenuUiState> {
  MenuUiCubit() : super(const MenuUiState(currency: 'GBP')) {
    loadCurrency();
  }

  Future<void> loadCurrency() async {
    final value = sharedPreferences?.getString('currency') ?? 'GBP';
    emit(state.copyWith(currency: value));
  }

  Future<void> setCurrency(String value) async {
    String symbol = "£";
    if (value == "USD" || value == "AUD") {
      symbol = "\$";
    } else if (value == "INR") {
      symbol = "₹";
    }
    await sharedPreferences?.setString('currency', value);
    await sharedPreferences?.setString('preferred_currency_sign', symbol);
    currencySymbol = symbol;
    emit(state.copyWith(currency: value));
  }
}
