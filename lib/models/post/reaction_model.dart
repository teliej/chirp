import 'package:cloud_firestore/cloud_firestore.dart';

// posts (collection)
//   └── postId_123 (document)
//         ├── text: "Hello 🌍"
//         ├── replyCount: 2
//         ├── likeCount: 5
//         ├── ...
//         └── reactions (sub-collection)
//               └── reactionId_xxx (ReactionModel)

// --- Model ---
class ReactionModel {
  final String id;       // reactionId
  final String userId;   // who reacted
  final String type;     // "like", "love", "😂", etc.
  final DateTime createdAt;

  const ReactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory ReactionModel.fromMap(Map<String, dynamic> data, String docId) {
    return ReactionModel(
      id: docId,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'like',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
