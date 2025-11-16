import 'package:flutter/material.dart';
import '/models/route_model.dart';

class RoutesList extends StatelessWidget {
  const RoutesList({super.key, required this.routes, required this.onTap});

  final List<RouteModel> routes;
  final void Function(RouteModel) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Routes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Results: ${routes.length}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...routes.map(
          (r) => ListTile(
            leading: const Icon(Icons.directions_run, color: Colors.purple),
            title: Text(r.name),
            subtitle: Text(
              '${(r.distanceM / 1000).toStringAsFixed(1)} km • ⭐ ${r.averageRating}',
            ),
            onTap: () => onTap(r),
          ),
        ),
      ],
    );
  }
}
