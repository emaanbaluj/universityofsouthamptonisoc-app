import 'dart:async';
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
  String? currentPrayer; // Track the current prayer name
  String? nextPrayer; // Track the next prayer name
  Duration? _timeUntilNextPrayer;
  Timer? _countdownTimer;
  bool isLoading = true;
  String errorMessage = '';

  // List of prayer names corresponding to the times
  final List<String> prayerNames = ['Fajr', 'Zuhr', 'Asr', 'Maghrib', 'Isha'];

  // Custom margins for each prayer name
  final List<EdgeInsets> prayerMargins = [
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

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      await Future.wait([
        fetchBeginTimes(),
        fetchJammahTimes(),
        fetchDates(),
      ]);

      // Calculate the time until the next prayer after data is fetched
      _calculateTimeUntilNextPrayer();

      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to fetch data: $e';
      });
    }
  }

  void _calculateTimeUntilNextPrayer() {
    DateTime now = DateTime.now().toLocal(); // Ensure we are using the local time
    print('Current Time: $now'); // Log the current time

    // Parse the prayer times into DateTime objects for today
    List<DateTime> prayerTimes = beginTimes.map((time) {
      DateTime parsedTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(time.time.split(":")[0]),
        int.parse(time.time.split(":")[1]),
      ).toLocal(); // Convert to local time just to be sure
      print('Parsed Prayer Time: $parsedTime'); // Log each parsed prayer time
      return parsedTime;
    }).toList();

    // Sort the prayer times to ensure they are in chronological order
    prayerTimes.sort((a, b) => a.compareTo(b));

    // Find the current prayer and next prayer time
    DateTime? nextPrayerTime;
    for (int i = 0; i < prayerTimes.length; i++) {
      if (prayerTimes[i].isAfter(now)) {
        nextPrayerTime = prayerTimes[i];
        currentPrayer = i == 0 ? prayerNames.last : prayerNames[i - 1]; // Set the current prayer name
        nextPrayer = prayerNames[i]; // Set the next prayer name
        break;
      }
    }

    // If all prayer times for today have passed, pick the first prayer time of tomorrow
    if (nextPrayerTime == null) {
      nextPrayerTime = prayerTimes.first.add(Duration(days: 1));
      currentPrayer = prayerNames.last; // Last prayer of the day
      nextPrayer = prayerNames.first; // First prayer of the next day
    }

    print('Current Prayer: $currentPrayer'); // Log the current prayer
    print('Next Prayer Time: $nextPrayerTime'); // Log the next prayer time
    print('Next Prayer: $nextPrayer'); // Log the next prayer name

    // Calculate the difference between now and the next prayer time
    _timeUntilNextPrayer = nextPrayerTime.difference(now);
    print('Time Until Next Prayer: $_timeUntilNextPrayer'); // Log the time difference

    // Start the countdown timer
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel(); // Cancel any existing timer
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeUntilNextPrayer != null) {
          if (_timeUntilNextPrayer!.inSeconds <= 0) {
            // Countdown has reached zero, update to the next prayer
            _calculateTimeUntilNextPrayer();
          } else {
            _timeUntilNextPrayer = _timeUntilNextPrayer! - Duration(seconds: 1);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

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
        throw Exception('Failed to load dates. Status codes: ${response1.statusCode}, ${response2.statusCode}');
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
          _buildTopSection(),
          _buildLogoSection(),
          _buildDateBox(),
          _buildCountdownBox(),
          _buildMainContent(),
          _buildFooterSection(),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 150,
      child: Container(
        color: const Color(0xFF631515), // Use the desired color
      ),
    );
  }

  Widget _buildLogoSection() {
    return Positioned(
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
    );
  }

  Widget _buildDateBox() {
    return Positioned(
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF631515),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  islamicDate ?? 'Loading Islamic date...',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF631515),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownBox() {
    return Positioned(
      bottom: 420,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          height: 140,
          width: 330, // Set your desired width
          decoration: BoxDecoration(
            color: const Color(0xFF631515),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: _timeUntilNextPrayer != null
                ? Text(
              '${_timeUntilNextPrayer!.inHours.toString().padLeft(2, '0')}:${(_timeUntilNextPrayer!.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeUntilNextPrayer!.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontFamily: 'Helvetica',
                color: Colors.white,
                fontSize: 36.0,
                fontWeight: FontWeight.bold,
              ),
            )
                : const Text(
              'Calculating...',
              style: TextStyle(
                fontFamily: 'Helvetica',
                color: Colors.white,
                fontSize: 24.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Positioned.fill(
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
              ? _buildErrorMessage()
              : _buildPrayerTimes(),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Text(
        errorMessage,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPrayerTimes() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPrayerHeaders(),
        const SizedBox(height: 5),
        ...prayerNames.asMap().entries.map((entry) {
          final index = entry.key;
          final prayerName = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                _buildPrayerName(prayerName, index),
                _buildBeginTime(index),
                _buildJammahTime(index),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPrayerHeaders() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spacing between items
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
    );
  }

  Widget _buildPrayerName(String prayerName, int index) {
    return Expanded(
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
    );
  }

  Widget _buildBeginTime(int index) {
    return Expanded(
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
    );
  }

  Widget _buildJammahTime(int index) {
    return Expanded(
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
    );
  }

  Widget _buildFooterSection() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: Container(
          height: 100,
          color: const Color(0xFF631515),
        ),
      ),
    );
  }
}