import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  double lat = 18.5246;
  double long = 73.8786;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,

            initialCameraPosition: CameraPosition(
              target: LatLng(lat, long),
              zoom: 15,
            ),
          ),
          Center(child: Icon(Icons.location_on)),
        ],
      ),
    );
  }
}
