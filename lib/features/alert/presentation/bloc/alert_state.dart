import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/models/alert_model.dart';

enum AlertStatus { initial, loading, success, failure }

class AlertState extends Equatable {
  final AlertStatus status;
  final List<AlertModel> alerts;
  final bool hasReachedMax;
  final String errorMessage;
  final LatLng? currentLocation;

  const AlertState({
    this.status = AlertStatus.initial,
    this.alerts = const [],
    this.hasReachedMax = false,
    this.errorMessage = '',
    this.currentLocation,
  });

  AlertState copyWith({
    AlertStatus? status,
    List<AlertModel>? alerts,
    bool? hasReachedMax,
    String? errorMessage,
    LatLng? currentLocation,
  }) {
    return AlertState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [status, alerts, hasReachedMax, errorMessage, currentLocation];
}
