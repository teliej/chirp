// providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';



// class UserProvider with ChangeNotifier {
//   UserModel? _currentUser;

//   UserModel? get currentUser => _currentUser;
//   bool get isLoggedIn => _currentUser != null;

//   Future<void> loadUser(String userId) async {
//     _currentUser = await AuthService().getUser(userId);
//     notifyListeners();
//   }

//   Future<void> signOut() async {
//     await AuthService().signOut();
//     _currentUser = null;
//     notifyListeners();
//   }
// }







/// i this is doing the work of post provider and post services too 
/// i already have a function to fetch posts for a user in post service
/// so i can just use that function from here
/// but i need to add pagination to that function





// class UserProvider with ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final int _limit = 5;

//   UserModel? _currentUser;
//   bool _isLoading = false;

//   // For pagination
//   final Map<String, List<PostModel>> _cachedPosts = {};
//   final Map<String, DocumentSnapshot?> _lastDocs = {};
//   final Map<String, bool> _hasMoreMap = {};

//   // Getters
//   UserModel? get currentUser => _currentUser;
//   bool get isLoggedIn => _currentUser != null;
//   bool get isLoading => _isLoading;

//   List<PostModel> getPostsForUser(String userId) {
//     return _cachedPosts[userId] ?? [];
//   }

//   // Load user from Firestore/Auth
//   Future<void> loadUser(String userId) async {
//     _currentUser = await AuthService().getUser(userId);
//     notifyListeners();
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await AuthService().signOut();
//     _currentUser = null;
//     _cachedPosts.clear();
//     _lastDocs.clear();
//     _hasMoreMap.clear();
//     notifyListeners();
//   }

//   // Fetch initial posts for user
//   Future<void> fetchInitialPosts(String userId) async {
//     if (_cachedPosts.containsKey(userId)) return; // Already cached

//     _cachedPosts[userId] = [];
//     _lastDocs[userId] = null;
//     _hasMoreMap[userId] = true;
//     await fetchMorePosts(userId);
//   }

//   // Fetch paginated posts
//   Future<void> fetchMorePosts(String userId) async {
//     if (_isLoading || !(_hasMoreMap[userId] ?? true)) return;

//     _isLoading = true;
//     notifyListeners();

//     try {
//       Query query = _firestore
//           .collection('posts')
//           .where('userId', isEqualTo: userId)
//           .orderBy('timestamp', descending: true)
//           .limit(_limit);

//       if (_lastDocs[userId] != null) {
//         query = query.startAfterDocument(_lastDocs[userId]!);
//       }

//       final snapshot = await query.get();

//       if (snapshot.docs.isEmpty) {
//         _hasMoreMap[userId] = false;
//       } else {
//         final newPosts = snapshot.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>; // 🔥 Cast it here
//           return PostModel.fromMap(data, doc.id);
//         }).toList();

//         _cachedPosts[userId] = [..._cachedPosts[userId]!, ...newPosts];
//         _lastDocs[userId] = snapshot.docs.last;
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Refresh user posts (optional helper)
//   Future<void> refreshPosts(String userId) async {
//     _cachedPosts.remove(userId);
//     _lastDocs.remove(userId);
//     _hasMoreMap.remove(userId);
//     await fetchInitialPosts(userId);
//   }
// }












class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await AuthService().getUser(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await AuthService().signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    await AuthService().updateUser(user);
    _currentUser = user;
    notifyListeners();
  }
}