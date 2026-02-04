import 'package:presshop/features/authentication/domain/entities/user.dart';

class CurrentUser {
  static final CurrentUser _instance = CurrentUser._internal();

  factory CurrentUser() {
    return _instance;
  }

  CurrentUser._internal();

  static User? _user;

  static User? get user => _user;

  static set user(User? user) {
    _user = user;
  }

  static bool get isLoggedIn => _user != null;

  static void clear() {
    _user = null;
  }
}
