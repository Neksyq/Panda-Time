import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Add a user
  Future<void> addUser(UserModel user) async {
    await _usersCollection.add(user.toJson());
  }

  // Get a user by Id
  Future<UserModel?> getUser(String id) async {
    DocumentSnapshot doc = await _usersCollection.doc(id).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Update user
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _usersCollection.doc(id).update(data);
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    await _usersCollection.doc(id).delete();
  }
}
