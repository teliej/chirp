import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user/user_model.dart';
import '../models/user/follower_model.dart';
import '../models/user/following_model.dart';



class UserService {
  final _users = FirebaseFirestore.instance.collection('users');  // doesn't load all users right away
                                                                  // it just a reference (a pointer)
                                                                  // only loads when we call .get()

  Future<void> setupUserFCM(String userId) async {
    final messaging = FirebaseMessaging.instance;

    // Get the current token
    final token = await messaging.getToken();
    if (token != null) {
      await saveUserToken(userId, token);
    }

    // Listen for token refresh and update Firestore only when it changes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      saveUserToken(userId, newToken);
    });
  }


  Future<void> saveUserToken(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final lastToken = prefs.getString('last_fcm_token');

    if (lastToken != token) {
      await _users.doc(userId).update({
        'fcmToken': token,
      });
      await prefs.setString('last_fcm_token', token);
      debugPrint('🔄 Token updated and cached locally.');
    } else {
      debugPrint('✅ Token unchanged (cached).');
    }
  }










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






  Future<bool> isUserFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _users
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId)
            .get();
      return doc.exists;
    } catch (e) {
      debugPrint("user_service isUserFollowing error: $e");
      return false;
    }
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = FirebaseFirestore.instance.batch();
    final timestamp = FieldValue.serverTimestamp();

    final currentUserRef = _users.doc(currentUserId);
    final targetUserRef = _users.doc(targetUserId);

    // Add to current user's following sub-collection
    final followingRef = currentUserRef.collection('following').doc(targetUserId);
    batch.set(followingRef, {
      'followingId': targetUserId,
      'createdAt': timestamp,
    });

    // Add to target user's followers sub-collection
    final followerRef = targetUserRef.collection('followers').doc(currentUserId);
    batch.set(followerRef, {
      'followerId': currentUserId,
      'createdAt': timestamp,
    });

    try {
      await batch.commit();
    } catch (e) {
      debugPrint("user_service followUser error: $e");
      rethrow;
    }
  }




  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = FirebaseFirestore.instance.batch();

    final currentUserRef = _users.doc(currentUserId);
    final targetUserRef = _users.doc(targetUserId);

    // Remove from current user's following sub-collection
    final followingRef = currentUserRef.collection('following').doc(targetUserId);
    batch.delete(followingRef);

    // Remove from target user's followers sub-collection
    final followerRef = targetUserRef.collection('followers').doc(currentUserId);
    batch.delete(followerRef);

    try {
      await batch.commit();
    } catch (e) {
      debugPrint("user_service unfollowUser error: $e");
      rethrow;
    }
  }





  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final snapshot = await _users
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("user_service searchUsers error: $e");
      return [];
    }
  } 






  Future<Map<String, dynamic>> getPaginatedUsers(
    String userId, {
    DocumentSnapshot? startAfter,
    int limit = 10,
    String type = 'followers'
  }) async {

    Map<String, dynamic> getType = {
      'followers': Follower,
      'following': Following,
      // 'other': UserModel,
    };

    try {

      // if (type != 'other'){} // later for including suggestion i mean discovery kind

      Query query = _users
          .doc(userId)
          .collection(type)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();

      List<String> userIds;
      if (type == 'followers') {
        userIds = snapshot.docs.map((doc) => doc['followerId'] as String).toList();
      } else  {
        userIds = snapshot.docs.map((doc) => doc['followingId'] as String).toList();
      }

      if (userIds.isEmpty) {
        return {
          'users': [],
          'lastDoc': null,
        };
      }

      final userSnapshot = await _users
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      final users = userSnapshot.docs
          .map((doc) => getType[type].fromMap(doc.data(), doc.id))
          .toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

      return {
        'users': users,
        'lastDoc': lastDoc,
      };
    } catch (e) {
      debugPrint("user_service getPaginatedFollowers error: $e");
      return {
        'users': [],
        'lastDoc': null,
      };
    }
  }







  
  Future<List<UserModel>> getSuggestedUsers(String userId, {int limit = 5}) async {
    try {
      // First, get the list of user IDs that the current user is following
      final followingSnapshot = await _users
          .doc(userId)
          .collection('following')
          .get();

      final followingIds = followingSnapshot.docs.map((doc) => doc['followingId'] as String).toSet();
      followingIds.add(userId); // Exclude self

      // Now, query for users not in the following list
      final snapshot = await _users
          .where(FieldPath.documentId, whereNotIn: followingIds.toList())
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("user_service getSuggestedUsers error: $e");
      return [];
    }
  }


  Future<void> deleteUser(String userId) async {
    try {
      await _users.doc(userId).delete();
    } catch (e) {
      debugPrint("user_service deleteUser error: $e");
      rethrow;
    }
  }





  // Future<List<UserModel>> getMultipleUsersByIds(List<String> userIds) async {
  //   try {
  //     if (userIds.isEmpty) return [];

  //     final snapshot = await _users
  //         .where(FieldPath.documentId, whereIn: userIds)
  //         .get();

  //     return snapshot.docs
  //         .map((doc) => UserModel.fromMap(doc.data(), doc.id))
  //         .toList();
  //   } catch (e) {
  //     debugPrint("user_service getMultipleUsersByIds error: $e");
  //     return [];
  //   }
  // }


  // Future<void> updateUserAvatar(String userId, String avatarUrl) async {
  //   try {
  //     await _users.doc(userId).update({
  //       'avatarUrl': avatarUrl,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     debugPrint("user_service updateUserAvatar error: $e");
  //     rethrow;
  //   }
  // }

  // Future<void> updateUserBackgroundImage(String userId, String backgroundImageUrl) async {
  //   try {
  //     await _users.doc(userId).update({
  //       'backgroundImageUrl': backgroundImageUrl,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     debugPrint("user_service updateUserBackgroundImage error: $e");
  //     rethrow;
  //   }
  // }

  // Future<List<UserModel>> getAllUsers() async {
  //   try {
  //     final snapshot = await _users.get();
  //     return snapshot.docs
  //         .map((doc) => UserModel.fromMap(doc.data(), doc.id))
  //         .toList();
  //   } catch (e) {
  //     debugPrint("user_service getAllUsers error: $e");
  //     return [];
  //   }
  // }







}