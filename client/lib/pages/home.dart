import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top section background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150, // Adjust the height as needed
            child: Container(
              color: Color(0xFF631515), // Use the desired color
            ),
          ),
          // Logo in the center of the top section
          Positioned(
            top: -85, // Adjust the position as needed
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/icons/soton_isoc_logo.png', // Replace with your logo asset
                height: 350, // Adjust the size as needed
              ),
            ),
          ),
          // Rest of the content
          Positioned.fill(
            top: 150, // This ensures the main content starts below the top section
            child: Center(
              child: Text('Your main content goes here'),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}