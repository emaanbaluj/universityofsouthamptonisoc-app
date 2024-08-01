import 'dart:convert';
import 'package:client/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/time.dart'; // Ensure this path is correct based on your project structure

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(), // Ensure HomePage is correctly implemented
    );
  }
}