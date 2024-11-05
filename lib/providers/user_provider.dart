import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  // // Load users initially -> Cool thing to keep in mind in the case when we need to update child widged based on the change of the state
  // Future<void> loadUsers() async {
  //   _userRepository.getUsersStream().listen((userList) {
  //     _users = userList;
  //     notifyListeners();
  //   });
  // }

  // Add a user
  Future<void> addUser(UserModel user) async {
    await _userRepository.addUser(user);
    //loadUsers(); // Reload the users
  }

  // Update a user
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _userRepository.updateUser(id, data);
  }

  // Delete a user
  Future<void> deleteUser(String id) async {
    await _userRepository.deleteUser(id);
  }
}
