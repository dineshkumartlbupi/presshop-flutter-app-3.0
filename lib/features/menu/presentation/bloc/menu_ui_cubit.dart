import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/main.dart';

class MenuUiState {
  final String currency;

  const MenuUiState({required this.currency});

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
    await sharedPreferences?.setString('currency', value);
    emit(state.copyWith(currency: value));
  }
}
