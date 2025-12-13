import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../domain/usecases/add_device.dart';
import '../../domain/usecases/get_active_admins.dart';
import '../../domain/usecases/get_dashboard_task_detail.dart';
import '../../domain/usecases/get_room_id.dart';
import '../../domain/usecases/update_location.dart';
import '../../domain/usecases/check_app_version.dart';
import '../../domain/usecases/activate_student_beans.dart';
import '../../../authentication/domain/usecases/get_profile.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetActiveAdmins getActiveAdmins;
  final UpdateLocation updateLocation;
  final AddDevice addDevice;
  final GetDashboardTaskDetail getDashboardTaskDetail;
  final GetRoomId getRoomId;
  final CheckAppVersion checkAppVersion;
  final ActivateStudentBeans activateStudentBeans;
  final GetProfile getProfile;

  DashboardBloc({
    required this.getActiveAdmins,
    required this.updateLocation,
    required this.addDevice,
    required this.getDashboardTaskDetail,
    required this.getRoomId,
    required this.checkAppVersion,
    required this.activateStudentBeans,
    required this.getProfile,
  }) : super(DashboardInitial()) {
    on<FetchActiveAdmins>(_onFetchActiveAdmins);
    on<UpdateLocationEvent>(_onUpdateLocation);
    on<AddDeviceEvent>(_onAddDevice);
    on<FetchTaskDetailEvent>(_onFetchTaskDetail);
    on<FetchRoomIdEvent>(_onFetchRoomId);
    on<CheckAppVersionEvent>(_onCheckAppVersion);
    on<ActivateStudentBeansEvent>(_onActivateStudentBeans);
    on<FetchMyProfileEvent>(_onFetchMyProfile);
    on<ChangeDashboardTabEvent>(_onChangeDashboardTab);
  }

  Future<void> _onFetchActiveAdmins(
    FetchActiveAdmins event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getActiveAdmins(NoParams());
    result.fold(
      (failure) => emit(const DashboardError("Failed to fetch active admins")),
      (admins) => emit(DashboardActiveAdminsLoaded(admins)),
    );
  }

  Future<void> _onUpdateLocation(
    UpdateLocationEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await updateLocation(UpdateLocationParams(event.params));
    result.fold(
      (failure) => emit(const DashboardError("Failed to update location")),
      (_) => emit(DashboardLocationUpdated()),
    );
  }

  Future<void> _onAddDevice(
    AddDeviceEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await addDevice(AddDeviceParams(event.params));
    result.fold(
      (failure) => emit(const DashboardError("Failed to add device")),
      (_) => emit(DashboardDeviceAdded()),
    );
  }

  Future<void> _onFetchTaskDetail(
    FetchTaskDetailEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await getDashboardTaskDetail(event.taskId);
    result.fold(
      (failure) => emit(const DashboardError("Failed to fetch task detail")),
      (taskDetail) => emit(DashboardTaskDetailLoaded(taskDetail)),
    );
  }

  Future<void> _onFetchRoomId(
    FetchRoomIdEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getRoomId(NoParams());
    result.fold(
      (failure) => emit(const DashboardError("Failed to fetch room ID")),
      (roomData) => emit(DashboardRoomIdLoaded(roomData)),
    );
  }

  Future<void> _onCheckAppVersion(
    CheckAppVersionEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await checkAppVersion(NoParams());
    result.fold(
      (failure) => emit(const DashboardError("Failed to check app version")),
      (versionData) => emit(DashboardAppVersionChecked(versionData)),
    );
  }

  Future<void> _onActivateStudentBeans(
    ActivateStudentBeansEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await activateStudentBeans(NoParams());
    result.fold(
      (failure) => emit(const DashboardError("Failed to activate student beans")),
      (data) => emit(StudentBeansActivated(data)),
    );
  }

  Future<void> _onFetchMyProfile(
    FetchMyProfileEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await getProfile(NoParams());
    result.fold(
      (failure) => emit(const DashboardError("Failed to fetch profile")),
      (user) => emit(DashboardMyProfileLoaded(user)),
    );
  }

  void _onChangeDashboardTab(
    ChangeDashboardTabEvent event,
    Emitter<DashboardState> emit,
  ) {
    emit(DashboardTabChanged(event.newIndex));
  }
}
