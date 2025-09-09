import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');  // doesn't load all users right away
                                                                  // it just a reference (a pointer)
                                                                  // only loads when we call .get()

  Future<UserModel?> getUser(String id) async {
    try {
      final doc = await _users.doc(id).get();
      if (!doc.exists) return null;
      debugPrint("user_service getUser: ${doc.data()}");
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      debugPrint("user_service getUser error. Error getting user: $e");
      rethrow;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toMap());
      debugPrint("user_service createUser: ${user.toMap()}");
    } catch (e) {
      debugPrint("user_service createUser error. Error creating user: $e");
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserField(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _users.doc(userId).update(updates);
    } catch (e) {
      rethrow;
    }
  }
}