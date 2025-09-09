import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';




class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<UserModel?> register(String email, String password, String username, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      final newUser = UserModel(
        id: firebaseUser.uid,
        username: username,
        name: name,
        email: email,
        avatarUrl: '',
        backgroundImageUrl: '',
        bio: '',
        bioLink: '',
        followers: 0,
        following: 0,
        interests: [],
        posts: [],
        savedPosts: [],
        isVerified: false,
        role: "user",
        createdAt: DateTime.now(),
        updatedAt: null,
        lastActive: DateTime.now(),
        location: null,
      );

      await _userService.createUser(newUser);

      await firebaseUser.sendEmailVerification();
      return newUser;
    } on FirebaseAuthException catch (e) {
      debugPrint("problem with auth service register");
      throw _handleAuthError(e);
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      var userDoc = await _userService.getUser(firebaseUser.uid);
      // If user doc doesn't exist, create one
      // This handles the case where user registered via email/password but no Firestore doc
      // or user was deleted from Firestore but still exists in Firebase Auth
      // In a real app, you might want to handle this differently
      // For example, you might want to prevent login if no user doc exists
      // or you might want to prompt the user to complete their profile
      // Here, we simply create a new user doc with basic info
      if (userDoc == null) { 
        await _userService.createUser(UserModel(
          id: firebaseUser.uid,
          username: firebaseUser.email!.split('@')[0],
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL ?? '',
          backgroundImageUrl: '',
          bio: '',
          bioLink: '',
          followers: 0,
          following: 0,
          interests: [],
          posts: [],
          savedPosts: [],
          isVerified: false,
          role: "user",
          createdAt: DateTime.now(),
          updatedAt: null,
          lastActive: DateTime.now(),
          location: null,
        ));
        userDoc = await _userService.getUser(firebaseUser.uid);
      }
      return userDoc;
    } on FirebaseAuthException catch (e) {
      debugPrint("problem with auth service sign in");
      throw _handleAuthError(e);
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Check if Firestore doc exists
      var userDoc = await _userService.getUser(firebaseUser.uid);
      if (userDoc == null) {
        userDoc = UserModel(
          id: firebaseUser.uid,
          username: firebaseUser.displayName ?? '',
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          avatarUrl: firebaseUser.photoURL ?? '',
          backgroundImageUrl: '',
          bio: '',
          bioLink: '',
          followers: 0,
          following: 0,
          interests: [],
          posts: [],
          savedPosts: [],
          isVerified: false,
          role: "user",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastActive: DateTime.now(),
          location: null,
        );
        await _userService.createUser(userDoc);
      }

      return userDoc;
    } on FirebaseAuthException catch (e) {
      debugPrint("problem with auth service google sign in");
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
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
































// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final _users = FirebaseFirestore.instance.collection('users'); // doesn't load all users right away
//                                                                   // it just a reference (a pointer)
//                                                                   // only loads when we call .get()

//   /// 🔹 Create/Update user profile in Firestore
//   Future<void> _ensureUserDoc(User user) async {
//     final userDoc = await _users.doc(user.uid).get();
//     if (!userDoc.exists) {
//       final userModel = UserModel(
//         id: user.uid,
//         email: user.email ?? '',
//         name: user.displayName ?? '',
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//       await _users.doc(user.uid).set(userModel.toMap());
//     } else {
//       await _users.doc(user.uid).update({
//         'email': user.email,
//         'name': user.displayName ?? '',
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     }
//   }

//   /// 🔹 Get user profile
//   Future<UserModel?> getUser(String id) async {
//     final doc = await _users.doc(id).get();
//     if (!doc.exists || doc.data() == null) return null;
//     return UserModel.fromMap(doc.data()!, doc.id);
//   }

//   /// 🔹 Register (email + password)
//   Future<UserModel?> register(String email, String password) async {
//     try {
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final user = userCredential.user;
//       if (user != null) {
//         await _ensureUserDoc(user);
//         await user.sendEmailVerification();
//         return await getUser(user.uid);
//       }
//       return null;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }

//   /// 🔹 Sign in (email + password)
//   Future<UserModel?> signIn(String email, String password) async {
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       final user = userCredential.user;
//       if (user != null) {
//         await _ensureUserDoc(user);
//         return await getUser(user.uid);
//       }
//       return null;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }

//   /// 🔹 Google Sign In
//   Future<UserModel?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return null;

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       final user = userCredential.user;

//       if (user != null) {
//         await _ensureUserDoc(user);
//         return await getUser(user.uid);
//       }
//       return null;
//     } on FirebaseAuthException catch (e) {
//       throw _handleAuthError(e);
//     }
//   }

//   /// 🔹 Update whole user
//   Future<void> updateUser(UserModel user) async {
//     try {
//       final updatedUser = user.copyWith(
//         updatedAt: DateTime.now(),
//       );
//       await _users.doc(user.id).set(updatedUser.toMap(), SetOptions(merge: true));
//     } catch (e) {
//       debugPrint('Error updating user: $e');
//       rethrow;
//     }
//   }

//   /// 🔹 Update specific fields
//   Future<void> updateUserField(String userId, Map<String, dynamic> updates) async {
//     try {
//       updates['updatedAt'] = FieldValue.serverTimestamp();
//       await _users.doc(userId).update(updates);
//     } catch (e) {
//       throw Exception('Failed to update user: $e');
//     }
//   }

//   /// 🔹 Sign out
//   Future<void> signOut() async => _auth.signOut();

//   /// 🔹 Handle errors
//   String _handleAuthError(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//         return 'No user found for that email.';
//       case 'wrong-password':
//         return 'Incorrect password.';
//       case 'email-already-in-use':
//         return 'This email is already registered.';
//       case 'invalid-email':
//         return 'Invalid email address.';
//       case 'weak-password':
//         return 'Password is too weak.';
//       default:
//         return 'Something went wrong. Please try again.';
//     }
//   }
// }
