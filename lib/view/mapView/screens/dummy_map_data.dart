// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image/image.dart' as image;

// final Map<String, String> markerIcons = {
//   "accident": "assets/markers/car-crash.gif",
//   "fire": "assets/markers/car-crash.gif",
//   "medical": "assets/markers/car-crash.gif",
//   "gun": "assets/markers/car-crash.gif",
//   "protest": "assets/markers/car-crash.gif",
//   "knife": "assets/markers/car-crash.gif",
//   "fight": "assets/markers/car-crash.gif",

//   // other cases
//   "content": "assets/markers/avatar.png",
//   "hopper": "assets/markers/avatar.png",
// };

// const DEFAULT_INCIDENTS = [
//   {
//     "id": "incident-1",
//     "markerType": "icon",
//     "type": "accident",
//     "position": {"lat": 51.518018, "lng": -0.144999},
//     "address": "167 Great Portland St",
//     "time": "10:40 AM",
//   },
//   {
//     "id": "incident-2",
//     "markerType": "icon",
//     "type": "fire",
//     "position": {"lat": 51.5014, "lng": -0.1419},
//     "address": "Buckingham Palace Rd",
//     "time": "09:55 AM",
//   },
//   {
//     "id": "incident-3",
//     "markerType": "icon",
//     "type": "medical",
//     "position": {"lat": 51.5027, "lng": -0.1196},
//     "address": "Waterloo Station",
//     "time": "10:10 AM",
//   },
//   {
//     "id": "incident-4",
//     "markerType": "icon",
//     "type": "gun",
//     "position": {"lat": 51.5079, "lng": -0.0877},
//     "address": "London Bridge",
//     "time": "09:30 AM",
//   },
//   {
//     "id": "incident-5",
//     "markerType": "icon",
//     "type": "protest",
//     "position": {"lat": 51.5128, "lng": -0.0984},
//     "address": "St. Paul's Cathedral",
//     "time": "09:45 AM",
//   },
//   {
//     "id": "incident-6",
//     "markerType": "icon",
//     "type": "knife",
//     "position": {"lat": 51.5130, "lng": -0.1190},
//     "address": "Wellington Street",
//     "time": "09:45 AM",
//   },
//   {
//     "id": "incident-7",
//     "markerType": "icon",
//     "type": "fight",
//     "position": {"lat": 51.5232, "lng": -0.1200},
//     "address": "Trafalgar Square",
//     "time": "09:45 AM",
//   },

//   // Content marker
//   {
//     "id": "content-1",
//     "markerType": "content",
//     "position": {"lat": 51.5150, "lng": -0.1300},
//     "image":
//         "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400",
//     "title": "Beautiful Landscape",
//     "description": "A stunning view of the countryside",
//     "address": "Hyde Park",
//     "time": "11:00 AM",
//   },

//   // Hopper marker
//   {
//     "id": "hopper-1",
//     "markerType": "hopper",
//     "position": {"lat": 51.5100, "lng": -0.1250},
//     "image":
//         "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200",
//     "name": "John Doe",
//     "rating": "4.8",
//     "specialization": "Emergency Response",
//     "distance": "0.5 miles",
//     "address": "Oxford Street",
//     "statusColor": "#10b981",
//   },
// ];

// Future<BitmapDescriptor> bitmapResize(
//   String assetPath, {
//   int width = 160,
// }) async {
//   final byteData = await rootBundle.load(assetPath);
//   final uint8list = byteData.buffer.asUint8List();

//   final img = image.decodeImage(uint8list);
//   if (img == null) return BitmapDescriptor.defaultMarker;
//   final resized = image.copyResize(img, width: width);
//   final resizedBytes = image.encodePng(resized);
//   return BitmapDescriptor.fromBytes(resizedBytes);
// }
