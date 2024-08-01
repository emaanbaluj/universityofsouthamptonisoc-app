import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/time.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Time> prayerTimes = [];

  @override
  void initState() {
    super.initState();
    fetchBeginTimes();
  }

  Future<void> fetchBeginTimes() async {
    try {
      // Use '10.0.2.2' for Android emulator, '127.0.0.1' for iOS simulator, or your machine's IP for a physical device
      var response = await http.get(Uri.http('10.0.2.2:5000', 'api/begin_times'));

      if (response.statusCode == 200) {
        // Print the raw JSON for debugging
        print('Raw JSON: ${response.body}');

        // Decode JSON directly into a List
        List jsonData = jsonDecode(response.body);

        setState(() {
          prayerTimes.clear(); // Clear existing data to avoid duplicates
          for (var eachTime in jsonData) {
            final prayerTime = Time.fromJson(eachTime);
            prayerTimes.add(prayerTime);
          }
        });

        print('Prayer times fetched: ${prayerTimes.length}');
      } else {
        print('Failed to load prayer times. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
    }
  }

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
            top: 280,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.only(top: 0),
                      width: 350,
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color(0xFF631515),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Transform.translate(
                        offset: Offset(0, -20), // Move text up by 10 pixels
                        child: prayerTimes.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: prayerTimes.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0.0),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 138.0),
                                title: Text(
                                  '${prayerTimes[index].time}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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