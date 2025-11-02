import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;                // shows heading above field
  final String? hint;                 // optional placeholder text
  final bool obscure;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefixIcon;           // optional, you can skip this now
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscure = false,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,             // heading above the field
        hintText: hint,
        //  Add this labelStyle to make labels darker and readable
        labelStyle: const TextStyle(
          color: Colors.black87,      // darker text instead of light gray
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}
