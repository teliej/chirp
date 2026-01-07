import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user/user_model.dart';
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

  final Map<String, UserModel?> _cache = {};

  // follower following discovery
  DocumentSnapshot? _lastUserDoc;
  List<UserModel> _users = [];

  List<UserModel> get users => _users;

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



  // Future<UserModel?> getUserById(String userId) async {
  //   return await _userService.getUser(userId);
  // }

  Future<void> fetchUser(String userId) async {
    if (!_cache.containsKey(userId)) {
      _cache[userId] = await _userService.getUser(userId);
      notifyListeners();
    }
    }

  UserModel? getUserById(String userId) {
    return _cache[userId];
  }
  







  Future<bool> isUserFollowing(String targetUserId) async {
    if (_currentUser == null) return false;
    return await _userService.isUserFollowing(_currentUser!.id, targetUserId);
  }


  Future<bool> followUser(String targetUserId) async {
    if (_currentUser == null) return false;
    try {
      await _userService.followUser(_currentUser!.id, targetUserId);
      return true;
    } catch (e) {
      debugPrint("user_provider followUser error: $e");
      return false;
    }
  }

  Future<bool> unfollowUser(String targetUserId) async {
    if (_currentUser == null) return false;
    try {
      await _userService.unfollowUser(_currentUser!.id, targetUserId);
      return true;
    } catch (e) {
      debugPrint("user_provider unfollowUser error: $e");
      return false;
    }
  }

  Future<bool> toggleFollowUser(String targetUserId) async {
    if (_currentUser == null) return false;
    bool isFollowing = await isUserFollowing(targetUserId);
    if (isFollowing) {
      return await unfollowUser(targetUserId);
    } else {
      return await followUser(targetUserId);
    }
  }



























  // Future<List<UserModel>> getFollowers(String userId) async {
  //   return await _userService.getFollowers(userId);
  // }




  /// Fetch initial followers/following with pagination
  Future<void> getInitialUsers(
    String userId, 
    {
      int limit = 10,
      String type = 'followers'
    }) async {

    try {
      final result = await _userService.getPaginatedUsers(
        userId,
        limit: limit,
        type: type
      );


      // result['user'] is a List<FollowerModel> or List<FollowingModel>
      // We need to convert each to UserModel by fetching user data using their id
      List<dynamic> userRefs = result['user'];
      _users = [];
      for (var ref in userRefs) {
        final userId = type == 'followers' ? ref.followerId : ref.followingId;

        // Try cache first
        UserModel? user = getUserById(userId);

        if (user == null) {
          user = await _userService.getUser(userId);
          _cache[userId] = user;
        }
        if (user != null) {
          _users.add(user);
        }
      }

      _lastUserDoc = result['lastDoc'];
      notifyListeners();
    } catch (e) {
      debugPrint("user_provider getInitialFollowers error: $e");
    }
  }

  /// Fetch more followers/following for pagination
  Future<void> getMoreUsers(
    String userId, 
    {
      int limit = 10,
      String type = 'followers'
    }) async {

    if (_lastUserDoc == null) return;

    try {
      final result = await _userService.getPaginatedUsers(
        userId,
        limit: limit,
        startAfter: _lastUserDoc,
        type: type
      );


      // result['user'] is a List<FollowerModel> or List<FollowingModel>
      // We need to convert each to UserModel by fetching user data using their id
      List<dynamic> userRefs = result['user'];
      for (var ref in userRefs) {
        final userId = type == 'followers' ? ref.followerId : ref.followingId;

        // Try cache first
        UserModel? user = getUserById(userId);

        if (user == null) {
          user = await _userService.getUser(userId);
          _cache[userId] = user;
        }
        if (user != null) {
          _users.add(user);
        }
      }

      _lastUserDoc = result['lastDoc'];
      notifyListeners();
    } catch (e) {
      debugPrint("user_provider getMoreFollowers error: $e");
    }
  }







  // Future<List<UserModel>> getFollowing(String userId) async {
  //   return await _userService.getFollowing(userId);
  // }





















  Future<List<UserModel>> getSuggestedUsers({int limit = 5}) async {
    if (_currentUser == null) return [];
    return await _userService.getSuggestedUsers(_currentUser!.id, limit: limit);
  }


  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    return await _userService.searchUsers(query);
  }





  /// Sign out user
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
  //delete account and delete user data from firestore
  Future<void> deleteAccount() async {
    if (_currentUser == null) return;
    try {
      await _authService.deleteAccount();
      await _userService.deleteUser(_currentUser!.id);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint("user_provider deleteAccount error: $e");
      rethrow;
    }
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