class User {
  final String id;
  final String email;
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String gender;
  final String fitnessGoal; // 'lose_weight', 'maintain', 'gain_weight'
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.fitnessGoal,
    required this.activityLevel,
    required this.createdAt,
  });

  // Convert User to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      height: map['height'] ?? 0.0,
      weight: map['weight'] ?? 0.0,
      gender: map['gender'] ?? '',
      fitnessGoal: map['fitnessGoal'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method for updating user data
  User copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? fitnessGoal,
    String? activityLevel,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}