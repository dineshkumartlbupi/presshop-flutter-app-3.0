import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(GetCurrentLocationEvent()),
      child: Scaffold(
        body: BlocConsumer<MapBloc, MapState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            if (state.myLocation != null && _controller != null) {
              _controller?.animateCamera(
                CameraUpdate.newLatLngZoom(state.myLocation!, 14),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: state.initialCamera ??
                      const CameraPosition(
                        target: LatLng(0, 0),
                        zoom: 2,
                      ),
                  onMapCreated: (controller) {
                    _controller = controller;
                    if (state.myLocation != null) {
                      _controller?.animateCamera(
                        CameraUpdate.newLatLngZoom(state.myLocation!, 14),
                      );
                    }
                  },
                  markers: state.markers,
                  polylines: state.polylines,
                  polygons: state.polygons,
                  circles: state.circles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: (position) {
                    // Handle map tap if needed
                  },
                ),
                if (state.isLoadingNews) // Or a general loading flag
                  const Center(child: CircularProgressIndicator()),
                Positioned(
                  top: 50,
                  left: 15,
                  right: 15,
                  child: Card(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search location...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                      ),
                      onSubmitted: (value) {
                        context
                            .read<MapBloc>()
                            .add(SearchPlacesEvent(query: value));
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
