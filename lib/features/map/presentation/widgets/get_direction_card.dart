import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:presshop/core/utils/ui_utils.dart';
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

    // Initialize with current location address if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<MapBloc>().state;
      if (state.myLocationAddress != null &&
          state.myLocationAddress!.isNotEmpty) {
        setState(() {
          _currentLocationController.text = state.myLocationAddress!;
          _selectedOrigin = state.myLocation;
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

    final url = "${ApiConstantsNew.config.googleMapURL}"
        "?input=$input"
        "&key=${ApiConstantsNew.config.googleMapApiKey}"
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
    final url = "${ApiConstantsNew.config.googlePlaceDetailsURL}"
        "?place_id=$placeId"
        "&key=${ApiConstantsNew.config.googleMapApiKey}";

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
            start: origin ?? const LatLng(0, 0),
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

  void _handleMapSelectedLocation(MapState state) {
    if (state.mapSelectedLocation != null &&
        state.mapSelectedAddress != null &&
        state.mapSelectedIsOrigin != null &&
        state.mapSelectedLocation != _lastProcessedMapLocation) {
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
    final double scalingWidth = isIpad ? 550 : size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade300;

    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state.mapSelectedLocation != null &&
            state.mapSelectedAddress != null &&
            state.mapSelectedIsOrigin != null &&
            state.mapSelectedLocation != _lastProcessedMapLocation) {
          _handleMapSelectedLocation(state);
        }

        if (state.myLocationAddress != null) {
          if (_currentLocationController.text.isEmpty ||
              _currentLocationController.text == 'Current Location') {
            setState(() {
              _currentLocationController.text = state.myLocationAddress!;
              _selectedOrigin = state.myLocation;
            });
          }
        }
      },
      child: SizedBox(
        width: scalingWidth * 0.7,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// ------- POINTER TRIANGLE (Behind Card) -------
            Positioned(
              right: scalingWidth * 0.04,
              top: -scalingWidth * 0.02,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: scalingWidth * 0.05,
                  height: scalingWidth * 0.05,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(
                        color: isDark ? borderColor : Colors.transparent,
                        width: 1.2),
                  ),
                ),
              ),
            ),

            Container(
              width: scalingWidth * 0.7,
              padding: EdgeInsets.all(scalingWidth * 0.035),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isDark ? borderColor : Colors.transparent,
                    width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
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
                      fontSize: scalingWidth * 0.028,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),

                  SizedBox(height: scalingWidth * 0.02),
                  Divider(height: 1, color: borderColor),
                  SizedBox(height: scalingWidth * 0.025),

                  /// ------- LOCATION INPUTS -------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.my_location,
                            size: scalingWidth * 0.045,
                            color: Colors.redAccent,
                          ),
                          SizedBox(height: scalingWidth * 0.02),
                          dottedLine(borderColor),
                          SizedBox(height: scalingWidth * 0.02),
                          Icon(
                            Icons.location_on_outlined,
                            size: scalingWidth * 0.045,
                            color: const Color.fromARGB(255, 121, 121, 121),
                          ),
                        ],
                      ),
                      SizedBox(width: scalingWidth * 0.04),
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
                                style: TextStyle(
                                  fontSize: scalingWidth * 0.035,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Your Location',
                                  filled: true,
                                  hintStyle:
                                      TextStyle(fontSize: scalingWidth * 0.035),
                                  fillColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: scalingWidth * 0.02,
                                    horizontal: scalingWidth * 0.03,
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.pink,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: scalingWidth * 0.03),
                            CompositedTransformTarget(
                              link: _destinationLayerLink,
                              child: TextField(
                                controller: _destinationController,
                                focusNode: _destinationFocusNode,
                                onChanged: (value) =>
                                    _searchPlaces(value, isOrigin: false),
                                style: TextStyle(
                                  fontSize: scalingWidth * 0.035,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Destination',
                                  hintStyle:
                                      TextStyle(fontSize: scalingWidth * 0.035),
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: scalingWidth * 0.02,
                                    horizontal: scalingWidth * 0.03,
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: borderColor,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Colors.pink,
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

                  SizedBox(height: scalingWidth * 0.035),

                  /// ------- GO BUTTON -------
                  SizedBox(
                    width: double.infinity,
                    height: scalingWidth * 0.1,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_destinationController.text.isEmpty) {
                                return;
                              }

                              final origin = _selectedOrigin;

                              final state = context.read<MapBloc>().state;
                              final destination =
                                  _selectedDestination ?? state.destination;
                              if (destination != null) {
                                await _getRoute(origin, destination);
                                if (context.mounted) {
                                  context
                                      .read<MapBloc>()
                                      .add(StartNavigationEvent());
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: scalingWidth * 0.045,
                              height: scalingWidth * 0.045,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
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
                                fontSize: scalingWidth * 0.028,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            /// ------- DROPDOWNS (On Top) -------
            if (_showCurrentLocationDropdown &&
                _currentLocationPredictions.isNotEmpty)
              CompositedTransformFollower(
                link: _originLayerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 40),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 150,
                      maxWidth: 200,
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
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              prediction['description'],
                              style: const TextStyle(fontSize: 12),
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
                offset: const Offset(0, 40),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 150,
                      maxWidth: 200,
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
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              prediction['description'],
                              style: const TextStyle(fontSize: 12),
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
      ),
    );
  }
}

Widget dottedLine(Color color) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 2,
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
      ),
      const SizedBox(height: 1),
      Container(width: 2, height: 6, color: color),
      const SizedBox(height: 1),
      Container(
        width: 2,
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
        ),
      ),
    ],
  );
}
