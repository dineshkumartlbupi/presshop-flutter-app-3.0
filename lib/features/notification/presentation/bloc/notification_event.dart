part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {
  final int offset;
  final int limit;

  const FetchNotificationsEvent({this.offset = 0, this.limit = 10});

  @override
  List<Object?> get props => [offset, limit];
}

class MarkNotificationsAsReadEvent extends NotificationEvent {}

class ClearAllNotificationsEvent extends NotificationEvent {}

class CheckStudentBeansEvent extends NotificationEvent {}

class StudentBeansActivationEvent extends NotificationEvent {}

class MarkStudentBeansVisitedEvent extends NotificationEvent {}
