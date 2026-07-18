/// Represents a single weight log entry.
class WeightEntry {
  final String date; // Format: YYYY-MM-DD
  final double weightKg;
  final String userName;

  WeightEntry({
    required this.date,
    required this.weightKg,
    this.userName = '',
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: json['date'] ?? '',
      weightKg: (json['weightKg'] ?? 0).toDouble(),
      userName: json['userName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weightKg': weightKg,
      'userName': userName,
    };
  }
}
