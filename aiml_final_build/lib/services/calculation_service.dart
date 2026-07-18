import '../models/models.dart';
import '../utils/fitness_utils.dart';
import 'package:intl/intl.dart';

class CalculationService {
  /// Calculates BMI
  double calculateBmiValue(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// Gets BMI Category
  String getBmiCategory(double bmi) {
    if (bmi <= 0) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Calculates Daily Net Calories (Consumed - Burned)
  double calculateNetCalories(double consumed, double burned) {
    return double.parse((consumed - burned).toStringAsFixed(1));
  }

  /// Calculates Daily Burned Calories for a specific date
  double calculateTotalBurned(List<WorkoutRecord> workouts, String date) {
    return workouts
        .where((w) => w.date == date)
        .fold(0.0, (sum, w) => sum + w.calories);
  }

  /// Calculates Daily Consumed Calories for a specific date
  double calculateTotalConsumed(List<MealRecord> meals, String date) {
    return meals
        .where((m) => m.date == date)
        .fold(0.0, (sum, m) => sum + m.calories);
  }

  /// Calculates Workout Stats (Total Workouts, Total Calories, Avg Duration)
  Map<String, dynamic> calculateWorkoutStats(List<WorkoutRecord> workouts) {
    if (workouts.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalCalories': 0.0,
        'avgDuration': 0.0,
      };
    }
    final totalCalories = workouts.fold(0.0, (sum, w) => sum + w.calories);
    final totalDuration = workouts.fold(0.0, (sum, w) => sum + w.duration);
    return {
      'totalWorkouts': workouts.length,
      'totalCalories': double.parse(totalCalories.toStringAsFixed(1)),
      'avgDuration': double.parse((totalDuration / workouts.length).toStringAsFixed(1)),
    };
  }

  /// Calculates Goal Progress percentage
  double calculateGoalProgress(double currentWeight, FitnessGoal goal, double startingWeight) {
    if (goal.targetWeightKg == startingWeight) return 100.0;
    
    // Progress = (Start - Current) / (Start - Target)
    final totalChangeNeeded = (startingWeight - goal.targetWeightKg).abs();
    final currentChangeMade = (startingWeight - currentWeight).abs();
    
    if (totalChangeNeeded == 0) return 100.0;
    
    final progress = (currentChangeMade / totalChangeNeeded) * 100;
    return double.parse(progress.clamp(0.0, 100.0).toStringAsFixed(1));
  }

  /// Gets total calories burned per day for the last 7 days
  Map<String, double> getWeeklyCaloriesData(List<WorkoutRecord> workouts) {
    final Map<String, double> data = {};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final total = calculateTotalBurned(workouts, dateStr);
      data[dateStr] = total;
    }
    return data;
  }

  /// Gets workout count per day for the last 7 days
  Map<String, int> getWeeklyFrequencyData(List<WorkoutRecord> workouts) {
    final Map<String, int> data = {};
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final count = workouts.where((w) => w.date == dateStr).length;
      data[dateStr] = count;
    }
    return data;
  }
}
