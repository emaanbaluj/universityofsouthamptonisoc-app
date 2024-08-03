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
  List<Time> beginTimes = [];
  List<Time> jammahTimes = [];
  bool isLoading = true; // To manage loading state
  String errorMessage = ''; // To display error messages
  List<String> prayerNames = ['Fajr', 'Zuhr', 'Asr', 'Maghrib', 'Isha'];

  // Add a list of custom margins for each prayer name
  List<EdgeInsets> prayerMargins = [
    EdgeInsets.only(left: 25.0), // Fajr
    EdgeInsets.only(left: 21.0), // Zuhr
    EdgeInsets.only(left: 26.0), // Asr
    EdgeInsets.only(left: 0.0), // Maghrib
    EdgeInsets.only(left: 21.0), // Isha
  ];

  @override
  void initState() {
    super.initState();
    fetchBeginTimes();
    fetchJammahTimes();
  }

  Future<void> fetchJammahTimes() async {
    try {
      var response = await http.get(Uri.http('10.0.2.2:5000', 'api/jammah_times'));

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);

        setState(() {
          jammahTimes.clear(); // Clear existing data to avoid duplicates
          for (var eachTime in jsonData) {
            final prayerTime = Time.fromJson(eachTime);
            jammahTimes.add(prayerTime);
          }
          isLoading = false; // Stop loading when data is fetched
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load Jammah times. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching Jammah times: $e';
      });
    }
  }

  Future<void> fetchBeginTimes() async {
    try {
      var response = await http.get(Uri.http('10.0.2.2:5000', 'api/begin_times'));

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);

        setState(() {
          beginTimes.clear(); // Clear existing data to avoid duplicates
          for (var eachTime in jsonData) {
            final prayerTime = Time.fromJson(eachTime);
            beginTimes.add(prayerTime);
          }
          isLoading = false; // Stop loading when data is fetched
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load Begin times. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching Begin times: $e';
      });
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
            height: 150,
            child: Container(
              color: const Color(0xFF631515), // Use the desired color
            ),
          ),
          // Logo in the center of the top section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: const Offset(0, -75),
              // Move the logo upwards by 75 pixels
              child: Center(
                child: Image.asset(
                  'assets/icons/soton_isoc_logo.png',
                  height: 350, // Adjust the size as needed
                  width: double.maxFinite,
                ),
              ),
            ),
          ),
          // Main content
          Positioned.fill(
            top: 290, // Adjusted top padding for main content
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
                width: 330,
                // Adjust width to make the box smaller
                height: 255,
                decoration: BoxDecoration(
                  color: const Color(0xFF631515),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Spacing between items
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.centerLeft, // Align to the left
                            child: const Padding(
                              padding: EdgeInsets.only(left: 27.0), // Reduced padding
                              child: Text(
                                'Ṣalāh',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.center, // Center alignment
                            child: const Text(
                              'Begins',
                              style: TextStyle(
                                fontFamily: 'Helvetica',
                                color: Colors.white,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            alignment: Alignment.centerRight, // Align to the right
                            child: const Padding(
                              padding: EdgeInsets.only(right: 12.0), // Reduced padding
                              child: Text(
                                'Jama’ah',
                                style: TextStyle(
                                  fontFamily: 'Helvetica',
                                  color: Colors.white,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5), // Reduced space between headers and content
                    // Space between headers and content
                    // Prayer Times
                    ...prayerNames.asMap().entries.map((entry) {
                      final index = entry.key;
                      final prayerName = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0), // Reduced padding
                        child: Row(
                          children: [
                            // Prayer Name with custom margin
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: prayerMargins[index],
                                child: Text(
                                  prayerName,
                                  style: const TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: Colors.white,
                                    fontSize: 24.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            // Begin Time
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  beginTimes.length > index ? beginTimes[index].time : 'N/A',
                                  style: const TextStyle(
                                    fontFamily: 'Helvetica',
                                    color: Colors.white,
                                    fontSize: 24.0,
                                  ),
                                ),
                              ),
                            ),
                            // Jammah Time
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.center, // Change to center alignment
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10.0), // Adjust padding
                                  child: Text(
                                    jammahTimes.length > index
                                        ? jammahTimes[index].time
                                        : 'N/A',
                                    style: const TextStyle(
                                      fontFamily: 'Helvetica',
                                      color: Colors.white,
                                      fontSize: 24.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          // Footer Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: const Color(0xFF631515),
            ),
          ),
        ],
      ),
    );
  }
}