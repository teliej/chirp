// providers/post_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

// class PostProvider extends ChangeNotifier {
//   final PostService _postService = PostService();
  
//   List<PostModel> _posts = [];
//   bool _hasMore = true;
//   bool _isLoading = false;
//   DocumentSnapshot? _lastDoc;

//   List<PostModel> get posts => _posts;
//   bool get hasMore => _hasMore;
//   bool get isLoading => _isLoading;


//   Future<void> fetchInitialPosts() async {
//     if (_isLoading) return;
//     _isLoading = true;
//     notifyListeners();

//     final newPosts = await _postService.fetchPosts(limit: 5);

//     if (newPosts.isNotEmpty) {
//       _posts = newPosts;
//       _lastDoc = await _getLastDocument(newPosts.last.id);
//     } else {
//       _hasMore = false;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> fetchMorePosts() async {
//     if (!_hasMore || _isLoading) return;

//     _isLoading = true;
//     notifyListeners();

//     final newPosts = await _postService.fetchPosts(
//       startAfter: _lastDoc,
//       limit: 5,
//     );

//     if (newPosts.isNotEmpty) {
//       _posts.addAll(newPosts);
//       _lastDoc = await _getLastDocument(newPosts.last.id);
//     } else {
//       _hasMore = false;
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<DocumentSnapshot?> _getLastDocument(String postId) async {
//     final doc = await FirebaseFirestore.instance
//         .collection('posts')
//         .doc(postId)
//         .get();
//     return doc;
//   }


//   // Future<void> fetchPosts() async {
//   //   _feedPosts = await PostService().getAllPosts();
//   //   notifyListeners();
//   // }


//   Future<void> addPost(PostModel post) async {
//     await PostService().createPost(post);
//     _posts.insert(0, post);
//     notifyListeners();
//   }
// }















class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Feed
  List<PostModel> _feedPosts = [];
  DocumentSnapshot? _feedLastDoc;
  bool _isFeedLoading = false;
  bool _hasMoreFeed = true;
  bool _isFeedInitialized = false;

  // User-specific posts (cached by userId)
  final Map<String, List<PostModel>> _userPostsCache = {};
  final Map<String, DocumentSnapshot?> _userLastDocs = {};
  final Map<String, bool> _userHasMore = {};
  final Map<String, bool> _userLoading = {}; // Track per-user loading
  final int _limit = 5;

  // ----------------------------
  // Getters
  // ----------------------------
  List<PostModel> get feedPosts => _feedPosts;
  bool get isFeedLoading => _isFeedLoading;
  bool get hasMoreFeed => _hasMoreFeed;

  List<PostModel> getUserPosts(String userId) => _userPostsCache[userId] ?? [];
  bool isUserLoading(String userId) => _userLoading[userId] ?? false;

  // ----------------------------
  // Feed Methods
  // ----------------------------
  Future<void> fetchInitialFeed() async {
    if (_isFeedInitialized || _isFeedLoading) return; // Already loaded or loading
    _isFeedLoading = true;
    notifyListeners();

    try {
      final posts = await _postService.fetchPosts(limit: _limit);
      if (posts.isNotEmpty) {
        _feedPosts = posts;
        _feedLastDoc = await _getLastDoc(posts.last.id);
      } else {
        _hasMoreFeed = false;
      }
      _isFeedInitialized = true; // Mark feed as loaded
    } finally {
      _isFeedLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreFeed() async {
    if (!_hasMoreFeed || _isFeedLoading) return;
    _isFeedLoading = true;
    notifyListeners();

    try {
      final posts = await _postService.fetchPosts(
        limit: _limit,
        startAfter: _feedLastDoc,
      );
      if (posts.isNotEmpty) {
        _feedPosts.addAll(posts);
        _feedLastDoc = await _getLastDoc(posts.last.id);
      } else {
        _hasMoreFeed = false;
      }
    } finally {
      _isFeedLoading = false;
      notifyListeners();
    }
  }

  // ----------------------------
  // User Posts Methods
  // ----------------------------
  Future<void> fetchInitialUserPosts(String userId) async {
    if (_userPostsCache.containsKey(userId)) return; // Already cached
    _userPostsCache[userId] = [];
    _userLastDocs[userId] = null;
    _userHasMore[userId] = true;
    await fetchMoreUserPosts(userId);
  }

  Future<void> fetchMoreUserPosts(String userId) async {
    if (!(_userHasMore[userId] ?? true) || (_userLoading[userId] ?? false)) {
      return;
    }

    _userLoading[userId] = true;
    notifyListeners();

    try {
      final query = _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(_limit);

      final lastDoc = _userLastDocs[userId];
      final snapshot = lastDoc != null
          ? await query.startAfterDocument(lastDoc).get()
          : await query.get();

      if (snapshot.docs.isEmpty) {
        _userHasMore[userId] = false;
      } else {
        final newPosts = snapshot.docs.map((doc) {
          // final data = doc.data() as Map<String, dynamic>; // ✅ Safe cast
          final data = doc.data(); // ✅ Safe cast
          return PostModel.fromMap(data, doc.id);
        }).toList();

        _userPostsCache[userId] = [..._userPostsCache[userId]!, ...newPosts];
        _userLastDocs[userId] = snapshot.docs.last;
      }
    } finally {
      _userLoading[userId] = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserPosts(String userId) async {
    _userPostsCache.remove(userId);
    _userLastDocs.remove(userId);
    _userHasMore.remove(userId);
    await fetchInitialUserPosts(userId);
  }

  // ----------------------------
  // Common Post Actions
  // ----------------------------
  Future<void> addPost(PostModel post) async {
    await _postService.createPost(post);
    _feedPosts.insert(0, post);
    _userPostsCache[post.userId]?.insert(0, post);
    notifyListeners();
  }

  Future<void> deletePost(PostModel post) async {
    await _postService.deletePost(post);
    _feedPosts.removeWhere((p) => p.id == post.id);
    _userPostsCache[post.userId]?.removeWhere((p) => p.id == post.id);
    notifyListeners();
  }

  Future<DocumentSnapshot?> _getLastDoc(String postId) async {
    return await _firestore.collection('posts').doc(postId).get();
  }
}
