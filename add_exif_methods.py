import sys
import os

path = '/Users/rajesh/Documents/PresshopComplete/presshop-flutter-app-3.0-new-app/lib/features/publish/presentation/pages/publish_content_screen.dart'
if not os.path.exists(path):
    print(f"File not found: {path}")
    exit(1)

with open(path, 'r') as f:
    lines = f.readlines()

new_methods = """
  Future<void> _extractExifFromFile(String filePath) async {
    try {
      final fileBytes = await File(filePath).readAsBytes();
      final tags = await pure_exif.readExifFromBytes(fileBytes);

      double extractedLat = 0.0;
      double extractedLng = 0.0;

      if (tags.containsKey('GPS GPSLatitude') &&
          tags.containsKey('GPS GPSLongitude')) {
        final latRatio = tags['GPS GPSLatitude']!.values.toList();
        final lonRatio = tags['GPS GPSLongitude']!.values.toList();
        final latRef = tags['GPS GPSLatitudeRef']?.printable;
        final lonRef = tags['GPS GPSLongitudeRef']?.printable;

        double lat = _convertRatioToDouble(latRatio);
        double lon = _convertRatioToDouble(lonRatio);

        if (latRef == 'S') lat = -lat;
        if (lonRef == 'W') lon = -lon;

        extractedLat = lat;
        extractedLng = lon;
      }

      if (extractedLat != 0.0 && extractedLng != 0.0) {
        final List<geo.Placemark> placemarks =
            await geo.placemarkFromCoordinates(extractedLat, extractedLng);
        if (placemarks.isNotEmpty) {
          final geo.Placemark place = placemarks.first;
          setState(() {
            locationController.text =
                "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}";
          });
          return;
        }
      }
      
      _fetchCurrentLocation();
    } catch (e) {
      debugPrint("Error extracting EXIF in publish screen: $e");
      _fetchCurrentLocation();
    }
  }

  double _convertRatioToDouble(dynamic ratio) {
    try {
      if (ratio is List && ratio.length >= 3) {
        double d = ratio[0].numerator /
            (ratio[0].denominator == 0 ? 1 : ratio[0].denominator);
        double m = ratio[1].numerator /
            (ratio[1].denominator == 0 ? 1 : ratio[1].denominator);
        double s = ratio[2].numerator /
            (ratio[2].denominator == 0 ? 1 : ratio[2].denominator);
        double result = d + (m / 60.0) + (s / 3600.0);
        if (result.isNaN || result.isInfinite) return 0.0;
        return result;
      }
    } catch (e) {
      debugPrint("EXIF ratio convert error: $e");
    }
    return 0.0;
  }
"""

# Insert before the last closing brace
for i in range(len(lines) - 1, -1, -1):
    if lines[i].strip() == '}':
        lines.insert(i, new_methods)
        break

with open(path, 'w') as f:
    f.writelines(lines)
print("Successfully added EXIF methods.")
