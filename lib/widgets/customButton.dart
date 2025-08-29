import 'package:flutter/material.dart';

Widget customButton(String btnName, VoidCallback onTap) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: onTap,

    child: Text(btnName, style: TextStyle(fontSize: 16)),
  );
}
