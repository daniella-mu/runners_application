import 'package:flutter/material.dart';
import '/widgets/custom_textfield.dart';

class ExplorerSearchBar extends StatelessWidget {
  const ExplorerSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hint: 'Search routes...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
      onSubmitted: onSubmitted,
      // NOTE: CustomTextField doesn't expose onChanged directly in your version;
      // if yours doesn’t, wrap with Listener. If it does, pass onChanged here:
      // onChanged: onChanged,
    );
  }
}
