import 'package:cloud_firestore/cloud_firestore.dart';

// // --- Model ---

// class PostModel {
//   final String id;
//   final String userId;
//   final String avatarUrl;
//   final String displayName;
//   final String handle;
//   final DateTime timestamp;
//   final bool isFollowing;
//   final String text;
//   final List<String> mediaUrls;
//   final List<String> categories;
//   final int replies;
//   final int rechirps;
//   final int votes;

//   const PostModel({
//     required this.id,
//     required this.userId,
//     required this.avatarUrl,
//     required this.displayName,
//     required this.handle,
//     required this.timestamp,
//     required this.isFollowing,
//     required this.text,
//     this.mediaUrls = const [],
//     this.categories = const [],
//     required this.replies,
//     required this.rechirps,
//     required this.votes,
//   });

//   factory PostModel.fromMap(Map<String, dynamic> data, String docId) {
//     return PostModel(
//       id: docId,
//       userId: data['userId'] ?? '',
//       avatarUrl: data['avatarUrl'] ?? '',
//       displayName: data['displayName'] ?? '',
//       handle: data['handle'] ?? '',
//       timestamp: (data['timestamp'] as Timestamp).toDate(),
//       isFollowing: data['isFollowing'] ?? false,
//       text: data['text'] ?? '',
//       mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
//       categories: List<String>.from(data['categories'] ?? []),
//       replies: data['replies'] ?? 0,
//       rechirps: data['rechirps'] ?? 0,
//       votes: data['votes'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'avatarUrl': avatarUrl,
//       'displayName': displayName,
//       'handle': handle,
//       'timestamp': Timestamp.fromDate(timestamp),
//       'isFollowing': isFollowing,
//       'text': text,
//       'mediaUrls': mediaUrls,
//       'categories': categories,
//       'replies': replies,
//       'rechirps': rechirps,
//       'votes': votes,
//     };
//   }
// }







// posts (collection)
//   └── postId_123 (document)
//         ├── userId: "user_abc"
//         ├── text: "Hello world 🌍"
//         ├── mediaUrls: ["https://img1.jpg"]
//         ├── replyCount: 12
//         ├── rechirpCount: 3
//         ├── likeCount: 40
//         ├── createdAt: ...
//         ├── updatedAt: ...
//         ├── edited: false
//         ├── isDeleted: false
//         └── visibility: "public"

//         ├── replies (sub-collection)
//         ├── likes (sub-collection)
//         └── rechirps (sub-collection)





// --- Refined Post Model ---
class PostModel {
  final String id;
  final String userId; // Author ID
  final String text;
  final List<String> mediaUrls;
  final List<String> categories; // hashtags/topics

  // Engagement counts
  final int replyCount;
  final int rechirpCount;
  final int likeCount;

  // Flags
  final bool isDeleted;
  final String visibility; // public, private, followers-only
  final bool edited;

  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostModel({
    required this.id,
    required this.userId,
    required this.text,
    this.mediaUrls = const [],
    this.categories = const [],
    this.replyCount = 0,
    this.rechirpCount = 0,
    this.likeCount = 0,
    this.isDeleted = false,
    this.visibility = "public",
    this.edited = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> data, String docId) {
    return PostModel(
      id: docId,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      replyCount: data['replyCount'] ?? 0,
      rechirpCount: data['rechirpCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      isDeleted: data['isDeleted'] ?? false,
      visibility: data['visibility'] ?? 'public',
      edited: data['edited'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'text': text,
      'mediaUrls': mediaUrls,
      'categories': categories,
      'replyCount': replyCount,
      'rechirpCount': rechirpCount,
      'likeCount': likeCount,
      'isDeleted': isDeleted,
      'visibility': visibility,
      'edited': edited,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}