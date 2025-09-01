// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   // Replace with your Google Maps API Key
//   final String _apiKey = "AIzaSyDcjzxIOfg_gIIgfe45jv4JnJ-5ozuaW_Q";

//   // Controllers and state variables
//   GoogleMapController? _mapController;
//   final TextEditingController _destinationController = TextEditingController();

//   // Initial map position (e.g., a central point)
//   static const LatLng _initialPosition = LatLng(20.5937, 78.9629); // India

//   // Markers and Polylines
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};

//   // Current location
//   LatLng? _currentPosition;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   // 1. Get User's Current Location
//   Future<void> _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Location services are disabled. Please enable them.'),
//         ),
//       );
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permissions are denied')),
//         );
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Location permissions are permanently denied, we cannot request permissions.',
//           ),
//         ),
//       );
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       _currentPosition = LatLng(position.latitude, position.longitude);
//       _mapController?.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(target: _currentPosition!, zoom: 14),
//         ),
//       );
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('currentPosition'),
//           position: _currentPosition!,
//           infoWindow: const InfoWindow(title: 'My Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueAzure,
//           ),
//         ),
//       );
//     });
//   }

//   // 2. Get Directions and Draw Route
//   Future<void> _getDirections(String destination) async {
//     if (_currentPosition == null || destination.isEmpty) {
//       return;
//     }

//     // A. Get destination coordinates from place name (using Places API)
//     String url =
//         'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$destination&inputtype=textquery&fields=geometry&key=$_apiKey';
//     var response = await http.get(Uri.parse(url));
//     var json = jsonDecode(response.body);

//     if (json['status'] != 'OK' || json['candidates'].isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Destination not found.')));
//       return;
//     }

//     var location = json['candidates'][0]['geometry']['location'];
//     LatLng destinationLatLng = LatLng(location['lat'], location['lng']);

//     // B. Get polyline points (using Directions API)
//     PolylinePoints polylinePoints = PolylinePoints();
//     String originStr =
//         '${_currentPosition!.latitude},${_currentPosition!.longitude}';
//     String destStr =
//         '${destinationLatLng.latitude},${destinationLatLng.longitude}';

//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       request: PolylineRequest(
//         origin: PointLatLng(
//           _currentPosition!.latitude,
//           _currentPosition!.longitude,
//         ),
//         destination: PointLatLng(
//           destinationLatLng.latitude,
//           destinationLatLng.longitude,
//         ),
//         mode: TravelMode.driving,
//       ),

//       // travelMode: TravelMode.driving,
//     );

//     setState(() {
//       // Clear previous markers (except current location) and polylines
//       _markers.removeWhere((m) => m.markerId.value != 'currentPosition');
//       _polylines.clear();

//       // Add destination marker
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('destinationPosition'),
//           position: destinationLatLng,
//           infoWindow: InfoWindow(title: destination),
//         ),
//       );

//       // Add polyline to the map
//       if (result.points.isNotEmpty) {
//         _polylines.add(
//           Polyline(
//             polylineId: const PolylineId('route'),
//             points:
//                 result.points
//                     .map((point) => LatLng(point.latitude, point.longitude))
//                     .toList(),
//             color: Colors.blue,
//             width: 5,
//           ),
//         );
//       }

//       // Adjust camera to fit the route
//       _mapController?.animateCamera(
//         CameraUpdate.newLatLngBounds(
//           LatLngBounds(
//             southwest: LatLng(
//               _currentPosition!.latitude < destinationLatLng.latitude
//                   ? _currentPosition!.latitude
//                   : destinationLatLng.latitude,
//               _currentPosition!.longitude < destinationLatLng.longitude
//                   ? _currentPosition!.longitude
//                   : destinationLatLng.longitude,
//             ),
//             northeast: LatLng(
//               _currentPosition!.latitude > destinationLatLng.latitude
//                   ? _currentPosition!.latitude
//                   : destinationLatLng.latitude,
//               _currentPosition!.longitude > destinationLatLng.longitude
//                   ? _currentPosition!.longitude
//                   : destinationLatLng.longitude,
//             ),
//           ),
//           100.0, // Padding
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Google Maps Route'),
//         backgroundColor: Colors.blue.shade700,
//         foregroundColor: Colors.white,
//       ),
//       body: Stack(
//         children: [
//           // Google Map Widget
//           GoogleMap(
//             onMapCreated: (controller) => _mapController = controller,
//             initialCameraPosition: const CameraPosition(
//               target: _initialPosition,
//               zoom: 5,
//             ),
//             markers: _markers,
//             polylines: _polylines,
//             myLocationEnabled: false, // We use a custom marker
//             zoomControlsEnabled: true,
//           ),
//           // Search UI
//           Positioned(
//             top: 10,
//             left: 15,
//             right: 15,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _destinationController,
//                       decoration: const InputDecoration(
//                         hintText: 'Search Destination',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.search),
//                     onPressed: () {
//                       FocusScope.of(context).unfocus(); // Dismiss keyboard
//                       _getDirections(_destinationController.text);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
