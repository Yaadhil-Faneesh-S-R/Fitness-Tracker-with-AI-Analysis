import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class DatabaseService {
  static const String _profileFile = 'profile.json';
  static const String _workoutsFile = 'workouts.json';
  static const String _mealsFile = 'meals.json';
  static const String _goalsFile = 'goals.json';
  static const String _weightLogFile = 'weight_log.json';
  static const String _registryFile = 'users_registry.json';

  String _currentUserId = 'default';
  
  // In-memory web storage fallback
  final Map<String, String> _webStorage = {};

  void setCurrentUser(String userId) {
    // Sanitize userId to be file-friendly
    _currentUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    if (_currentUserId.isEmpty) _currentUserId = 'default';
  }

  String get currentUserId => _currentUserId;

  String _getUserFileName(String fileName) {
    if (fileName == _registryFile) return fileName;
    return '${_currentUserId}_$fileName';
  }

  Future<String> get _localPath async {
    if (kIsWeb) return '';
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _writeString(String fileName, String content) async {
    final targetFile = _getUserFileName(fileName);
    if (kIsWeb) {
      _webStorage[targetFile] = content;
      return;
    }
    final path = await _localPath;
    final file = File('$path/$targetFile');
    await file.writeAsString(content);
  }

  Future<String?> _readString(String fileName) async {
    final targetFile = _getUserFileName(fileName);
    if (kIsWeb) {
      return _webStorage[targetFile];
    }
    final path = await _localPath;
    final file = File('$path/$targetFile');
    if (!await file.exists()) return null;
    return await file.readAsString();
  }

  Future<void> initDatabase() async {}

  // --- User Registry ---
  Future<List<String>> getAllUserIds() async {
    try {
      final content = await _readString(_registryFile);
      if (content == null) return [];
      final List<dynamic> list = jsonDecode(content);
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<void> registerUser(String userId) async {
    final users = await getAllUserIds();
    final sanitized = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    if (!users.contains(sanitized)) {
      users.add(sanitized);
      await _writeString(_registryFile, jsonEncode(users));
    }
  }

  Future<void> deleteUserData(String userId) async {
    if (kIsWeb) return;
    final sanitized = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();
    final path = await _localPath;
    final filesToDelete = [
      '${sanitized}_$_profileFile',
      '${sanitized}_$_workoutsFile',
      '${sanitized}_$_mealsFile',
      '${sanitized}_$_goalsFile',
      '${sanitized}_$_weightLogFile',
    ];
    
    for (final fileName in filesToDelete) {
      final file = File('$path/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  // --- Profile ---
  Future<void> saveProfile(UserProfile profile) async {
    await registerUser(profile.name);
    setCurrentUser(profile.name);
    await _writeString(_profileFile, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    try {
      final content = await _readString(_profileFile);
      if (content == null) return null;
      return UserProfile.fromJson(jsonDecode(content));
    } catch (e) {
      return null;
    }
  }

  // --- Workouts ---
  Future<void> addWorkout(WorkoutRecord workout) async {
    final workouts = await loadWorkouts();
    workouts.add(workout);
    await _writeString(_workoutsFile, jsonEncode(workouts.map((w) => w.toJson()).toList()));
  }

  Future<List<WorkoutRecord>> loadWorkouts() async {
    try {
      final content = await _readString(_workoutsFile);
      if (content == null) return [];
      final List<dynamic> list = jsonDecode(content);
      return list.map((item) => WorkoutRecord.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Meals ---
  Future<void> addMeal(MealRecord meal) async {
    final meals = await loadMeals();
    meals.add(meal);
    await _writeString(_mealsFile, jsonEncode(meals.map((m) => m.toJson()).toList()));
  }

  Future<List<MealRecord>> loadMeals() async {
    try {
      final content = await _readString(_mealsFile);
      if (content == null) return [];
      final List<dynamic> list = jsonDecode(content);
      return list.map((item) => MealRecord.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Goals ---
  Future<void> saveGoal(FitnessGoal goal) async {
    await _writeString(_goalsFile, jsonEncode(goal.toJson()));
  }

  Future<FitnessGoal?> loadGoal() async {
    try {
      final content = await _readString(_goalsFile);
      if (content == null) return null;
      return FitnessGoal.fromJson(jsonDecode(content));
    } catch (e) {
      return null;
    }
  }

  // --- Weight Log ---
  Future<void> addWeightEntry(WeightEntry entry) async {
    final entries = await loadWeightLog();
    entries.add(entry);
    await _writeString(_weightLogFile, jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<List<WeightEntry>> loadWeightLog() async {
    try {
      final content = await _readString(_weightLogFile);
      if (content == null) return [];
      final List<dynamic> list = jsonDecode(content);
      return list.map((item) => WeightEntry.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }
}
