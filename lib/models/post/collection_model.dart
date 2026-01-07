import 'package:cloud_firestore/cloud_firestore.dart';

// users/{userId}

// --- Model ---
class PostCollection {
  final String postId;
  final DateTime savedAt;

  const PostCollection({
    required this.postId,
    required this.savedAt,
  });

  factory PostCollection.fromMap(Map<String, dynamic> data) {
    return PostCollection(
      postId: data['postId'] ?? '',
      savedAt: (data['savedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}
