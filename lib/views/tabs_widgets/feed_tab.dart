import 'package:flutter/material.dart';
import '../../widgets/post_model.dart';

/// Drop this file anywhere in your Flutter project and set `home: FeedTab()`
/// in your MaterialApp to see it in action.
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // padding: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(5),
      children: [
        ChirpPostCard(
          post:ChirpPost(
            userId: "user_123",
            avatarUrl: 
              'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?q=80&w=200',
            displayName: "John Doe",
            handle: "@johndoe",
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            text: "Beautiful sunset today 🌅",
            mediaUrls: [
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1080',
              "https://picsum.photos/300/200?1"
              ],
            categories: ["#sunset", "#nature"],
            replies: 12,
            rechirps: 4,
            votes: 87,
            isFollowing: true,
          ),
        ),
        SizedBox(height: 16),
        ChirpPostCard(
          post: ChirpPost(
            userId: "user_123",
            avatarUrl: "https://i.pravatar.cc/150?img=3",
            displayName: "John Doe",
            handle: "@johndoe",
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            text: "Beautiful sunset today 🌅",
            mediaUrls: ["https://picsum.photos/300/200?1"],
            categories: ["#sunset", "#nature"],
            replies: 12,
            rechirps: 4,
            votes: 87,
            isFollowing: true,
          ),
        ),
      ],
    );
  }
}