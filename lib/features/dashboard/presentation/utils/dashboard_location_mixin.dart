import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as lc;
import 'package:presshop/core/widgets/error/location_error_screen.dart';
import 'package:presshop/main.dart';

mixin DashboardLocationMixin<T extends StatefulWidget> on State<T> {
  Future<void> handleProceedWithLocation({
    required lc.LocationData? locationData,
    required Function(double lat, double lng, String address) onLocationUpdated,
  }) async {
    if (locationData != null && locationData.latitude != null) {
      final latitude = locationData.latitude!;
      final longitude = locationData.longitude!;

      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          String fullAddress = [
            if (place.street?.isNotEmpty ?? false) place.street,
            if (place.locality?.isNotEmpty ?? false) place.locality,
            if (place.administrativeArea?.isNotEmpty ?? false)
              place.administrativeArea,
            if (place.country?.isNotEmpty ?? false) place.country,
          ].whereType<String>().join(", ");

          onLocationUpdated(latitude, longitude, fullAddress);
        }
      } catch (e) {
        debugPrint("Geocoding error: $e");
      }
    }
  }

  void handleGoToLocationErrorScreen(
      Function(lc.LocationData) onLocationFixed) {
    Navigator.of(navigatorKey.currentContext!)
        .push(
      MaterialPageRoute(
        builder: (context) => LocationErrorScreen(),
      ),
    )
        .then((value) {
      if (value != null) {
        onLocationFixed(value);
      }
    });
  }
}
