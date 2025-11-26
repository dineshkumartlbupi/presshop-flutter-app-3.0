import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/view/mapView/screens/marketplace_screen.dart';

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
  LatLng?
      _lastProcessedMapLocation; // Track last processed location to avoid reprocessing

  @override
  void initState() {
    super.initState();
    _currentLocationController.text = 'Current Location';

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

    const googleApiKey = 'AIzaSyAI46rVhROb5Dztv1aIDLvGH6QtGe3Addk';
    final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$input"
        "&key=$googleApiKey"
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
    const googleApiKey = 'AIzaSyAI46rVhROb5Dztv1aIDLvGH6QtGe3Addk';
    final url = "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&key=$googleApiKey";

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

      // Get route if both origin and destination are set
      if (!isOrigin && _selectedDestination != null) {
        // If destination is selected, get route (origin can be null for current location)
        await _getRoute(_selectedOrigin, _selectedDestination!);
      } else if (isOrigin &&
          _selectedOrigin != null &&
          _selectedDestination != null) {
        // If origin is selected and destination is already set, get route
        await _getRoute(_selectedOrigin, _selectedDestination!);
      }
    }
  }

  Future<void> _getRoute(LatLng? origin, LatLng destination) async {
    // Prevent multiple simultaneous route requests
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
        _selectedOrigin = null; // null means use current location
        _currentLocationFocusNode.unfocus();
      });

      // Get route if destination is already set
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

      // Clear the selection immediately
      mapController.clearMapSelectedLocation();

      // Get route if both are set (with a delay to avoid flickering and prevent multiple calls)
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
            width: 233,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: Offset(0, 0),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.black.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 10),

                /// ------- LOCATION INPUTS -------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.my_location,
                          size: 11,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 10),
                        dottedLine(),
                        const SizedBox(height: 10),
                        const Icon(Icons.location_on_outlined, size: 11),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              TextField(
                                controller: _currentLocationController,
                                focusNode: _currentLocationFocusNode,
                                onChanged: (value) =>
                                    _searchPlaces(value, isOrigin: true),
                                decoration: InputDecoration(
                                  hintText: 'Your Location',
                                  filled: true,
                                  hintStyle: const TextStyle(fontSize: 12),
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.2,
                                    ),
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.my_location,
                                          size: 18,
                                        ),
                                        onPressed: _useCurrentLocation,
                                        tooltip: 'Use Current Location',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.map, size: 18),
                                        onPressed: () {
                                          ref
                                              .read(
                                                mapControllerProvider.notifier,
                                              )
                                              .setDestinationSelectionMode(
                                                true,
                                                isOrigin: true,
                                              );
                                          _currentLocationFocusNode.unfocus();
                                        },
                                        tooltip: 'Select on Map',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_showCurrentLocationDropdown &&
                                  _currentLocationPredictions.isNotEmpty)
                                Positioned(
                                  top: 40,
                                  left: 0,
                                  right: 0,
                                  child: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 150,
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount:
                                            _currentLocationPredictions.length,
                                        itemBuilder: (context, index) {
                                          final prediction =
                                              _currentLocationPredictions[
                                                  index];
                                          return InkWell(
                                            onTap: () {
                                              _selectPlace(
                                                prediction['place_id'],
                                                prediction['description'],
                                                isOrigin: true,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              child: Text(
                                                prediction['description'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
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
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              TextField(
                                controller: _destinationController,
                                focusNode: _destinationFocusNode,
                                onChanged: (value) =>
                                    _searchPlaces(value, isOrigin: false),
                                decoration: InputDecoration(
                                  hintText: 'Destination',
                                  hintStyle: const TextStyle(fontSize: 12),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1.2,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.map, size: 18),
                                    onPressed: () {
                                      // Enable map selection mode
                                      ref
                                          .read(mapControllerProvider.notifier)
                                          .setDestinationSelectionMode(true);
                                      _destinationFocusNode.unfocus();
                                    },
                                    tooltip: 'Select on Map',
                                  ),
                                ),
                              ),
                              if (_showDestinationDropdown &&
                                  _destinationPredictions.isNotEmpty)
                                Positioned(
                                  top: 40,
                                  left: 0,
                                  right: 0,
                                  child: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 150,
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount:
                                            _destinationPredictions.length,
                                        itemBuilder: (context, index) {
                                          final prediction =
                                              _destinationPredictions[index];
                                          return InkWell(
                                            onTap: () {
                                              _selectPlace(
                                                prediction['place_id'],
                                                prediction['description'],
                                                isOrigin: false,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              child: Text(
                                                prediction['description'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
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
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// ------- GO BUTTON -------
                SizedBox(
                  width: double.infinity,
                  height: 32,
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
                            // Use selected origin or current location (null = current location)
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
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          /// ------- POINTER TRIANGLE -------
          Positioned(
            right: 16,
            top: -8,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(width: 22, height: 22, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

Widget dottedLine() {
  return SizedBox(
    height: 20,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final boxHeight = constraints.maxHeight;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            (boxHeight / 4).floor(),
            (index) => Container(width: 2, height: 2, color: Colors.grey),
          ),
        );
      },
    ),
  );
}
