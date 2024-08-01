class Time {
  final String prayer;
  final String time;

  Time({required this.prayer, required this.time});

  factory Time.fromJson(Map<String, dynamic> json) {
    return Time(
      prayer: json['prayer'],  // Access by key
      time: json['time'],      // Access by key
    );
  }
}