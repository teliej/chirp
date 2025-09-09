import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  /// Listen to auth state changes (login/logout) and load user profile
  void listenToAuthChanges() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        debugPrint("user_provider: User is signed out");
        _currentUser = null;
        notifyListeners();
      } else {
        await loadUser(firebaseUser.uid);
        // 🔥 update last active
        await _userService.updateUserField(firebaseUser.uid, {
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Load user profile from Firestore
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    // notifyListeners();
    try {
      _currentUser = await _userService.getUser(userId);
      debugPrint("user_provider loadUser: $_currentUser");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Update full user document
  Future<void> updateUser(UserModel user) async {
    await _userService.updateUser(user);
    _currentUser = user;
    notifyListeners();
  }

  /// Update specific fields in Firestore
  Future<void> updateUserFields(Map<String, dynamic> updates) async {
    if (_currentUser == null) return;
    await _userService.updateUserField(_currentUser!.id, updates);
    _currentUser = await _userService.getUser(_currentUser!.id);
    notifyListeners();
  }
}