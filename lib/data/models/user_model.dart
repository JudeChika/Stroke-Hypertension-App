class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final double? age; // Optional initially
  final double? bmi;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.age,
    this.bmi,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'age': age,
      'bmi': bmi,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Create from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age']?.toDouble(),
      bmi: map['bmi']?.toDouble(),
    );
  }
}