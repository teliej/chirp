import 'package:cloud_firestore/cloud_firestore.dart';
// --- Model ---

// posts (collection)
//   └── postId_123 (document)
//         ├── userId: "user_abc"
//         ├── text: "This is a post"
//         └── replyCount: 5
//         │
//         └── replies (sub-collection)
//               ├── replyId_001
//               │     ├── parentPostId: "postId_123"                   //want replys nested under posts
//               │     ├── userId: "user_xyz"
//               │     ├── text: "Nice one!"
//               │     ├── likeCount: 2
//               │     ├── createdAt: ...
//               │     └── isDeleted: false
//               │
//               └── replyId_002
//                     ├── parentPostId: "postId_123"
//                     ├── userId: "user_abc"
//                     ├── text: "Thanks!"
//                     └── likeCount: 1




class ReplyModel {
  final String id;
  final String parentPostId; // links reply to original post
  final String userId; // author of reply
  final String text;
  final List<String> mediaUrls;

  // Engagement
  final int likeCount;

  // Flags
  final bool isDeleted;
  final bool edited;

  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReplyModel({
    required this.id,
    required this.parentPostId,
    required this.userId,
    required this.text,
    this.mediaUrls = const [],
    this.likeCount = 0,
    this.isDeleted = false,
    this.edited = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReplyModel.fromMap(Map<String, dynamic> data, String docId) {
    return ReplyModel(
      id: docId,
      parentPostId: data['parentPostId'] ?? '',
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      likeCount: data['likeCount'] ?? 0,
      isDeleted: data['isDeleted'] ?? false,
      edited: data['edited'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentPostId': parentPostId,
      'userId': userId,
      'text': text,
      'mediaUrls': mediaUrls,
      'likeCount': likeCount,
      'isDeleted': isDeleted,
      'edited': edited,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
