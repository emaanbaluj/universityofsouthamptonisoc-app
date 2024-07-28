import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color(0xFF631515),
            height: 40.0,  // Adjust the height as needed
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Home Page'),
                backgroundColor: Color(0xFF631515),
              ),
              body: Center(
                child: Text('Welcome to the Home Page!'),
              ),
            ),
          ),
          Container(
            color: Color(0xFF631515),
            height: 90.0,  // Adjust the height as needed
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}