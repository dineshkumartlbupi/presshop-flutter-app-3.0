import 'package:presshop/core/core_export.dart';

abstract class MenuService {
  Future<String> getDeviceId();
  Future<void> clearSession();
  Future<void> googleSignOut();
}
