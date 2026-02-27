import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class FetchActiveAdmins extends DashboardEvent {
  const FetchActiveAdmins();
}

class UpdateLocationEvent extends DashboardEvent {
  const UpdateLocationEvent(this.params);
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}

class AddDeviceEvent extends DashboardEvent {
  const AddDeviceEvent(this.params);
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}

class FetchTaskDetailEvent extends DashboardEvent {
  const FetchTaskDetailEvent(this.taskId);
  final String taskId;

  @override
  List<Object> get props => [taskId];
}

class FetchRoomIdEvent extends DashboardEvent {
  const FetchRoomIdEvent(this.params);
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}

class CheckAppVersionEvent extends DashboardEvent {
  const CheckAppVersionEvent();
}

class ActivateStudentBeansEvent extends DashboardEvent {
  const ActivateStudentBeansEvent();
}

class FetchMyProfileEvent extends DashboardEvent {
  const FetchMyProfileEvent();
}

class ChangeDashboardTabEvent extends DashboardEvent {
  const ChangeDashboardTabEvent(this.newIndex);
  final int newIndex;

  @override
  List<Object> get props => [newIndex];
}

class DashboardCheckStudentBeansEvent extends DashboardEvent {
  const DashboardCheckStudentBeansEvent();
}

class DashboardMarkStudentBeansVisitedEvent extends DashboardEvent {
  const DashboardMarkStudentBeansVisitedEvent();
}
