import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String password;
  final String email;

  UserModel({required this.id, required this.password, required this.email});

  // Converts Firestore document to UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return UserModel(
      id: doc.id,
      password: data['password'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // Converts UserModel to JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {email: email, password: password};
  }
}
