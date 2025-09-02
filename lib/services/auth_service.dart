import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection('users'); // doesn't load all users right away
                                                                  // it just a reference (a pointer)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'users';




  Future<UserModel?> getUser(String id) async {
    final doc = await _users.doc(id).get(); // data only loads when we call .get()
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }





  Future<void> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionPath)
          .doc(user.id)
          .set(updatedUser.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }





  // ✅ Update specific field(s) of a user
  Future<void> updateUserField(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp(); // Track updates
      await _users.doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }





  Future<void> signOut() async {
    FirebaseAuth.instance.signOut();
  }




  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }




  Future<void> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔥 Send email verification
      await userCredential.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }




  // Future<void> signInWithGoogle() async {
  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user; // Return signed-in user
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }




  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}