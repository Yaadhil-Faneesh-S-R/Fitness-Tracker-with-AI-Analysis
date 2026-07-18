/// Represents a user's personal profile information.
class UserProfile {
  final String name;
  final int age;
  final double heightCm;
  final double weightKg;

  UserProfile({
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      heightCm: (json['heightCm'] ?? 0).toDouble(),
      weightKg: (json['weightKg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
    };
  }
}
