import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_detail.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/dashboard/domain/entities/student_beans_info.dart';
import '../../../authentication/domain/entities/user.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardActiveAdminsLoaded extends DashboardState {
  const DashboardActiveAdminsLoaded(this.admins);
  final List<AdminDetail> admins;

  @override
  List<Object> get props => [admins];
}

class DashboardLocationUpdated extends DashboardState {}

class DashboardDeviceAdded extends DashboardState {}

class DashboardTaskDetailLoaded extends DashboardState {
  const DashboardTaskDetailLoaded(this.taskDetail);
  final TaskAssignedEntity taskDetail;

  @override
  List<Object> get props => [taskDetail];
}

class DashboardRoomIdLoaded extends DashboardState {
  const DashboardRoomIdLoaded(this.roomData);
  final Map<String, dynamic> roomData;

  @override
  List<Object> get props => [roomData];
}

class DashboardAppVersionChecked extends DashboardState {
  const DashboardAppVersionChecked(this.versionData);
  final Map<String, dynamic> versionData;

  @override
  List<Object> get props => [versionData];
}

class StudentBeansActivated extends DashboardState {
  const StudentBeansActivated(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class DashboardMyProfileLoaded extends DashboardState {
  const DashboardMyProfileLoaded(this.user);
  final User user;

  @override
  List<Object> get props => [user];
}

class DashboardTabChanged extends DashboardState {
  const DashboardTabChanged(this.index);
  final int index;

  @override
  List<Object> get props => [index];
}

class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class DashboardStudentBeansInfoLoaded extends DashboardState {
  const DashboardStudentBeansInfoLoaded(this.info);
  final StudentBeansInfo info;

  @override
  List<Object> get props => [info];
}

class DashboardMarkStudentBeansVisitedLoaded extends DashboardState {}
