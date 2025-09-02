import 'package:cloud_firestore/cloud_firestore.dart';

extension UserModelCopy on UserModel {
  UserModel copyWith({
    String? username,
    String? name,
    String? email,
    String? avatarUrl,
    String? backgroundImageUrl,
    String? bio,
    String? bioLink,
    int? followers,
    int? following,
    List<String>? interests,
    List<String>? posts,
    List<String>? savedPosts,
    bool? isVerified,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    Map<String, dynamic>? location,
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
      followers: followers ?? this.followers,
      following: following ?? this.following,
      interests: interests ?? this.interests,
      posts: posts ?? this.posts,
      savedPosts: savedPosts ?? this.savedPosts,
      isVerified: isVerified ?? this.isVerified,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      location: location ?? this.location,
    );
  }
}


// models/user_model.dart
class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String avatarUrl;
  final String backgroundImageUrl;
  final String bio;
  final String bioLink;
  final int followers;
  final int following;
  final List<String> interests;
  final List<String> posts; // post IDs
  final List<String> savedPosts;
  final bool isVerified;
  final String role; // e.g., "user", "admin"
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActive;
  final Map<String, dynamic>? location;

  const UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.backgroundImageUrl,
    required this.bio,
    required this.bioLink,
    required this.followers,
    required this.following,
    required this.interests,
    required this.posts,
    this.savedPosts = const [],
    this.isVerified = false,
    this.role = "user",
    required this.createdAt,
    this.updatedAt,
    this.lastActive,
    this.location,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      username: data['username'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      backgroundImageUrl: data['backgroundImageUrl'] ?? '',
      bio: data['bio'] ?? '',
      bioLink: data['bioLink'] ?? '',
      location: data['location'],
      followers: data['followers'] ?? 0,
      following: data['following'] ?? 0,
      interests: List<String>.from(data['interests'] ?? []),
      posts: List<String>.from(data['posts'] ?? []),
      savedPosts: List<String>.from(data['savedPosts'] ?? []),
      isVerified: data['isVerified'] ?? false,
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      lastActive: data['lastActive'] != null ? (data['lastActive'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'bio': bio,
      'bioLink': bioLink,
      'location': location,
      'followers': followers,
      'following': following,
      'interests': interests,
      'posts': posts,
      'savedPosts': savedPosts,
      'isVerified': isVerified,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
    };
  }
}


// Alternatively, don’t store posts at all if you always query posts by userId 
// (Firestore makes this easy):

// FirebaseFirestore.instance
//   .collection('posts')
//   .where('userId', isEqualTo: userId).get();




// // Profile data model for demonstration
// class UserProfile {
//   final String name;
//   final String handle;
//   final String avatarUrl;
//   final String bio;
//   final String link;
//   final int followers;
//   final int following;
//   final List<PostModel> posts;

//   const UserProfile({
//     required this.name,
//     required this.handle,
//     required this.avatarUrl,
//     required this.bio,
//     required this.link,
//     required this.followers,
//     required this.following,
//     required this.posts,
//   });
// }