part of 'menu_bloc.dart';

enum MenuLogoutStatus { initial, loading, success, failure }
enum MenuStatus { initial, loading, success, failure }

class MenuState extends Equatable {
  final int notificationCount;
  final int alertCount;
  final MenuLogoutStatus logoutStatus;
  final MenuStatus status;
  final String? errorMessage;

  const MenuState({
    this.notificationCount = 0,
    this.alertCount = 0,
    this.logoutStatus = MenuLogoutStatus.initial,
    this.status = MenuStatus.initial,
    this.errorMessage,
  });

  MenuState copyWith({
    int? notificationCount,
    int? alertCount,
    MenuLogoutStatus? logoutStatus,
    MenuStatus? status,
    String? errorMessage,
  }) {
    return MenuState(
      notificationCount: notificationCount ?? this.notificationCount,
      alertCount: alertCount ?? this.alertCount,
      logoutStatus: logoutStatus ?? this.logoutStatus,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        notificationCount,
        alertCount,
        logoutStatus,
        status,
        errorMessage,
      ];
}
