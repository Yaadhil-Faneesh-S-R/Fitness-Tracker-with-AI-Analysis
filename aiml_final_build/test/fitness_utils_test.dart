/// =============================================================================
/// Fitness Tracker System - Unit Tests for Fitness Utilities
/// =============================================================================
/// Tests the pure calculation functions in fitness_utils.dart.
///
/// Test Coverage:
///   - Calorie calculation with known MET values
///   - Calorie calculation with invalid (negative/zero) inputs
///   - BMI calculation for all 4 categories (Underweight, Normal, Overweight, Obese)
///   - BMI calculation with invalid inputs
/// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/utils/fitness_utils.dart';

void main() {
  // ===========================================================================
  // Calorie Calculation Tests
  // ===========================================================================
  group('calculateCalories', () {
    test('should calculate calories correctly for Running', () {
      // Formula: MET × weight × duration × 0.0175
      // Running MET = 8.0, weight = 70kg, duration = 30min
      // Expected: 8.0 × 70 × 30 × 0.0175 = 294.0
      final result = calculateCalories(70, 30, 'Running');
      expect(result, equals(294.0));
    });

    test('should calculate calories correctly for Walking', () {
      // Walking MET = 3.5, weight = 65kg, duration = 45min
      // Expected: 3.5 × 65 × 45 × 0.0175 = 179.16
      final result = calculateCalories(65, 45, 'Walking');
      expect(result, equals(179.16));
    });

    test('should calculate calories correctly for Cycling', () {
      // Cycling MET = 7.0, weight = 80kg, duration = 20min
      // Expected: 7.0 × 80 × 20 × 0.0175 = 196.0
      final result = calculateCalories(80, 20, 'Cycling');
      expect(result, equals(196.0));
    });

    test('should calculate calories correctly for Strength Training', () {
      // Strength Training MET = 6.0, weight = 75kg, duration = 60min
      // Expected: 6.0 × 75 × 60 × 0.0175 = 472.5
      final result = calculateCalories(75, 60, 'Strength Training');
      expect(result, equals(472.5));
    });

    test('should return 0.0 for negative weight', () {
      final result = calculateCalories(-70, 30, 'Running');
      expect(result, equals(0.0));
    });

    test('should return 0.0 for negative duration', () {
      final result = calculateCalories(70, -30, 'Running');
      expect(result, equals(0.0));
    });

    test('should return 0.0 for zero weight', () {
      final result = calculateCalories(0, 30, 'Running');
      expect(result, equals(0.0));
    });

    test('should return 0.0 for zero duration', () {
      final result = calculateCalories(70, 0, 'Running');
      expect(result, equals(0.0));
    });

    test('should use default MET of 1.0 for unknown exercises', () {
      // Unknown exercise defaults to MET 1.0
      // Expected: 1.0 × 70 × 30 × 0.0175 = 36.75
      final result = calculateCalories(70, 30, 'Swimming');
      expect(result, equals(36.75));
    });
  });

  // ===========================================================================
  // BMI Calculation Tests
  // ===========================================================================
  group('calculateBmi', () {
    test('should calculate Normal BMI correctly', () {
      // 70kg, 175cm → BMI = 70 / (1.75²) = 22.86
      final result = calculateBmi(70, 175);
      expect(result.bmi, equals(22.86));
      expect(result.category, equals('Normal'));
    });

    test('should detect Obese category', () {
      // 100kg, 170cm → BMI = 100 / (1.7²) = 34.6
      final result = calculateBmi(100, 170);
      expect(result.bmi, equals(34.6));
      expect(result.category, equals('Obese'));
    });

    test('should detect Underweight category', () {
      // 50kg, 180cm → BMI = 50 / (1.8²) = 15.43
      final result = calculateBmi(50, 180);
      expect(result.bmi, equals(15.43));
      expect(result.category, equals('Underweight'));
    });

    test('should detect Overweight category', () {
      // 80kg, 170cm → BMI = 80 / (1.7²) = 27.68
      final result = calculateBmi(80, 170);
      expect(result.bmi, equals(27.68));
      expect(result.category, equals('Overweight'));
    });

    test('should return Invalid Data for zero weight', () {
      final result = calculateBmi(0, 175);
      expect(result.bmi, equals(0.0));
      expect(result.category, equals('Invalid Data'));
    });

    test('should return Invalid Data for zero height', () {
      final result = calculateBmi(70, 0);
      expect(result.bmi, equals(0.0));
      expect(result.category, equals('Invalid Data'));
    });

    test('should return Invalid Data for negative values', () {
      final result = calculateBmi(-70, 175);
      expect(result.bmi, equals(0.0));
      expect(result.category, equals('Invalid Data'));
    });
  });
}
