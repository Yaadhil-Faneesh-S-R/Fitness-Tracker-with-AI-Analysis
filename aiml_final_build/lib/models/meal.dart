/// Represents a single meal record logged by the user.
class MealRecord {
  final String date;     // Format: YYYY-MM-DD
  final String type;     // Breakfast, Lunch, Dinner, Snack
  final String foodName;
  final double calories;
  final String userName;

  MealRecord({
    required this.date,
    required this.type,
    required this.foodName,
    required this.calories,
    this.userName = '',
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      foodName: json['foodName'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      userName: json['userName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'type': type,
      'foodName': foodName,
      'calories': calories,
      'userName': userName,
    };
  }
}
