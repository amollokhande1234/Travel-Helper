import 'package:flutter/material.dart';

Widget buildTextField(
  TextEditingController? controller,
  String hint,
  IconData icon, {
  bool isPassword = false,
  TextInputType? textInputType,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    style: const TextStyle(color: Colors.black),
    keyboardType: textInputType,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
