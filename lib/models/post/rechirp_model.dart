import 'package:cloud_firestore/cloud_firestore.dart';

// posts (collection)
//   └── postId_123 (document)
//         ├── text: "Hello 🌍"
//         ├── replyCount: 2
//         ├── likeCount: 5
//         ├── ...
//         └── rechirps (sub-collection)
//               └── rechirpId_xxx (RechirpModel)

// --- Model ---
class RechirpModel {
  final String id;
  final String userId; // who rechirped
  final String postId; // which post
  final DateTime createdAt;

  const RechirpModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  factory RechirpModel.fromMap(Map<String, dynamic> data, String docId) {
    return RechirpModel(
      id: docId,
      userId: data['userId'] ?? '',
      postId: data['postId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'postId': postId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}