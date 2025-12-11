part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, success, failure, empty }

class NotificationState extends Equatable {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final bool hasReachedMax;
  final int unreadCount;
  final String errorMessage;

  // Student Beans Logic
  final bool shouldShowStudentBeansDialog;
  final String studentBeansHeading;
  final String studentBeansDescription;
  final String? studentBeansActivationUrl;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.notifications = const [],
    this.hasReachedMax = false,
    this.unreadCount = 0,
    this.errorMessage = '',
    this.shouldShowStudentBeansDialog = false,
    this.studentBeansHeading = '',
    this.studentBeansDescription = '',
    this.studentBeansActivationUrl,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    bool? hasReachedMax,
    int? unreadCount,
    String? errorMessage,
    bool? shouldShowStudentBeansDialog,
    String? studentBeansHeading,
    String? studentBeansDescription,
    String? studentBeansActivationUrl,
  }) {
    return NotificationState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldShowStudentBeansDialog:
          shouldShowStudentBeansDialog ?? this.shouldShowStudentBeansDialog,
      studentBeansHeading: studentBeansHeading ?? this.studentBeansHeading,
      studentBeansDescription:
          studentBeansDescription ?? this.studentBeansDescription,
      studentBeansActivationUrl:
          studentBeansActivationUrl ?? this.studentBeansActivationUrl,
    );
  }

  @override
  List<Object?> get props => [
        status,
        notifications,
        hasReachedMax,
        unreadCount,
        errorMessage,
        shouldShowStudentBeansDialog,
        studentBeansHeading,
        studentBeansDescription,
        studentBeansActivationUrl
      ];
}
