import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Import this if needed for debugging
import 'package:client/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: HomePage(),
    );
  }
}