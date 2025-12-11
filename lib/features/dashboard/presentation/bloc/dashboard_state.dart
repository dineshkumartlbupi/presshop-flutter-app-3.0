import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_detail.dart';
import '../../domain/entities/task_detail.dart';
import '../../../authentication/domain/entities/user.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardActiveAdminsLoaded extends DashboardState {
  final List<AdminDetail> admins;

  const DashboardActiveAdminsLoaded(this.admins);

  @override
  List<Object> get props => [admins];
}

class DashboardLocationUpdated extends DashboardState {}

class DashboardDeviceAdded extends DashboardState {}

class DashboardTaskDetailLoaded extends DashboardState {
  final TaskDetail taskDetail;

  const DashboardTaskDetailLoaded(this.taskDetail);

  @override
  List<Object> get props => [taskDetail];
}

class DashboardRoomIdLoaded extends DashboardState {
  final Map<String, dynamic> roomData;

  const DashboardRoomIdLoaded(this.roomData);

  @override
  List<Object> get props => [roomData];
}

class DashboardAppVersionChecked extends DashboardState {
  final Map<String, dynamic> versionData;

  const DashboardAppVersionChecked(this.versionData);

  @override
  List<Object> get props => [versionData];
}

class StudentBeansActivated extends DashboardState {
  final Map<String, dynamic> data;

  const StudentBeansActivated(this.data);

  @override
  List<Object> get props => [data];
}

class DashboardMyProfileLoaded extends DashboardState {
  final User user;

  const DashboardMyProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class DashboardTabChanged extends DashboardState {
  final int index;

  const DashboardTabChanged(this.index);

  @override
  List<Object> get props => [index];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
