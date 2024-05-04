import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationTracker extends StatelessWidget {
  const LocationTracker({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        currentPosition = position;
      });
    } else {
      LocationPermission permissionRequested =
          await Geolocator.requestPermission();
      if (permissionRequested == LocationPermission.always ||
          permissionRequested == LocationPermission.whileInUse) {
        _getUserLocation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real-Time Location Tracker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: currentPosition != null
          ? GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                ),
                zoom: 16,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: {
                Marker(
                  markerId: MarkerId('my-current-location'),
                  position: LatLng(
                    currentPosition!.latitude,
                    currentPosition!.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: 'My Current Location',
                    snippet:
                        '${currentPosition!.latitude}${currentPosition!.longitude}',
                  ),
                ),
                const Marker(
                  markerId: MarkerId('my-previous-location'),
                  position: LatLng(23.79318, 90.29625),
                  infoWindow: InfoWindow(
                    title: 'My Previous Location',
                    snippet: '23.79318,90.29625',
                  ),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId('poly_one'),
                  color: Colors.blueAccent,
                  width: 5,
                  points: [
                    LatLng(
                        currentPosition!.latitude, currentPosition!.longitude),
                    LatLng(23.79318, 90.29625),
                  ],
                ),
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
