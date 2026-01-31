import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/dashboard/domain/usecases/remove_device.dart';
import 'package:presshop/features/notification/domain/usecases/get_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/main.dart';
import 'package:presshop/features/authentication/domain/usecases/logout_user.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetNotifications getNotifications;
  final RemoveDevice removeDevice;
  final LogoutUser logoutUser;

  MenuBloc({
    required this.getNotifications,
    required this.removeDevice,
    required this.logoutUser,
  }) : super(const MenuState()) {
    on<MenuLoadCounts>(_onLoadCounts);
    on<MenuLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadCounts(
    MenuLoadCounts event,
    Emitter<MenuState> emit,
  ) async {
    final result = await getNotifications();
    result.fold(
      (failure) => emit(state.copyWith(status: MenuStatus.failure)),
      (notificationsResult) {
        emit(state.copyWith(
          status: MenuStatus.success,
          notificationCount: notificationsResult.unreadCount,
          alertCount: notificationsResult.alertCount,
        ));
      },
    );
  }

  Future<void> _onLogoutRequested(
    MenuLogoutRequested event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(logoutStatus: MenuLogoutStatus.loading));

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "";
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "";
      }
    } catch (e) {
      // Ignore
    }

    // Attempt to remove device token from server
    await removeDevice(RemoveDeviceParams(deviceId: deviceId));

    // Selective Wipe
    try {
      rememberMe = false;
      const storage = FlutterSecureStorage();
      await storage.delete(key: tokenKey);
      await storage.delete(key: refreshtokenKey);
      await sharedPreferences?.remove(tokenKey);
      await sharedPreferences?.remove(refreshtokenKey);
      await sharedPreferences?.remove(rememberKey);

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      await FirebaseAnalytics.instance.logEvent(
        name: 'device_token_removed',
        parameters: {
          'message': 'Device token removed successfully',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error during logout cleanup: $e");
      }
    }

    final result = await logoutUser(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        logoutStatus: MenuLogoutStatus.failure,
        errorMessage: "Logout failed",
      )),
      (_) => emit(state.copyWith(logoutStatus: MenuLogoutStatus.success)),
    );
  }
}
