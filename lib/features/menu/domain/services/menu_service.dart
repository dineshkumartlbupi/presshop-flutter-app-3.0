
abstract class MenuService {
  Future<String> getDeviceId();
  Future<void> clearSession();
  Future<void> googleSignOut();
}
