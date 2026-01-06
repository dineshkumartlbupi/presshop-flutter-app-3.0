import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/utils/Common.dart';
import 'package:presshop/view/map_and_news/controller/map_controller.dart';

class GetDirectionCard extends ConsumerStatefulWidget {
  const GetDirectionCard({super.key});

  @override
  ConsumerState<GetDirectionCard> createState() => _GetDirectionCardState();
}

class _GetDirectionCardState extends ConsumerState<GetDirectionCard> {
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _currentLocationFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();
  List<dynamic> _currentLocationPredictions = [];
  List<dynamic> _destinationPredictions = [];
  bool _showCurrentLocationDropdown = false;
  bool _showDestinationDropdown = false;
  bool _isLoading = false;
  LatLng? _selectedOrigin;
  LatLng? _selectedDestination;
  LatLng? _lastProcessedMapLocation;

  @override
  void initState() {
    super.initState();

    _currentLocationFocusNode.addListener(() {
      if (!_currentLocationFocusNode.hasFocus) {
        setState(() {
          _showCurrentLocationDropdown = false;
        });
      }
    });

    _destinationFocusNode.addListener(() {
      if (!_destinationFocusNode.hasFocus) {
        setState(() {
          _showDestinationDropdown = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationController.dispose();
    _currentLocationFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String input, {bool isOrigin = false}) async {
    if (input.isEmpty) {
      setState(() {
        if (isOrigin) {
          _currentLocationPredictions = [];
          _showCurrentLocationDropdown = false;
        } else {
          _destinationPredictions = [];
          _showDestinationDropdown = false;
        }
      });
      return;
    }
// const googleMapAPiKey = "AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI";
// const appleMapAPiKey = "AIzaSyA0ZDsoYkDf4Dkh_jOCBzWBAIq5w6sk8gw";
    // const googleApiKey = 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI';
    final url = "$googleMapURL"
        "?input=$input"
        "&key=$googleMapAPiKey"
        "&types=geocode";

    final response = await http.get(Uri.parse(url));

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final preds = data['predictions'] as List<dynamic>? ?? [];

      setState(() {
        if (isOrigin) {
          _currentLocationPredictions = preds;
          _showCurrentLocationDropdown = preds.isNotEmpty;
        } else {
          _destinationPredictions = preds;
          _showDestinationDropdown = preds.isNotEmpty;
        }
      });
    } else {
      setState(() {
        if (isOrigin) {
          _currentLocationPredictions = [];
          _showCurrentLocationDropdown = false;
        } else {
          _destinationPredictions = [];
          _showDestinationDropdown = false;
        }
      });
    }
  }

  Future<void> _selectPlace(
    String placeId,
    String description, {
    bool isOrigin = false,
  }) async {
    // const googleApiKey = 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI';
    final url = "$googlePlaceDetailsURL"
        "?place_id=$placeId"
        "&key=$googleMapAPiKey";

    final response = await http.get(Uri.parse(url));

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final selectedLocation = LatLng(location['lat'], location['lng']);

      setState(() {
        if (isOrigin) {
          _showCurrentLocationDropdown = false;
          _currentLocationPredictions = [];
          _currentLocationController.text = description;
          _selectedOrigin = selectedLocation;
          _currentLocationFocusNode.unfocus();
        } else {
          _showDestinationDropdown = false;
          _destinationPredictions = [];
          _destinationController.text = description;
          _selectedDestination = selectedLocation;
          _destinationFocusNode.unfocus();
        }
      });

      if (!isOrigin && _selectedDestination != null) {
        await _getRoute(_selectedOrigin, _selectedDestination!);
      } else if (isOrigin &&
          _selectedOrigin != null &&
          _selectedDestination != null) {
        await _getRoute(_selectedOrigin, _selectedDestination!);
      }
    }
  }

  Future<void> _getRoute(LatLng? origin, LatLng destination) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mapController = ref.read(mapControllerProvider.notifier);
      await mapController.addRoute(origin, destination);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    final state = ref.read(mapControllerProvider);
    if (state.myLocation != null) {
      setState(() {
        _currentLocationController.text = 'Current Location';
        _selectedOrigin = null;
        _currentLocationFocusNode.unfocus();
      });

      if (_selectedDestination != null) {
        await _getRoute(_selectedOrigin, _selectedDestination!);
      }
    }
  }

  void _handleMapSelectedLocation() {
    final state = ref.read(mapControllerProvider);

    // Only process if we have a new selection that hasn't been processed
    if (state.mapSelectedLocation != null &&
        state.mapSelectedAddress != null &&
        state.mapSelectedIsOrigin != null &&
        state.mapSelectedLocation != _lastProcessedMapLocation) {
      final mapController = ref.read(mapControllerProvider.notifier);

      // Mark as processed
      _lastProcessedMapLocation = state.mapSelectedLocation;

      if (state.mapSelectedIsOrigin == true) {
        setState(() {
          _currentLocationController.text = state.mapSelectedAddress!;
          _selectedOrigin = state.mapSelectedLocation;
        });
      } else {
        setState(() {
          _destinationController.text = state.mapSelectedAddress!;
          _selectedDestination = state.mapSelectedLocation;
        });
      }

      mapController.clearMapSelectedLocation();

      if (!_isLoading) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_isLoading) {
            if (_selectedOrigin != null && _selectedDestination != null) {
              _getRoute(_selectedOrigin, _selectedDestination!);
            } else if (_selectedDestination != null) {
              _getRoute(_selectedOrigin, _selectedDestination!);
            }
          }
        });
      }
    }
  }

  final LayerLink _originLayerLink = LayerLink();
  final LayerLink _destinationLayerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapControllerProvider);

    // Listen to map controller state changes (only in build method)
    ref.listen(mapControllerProvider, (previous, next) {
      if (next.mapSelectedLocation != null &&
          next.mapSelectedAddress != null &&
          next.mapSelectedIsOrigin != null &&
          next.mapSelectedLocation != _lastProcessedMapLocation) {
        _handleMapSelectedLocation();
      }
    });

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size260,
            padding: const EdgeInsets.all(size12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: size12,
                  spreadRadius: size1,
                  offset: Offset(size0, size0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ------- TITLE -------
                Text(
                  'Get Direction',
                  style: TextStyle(
                    fontSize: size10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F1F1F),
                  ),
                ),

                const SizedBox(height: size8),
                const Divider(height: size1, color: Colors.black12),
                const SizedBox(height: size10),

                /// ------- LOCATION INPUTS -------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.my_location,
                          size: size18,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 8),
                        dottedLine(),
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.location_on_outlined,
                          size: size18,
                          color: Color.fromARGB(255, 121, 121, 121),
                        ),
                      ],
                    ),
                    const SizedBox(width: size18),
                    Expanded(
                      child: Column(
                        children: [
                          CompositedTransformTarget(
                            link: _originLayerLink,
                            child: TextField(
                              controller: _currentLocationController,
                              focusNode: _currentLocationFocusNode,
                              onChanged: (value) =>
                                  _searchPlaces(value, isOrigin: true),
                              decoration: InputDecoration(
                                hintText: 'Your Location',
                                filled: true,
                                hintStyle: const TextStyle(fontSize: size12),
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: size8,
                                  horizontal: size12,
                                ),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBDBDBD),
                                    width: size1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                  borderSide: BorderSide(
                                    color: colorThemePink,
                                    width: size1_2,
                                  ),
                                ),
                                // suffixIcon: Row(
                                //   mainAxisSize: MainAxisSize.min,
                                //   children: [
                                //     IconButton(
                                //       icon: const Icon(
                                //         Icons.my_location,
                                //         size: 18,
                                //       ),
                                //       onPressed: _useCurrentLocation,
                                //       tooltip: 'Use Current Location',
                                //     ),
                                //     IconButton(
                                //       icon: const Icon(Icons.map, size: 18),
                                //       onPressed: () {
                                //         ref
                                //             .read(
                                //               mapControllerProvider.notifier,
                                //             )
                                //             .setDestinationSelectionMode(
                                //               true,
                                //               isOrigin: true,
                                //             );
                                //         _currentLocationFocusNode.unfocus();
                                //       },
                                //       tooltip: 'Select on Map',
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                          ),
                          const SizedBox(height: size12),
                          CompositedTransformTarget(
                            link: _destinationLayerLink,
                            child: TextField(
                              controller: _destinationController,
                              focusNode: _destinationFocusNode,
                              onChanged: (value) =>
                                  _searchPlaces(value, isOrigin: false),
                              decoration: InputDecoration(
                                hintText: 'Destination',
                                hintStyle: const TextStyle(fontSize: size12),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: size8,
                                  horizontal: size12,
                                ),
                                isDense: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFBDBDBD),
                                    width: size1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(size8),
                                  borderSide: BorderSide(
                                    color: colorThemePink,
                                    width: size1_2,
                                  ),
                                ),
                                // suffixIcon: IconButton(
                                //   icon: const Icon(Icons.map, size: 18),
                                //   onPressed: () {
                                //     // Enable map selection mode
                                //     ref
                                //         .read(mapControllerProvider.notifier)
                                //         .setDestinationSelectionMode(true);
                                //     _destinationFocusNode.unfocus();
                                //   },
                                //   tooltip: 'Select on Map',
                                // ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: size14),

                /// ------- GO BUTTON -------
                SizedBox(
                  width: double.infinity,
                  height: size35,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_destinationController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a destination'),
                                ),
                              );
                              return;
                            }

                            final origin = _selectedOrigin;

                            // Use selected destination or state destination
                            final destination =
                                _selectedDestination ?? state.destination;
                            if (destination != null) {
                              await _getRoute(origin, destination);
                              // Start navigation
                              ref
                                  .read(mapControllerProvider.notifier)
                                  .startNavigation();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select a destination from the suggestions or map',
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: size0,
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: size16,
                            height: size16,
                            child: CircularProgressIndicator(
                              strokeWidth: size2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'GO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: size10,
                              letterSpacing: size1_2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          /// ------- POINTER TRIANGLE -------
          Positioned(
            right: size16,
            top: sizeMinus8,
            child: Transform.rotate(
              angle: math.pi / 4,
              child:
                  Container(width: size22, height: size22, color: Colors.white),
            ),
          ),

          /// ------- DROPDOWNS (On Top) -------
          if (_showCurrentLocationDropdown &&
              _currentLocationPredictions.isNotEmpty)
            CompositedTransformFollower(
              link: _originLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(size0, size40),
              child: Material(
                elevation: size4,
                borderRadius: BorderRadius.circular(size8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: size150,
                    maxWidth: size200, // Match approx width of text field
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _currentLocationPredictions.length,
                    itemBuilder: (context, index) {
                      final prediction = _currentLocationPredictions[index];
                      return InkWell(
                        onTap: () {
                          _selectPlace(
                            prediction['place_id'],
                            prediction['description'],
                            isOrigin: true,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: size12,
                            vertical: size8,
                          ),
                          child: Text(
                            prediction['description'],
                            style: const TextStyle(fontSize: size12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          if (_showDestinationDropdown && _destinationPredictions.isNotEmpty)
            CompositedTransformFollower(
              link: _destinationLayerLink,
              showWhenUnlinked: false,
              offset: const Offset(size0, size40),
              child: Material(
                elevation: size4,
                borderRadius: BorderRadius.circular(size8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: size150,
                    maxWidth: size200,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _destinationPredictions.length,
                    itemBuilder: (context, index) {
                      final prediction = _destinationPredictions[index];
                      return InkWell(
                        onTap: () {
                          _selectPlace(
                            prediction['place_id'],
                            prediction['description'],
                            isOrigin: false,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: size12,
                            vertical: size8,
                          ),
                          child: Text(
                            prediction['description'],
                            style: const TextStyle(fontSize: size12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

Widget dottedLine() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: size2,
        height: size3,
        decoration: BoxDecoration(
          color: Colors.grey,

          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(size2),
              topRight: Radius.circular(size2)), // color: Colors.grey,
        ),
      ),
      SizedBox(height: size1),
      Container(width: size2, height: size6, color: Colors.grey),
      SizedBox(height: size1),
      Container(
        width: size2,
        height: size3,
        decoration: BoxDecoration(
          color: Colors.grey,

          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(size2),
              bottomRight: Radius.circular(size2)), // color: Colors.grey,
        ),
      ),
    ],
  );
}
