import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/post_provider.dart';
import '../../models/user_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  //new
  // late UserModel user;
  // late PostProvider postProvider;
  // late UserProvider userProvider;

  bool isGridView = true;
  //new
  final ScrollController _scrollController = ScrollController();

  // // Example profile and posts (replace with your backend data)
  // late final UserModel currentUser;
  
  @override
  bool get wantKeepAlive => true;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    //new
    final user = context.read<UserProvider>().currentUser;

    if (user != null) {
      context.read<PostProvider>().fetchInitialUserPosts(user.id);
    }

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final user = context.read<UserProvider>().currentUser;
        if (user != null) {
          context.read<PostProvider>().fetchMoreUserPosts(user.id);
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final postProvider = context.watch<PostProvider>();
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    // Handle loading or null state
    if (currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
              currentUser.name,
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
              
              PopupMenuButton<String>(
                // color: Colors.grey[900], // 🔥 Background color of menu
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(16), // 🔥 Rounded corners
                // ),
                icon: Icon(
                  Icons.more_vert,
                  color: theme.textTheme.bodyLarge?.color, // 🔥 Custom icon color
                ),
                onSelected: (value) {
                  // Handle menu actions
                  if (value == 'security') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("security clicked")),
                    );
                  } else if (value == 'logout') {
                    userProvider.signOut();
                    Navigator.pushReplacementNamed(context, '/login');

                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("Logged out")),
                    // );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'security',
                    child: Text('Security'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              ),

            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: currentUser.backgroundImageUrl.isNotEmpty
                        ? currentUser.backgroundImageUrl
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
                              backgroundImage: NetworkImage(currentUser.avatarUrl),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentUser.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                currentUser.username,
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
                  Text(currentUser.bio, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14), maxLines: 5,),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        currentUser.bioLink,
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
                      _buildStat("Posts", currentUser.posts.length.toString(), theme),
                      _buildStat("Followers", currentUser.followers.toString(), theme),
                      _buildStat("Following", currentUser.following.toString(), theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/update-profile');
                    },
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
            _buildPostsTab(theme, postProvider, currentUser),
            _buildMediaTab(theme, postProvider, currentUser),
            _buildCollectionsTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(ThemeData theme, PostProvider postProvider, UserModel user) {

    final posts = postProvider.getUserPosts(user.id);
    final loading = postProvider.isUserLoading(user.id);

    if (loading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return const Center(child: Text("No posts yet."));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Flexible(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: posts.length + (loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final post = posts[index];
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

  Widget _buildMediaTab(ThemeData theme, PostProvider postProvider, UserModel user) {

    final posts = postProvider.getUserPosts(user.id);

    final allMedia = posts.expand((p) => p.mediaUrls).toList();
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