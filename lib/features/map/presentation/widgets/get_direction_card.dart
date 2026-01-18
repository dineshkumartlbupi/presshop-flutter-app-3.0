import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';

class GetDirectionCard extends StatefulWidget {
  const GetDirectionCard({super.key});

  @override
  State<GetDirectionCard> createState() => _GetDirectionCardState();
}

class _GetDirectionCardState extends State<GetDirectionCard> {
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
      context.read<MapBloc>().add(GetRouteEvent(
            start: origin ??
                const LatLng(
                    0, 0), // Handle null origin appropriately in Bloc or Logic
            end: destination,
          ));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

/*
  Future<void> _useCurrentLocation() async {
     final state = context.read<MapBloc>().state;
    if (state.myLocation != null) {
      setState(() {
        _currentLocationController.text = 'Current Location';
        _selectedOrigin = null; // Use null to signify current location
        _currentLocationFocusNode.unfocus();
      });

      if (_selectedDestination != null) {
        await _getRoute(_selectedOrigin, _selectedDestination!);
      }
    }
  }
*/

  void _handleMapSelectedLocation(MapState state) {
    // Only process if we have a new selection that hasn't been processed
    if (state.mapSelectedLocation != null &&
        state.mapSelectedAddress != null &&
        state.mapSelectedIsOrigin != null &&
        state.mapSelectedLocation != _lastProcessedMapLocation) {
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

      context.read<MapBloc>().add(ClearMapSelectedLocationEvent());

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
    final size = MediaQuery.of(context).size;

    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state.mapSelectedLocation != null &&
            state.mapSelectedAddress != null &&
            state.mapSelectedIsOrigin != null &&
            state.mapSelectedLocation != _lastProcessedMapLocation) {
          _handleMapSelectedLocation(state);
        }
      },
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size.width * numD70,
                padding: EdgeInsets.all(size.width * numD032),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * numD042),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: size.width * numD032,
                      spreadRadius: 1.0,
                      offset: Offset(0.0, 0.0),
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
                        fontSize: size.width * numD026,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),

                    SizedBox(height: size.width * numD021),
                    const Divider(height: 1.0, color: Colors.black12),
                    SizedBox(height: size.width * numD026),

                    /// ------- LOCATION INPUTS -------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.my_location,
                              size: size.width * numD048,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 8),
                            dottedLine(),
                            const SizedBox(height: 8),
                            Icon(
                              Icons.location_on_outlined,
                              size: size.width * numD048,
                              color: Color.fromARGB(255, 121, 121, 121),
                            ),
                          ],
                        ),
                        SizedBox(width: size.width * numD048),
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
                                    hintStyle: TextStyle(
                                        fontSize: size.width * numD032),
                                    fillColor: Colors.grey.shade100,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: size.width * numD021,
                                      horizontal: size.width * numD032,
                                    ),
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD021),
                                      borderSide: BorderSide(
                                        color: Color(0xFFBDBDBD),
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD021),
                                      borderSide: BorderSide(
                                        color: colorThemePink,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.width * numD032),
                              CompositedTransformTarget(
                                link: _destinationLayerLink,
                                child: TextField(
                                  controller: _destinationController,
                                  focusNode: _destinationFocusNode,
                                  onChanged: (value) =>
                                      _searchPlaces(value, isOrigin: false),
                                  decoration: InputDecoration(
                                    hintText: 'Destination',
                                    hintStyle: TextStyle(
                                        fontSize: size.width * numD032),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: size.width * numD021,
                                      horizontal: size.width * numD032,
                                    ),
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD021),
                                      borderSide: BorderSide(
                                        color: Color(0xFFBDBDBD),
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD021),
                                      borderSide: BorderSide(
                                        color: colorThemePink,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.width * numD037),

                    /// ------- GO BUTTON -------
                    SizedBox(
                      width: double.infinity,
                      height: size.width * numD09,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_destinationController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please enter a destination'),
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
                                  if (context.mounted) {
                                    context
                                        .read<MapBloc>()
                                        .add(StartNavigationEvent());
                                  }
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
                          elevation: 0.0,
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * numD021),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: size.width * numD042,
                                height: size.width * numD042,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'GO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: size.width * numD026,
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
                right: size.width * numD03, // Align towards the right
                top: -size.width * numD021,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                      width: size.width * numD058,
                      height: size.width * numD058,
                      color: Colors.white),
                ),
              ),

              /// ------- DROPDOWNS (On Top) -------
              if (_showCurrentLocationDropdown &&
                  _currentLocationPredictions.isNotEmpty)
                CompositedTransformFollower(
                  link: _originLayerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0.0, size.width * numD10),
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(size.width * numD021),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.width * numD40,
                        maxWidth: size.width *
                            numD53, // Match approx width of text field
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
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD032,
                                vertical: size.width * numD021,
                              ),
                              child: Text(
                                prediction['description'],
                                style:
                                    TextStyle(fontSize: size.width * numD032),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              if (_showDestinationDropdown &&
                  _destinationPredictions.isNotEmpty)
                CompositedTransformFollower(
                  link: _destinationLayerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0.0, size.width * numD10),
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(size.width * numD021),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: size.width * numD40,
                        maxWidth: size.width * numD53,
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
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD032,
                                vertical: size.width * numD021,
                              ),
                              child: Text(
                                prediction['description'],
                                style:
                                    TextStyle(fontSize: size.width * numD032),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

Widget dottedLine() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 2.0,
        height: 3.0,
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(2.0), topRight: Radius.circular(2.0)),
        ),
      ),
      SizedBox(height: 1.0),
      Container(width: 2.0, height: 6.0, color: Colors.grey),
      SizedBox(height: 1.0),
      Container(
        width: 2.0,
        height: 3.0,
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(2.0),
              bottomRight: Radius.circular(2.0)),
        ),
      ),
    ],
  );
}
