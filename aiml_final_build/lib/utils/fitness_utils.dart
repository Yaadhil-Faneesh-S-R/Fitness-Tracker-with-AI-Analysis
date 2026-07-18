/// =============================================================================
/// Fitness Tracker System - Fitness Utility Functions
/// =============================================================================
/// Contains pure calculation functions for fitness metrics.
/// These functions have no side effects and are easily unit-testable.
///
/// Functions:
///   - [calculateCalories]: Calculates calories burned using the MET formula
///   - [calculateBmi]: Calculates BMI and returns value with category
/// =============================================================================

/// MET (Metabolic Equivalent of Task) values for supported exercises.
///
/// MET represents the energy cost of physical activities as a multiple
/// of the resting metabolic rate. Higher MET = more calories burned.
const Map<String, double> metValues = {
  'Running': 8.0,
  'Walking': 3.5,
  'Cycling': 7.0,
  'Strength Training': 6.0,
};

/// List of supported exercise types for the dropdown UI.
const List<String> supportedExercises = [
  'Running',
  'Walking',
  'Cycling',
  'Strength Training',
];

/// Calculates calories burned during a workout session.
///
/// Uses the standard MET formula:
///   calories = MET × weight(kg) × duration(min) × 0.0175
///
/// Parameters:
///   - [weightKg]: User's body weight in kilograms
///   - [durationMin]: Workout duration in minutes
///   - [exerciseType]: Type of exercise (must be in [metValues])
///
/// Returns the estimated calories burned, rounded to 2 decimal places.
/// Returns 0.0 if any input is invalid (zero or negative).
double calculateCalories(double weightKg, double durationMin, String exerciseType) {
  // Validate inputs — weight and duration must be positive
  if (weightKg <= 0 || durationMin <= 0) {
    return 0.0;
  }

  // Look up MET value; default to 1.0 for unknown exercises
  final double met = metValues[exerciseType] ?? 1.0;

  // Apply the MET calorie formula
  final double calories = met * weightKg * durationMin * 0.0175;

  // Round to 2 decimal places for clean display
  return double.parse(calories.toStringAsFixed(2));
}

/// Result class for BMI calculation, containing the value and category.
class BmiResult {
  final double bmi;
  final String category;

  const BmiResult(this.bmi, this.category);

  @override
  String toString() => 'BMI: $bmi ($category)';
}

/// Calculates Body Mass Index (BMI) and determines the weight category.
///
/// Formula: BMI = weight(kg) / height(m)²
///
/// BMI Categories (WHO standard):
///   - Underweight: BMI < 18.5
///   - Normal: 18.5 ≤ BMI ≤ 24.9
///   - Overweight: 25.0 ≤ BMI ≤ 29.9
///   - Obese: BMI ≥ 30.0
///
/// Parameters:
///   - [weightKg]: User's body weight in kilograms
///   - [heightCm]: User's height in centimeters
///
/// Returns a [BmiResult] with the BMI value and category string.
/// Returns BMI = 0.0 with "Invalid Data" if inputs are invalid.
BmiResult calculateBmi(double weightKg, double heightCm) {
  // Validate inputs
  if (weightKg <= 0 || heightCm <= 0) {
    return const BmiResult(0.0, 'Invalid Data');
  }

  // Convert height from centimeters to meters
  final double heightM = heightCm / 100.0;

  // Calculate BMI using the standard formula
  double bmi = weightKg / (heightM * heightM);

  // Round to 2 decimal places
  bmi = double.parse(bmi.toStringAsFixed(2));

  // Determine WHO weight category
  String category;
  if (bmi < 18.5) {
    category = 'Underweight';
  } else if (bmi <= 24.9) {
    category = 'Normal';
  } else if (bmi <= 29.9) {
    category = 'Overweight';
  } else {
    category = 'Obese';
  }

  return BmiResult(bmi, category);
}
