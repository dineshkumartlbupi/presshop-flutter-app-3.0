import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/dashboard/domain/usecases/remove_device.dart';
import 'package:presshop/features/notification/domain/usecases/get_notifications.dart';
import 'package:presshop/features/authentication/data/datasources/auth_local_data_source.dart';

import 'package:presshop/features/authentication/domain/usecases/logout_user.dart';
import '../../domain/services/menu_service.dart';
import 'package:presshop/core/utils/current_user.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc({
    required this.getNotifications,
    required this.removeDevice,
    required this.logoutUser,
    required this.menuService,
    required this.authLocalDataSource,
  }) : super(const MenuState()) {
    on<MenuLoadCounts>(_onLoadCounts);
    on<MenuLogoutRequested>(_onLogoutRequested);
  }
  final GetNotifications getNotifications;
  final RemoveDevice removeDevice;
  final LogoutUser logoutUser;
  final MenuService menuService;
  final AuthLocalDataSource authLocalDataSource;

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

    String deviceId = await menuService.getDeviceId();
    await removeDevice(RemoveDeviceParams(deviceId: deviceId));
    try {
      await menuService.clearSession();
      await authLocalDataSource.clearCache();
      await menuService.googleSignOut();
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
      (_) {
        CurrentUser.clear();
        emit(state.copyWith(logoutStatus: MenuLogoutStatus.success));
      },
    );
  }
}
