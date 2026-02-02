import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/api/api_client.dart';
import '../../data/models/alert_model.dart';
import 'alert_event.dart';
import 'alert_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final ApiClient apiClient;
  final Location location;
  int _limit = 10;
  int _offset = 0;
  bool _isFetching = false;

  AlertBloc({required this.apiClient, Location? location})
      : location = location ?? Location.instance,
        super(const AlertState()) {
    on<FetchAlertsEvent>(_onFetchAlerts);
    on<RefreshAlertsEvent>(_onRefreshAlerts);
    on<LoadMoreAlertsEvent>(_onLoadMoreAlerts);
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
  }

  Future<void> _onFetchAlerts(
      FetchAlertsEvent event, Emitter<AlertState> emit) async {
    emit(state.copyWith(status: AlertStatus.loading));
    _offset = 0;
    await _fetchAlerts(emit, isRefresh: true);
  }

  Future<void> _onRefreshAlerts(
      RefreshAlertsEvent event, Emitter<AlertState> emit) async {
    _offset = 0;
    await _fetchAlerts(emit, isRefresh: true);
  }

  Future<void> _onLoadMoreAlerts(
      LoadMoreAlertsEvent event, Emitter<AlertState> emit) async {
    if (state.hasReachedMax || _isFetching) return;
    _offset += _limit;
    await _fetchAlerts(emit, isRefresh: false);
  }

  Future<void> _fetchAlerts(Emitter<AlertState> emit,
      {required bool isRefresh}) async {
    _isFetching = true;
    try {
      final response = await apiClient.get(
        allAlertUrl, // Using constant directly, assuming it's the endpoint path
        queryParameters: {
          "limit": _limit,
          "offset": _offset,
        },
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        var dataModel = data['data'] as List;
        List<AlertModel> newAlerts =
            dataModel.map((e) => AlertModel.fromJson(e)).toList();

        bool hasReachedMax = newAlerts.length < _limit;

        emit(state.copyWith(
          status: AlertStatus.success,
          alerts: isRefresh
              ? newAlerts
              : (List.of(state.alerts)..addAll(newAlerts)),
          hasReachedMax: hasReachedMax,
        ));
      } else {
        emit(state.copyWith(
            status: AlertStatus.failure,
            errorMessage: "Failed to fetch alerts"));
      }
    } catch (e) {
      emit(state.copyWith(
          status: AlertStatus.failure, errorMessage: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onGetCurrentLocation(
      GetCurrentLocationEvent event, Emitter<AlertState> emit) async {
    try {
      bool serviceEnable = await location.serviceEnabled();
      if (!serviceEnable) {
        serviceEnable = await location.requestService();
        if (!serviceEnable) {
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      LocationData loc = await location.getLocation();
      if (loc.latitude != null && loc.longitude != null) {
        emit(state.copyWith(
            currentLocation: LatLng(loc.latitude!, loc.longitude!)));
      }
    } catch (e) {
      // Handle location error silently or emit failure if critical
      // For now we just log locally or ignore as likely perm issue handled by UI checks usually
    }
  }
}
