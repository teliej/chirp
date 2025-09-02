import 'package:cloud_firestore/cloud_firestore.dart';

// --- Model ---

class PostModel {
  final String id;
  final String userId;
  final String avatarUrl;
  final String displayName;
  final String handle;
  final DateTime timestamp;
  final bool isFollowing;
  final String text;
  final List<String> mediaUrls;
  final List<String> categories;
  final int replies;
  final int rechirps;
  final int votes;

  const PostModel({
    required this.id,
    required this.userId,
    required this.avatarUrl,
    required this.displayName,
    required this.handle,
    required this.timestamp,
    required this.isFollowing,
    required this.text,
    this.mediaUrls = const [],
    this.categories = const [],
    required this.replies,
    required this.rechirps,
    required this.votes,
  });

  factory PostModel.fromMap(Map<String, dynamic> data, String docId) {
    return PostModel(
      id: docId,
      userId: data['userId'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      displayName: data['displayName'] ?? '',
      handle: data['handle'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isFollowing: data['isFollowing'] ?? false,
      text: data['text'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      replies: data['replies'] ?? 0,
      rechirps: data['rechirps'] ?? 0,
      votes: data['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'avatarUrl': avatarUrl,
      'displayName': displayName,
      'handle': handle,
      'timestamp': Timestamp.fromDate(timestamp),
      'isFollowing': isFollowing,
      'text': text,
      'mediaUrls': mediaUrls,
      'categories': categories,
      'replies': replies,
      'rechirps': rechirps,
      'votes': votes,
    };
  }
}
