import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapRoutePage extends StatefulWidget {
  const MapRoutePage({super.key});
  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  GoogleMapController? mapController;
  LatLng? currentLocation;
  LatLng? destination;
  Set<Polyline> polylines = {};
  final TextEditingController searchController = TextEditingController();
  String routeType =
      "driving-car"; // driving-car, foot-walking, cycling-regular

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> searchPlace(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'FlutterApp'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      if (data.isNotEmpty) {
        setState(() {
          destination = LatLng(
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon']),
          );
        });
        getRoute();
      }
    }
  }

  Future<void> getRoute() async {
    if (currentLocation == null || destination == null) return;

    final apiKey = dotenv.env['OPENROUTESERVICE_API_KEY'];
    final url = 'https://api.openrouteservice.org/v2/directions/$routeType';
    final body = jsonEncode({
      "coordinates": [
        [currentLocation!.longitude, currentLocation!.latitude],
        [destination!.longitude, destination!.latitude],
      ],
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Authorization': apiKey!, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;

      List<LatLng> points =
          coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();

      setState(() {
        polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        };
      });

      // Move camera to fit route
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            _boundsFromLatLngList([currentLocation!, destination!]),
            50,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get route: ${response.statusCode}")),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double south = list.first.latitude;
    double north = list.first.latitude;
    double west = list.first.longitude;
    double east = list.first.longitude;

    for (var latLng in list) {
      if (latLng.latitude > north) north = latLng.latitude;
      if (latLng.latitude < south) south = latLng.latitude;
      if (latLng.longitude > east) east = latLng.longitude;
      if (latLng.longitude < west) west = latLng.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Maps Route")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search destination",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      searchPlace(searchController.text);
                    }
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: routeType,
                items: const [
                  DropdownMenuItem(
                    value: "driving-car",
                    child: Text("Driving"),
                  ),
                  DropdownMenuItem(
                    value: "foot-walking",
                    child: Text("Walking"),
                  ),
                  DropdownMenuItem(
                    value: "cycling-regular",
                    child: Text("Cycling"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      routeType = value;
                      getRoute();
                    });
                  }
                },
              ),
            ],
          ),
          Expanded(
            child:
                currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: currentLocation!,
                        zoom: 14,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: {
                        if (currentLocation != null)
                          Marker(
                            markerId: const MarkerId("current"),
                            position: currentLocation!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue,
                            ),
                          ),
                        if (destination != null)
                          Marker(
                            markerId: const MarkerId("destination"),
                            position: destination!,
                          ),
                      },
                      polylines: polylines,
                      onMapCreated: (controller) => mapController = controller,
                    ),
          ),
        ],
      ),
    );
  }
}
