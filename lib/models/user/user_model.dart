import 'package:cloud_firestore/cloud_firestore.dart';

// extension UserModelCopy on UserModel {
//   UserModel copyWith({
//     String? username,
//     String? name,
//     String? email,
//     String? avatarUrl,
//     String? backgroundImageUrl,
//     String? bio,
//     String? bioLink,
//     int? followers,
//     int? following,
//     List<String>? interests,
//     List<String>? posts,
//     List<String>? savedPosts,
//     bool? isVerified,
//     String? role,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     DateTime? lastActive,
//     Map<String, dynamic>? location,
//   }) {
//     return UserModel(
//       id: id,
//       username: username ?? this.username,
//       name: name ?? this.name,
//       email: email ?? this.email,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
//       bio: bio ?? this.bio,
//       bioLink: bioLink ?? this.bioLink,
//       followers: followers ?? this.followers,
//       following: following ?? this.following,
//       interests: interests ?? this.interests,
//       posts: posts ?? this.posts,
//       savedPosts: savedPosts ?? this.savedPosts,
//       isVerified: isVerified ?? this.isVerified,
//       role: role ?? this.role,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       lastActive: lastActive ?? this.lastActive,
//       location: location ?? this.location,
//     );
//   }
// }


// // models/user_model.dart

// class UserModel {

//   final String id;
//   final String username;
//   final String name;
//   final String email;

//   final String avatarUrl;
//   final String backgroundImageUrl;

//   final String bio;
//   final String bioLink;

//   final List<String> interests;

//   final int followers;
//   final int following;
//   final List<String> posts; // post IDs
//   final List<String> savedPosts;

//   final bool isVerified;
//   final String role; // e.g., "user", "admin"
  
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final DateTime? lastActive;
//   final Map<String, dynamic>? location;

//   const UserModel({
//     required this.id,
//     required this.username,
//     required this.name,
//     required this.email,
//     required this.avatarUrl,
//     required this.backgroundImageUrl,
//     required this.bio,
//     required this.bioLink,
//     required this.followers,
//     required this.following,
//     required this.interests,
//     required this.posts,
//     this.savedPosts = const [],
//     this.isVerified = false,
//     this.role = "user",
//     required this.createdAt,
//     this.updatedAt,
//     this.lastActive,
//     this.location,
//   });

//   factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
//     return UserModel(
//       id: docId,
//       username: data['username'] ?? '',
//       name: data['name'] ?? '',
//       email: data['email'] ?? '',
//       avatarUrl: data['avatarUrl'] ?? '',
//       backgroundImageUrl: data['backgroundImageUrl'] ?? '',
//       bio: data['bio'] ?? '',
//       bioLink: data['bioLink'] ?? '',
//       location: data['location'],
//       followers: data['followers'] ?? 0,
//       following: data['following'] ?? 0,
//       interests: List<String>.from(data['interests'] ?? []),
//       posts: List<String>.from(data['posts'] ?? []),
//       savedPosts: List<String>.from(data['savedPosts'] ?? []),
//       isVerified: data['isVerified'] ?? false,
//       role: data['role'] ?? 'user',
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//       updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
//       lastActive: data['lastActive'] != null ? (data['lastActive'] as Timestamp).toDate() : null,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'username': username,
//       'name': name,
//       'email': email,
//       'avatarUrl': avatarUrl,
//       'backgroundImageUrl': backgroundImageUrl,
//       'bio': bio,
//       'bioLink': bioLink,
//       'location': location,
//       'followers': followers,
//       'following': following,
//       'interests': interests,
//       'posts': posts,
//       'savedPosts': savedPosts,
//       'isVerified': isVerified,
//       'role': role,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
//       'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
//     };
//   }
// }




// users (collection)
//   └── userId_123 (document)
//         ├── username: "john_doe"
//         ├── email: "john@example.com"
//         ├── avatarUrl: "https://..."
//         ├── createdAt: 2025-09-09
//         │
//         ├── followers (sub-collection)
//         │     └── followerId_abc (document)
//         │           ├── followerId: "user_456"
//         │           └── createdAt: ...
//         │
//         ├── following (sub-collection)
//         │     └── followingId_xyz (document)
//         │           ├── followingId: "user_789"
//         │           └── createdAt: ...
//         │
//         └── saved_posts (sub-collection)
//               └── postId_123 (document)
//                     ├── postId: "post_123"
//                     └── savedAt: ...





/// User roles for safer querying instead of using raw strings
enum UserRole { user, admin, moderator }

/// Optional structured location model
class UserLocation {
  final double lat;
  final double lng;
  final String? city;
  final String? country;

  const UserLocation({
    required this.lat,
    required this.lng,
    this.city,
    this.country,
  });

  factory UserLocation.fromMap(Map<String, dynamic> data) {
    return UserLocation(
      lat: (data['lat'] ?? 0).toDouble(),
      lng: (data['lng'] ?? 0).toDouble(),
      city: data['city'],
      country: data['country'],
    );
  }

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
      };
}

/// Core User Model
class UserModel {
  final String id;
  final String username;
  final String? name;
  final String email;

  final String? avatarUrl;
  final String? backgroundImageUrl;

  final String? bio;
  final String? bioLink;
  final String? bioLinkText;

  /// Store counts only (followers, following, posts).
  /// The actual lists live in sub-collections for scalability.
  final int followersCount;
  final int followingCount;
  final int postsCount;

  final List<String> interests;

  final bool isVerified;
  final UserRole role;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActive;

  final UserLocation? location;

  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.username,
    this.name,
    required this.email,
    this.avatarUrl = '',
    this.backgroundImageUrl = '',
    this.bio = '',
    this.bioLink = '',
    this.bioLinkText = 'Link',
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.interests = const [],
    this.isVerified = false,
    this.role = UserRole.user,
    required this.createdAt,
    this.updatedAt,
    this.lastActive,
    this.location,
    this.fcmToken = '',
  });

  /// Factory for Firestore -> Dart model
  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      username: data['username'] ?? '',
      name: data['name'],
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      backgroundImageUrl: data['backgroundImageUrl'],
      bio: data['bio'],
      bioLink: data['bioLink'],
      bioLinkText: data['bioLinkText'],
      location: data['location'] != null
          ? UserLocation.fromMap(data['location'])
          : null,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      interests: List<String>.from(data['interests'] ?? []),
      isVerified: data['isVerified'] ?? false,
      role: _roleFromString(data['role']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] as Timestamp).toDate()
          : null,
      fcmToken: data['fcmToken'] ?? '',
    );
  }

  /// Convert Dart model -> Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'bio': bio,
      'bioLink': bioLink,
      'bioLinkText': bioLinkText,
      'location': location?.toMap(),
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'interests': interests,
      'isVerified': isVerified,
      'role': role.name, // save enum as string
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'fcmToken': fcmToken,
    };
  }

  /// Enum conversion helpers
  static UserRole _roleFromString(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      default:
        return UserRole.user;
    }
  }

  /// `copyWith` for immutability
  UserModel copyWith({
    String? username,
    String? name,
    String? email,
    String? avatarUrl,
    String? backgroundImageUrl,
    String? bio,
    String? bioLink,
    String? bioLinkText,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    List<String>? interests,
    bool? isVerified,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    UserLocation? location,
    String? fcmToken,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      bio: bio ?? this.bio,
      bioLink: bioLink ?? this.bioLink,
      bioLinkText: bioLinkText ?? this.bioLinkText,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      interests: interests ?? this.interests,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      location: location ?? this.location,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
