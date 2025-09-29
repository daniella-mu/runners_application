import 'package:flutter/material.dart';
import '/models/route_model.dart';

class RouteDetailsScreen extends StatelessWidget {
  const RouteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the RouteModel passed from RoutesExplorer
    final RouteModel route =
        ModalRoute.of(context)!.settings.arguments as RouteModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(route.name),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //  Route name
            Text(
              route.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            //  Description
            Text(
              route.description,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            //  Route stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                      "${(route.distanceM / 1000).toStringAsFixed(1)} km"),
                  avatar: const Icon(Icons.route, color: Colors.white, size: 20),
                  backgroundColor: Colors.teal,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                Chip(
                  label: Text(" ${route.averageRating}"),
                  avatar: const Icon(Icons.star, color: Colors.white, size: 20),
                  backgroundColor: Colors.orange,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                Chip(
                  label: Text(" ${route.popularity}%"),
                  avatar:
                      const Icon(Icons.trending_up, color: Colors.white, size: 20),
                  backgroundColor: Colors.purple,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 30),

            //  Placeholder for map preview
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Text("🗺️ Map preview of this route"),
              ),
            ),
            const SizedBox(height: 30),

            //  User Comments Section
            const Text(
              "User Comments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "“Great route with lots of shade and water fountains. Perfect for a sunny day!” – Alex",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "“Loved the scenic views along the river. Watch out for the steep hill midway!” – Priya",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "“A bit crowded during weekends, but overall a fantastic run.” – Sam",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            //  Start Run button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // later connect this to your gps_run_screen
                  debugPrint("Starting run on ${route.name}");
                },
                icon: const Icon(Icons.directions_run),
                label: const Text(
                  "Start Run",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
