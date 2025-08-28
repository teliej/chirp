import 'package:flutter/material.dart';
import '../../widgets/post_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:provider/provider.dart';
// import '../../providers/theme_provider.dart';

// Profile data model for demonstration
class UserProfile {
  final String name;
  final String handle;
  final String avatarUrl;
  final String bio;
  final String link;
  final int followers;
  final int following;
  final List<ChirpPost> posts;

  const UserProfile({
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.bio,
    required this.link,
    required this.followers,
    required this.following,
    required this.posts,
  });
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool isGridView = true;

  // Example profile and posts (replace with your backend data)
  late final UserProfile profile;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    profile = UserProfile(
      name: "John Doe",
      handle: "@johndoe",
      avatarUrl: "https://i.pravatar.cc/150?img=3",
      bio: "Passionate about design, tech, and travel. Sharing my journey here ✨",
      link: "johndoe.dev",
      followers: 1200,
      following: 350,
      posts: [
        ChirpPost(
          userId: "user_123",
          avatarUrl: "https://i.pravatar.cc/150?img=3",
          displayName: "John Doe",
          handle: "@johndoe",
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          text: "Beautiful sunset today 🌅",
          mediaUrls: [
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
            "https://images.unsplash.com/photo-1465101046530-73398c7f28ca",
          ],
          categories: ["#sunset", "#nature"],
          replies: 12,
          rechirps: 4,
          votes: 87,
          isFollowing: true,
        ),
        ChirpPost(
          userId: "user_123",
          avatarUrl: "https://i.pravatar.cc/150?img=3",
          displayName: "John Doe",
          handle: "@johndoe",
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          text: "Exploring the city lights 🌃",
          mediaUrls: [
            "https://images.unsplash.com/photo-1465101178521-c1a9136a3b99",
          ],
          categories: ["#city", "#night"],
          replies: 8,
          rechirps: 2,
          votes: 45,
          isFollowing: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 220,
            pinned: true,
            elevation: 10,
            title: Text(
              profile.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: theme.textTheme.bodyLarge?.color),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: theme.textTheme.bodyLarge?.color),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: profile.posts.isNotEmpty && profile.posts.first.mediaUrls.isNotEmpty
                        ? profile.posts.first.mediaUrls.first
                        : "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5), // top fade for contrast
                          theme.colorScheme.surface.withOpacity(
                            Theme.of(context).brightness == Brightness.dark ? 0.9 : 0.95,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Hero(
                            tag: "profile-avatar",
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(profile.avatarUrl),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                profile.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                profile.handle,
                                style: theme.textTheme.bodyMedium
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.bio, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14), maxLines: 5,),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        profile.link,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStat("Posts", profile.posts.length.toString(), theme),
                      _buildStat("Followers", profile.followers.toString(), theme),
                      _buildStat("Following", profile.following.toString(), theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: const Text("Edit Profile"),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    // unselectedLabelColor: theme.unselectedWidgetColor,
                    unselectedLabelColor: theme.textTheme.bodyLarge?.color,
                    tabs: const [
                      Tab(icon: Icon(Icons.article), text: "Posts"),
                      Tab(icon: Icon(Icons.image), text: "Media"),
                      Tab(icon: Icon(Icons.collections), text: "Collections"),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(theme),
            _buildMediaTab(theme),
            _buildCollectionsTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: profile.posts.length,
                itemBuilder: (context, index) {
                  final post = profile.posts[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    color: theme.cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(post.avatarUrl),
                          ),
                          title: Text(post.handle, style: theme.textTheme.bodyLarge),
                          subtitle: Text(
                            post.timestamp.toLocal().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                            onPressed: () {},
                          ),
                        ),
                        if (post.mediaUrls.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(post.mediaUrls.first, fit: BoxFit.cover),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(post.text, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaTab(ThemeData theme) {
    final allMedia = profile.posts.expand((p) => p.mediaUrls).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: IconButton(
                  icon: Icon(isGridView ? Icons.list : Icons.grid_view, color: theme.iconTheme.color),
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                ),
              ),
            ),
            Flexible(
              child: isGridView
                ? GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: allMedia.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(allMedia[index], fit: BoxFit.cover),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: allMedia.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        color: theme.cardColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(allMedia[index], fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCollectionsTab(ThemeData theme) {
    return Center(
      child: Text("Collections coming soon...", style: theme.textTheme.bodyMedium),
    );
  }

  Widget _buildStat(String label, String value, ThemeData theme) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}