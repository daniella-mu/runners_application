// lib/views/home/widgets/start_run_button.dart
import 'package:flutter/material.dart';
import '/models/route_model.dart';
import '/views/run/gps_run_screen.dart';

class StartRunButton extends StatelessWidget {
  final RouteModel route;
  final Color color;

  const StartRunButton({super.key, required this.route, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GpsRunScreen(route: route)),
          );
        },
        icon: const Icon(Icons.directions_run),
        label: const Text(
          'Start Run',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
