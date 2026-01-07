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
class Follower {
  final String followerId; // who follows me
  final DateTime createdAt;

  const Follower({
    required this.followerId,
    required this.createdAt,
  });

  factory Follower.fromMap(Map<String, dynamic> data) {
    return Follower(
      followerId: data['followerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'followerId': followerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}





// Usage example:
// final followersSnapshot = await FirebaseFirestore.instance
//     .collection('users')
//     .doc(userId)
//     .collection('followers')
//     .get();

// final followers = followersSnapshot.docs
//     .map((doc) => Follower.fromMap(doc.data()))
//     .toList();
// Now `followers` is a list of Follower objects representing all followers of the user.



// for fast checks like does user a follow user b
// final doc = await FirebaseFirestore.instance
//     .collection('users')
//     .doc(userA)
//     .collection('following')
//     .doc(userB)
//     .get();

// bool isFollowing = doc.exists;
