/// =============================================================================
/// Fitness Tracker System - Main Entry Point
/// =============================================================================
/// Software Engineering Project
/// 
/// Description:
///   Main application entry point that initializes the MaterialApp with
///   Material Design 3 theming and launches the home screen.
///
/// Architecture:
///   - Model: Data models for Profile and Workout
///   - Service: Backend and Database services for business logic and persistence
///   - View: Flutter widgets for the UI layer
///   - Utils: Utility functions for calculations (BMI, Calories)
/// =============================================================================

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Application entry point
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitnessTrackerApp());
}

/// Root widget of the Fitness Tracker application.
/// 
/// Configures the Material Design 3 theme with a fitness-oriented
/// teal/green color scheme and launches the [HomeScreen].
class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material Design 3 with a teal-based fitness theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B), // Teal 600
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Card styling
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        // Input field styling
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        // Elevated button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
