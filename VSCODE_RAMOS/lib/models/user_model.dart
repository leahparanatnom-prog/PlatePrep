import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String name;
  final String email;
  final int calorieTarget;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.calorieTarget = 2000,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'calorieTarget': calorieTarget,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      userId: id ?? map['userId'] ?? '',
      name: map['name'] ?? 'Chef',
      email: map['email'] ?? '',
      calorieTarget: (map['calorieTarget'] is num)
          ? (map['calorieTarget'] as num).toInt()
          : 2000,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, id: doc.id);
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    int? calorieTarget,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      calorieTarget: calorieTarget ?? this.calorieTarget,
    );
  }
}

