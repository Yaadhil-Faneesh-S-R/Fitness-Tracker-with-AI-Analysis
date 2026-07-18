/// Represents the user's fitness goal.
class FitnessGoal {
  final String type;           // Weight Loss, Muscle Gain, Maintenance
  final double targetWeightKg;
  final int durationWeeks;

  FitnessGoal({
    required this.type,
    required this.targetWeightKg,
    required this.durationWeeks,
  });

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      type: json['type'] ?? 'Maintenance',
      targetWeightKg: (json['targetWeightKg'] ?? 0).toDouble(),
      durationWeeks: json['durationWeeks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'targetWeightKg': targetWeightKg,
      'durationWeeks': durationWeeks,
    };
  }
}
