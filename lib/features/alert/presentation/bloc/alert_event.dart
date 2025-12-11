import 'package:equatable/equatable.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object> get props => [];
}

class FetchAlertsEvent extends AlertEvent {
  const FetchAlertsEvent();
}

class RefreshAlertsEvent extends AlertEvent {}

class LoadMoreAlertsEvent extends AlertEvent {}

class GetCurrentLocationEvent extends AlertEvent {}
