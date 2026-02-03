import 'package:equatable/equatable.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object> get props => [];
}

class FetchAlertsEvent extends AlertEvent {
  const FetchAlertsEvent();
}

class RefreshAlertsEvent extends AlertEvent {
  const RefreshAlertsEvent();
}

class LoadMoreAlertsEvent extends AlertEvent {
  const LoadMoreAlertsEvent();
}

class GetCurrentLocationEvent extends AlertEvent {
  const GetCurrentLocationEvent();
}
