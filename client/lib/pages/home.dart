import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/time.dart'; // Ensure these models exist in your project

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Time> beginTimes = [];
  List<Time> jammahTimes = [];
  String? currentDate; // To store the current date
  String? islamicDate; // To store the Islamic date
  bool isLoading = true; // Loading state indicator
  String errorMessage = ''; // To display error messages if any
  List<String> prayerNames = ['Fajr', 'Zuhr', 'Asr', 'Maghrib', 'Isha'];

  // Custom margins for each prayer name
  List<EdgeInsets> prayerMargins = [
    const EdgeInsets.only(left: 25.0), // Fajr
    const EdgeInsets.only(left: 21.0), // Zuhr
    const EdgeInsets.only(left: 26.0), // Asr
    const EdgeInsets.only(left: 0.0),  // Maghrib
    const EdgeInsets.only(left: 21.0), // Isha
  ];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch prayer times and dates on init
  }

  // Fetch all data
  Future<void> fetchData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      await Future.wait([
        fetchBeginTimes(),
        fetchJammahTimes(),
        fetchDates(), // Fetch both dates
      ]);

      setState(() {
        isLoading = false; // Stop loading when data is fetched
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading if error occurs
        errorMessage = 'Failed to fetch data: $e'; // Set error message
      });
    }
  }

  // Fetch prayer begin times
  Future<void> fetchBeginTimes() async {
    try {
      var response = await http.get(Uri.http('10.0.2.2:5000', 'api/begin_times'));

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        setState(() {
          beginTimes = jsonData.map((eachTime) => Time.fromJson(eachTime)).toList();
        });
      } else {
        throw Exception('Failed to load Begin times. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Begin times: $e');
    }
  }

  // Fetch prayer jammah times
  Future<void> fetchJammahTimes() async {
    try {
      var response = await http.get(Uri.http('10.0.2.2:5000', 'api/jammah_times'));

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        setState(() {
          jammahTimes = jsonData.map((eachTime) => Time.fromJson(eachTime)).toList();
        });
      } else {
        throw Exception('Failed to load Jammah times. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Jammah times: $e');
    }
  }

  // Fetch current date and Islamic date
  Future<void> fetchDates() async {
    try {
      var response1 = await http.get(Uri.http('10.0.2.2:5000', '/api/current_date'));
      var response2 = await http.get(Uri.http('10.0.2.2:5000', '/api/islamic_date'));

      if (response1.statusCode == 200 && response2.statusCode == 200) {
        var jsonData1 = jsonDecode(response1.body);
        var jsonData2 = jsonDecode(response2.body);
        setState(() {
          currentDate = jsonData1['current_date'];
          islamicDate = jsonData2['islamic_date'];
        });
      } else {
        throw Exception(
            'Failed to load dates. Status codes: ${response1.statusCode}, ${response2.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching dates: $e');
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
    offset: const Offset(0, -75), // Move the logo upwards by 75 pixels
    child: Center(
    child: Image.asset(
    'assets/icons/soton_isoc_logo.png',
    height: 350, // Adjust the size as needed
    width: double.maxFinite,
    ),
    ),
    ),
    ),

    // Main content box with prayer times
    Positioned.fill(
    top: 290, // Adjusted top padding for main content
    child: Center(
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0.0),
    width: 330, // Adjust width to make the box smaller
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
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spacing between items
    children: [
    Expanded(
    flex: 3,
    child: Container(
    alignment: Alignment.centerLeft, // Align to the left
    child: const Padding(padding: EdgeInsets.only(left: 27.0), // Reduced padding
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
                  padding: const EdgeInsets.only(left: 10.0), // Adjust padding
                  child: Text(
                    jammahTimes.length > index ? jammahTimes[index].time : 'N/A',
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

    // New smaller box for dates
    Positioned(
    top: 180, // Position below the main content
    left: 0,
    right: 0,
    child: Center(
    child: Container(
    width: 330, // Smaller width
    height: 60, // Smaller height
    decoration: BoxDecoration(
    color: const Color(0xFFD9D9D9), // Use the specified color
    borderRadius: BorderRadius.circular(15),
    ),
    child: Center(
    child: isLoading
    ? const CircularProgressIndicator() // Show loading spinner
        : Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    currentDate ?? 'Loading current date...',
    style: const TextStyle(fontSize: 14, color: Color(0xFF631515), fontWeight:FontWeight.bold, ),
    ),
    Text(
    islamicDate ?? 'Loading Islamic date...',
    style: const TextStyle(fontSize: 14, color: Color(0xFF631515)),
    ),
    ],
    ),
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