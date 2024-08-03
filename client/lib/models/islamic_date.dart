
class IslamicDate {
  final String date;

  // Constructor with proper Dart syntax
  IslamicDate({required this.date});

  // Factory method to create an IslamicDate instance from JSON
  factory IslamicDate.fromJson(Map<String, dynamic> json) {
    return IslamicDate(
      date: json['islamic_date'],
    );
  }
}