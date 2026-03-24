// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:presshop/core/constants/all_keys.dart';
// import 'package:presshop/core/widgets/new_home_app_bar.dart';
// import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
// import 'package:presshop/features/map/presentation/bloc/map_event.dart';
// import 'package:presshop/features/map/presentation/bloc/map_state.dart';
// import 'package:presshop/features/map/presentation/widgets/serarch_filter_widget.dart';
// import 'package:presshop/core/di/injection_container.dart';

// class OptimisedMapPage2 extends StatefulWidget {
//   const OptimisedMapPage2({Key? key}) : super(key: key);

//   @override
//   State<OptimisedMapPage2> createState() => _SimpleMapPageState();
// }

// class _SimpleMapPageState extends State<OptimisedMapPage2> with AutomaticKeepAliveClientMixin {
//   late MapBloc _mapBloc;
//   List<dynamic> _predictions = [];
//   bool _showDropdown = false;

//   GoogleMapController? _controller;
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();

//   static const CameraPosition _initialPosition = CameraPosition(
//     target: LatLng(26.8467, 80.9462), // Lucknow
//     zoom: 14,
//   );

//   // Stable key for the map to prevent disposal/re-creation
//   final GlobalKey _mapGlobalKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _mapBloc = sl<MapBloc>()..add(GetCurrentLocationEvent());
//   }

//   @override
//   bool get wantKeepAlive => true; 

//   @override
//   void dispose() {
//     // Note: If you want the bloc to survive tab switches, don't close it here 
//     // IF it's provided from a higher level. But here we fetch it from 'sl',
//     // so we should be careful. In standard Bloc patterns, the creator closes it.
//     // _mapBloc.close(); 
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _searchPlaces(String input) async {
//     if (input.isEmpty) {
//       if (mounted) {
//         setState(() {
//           _predictions = [];
//           _showDropdown = false;
//         });
//       }
//       return;
//     }

//     final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
//         "?input=$input"
//         "&key=${AllKeys.googleApiKey}"
//         "&types=geocode";

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final preds = data['predictions'] as List<dynamic>? ?? [];

//         setState(() {
//           _predictions = preds;
//           _showDropdown = preds.isNotEmpty;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error searching places: $e");
//     }
//   }

//   Future<void> _selectPlace(String placeId, String description) async {
//     final url = "https://maps.googleapis.com/maps/api/place/details/json"
//         "?place_id=$placeId"
//         "&key=${AllKeys.googleApiKey}";

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final location = data['result']['geometry']['location'];
//         final latLng = LatLng(location['lat'], location['lng']);

//         _mapBloc.add(SetSearchedLocationEvent(latLng));

//         if (_controller != null) {
//           await _controller!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
//         }

//         setState(() {
//           _showDropdown = false;
//           _predictions = [];
//           _searchController.text = description;
//         });
//         _searchFocusNode.unfocus();
//       }
//     } catch (e) {
//       debugPrint("Error selecting place: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); 
//     final size = MediaQuery.of(context).size;

//     return BlocProvider.value(
//       value: _mapBloc,
//       child: Scaffold(
//         appBar: NewHomeAppBar(
//           size: size,
//           hideLeading: true,
//           showFilter: false,
//         ),
//         body: BlocBuilder<MapBloc, MapState>(
//           buildWhen: (previous, current) {
//             // Highly optimized build conditions
//             return previous.markers != current.markers ||
//                 previous.polylines != current.polylines ||
//                 previous.circles != current.circles ||
//                 previous.myLocation != current.myLocation ||
//                 previous.selectedAlertType != current.selectedAlertType ||
//                 previous.selectedDistance != current.selectedDistance ||
//                 previous.selectedCategory != current.selectedCategory;
//           },
//           builder: (context, state) {
//             return Center(
//               child: SizedBox.expand(
//                 child: Stack(
//                   children: [
//                     // RepaintBoundary isolates the map's heavy painting from the rest of the UI
//                     RepaintBoundary(
//                       child: GoogleMap(
//                         key: _mapGlobalKey,
//                         initialCameraPosition: state.initialCamera ?? _initialPosition,
//                         onMapCreated: (controller) {
//                           _controller = controller;
//                         },
//                         markers: state.markers,
//                         polylines: state.polylines,
//                         polygons: state.polygons,
//                         circles: state.circles,
//                         myLocationEnabled: true,
//                         myLocationButtonEnabled: false,
//                         zoomControlsEnabled: false,
//                         // Optimization: Disable expensive features if not needed
//                         tiltGesturesEnabled: false,
//                         rotateGesturesEnabled: false,
//                       ),
//                     ),
//                     Positioned(
//                       top: 10,
//                       left: 0,
//                       right: 0,
//                       // RepaintBoundary for the search bar as well
//                       child: RepaintBoundary(
//                         child: SearchAndFilterBar(
//                           searchController: _searchController,
//                           searchFocusNode: _searchFocusNode,
//                           onPressedOnNavigation: () {
//                             _mapBloc.add(ToggleGetDirectionCardEvent());
//                           },
//                           onChange: (value) {
//                             _searchPlaces(value);
//                           },
//                           selectedAlertType: state.selectedAlertType,
//                           selectedDistance: state.selectedDistance,
//                           selectedCategory: state.selectedCategory,
//                           onAlertTypeChanged: (value) {
//                             _mapBloc.add(UpdateFiltersEvent(
//                               alertType: value,
//                               distance: state.selectedDistance,
//                               category: state.selectedCategory,
//                             ));
//                           },
//                           onDistanceChanged: (value) {
//                             _mapBloc.add(UpdateFiltersEvent(
//                               alertType: state.selectedAlertType,
//                               distance: value,
//                               category: state.selectedCategory,
//                             ));
//                           },
//                           onCategoryChanged: (value) {
//                             _mapBloc.add(UpdateFiltersEvent(
//                               alertType: state.selectedAlertType,
//                               distance: state.selectedDistance,
//                               category: value,
//                             ));
//                           },
//                         ),
//                       ),
//                     ),
//                     if (_showDropdown && _predictions.isNotEmpty)
//                       Positioned(
//                         left: 12,
//                         right: 55,
//                         top: 60,
//                         child: Material(
//                           elevation: 4,
//                           borderRadius: BorderRadius.circular(8),
//                           child: ConstrainedBox(
//                             constraints: const BoxConstraints(maxHeight: 200),
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               padding: EdgeInsets.zero,
//                               itemCount: _predictions.length,
//                               itemBuilder: (context, index) {
//                                 final prediction = _predictions[index];
//                                 return InkWell(
//                                   onTap: () {
//                                     _selectPlace(
//                                       prediction['place_id'],
//                                       prediction['description'],
//                                     );
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 8,
//                                     ),
//                                     child: Text(prediction['description']),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
