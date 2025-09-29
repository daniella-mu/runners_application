import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/controllers/routes_controller.dart';
import '/models/route_model.dart';

class RoutesExplorerScreen extends StatefulWidget {
  const RoutesExplorerScreen({super.key});

  @override
  State<RoutesExplorerScreen> createState() => _RoutesExplorerScreenState();
}

class _RoutesExplorerScreenState extends State<RoutesExplorerScreen> {
  final RoutesController _controller = RoutesController();
  late Future<List<RouteModel>> _routesFuture;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  bool _distance = false;
  bool _safety = false;
  bool _preferences = false;

  @override
  void initState() {
    super.initState();
    _routesFuture = _controller.fetchRoutes();
  }

  void _addMarkers(List<RouteModel> routes) {
    _markers.clear();
    for (var route in routes) {
      _markers.add(
        Marker(
          markerId: MarkerId(route.routeId.toString()),
          position: LatLng(route.startLatitude, route.startLongitude),
          infoWindow: InfoWindow(
            title: route.name,
            snippet:
                "${(route.distanceM / 1000).toStringAsFixed(1)} km • ⭐ ${route.averageRating}",
            onTap: () {
              Navigator.pushNamed(
                context,
                '/route-details',
                arguments: route,
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Routes"),
        backgroundColor: Colors.purple,
      ),

      body: Column(
        children: [
          // 🔎 Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search routes...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // 🗺️ Map section
          SizedBox(
            height: 300,
            child: FutureBuilder<List<RouteModel>>(
              future: _routesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  _addMarkers(snapshot.data!);
                  return GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(-1.2921, 36.8219), // Nairobi center
                      zoom: 12,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text("No routes found"));
                }
              },
            ),
          ),

          // 📋 Routes + Filters in scrollable area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 📋 Routes list
                  FutureBuilder<List<RouteModel>>(
                    future: _routesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("Error: ${snapshot.error}"));
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        final routes = snapshot.data!;
                        return Column(
                          children: routes.map((route) {
                            return ListTile(
                              leading: const Icon(Icons.directions_run,
                                  color: Colors.purple),
                              title: Text(route.name),
                              subtitle: Text(
                                "${(route.distanceM / 1000).toStringAsFixed(1)} km • ⭐ ${route.averageRating}",
                              ),
                              onTap: () {
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(route.startLatitude,
                                        route.startLongitude),
                                    14,
                                  ),
                                );
                                Navigator.pushNamed(
                                  context,
                                  '/route-details',
                                  arguments: route,
                                );
                              },
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(child: Text("No routes found"));
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // ✅ Scrollable Filters
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        title: const Text("Distance"),
                        value: _distance,
                        onChanged: (val) =>
                            setState(() => _distance = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: const Text("Safety Rating"),
                        value: _safety,
                        onChanged: (val) =>
                            setState(() => _safety = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      CheckboxListTile(
                        title: const Text("User Preferences"),
                        value: _preferences,
                        onChanged: (val) =>
                            setState(() => _preferences = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      // Apply Filters button
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              debugPrint(
                                  "Filters applied: Distance=$_distance, Safety=$_safety, Preferences=$_preferences");
                            },
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: const Text(
                              "Apply Filters",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
