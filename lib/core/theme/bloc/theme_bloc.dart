import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class LoadThemeEvent extends ThemeEvent {}

// State
class ThemeState {
  final ThemeMode themeMode;
  ThemeState(this.themeMode);
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc(this.sharedPreferences) : super(ThemeState(ThemeMode.light)) {
    on<LoadThemeEvent>((event, emit) {
      final isDark = sharedPreferences.getBool('isDarkMode') ?? false;
      emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
    });

    on<ToggleThemeEvent>((event, emit) async {
      final isDark = state.themeMode == ThemeMode.dark;
      final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
      await sharedPreferences.setBool('isDarkMode', !isDark);
      emit(ThemeState(nextMode));
    });
  }
}
