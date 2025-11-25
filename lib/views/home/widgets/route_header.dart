// lib/views/home/widgets/route_header.dart
import 'package:flutter/material.dart';
import '/models/route_model.dart';

class RouteHeader extends StatelessWidget {
  final RouteModel route;

  /// NEW: dynamic rating coming from live feedback
  final double? overrideAverageRating;

  const RouteHeader({
    super.key,
    required this.route,
    this.overrideAverageRating, //  NEW
  });

  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFF9C27B0);

    // If override exists → use it; else fallback to DB value
    final double rating = overrideAverageRating ?? route.averageRating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          route.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),

        // ⭐ Updated to use dynamic rating
        _RatingStars(rating: rating),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(
              icon: Icons.route,
              label: '${(route.distanceM / 1000).toStringAsFixed(1)} km',
              color: Colors.teal,
            ),
            _StatChip(
              icon: Icons.star_rate_rounded,
              label: rating.toStringAsFixed(1), // 👈 updated here
              color: Colors.orange,
            ),
            _StatChip(
              icon: Icons.trending_up,
              label: '${route.popularity}%', // ❗ keep for now (static)
              color: purple,
            ),
          ],
        ),

        if (route.description.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            route.description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;

    return Row(
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        }
        if (i == full && hasHalf) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        }
        return const Icon(Icons.star_border, color: Colors.amber, size: 18);
      }),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 18),
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
