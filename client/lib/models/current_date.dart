
class CurrentDate {
  final String date;

  // Constructor with proper Dart syntax
  CurrentDate({required this.date});

  // Factory method to create an IslamicDate instance from JSON
  factory CurrentDate.fromJson(Map<String, dynamic> json) {
    return CurrentDate(
      date: json['current_date'],
    );
  }
}