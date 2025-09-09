// services/post_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import 'package:uuid/uuid.dart'; // for generating unique IDs
import 'dart:io'; // gives you File
import 'package:path/path.dart' as path;


class PostService {
  final CollectionReference _posts = FirebaseFirestore.instance.collection('posts');
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;



  // Future<List<PostModel>> getAllPosts() async {
  //   final snapshot = await _posts.orderBy('timestamp', descending: true).get();
  //   return snapshot.docs
  //       .map((doc) => PostModel.fromMap(doc.data(), doc.id))
  //       .toList();
  // }



  // // Fetch paginated posts
  Future<List<PostModel>> fetchPosts({
    DocumentSnapshot? startAfter,
    int limit = 5,
  }) async {
    Query query = _posts.orderBy('timestamp', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }



  //Error: [firebase_storage/object-not-found] Object 'uploads/userId/2024/6/uuid_filename.jpg' does not exist.
  Future<List<String>> uploadMedia(List<String> filePaths, String userId, {
    int limit = 3, // Upload 3 images at a time
  }) async {

    final List<String> uploadedUrls = [];

    // Convert file paths to File objects
    final files = filePaths.map((path) => File(path)).toList();

    for (int i = 0; i < files.length; i += limit) {
      final chunk = files.skip(i).take(limit);

      final results = await Future.wait(chunk.map((file) async {
        // Create unique path
        String ext = path.extension(file.path);
        String fileName =
            // 'uploads/$userId/${Uuid().v4()}$ext';
            // 'uploads/$userId/${DateTime.now().year}/${DateTime.now().month}/${Uuid().v4()}_$ext';
            'uploads/$userId/${DateTime.now().year}/${DateTime.now().month}/${Uuid().v4()}$ext';
        
        // Upload image
        UploadTask uploadTask = _storage.ref(fileName).putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        
        // Get download URL
        return await snapshot.ref.getDownloadURL();
      }));

      uploadedUrls.addAll(results);
    }

    return uploadedUrls;
  }




  Future<void> createPost(PostModel post) async {

    List<String> mediaUrls = await uploadMedia(post.mediaUrls, post.userId);

    Map<String, dynamic> mapedPost = post.toMap();
    mapedPost['mediaUrls'] = mediaUrls;
    await _posts.add(mapedPost);

  }





Future<void> deletePost(PostModel post, {bool isAdmin = false}) async {
    final currentUserId = _auth.currentUser?.uid;

    // 🔐 Security: Allow delete only if user owns the post OR is admin
    if (!isAdmin && post.userId != currentUserId) {
      debugPrint("Unauthorized delete attempt for post: ${post.id}");
      throw Exception("You don't have permission to delete this post.");
    }

    // 🧹 Delete all images safely
    for (final url in post.mediaUrls) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (e) {
        debugPrint('⚠️ Failed to delete image: $e');
      }
    }

    // 📝 Delete Firestore document
    try {
      await _posts.doc(post.id).delete();
      debugPrint('✅ Post ${post.id} deleted successfully.');
    } catch (e) {
      debugPrint('❌ Failed to delete post: $e');
      throw Exception('Failed to delete post.');
    }
  }
}