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
        print('Raw JSON: ${response.body}');
        List jsonData = jsonDecode(response.body);

        setState(() {
          jammahTimes.clear(); // Clear existing data to avoid duplicates
          for (var eachTime in jsonData) {
            final prayerTime = Time.fromJson(eachTime);
            jammahTimes.add(prayerTime);
          }
          isLoading = false; // Stop loading when data is fetched
        });
        print('Jammah times fetched: ${jammahTimes.length}');
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load Jammah times. Status code: ${response.statusCode}';
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching Jammah times: $e';
      });
      print(errorMessage);
    }
  }

  Future<void> fetchBeginTimes() async {
    try {
      var response = await http.get(Uri.http('10.0.2.2:5000', 'api/begin_times'));

      if (response.statusCode == 200) {
        print('Raw JSON: ${response.body}');
        List jsonData = jsonDecode(response.body);

        setState(() {
          beginTimes.clear(); // Clear existing data to avoid duplicates
          for (var eachTime in jsonData) {
            final prayerTime = Time.fromJson(eachTime);
            beginTimes.add(prayerTime);
          }
          isLoading = false; // Stop loading when data is fetched
        });
        print('Begin times fetched: ${beginTimes.length}');
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load Begin times. Status code: ${response.statusCode}';
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching Begin times: $e';
      });
      print(errorMessage);
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
            top: 0, // Adjust the position as needed
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(0, -50), // Move the logo upwards by 50 pixels
              child: Center(
                child: Image.asset(
                  'assets/icons/soton_isoc_logo.png', // Replace with your logo asset
                  height: 300, // Adjust the size as needed
                  width: double.maxFinite,
                ),
              ),
            ),
          ),
          // Main content
          Positioned.fill(
            top: 200, // Adjusted top padding for main content
            child: Column(
              children: [
                // Error message display
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Display Begin Times
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
                        offset: Offset(0, -25), // Move text up by 10 pixels
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: beginTimes.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                                    child: ListTile(
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 138.0),
                                      title: Text(
                                        '${beginTimes[index].time}',
                                        style: const TextStyle(
                                          fontFamily: 'Helvetica',
                                          color: Colors.white,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Display Jammah Times
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
                        offset: Offset(0, -335), // Move text up by 10 pixels
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: jammahTimes.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                                    child: ListTile(
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 138.0),
                                      title: Text(
                                        '${jammahTimes[index].time}',
                                        style: const TextStyle(
                                          fontFamily: 'Helvetica',
                                          color: Colors.white,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 510, // Adjust this value to align properly
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  width: 350,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF631515),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 650, // Adjust this value to align properly
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  width: 350,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0, // Align at the bottom of the screen
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              color: const Color(0xFF631515),
            ),
          ),
        ],
      ),
    );
  }
}