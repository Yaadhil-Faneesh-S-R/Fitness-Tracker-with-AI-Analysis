export 'user_profile.dart';
export 'workout.dart';
export 'meal.dart';
export 'goal.dart';
export 'weight_entry.dart';

class WorkoutRecord {
  final String date;       // Format: YYYY-MM-DD
  final String exercise;   // Exercise type (Running, Walking, etc.)
  final double duration;   // Duration in minutes
  final double calories;   // Calories burned (calculated)
  final String userName;   // Name of the user who logged this

  WorkoutRecord({
    required this.date,
    required this.exercise,
    required this.duration,
    required this.calories,
    this.userName = '',
  });

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      date: json['date'] ?? '',
      exercise: json['exercise'] ?? '',
      duration: (json['duration'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      userName: json['userName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'exercise': exercise,
      'duration': duration,
      'calories': calories,
      'userName': userName,
    };
  }
}
