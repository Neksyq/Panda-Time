import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final int age;
  final String email;

  UserModel(
      {required this.id,
      required this.name,
      required this.age,
      required this.email});

  // Converts Firestore document to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      email: data['email'] ?? '',
    );
  }

  // Converts UserModel to JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {"name": name, "age": age, email: email};
  }
}
