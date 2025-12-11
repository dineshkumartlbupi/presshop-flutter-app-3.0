import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/features/notification/domain/entities/notification_entity.dart';
import 'package:presshop/features/notification/domain/usecases/get_notifications.dart';
import 'package:presshop/features/notification/domain/usecases/mark_notifications_read.dart';
import 'package:presshop/features/notification/domain/usecases/clear_all_notifications.dart';
import 'package:presshop/features/notification/domain/usecases/check_student_beans.dart';
import 'package:presshop/features/notification/domain/usecases/activate_student_beans.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final MarkNotificationsAsRead markNotificationsAsRead;
  final ClearAllNotifications clearAllNotifications;
  final CheckStudentBeans checkStudentBeans;
  final ActivateStudentBeans activateStudentBeans;

  NotificationBloc({
    required this.getNotifications,
    required this.markNotificationsAsRead,
    required this.clearAllNotifications,
    required this.checkStudentBeans,
    required this.activateStudentBeans,
  }) : super(const NotificationState()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkNotificationsAsReadEvent>(_onMarkNotificationsAsRead);
    on<ClearAllNotificationsEvent>(_onClearAllNotifications);
    on<CheckStudentBeansEvent>(_onCheckStudentBeans);
    on<StudentBeansActivationEvent>(_onStudentBeansActivation);
  }

  Future<void> _onFetchNotifications(
      FetchNotificationsEvent event, Emitter<NotificationState> emit) async {
    if (event.offset == 0) {
      emit(state.copyWith(
          status: NotificationStatus.loading, notifications: []));
    }

    final result = await getNotifications(limit: event.limit, offset: event.offset);
    
    result.fold(
      (failure) => emit(state.copyWith(
          status: NotificationStatus.failure, errorMessage: failure.message)),
      (data) {
        List<NotificationEntity> allNotifications = List.from(state.notifications);
        if (event.offset == 0) {
          allNotifications = data.notifications;
        } else {
          allNotifications.addAll(data.notifications);
        }

        emit(state.copyWith(
          status: data.notifications.isEmpty && event.offset == 0
              ? NotificationStatus.empty
              : NotificationStatus.success,
          notifications: allNotifications,
          hasReachedMax: data.notifications.isEmpty,
          unreadCount: data.unreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkNotificationsAsRead(MarkNotificationsAsReadEvent event,
      Emitter<NotificationState> emit) async {
    final result = await markNotificationsAsRead();
    result.fold(
      (failure) => debugPrint("Error marking as read: ${failure.message}"),
      (success) => add(const FetchNotificationsEvent(offset: 0)),
    );
  }

  Future<void> _onClearAllNotifications(ClearAllNotificationsEvent event,
      Emitter<NotificationState> emit) async {
    final result = await clearAllNotifications();
    result.fold(
      (failure) => debugPrint("Error clearing notifications: ${failure.message}"),
      (success) => emit(state.copyWith(notifications: [], status: NotificationStatus.empty)),
    );
  }

  Future<void> _onCheckStudentBeans(
      CheckStudentBeansEvent event, Emitter<NotificationState> emit) async {
    final result = await checkStudentBeans();
    result.fold(
      (failure) => debugPrint("Error checking student beans: ${failure.message}"),
      (info) {
        if (info.shouldShow) {
          emit(state.copyWith(
            shouldShowStudentBeansDialog: true,
            studentBeansHeading: info.heading,
            studentBeansDescription: info.description,
          ));
        }
      },
    );
  }

  Future<void> _onStudentBeansActivation(StudentBeansActivationEvent event,
      Emitter<NotificationState> emit) async {
    final result = await activateStudentBeans();
    result.fold(
      (failure) => debugPrint("Error activating student beans: ${failure.message}"),
      (url) => emit(state.copyWith(studentBeansActivationUrl: url)),
    );
  }
}
