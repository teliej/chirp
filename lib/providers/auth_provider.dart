// // providers/auth_provider.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AuthProvider with ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   User? _user;
//   bool _isLoading = true;

//   AuthProvider() {
//     // Listen to auth changes globally
//     _auth.authStateChanges().listen((firebaseUser) {
//       _user = firebaseUser;
//       _isLoading = false;
//       notifyListeners();
//     });
//   }

//   User? get user => _user;
//   bool get isLoggedIn => _user != null;
//   bool get isLoading => _isLoading;

//   Future<void> signIn(String email, String password) async {
//     await _auth.signInWithEmailAndPassword(email: email, password: password);
//   }

//   Future<void> signUp(String email, String password) async {
//     await _auth.createUserWithEmailAndPassword(email: email, password: password);
//   }

//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   Future<void> sendEmailVerification() async {
//     await _user?.sendEmailVerification();
//   }

//   bool get isEmailVerified => _user?.emailVerified ?? false;
// }
