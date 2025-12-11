import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class FetchActiveAdmins extends DashboardEvent {}

class UpdateLocationEvent extends DashboardEvent {
  final Map<String, dynamic> params;

  const UpdateLocationEvent(this.params);

  @override
  List<Object> get props => [params];
}

class AddDeviceEvent extends DashboardEvent {
  final Map<String, dynamic> params;

  const AddDeviceEvent(this.params);

  @override
  List<Object> get props => [params];
}

class FetchTaskDetailEvent extends DashboardEvent {
  final String taskId;

  const FetchTaskDetailEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class FetchRoomIdEvent extends DashboardEvent {}

class CheckAppVersionEvent extends DashboardEvent {}

class ActivateStudentBeansEvent extends DashboardEvent {}

class FetchMyProfileEvent extends DashboardEvent {}

class ChangeDashboardTabEvent extends DashboardEvent {
  final int newIndex;

  const ChangeDashboardTabEvent(this.newIndex);

  @override
  List<Object> get props => [newIndex];
}
