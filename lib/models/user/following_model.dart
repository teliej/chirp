import 'package:cloud_firestore/cloud_firestore.dart';

// users/{userId}
//   ├── followers (sub-collection)
//   │     └── {followerIdDoc}
//   │           followerId: "abc123"
//   │           createdAt: ...
//   │
//   ├── following (sub-collection)
//   │     └── {followingIdDoc}
//   │           followingId: "xyz456"
//   │           createdAt: ...
//   │
//   ├── saved_posts (sub-collection)
//   │     └── {postIdDoc}
//   │           postId: "post_789"
//   │           savedAt: ...
//   │
//   └── posts (sub-collection, optional)
//         └── {postIdDoc}
//               postId: "post_123"
//               createdAt: ...

// --- Model ---
class Following {
  final String followingId; // who I follow
  final DateTime createdAt;

  const Following({
    required this.followingId,
    required this.createdAt,
  });

  factory Following.fromMap(Map<String, dynamic> data) {
    return Following(
      followingId: data['followingId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followingId': followingId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
