import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = "Fetching location...";
  String _areaName = "Fetching area...";

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    // Check for location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permission denied.";
        });
        return;
      }
    }

    // Check if location services are enabled
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });

    // Reverse Geocoding to get the area name
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      // Assuming the first placemark is the most relevant one
      if (placemarks.isNotEmpty) {
        setState(() {
          // Extracting relative area (like city or neighborhood)
          _areaName =
              "${placemarks[0].locality ?? ''}, ${placemarks[0].subLocality ?? ''}, ${placemarks[0].locality ?? ''}";
        });
      } else {
        setState(() {
          _areaName = "No area name found.";
        });
      }
    } catch (e) {
      setState(() {
        _areaName = "Error in geocoding: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_locationMessage),
            SizedBox(height: 20),
            Text(_areaName),
          ],
        ),
      ),
    );
  }
}
