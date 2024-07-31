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
              color: const Color(0xFF631515), // Use the desired color
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
          // Main content
          Positioned.fill(
            top: 280, // This ensures the main content starts below the top section
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(top: 50.0), // Adjust the top padding as needed
                      width: 350, // Increase the width slightly
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color(0xFF631515), // Adjust the color as needed
                        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: -175, // This ensures the main content starts below the top section
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(top: 50.0), // Adjust the top padding as needed
                      width: 350, // Increase the width slightly
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF631515), // Adjust the color as needed
                        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: -400, // This ensures the main content starts below the top section
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(top: 50.0), // Adjust the top padding as needed
                      width: 350, // Increase the width slightly
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9), // Adjust the color as needed
                        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            top: 735, // This ensures the main content starts below the top section
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(top: 50.0), // Adjust the top padding as needed
                      width: double.infinity, // Increase the width slightly
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF631515), // Adjust the color as needed

                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}