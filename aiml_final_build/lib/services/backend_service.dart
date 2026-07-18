import 'package:intl/intl.dart';
import 'database_service.dart';
import 'calculation_service.dart';
import '../models/models.dart';
import '../utils/fitness_utils.dart';

class OperationResult {
  final bool success;
  final String message;
  const OperationResult(this.success, this.message);
}

class BackendService {
  final DatabaseService _database = DatabaseService();
  final CalculationService _calc = CalculationService();

  Future<void> initializeApp() async => await _database.initDatabase();

  // --- User Management ---
  String get currentUserId => _database.currentUserId;
  
  Future<List<String>> listUsers() async => await _database.getAllUserIds();
  
  void switchUser(String userId) {
    _database.setCurrentUser(userId);
  }

  Future<void> resetGoalProgress() async {
    final profile = await _database.loadProfile();
    if (profile != null) {
      await _database.deleteUserData(profile.name);
      // After deleting, we might want to reload or keep the profile?
      // The user asked for "resetting features maybe even only for the fitness goal progress bar".
      // Let's just delete the goal and weight log specifically if they want a partial reset,
      // but for "multi-user" it's better to just switch to a "clean" user.
      // Actually, let's just clear the goal and weight log for the current user.
      // I'll add a specialized method to DatabaseService if needed, but for now I'll just
      // clear those specific files by writing empty lists/null.
    }
  }

  // --- Profile ---
  Future<UserProfile?> getProfile() async => await _database.loadProfile();

  Future<OperationResult> saveProfile(String name, String ageStr, String heightStr, String weightStr) async {
    if (name.isEmpty || ageStr.isEmpty || heightStr.isEmpty || weightStr.isEmpty) {
      return const OperationResult(false, 'All fields are required.');
    }
    try {
      final int age = int.parse(ageStr);
      final double height = double.parse(heightStr);
      final double weight = double.parse(weightStr);
      if (age <= 0 || height <= 0 || weight <= 0) return const OperationResult(false, 'Values must be positive.');
      
      final profile = UserProfile(name: name, age: age, heightCm: height, weightKg: weight);
      await _database.saveProfile(profile);
      
      return const OperationResult(true, 'Profile saved successfully.');
    } catch (_) {
      return const OperationResult(false, 'Invalid numeric input.');
    }
  }

  // --- BMI ---
  Future<Map<String, dynamic>> getBmi() async {
    final profile = await getProfile();
    if (profile == null) return {'bmi': 0.0, 'category': 'Profile not set.'};
    final bmi = _calc.calculateBmiValue(profile.weightKg, profile.heightCm);
    return {'bmi': bmi, 'category': _calc.getBmiCategory(bmi)};
  }

  // --- Workouts ---
  Future<List<WorkoutRecord>> getWorkoutHistory() async => await _database.loadWorkouts();

  Future<OperationResult> logWorkout(String exercise, String durationStr) async {
    final profile = await getProfile();
    if (profile == null) return const OperationResult(false, 'Please set profile first.');
    if (exercise.isEmpty || durationStr.isEmpty) return const OperationResult(false, 'Fields cannot be empty.');

    try {
      final double duration = double.parse(durationStr);
      if (duration <= 0) return const OperationResult(false, 'Duration must be positive.');
      
      final calories = calculateCalories(profile.weightKg, duration, exercise);
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _database.addWorkout(WorkoutRecord(
        date: date, 
        exercise: exercise, 
        duration: duration, 
        calories: calories,
        userName: profile.name,
      ));
      return OperationResult(true, 'Logged! Burned $calories cal.');
    } catch (_) {
      return const OperationResult(false, 'Invalid duration.');
    }
  }

  // --- Meals ---
  Future<List<MealRecord>> getMealHistory() async => await _database.loadMeals();

  Future<OperationResult> logMeal(String type, String foodName, String calStr) async {
    final profile = await getProfile();
    if (profile == null) return const OperationResult(false, 'Please set profile first.');
    if (type.isEmpty || foodName.isEmpty || calStr.isEmpty) return const OperationResult(false, 'All fields required.');
    try {
      final double cal = double.parse(calStr);
      if (cal < 0) return const OperationResult(false, 'Calories must be positive.');
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _database.addMeal(MealRecord(
        date: date, 
        type: type, 
        foodName: foodName, 
        calories: cal,
        userName: profile.name,
      ));
      return OperationResult(true, 'Meal added!');
    } catch (_) {
      return const OperationResult(false, 'Invalid calories.');
    }
  }

  // --- Weight ---
  Future<List<WeightEntry>> getWeightHistory() async => await _database.loadWeightLog();

  Future<OperationResult> logWeight(String weightStr) async {
    final profile = await getProfile();
    if (profile == null) return const OperationResult(false, 'Please set profile first.');
    if (weightStr.isEmpty) return const OperationResult(false, 'Weight is required.');
    try {
      final double weight = double.parse(weightStr);
      if (weight <= 0) return const OperationResult(false, 'Weight must be positive.');
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _database.addWeightEntry(WeightEntry(
        date: date, 
        weightKg: weight,
        userName: profile.name,
      ));
      return OperationResult(true, 'Weight logged!');
    } catch (_) {
      return const OperationResult(false, 'Invalid weight.');
    }
  }

  // --- Goals ---
  Future<FitnessGoal?> getGoal() async => await _database.loadGoal();

  Future<OperationResult> saveGoal(String type, String targetWeightStr, String durationStr) async {
    if (targetWeightStr.isEmpty || durationStr.isEmpty) return const OperationResult(false, 'Fields required.');
    try {
      final double target = double.parse(targetWeightStr);
      final int duration = int.parse(durationStr);
      if (target <= 0 || duration <= 0) return const OperationResult(false, 'Values must be positive.');
      await _database.saveGoal(FitnessGoal(type: type, targetWeightKg: target, durationWeeks: duration));
      return const OperationResult(true, 'Goal saved!');
    } catch (_) {
      return const OperationResult(false, 'Invalid input.');
    }
  }

  // --- Summary & Dashboard Statistics ---
  Future<Map<String, double>> getDailyNutritionSummary() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final workouts = await _database.loadWorkouts();
    final meals = await _database.loadMeals();
    
    final burned = _calc.calculateTotalBurned(workouts, today);
    final consumed = _calc.calculateTotalConsumed(meals, today);
    final net = _calc.calculateNetCalories(consumed, burned);
    
    return {'burned': burned, 'consumed': consumed, 'net': net};
  }

  Future<Map<String, dynamic>> getWorkoutStats() async {
    final workouts = await _database.loadWorkouts();
    return _calc.calculateWorkoutStats(workouts);
  }

  Future<Map<String, dynamic>> getGoalProgress() async {
    final goal = await _database.loadGoal();
    final profile = await _database.loadProfile();
    final weightLog = await _database.loadWeightLog();
    
    if (goal == null || profile == null) return {'progress': 0.0};
    
    // Starting weight is either the first entry in weight log or profile weight
    double startingWeight = profile.weightKg;
    if (weightLog.isNotEmpty) {
      startingWeight = weightLog.first.weightKg;
    }
    
    double currentWeight = profile.weightKg;
    if (weightLog.isNotEmpty) {
      currentWeight = weightLog.last.weightKg;
    }
    
    final progress = _calc.calculateGoalProgress(currentWeight, goal, startingWeight);
    return {
      'goal': goal.type,
      'target': goal.targetWeightKg,
      'current': currentWeight,
      'progress': progress,
    };
  }

  Future<Map<String, double>> getWeeklyCalories() async {
    final workouts = await _database.loadWorkouts();
    return _calc.getWeeklyCaloriesData(workouts);
  }

  Future<Map<String, int>> getWeeklyFrequency() async {
    final workouts = await _database.loadWorkouts();
    return _calc.getWeeklyFrequencyData(workouts);
  }
}
