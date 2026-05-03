part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {

  const FetchNotificationsEvent({this.offset = 0, this.limit = 10});
  final int offset;
  final int limit;

  @override
  List<Object?> get props => [offset, limit];
}

class MarkNotificationsAsReadEvent extends NotificationEvent {
  const MarkNotificationsAsReadEvent();
}

class ClearAllNotificationsEvent extends NotificationEvent {
  const ClearAllNotificationsEvent();
}

class CheckStudentBeansEvent extends NotificationEvent {
  const CheckStudentBeansEvent();
}

class StudentBeansActivationEvent extends NotificationEvent {
  const StudentBeansActivationEvent();
}

class MarkStudentBeansVisitedEvent extends NotificationEvent {
  const MarkStudentBeansVisitedEvent();
}
