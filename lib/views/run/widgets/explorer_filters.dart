import 'package:flutter/material.dart';
import '/widgets/custom_button.dart';

class ExplorerFilters extends StatelessWidget {
  const ExplorerFilters({
    super.key,
    required this.distance,
    required this.safety,
    required this.preferences,
    required this.onDistanceChanged,
    required this.onSafetyChanged,
    required this.onPreferencesChanged,
    required this.onApply,
  });

  final bool distance;
  final bool safety;
  final bool preferences;
  final ValueChanged<bool> onDistanceChanged;
  final ValueChanged<bool> onSafetyChanged;
  final ValueChanged<bool> onPreferencesChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Filters',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        CheckboxListTile(
          title: const Text("Distance ≤ 5 km"),
          value: distance,
          onChanged: (v) => onDistanceChanged(v ?? false),
        ),
        CheckboxListTile(
          title: const Text("Safety Rating ≥ 4"),
          value: safety,
          onChanged: (v) => onSafetyChanged(v ?? false),
        ),
        CheckboxListTile(
          title: const Text("Popularity ≥ 70"),
          value: preferences,
          onChanged: (v) => onPreferencesChanged(v ?? false),
        ),
        const SizedBox(height: 8),
        CustomButton(
          label: 'Apply Filters',
          onPressed: onApply,
          color: Colors.purple,
        ),
      ],
    );
  }
}
