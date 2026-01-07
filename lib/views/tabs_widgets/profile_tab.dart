import 'package:flutter/material.dart';
//packages
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Providers
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/post_provider.dart';
//models
import '../../models/user/user_model.dart';
//custom widget/utility functions
import 'package:share_plus/share_plus.dart';
import '../../widgets/blur_glass.dart';
import '../../utils/format_num.dart';
//screens
import '../screens/engagements_page.dart';

class ProfileTab extends StatefulWidget {
  final String? userId;
  final bool isMe;

  const ProfileTab({super.key, this.userId, this.isMe = true});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  UserModel? _currentUser; // Store the active user (either self or fetched)
  bool isGridView = true;
  //new
  final ScrollController _scrollController = ScrollController();

  
  // @override
  // bool get wantKeepAlive => widget.isMe;


  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 3, vsync: this);

  //   //NEW
  //   // Delay fetching until the widget tree is ready
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final userProvider = context.read<UserProvider>();
  //     final postProvider = context.read<PostProvider>();

  //     // Determine which user to load
  //     String? userId = widget.userId ?? userProvider.currentUser?.id;
  //     if (userId == null) return;

  //     // Fetch user (if it's not the current one)
  //     if (widget.userId != null) {
  //       await userProvider.fetchUser(userId);
  //       _currentUser = userProvider.getUserById(userId);
  //     } else {
  //       _currentUser = userProvider.currentUser;
  //     }

  //     // Fetch posts for that user
  //     await postProvider.fetchInitialUserPosts(userId);

  //     // Add infinite scroll listener
  //       _scrollController.addListener(() {
  //         if (_scrollController.position.pixels >=
  //             _scrollController.position.maxScrollExtent - 200) {
  //           context.read<PostProvider>().fetchMoreUserPosts(userId);    
  //         }
  //       });
  //   });
  // }


  bool scrollListenerAdded = false; // add this as a field


  @override
  bool get wantKeepAlive => widget.isMe;



  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If userId changes, reload user and posts
    if (widget.userId != oldWidget.userId) {
      _loadUserAndPosts();
    }
  }

  void _loadUserAndPosts() async {
    final userProvider = context.read<UserProvider>();
    final postProvider = context.read<PostProvider>();

    String? userId = widget.userId ?? userProvider.currentUser?.id;
    if (userId == null) return;

    setState(() {
      _currentUser = null; // Show loading while fetching
    });

    if (widget.userId != null) {
      await userProvider.fetchUser(userId);
      _currentUser = userProvider.getUserById(userId);
    } else {
      _currentUser = userProvider.currentUser;
    }

    await postProvider.fetchInitialUserPosts(userId);

    // Add infinite scroll listener only once
    if (!scrollListenerAdded) {
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          context.read<PostProvider>().fetchMoreUserPosts(userId);
        }
      });
      scrollListenerAdded = true;
    }

    setState(() {}); // Trigger rebuild with fetched data
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAndPosts();
    });
  }






  Future<void> _launchInAppBrowser(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView, // forces in-app browser
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
      ),
    )) {
      throw 'Could not launch $url';
    }
  }




  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final postProvider = context.watch<PostProvider>();
    final userProvider = context.watch<UserProvider>();

    final currentUser = _currentUser ?? userProvider.currentUser;

    // Handle loading or null state
    if (currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }





    Color darken(Color color, [double amount = .1]) {
      final hsl = HSLColor.fromColor(color);
      final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
      return hslDark.toColor();
    }



    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        physics: const MaxScrollPhysics(maxScrollExtent: 350),
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 140,
            pinned: true,
            elevation: 10,
            leadingWidth: 40,
            leading: !widget.isMe 
              ? IconButton(
                icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () => Navigator.of(context).pop(),
              ) 
              : null,
            titleSpacing: widget.isMe ? 10 : 0,
            title: Text(
              '@${currentUser.username}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),




            actions: [
              if (widget.isMe) ...[

                IconButton(
                  icon: Icon(Icons.settings,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],

              PopupMenuButton<String>(
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

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Logged out")),
                    );
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
                    imageUrl: currentUser.backgroundImageUrl!.isNotEmpty      //improviced the null check here
                        ? currentUser.backgroundImageUrl!
                        : "https://images.unsplash.com/photo-1506744038136-46273834b3fb",
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[300]),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.2)                      
                    ),
                  ),

                  // Glass card in the middle
                  Center(
                    child: GlassContainer(
                      borderRadius: 0,
                      blur: 10,
                      color: theme.colorScheme.surface,
                      padding: const EdgeInsets.all(0),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(45),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Rounded container behind TabBar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                  ),
                  // Avatar floating on the edge
                  Positioned(
                    bottom: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.textTheme.bodyMedium?.color, // fallback bg
                        backgroundImage: currentUser.avatarUrl != null && currentUser.avatarUrl!.isNotEmpty
                            ? NetworkImage(currentUser.avatarUrl!)
                            : null,
                        child: (currentUser.avatarUrl == null || currentUser.avatarUrl!.isEmpty)
                            ? Icon(Icons.person, size: 45, color: theme.scaffoldBackgroundColor)
                            : null,
                      ),
                    )
                  ),
                ],
              ),
            ),

          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentUser.name!,  //improviced the null check here
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.email, size: 12, color: theme.iconTheme.color),
                    const SizedBox(width: 4),
                    Text(currentUser.email, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  ]),

                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 12, color: theme.iconTheme.color),
                      const SizedBox(width: 4),
                      Text("Earth", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      const SizedBox(width: 16),
                      // Icon(Icons.cake, size: 12, color: theme.iconTheme.color),
                      // const SizedBox(width: 4),
                      // Text("Born Jan 1, 1990", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                      // const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 12, color: theme.iconTheme.color),
                      const SizedBox(width: 4),
                      Text("Joined Jan 2020", style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      currentUser.bio!, 
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14), 
                      maxLines: 3,
                      softWrap: true,
                      textAlign: TextAlign.center,
                    )
                  ),
                  

                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _launchInAppBrowser(currentUser.bioLink!),
                        child: Text(
                          currentUser.bioLink!,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        )
                      )
                    ]
                  ),

                  const SizedBox(height: 16),                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      if (!widget.isMe) ...[

                        IconButton(
                          onPressed: (){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Messaging comming soon!")),
                            );
                          }, 
                          icon: Icon(Icons.chat_outlined, color: theme.primaryColor),
                        ),

                        SizedBox(width: 16,),

                        SizedBox(
                          height: 40,
                          child: FutureBuilder<bool>(
                            future: userProvider.isUserFollowing(currentUser.id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator(); // loading state
                              }

                              bool isFollowing = snapshot.data!;
                              return OutlinedButton(
                                onPressed:() {
                                  isFollowing = !isFollowing;
                                  userProvider.toggleFollowUser(currentUser.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.textTheme.bodyMedium?.color,
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                              );
                            },
                          ),
                        ),
                      ],

                      if (widget.isMe)
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/update-profile');
                            }, 
                            child: Text("Edit Profile")),
                        ),

                      SizedBox(width: 16,),

                      IconButton(
                        onPressed: () async {
                          final profileUrl = "https://yourapp.com/user/${currentUser.username}";
                          await SharePlus.instance.share(
                            ShareParams(
                              text: 'Check out this profile: $profileUrl'
                            )
                          );
                        },
                        icon: Icon(Icons.share_outlined, color: theme.primaryColor),
                      ),

                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: _buildStat("Posts", currentUser.postsCount, theme),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => EngagementsPage(userId: currentUser.id, getType: 'followers'),
                            ),
                          );
                        },
                        child: _buildStat("Followers", currentUser.followersCount, theme),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => EngagementsPage(userId: currentUser.id, getType: 'following'),
                            ),
                          );
                        },
                        child: _buildStat("Following", currentUser.followingCount, theme),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 30, 
                    thickness: 8,
                    color: darken(theme.scaffoldBackgroundColor, .05),
                    
                  ),  //🔥 increased the height and thickness
                ]
              ),
            )
          ),
        ],

        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              dividerColor: theme.inputDecorationTheme.fillColor,
              dividerHeight: 4,
              unselectedLabelColor: theme.textTheme.bodyMedium?.color,
              tabs: [
                Tab(text: "Posts"),
                Tab(text: "Media"),
                Tab(text: "Likes"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPostsTab(theme, postProvider, currentUser),
                  _buildMediaTab(theme, postProvider, currentUser),
                  _buildCollectionsTab(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget _buildPostsTab(ThemeData theme, PostProvider postProvider, UserModel user) {
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
                            backgroundImage: NetworkImage(user.avatarUrl!),
                          ),
                          title: Text(user.username, style: theme.textTheme.bodyLarge),
                          subtitle: Text(
                            post.createdAt.toLocal().toString(),
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
                          child: Text(
                            post.text, 
                            style: theme.textTheme.bodyMedium?.copyWith(
                              overflow: TextOverflow.visible
                            ),
                            softWrap: true,
                          ),
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
    
    if (allMedia.isEmpty) {
      return const Center(child: Text("No media yet."));
    }
    
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

  Widget _buildStat(String label, int value, ThemeData theme) {
    return Column(
      children: [
          Text(formatNumber(value), style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold, 
          fontSize: 16,
          color: theme.textTheme.bodyMedium?.color)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
      ],
    );
  }
}















class MaxScrollPhysics extends ClampingScrollPhysics {
  final double maxScrollExtent;

  const MaxScrollPhysics({this.maxScrollExtent = 200, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  MaxScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return MaxScrollPhysics(
      maxScrollExtent: maxScrollExtent,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value > maxScrollExtent) {
      // Stop scrolling beyond max
      return value - maxScrollExtent;
    }
    return super.applyBoundaryConditions(position, value);
  }
}






























/*
══╡ EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE
╞════════════════════════════════════════════════════
The following SocketException was thrown resolving an image codec:
Connection failed (OS Error: Network is unreachable, errno = 101), address =
fastly.picsum.photos,
port = 443

When the exception was thrown, this was the stack:
#0      _NativeSocket.startConnect (dart:io-patch/socket_patch.dart:822:35)
#1      _RawSocket.startConnect (dart:io-patch/socket_patch.dart:2295:26)
#2      RawSocket.startConnect (dart:io-patch/socket_patch.dart:41:23)
#3      RawSecureSocket.startConnect (dart:io/secure_socket.dart:334:22)
#4      SecureSocket.startConnect (dart:io/secure_socket.dart:85:28)
#5      _ConnectionTarget.connect (dart:_http/http_impl.dart:2704:30)
#6      _HttpClient._getConnection.connect (dart:_http/http_impl.dart:3225:12)
#7      _HttpClient._getConnection (dart:_http/http_impl.dart:3230:12)
#8      _HttpClient._openUrl (dart:_http/http_impl.dart:3053:12)
#9      _HttpClient._openUrlFromRequest (dart:_http/http_impl.dart:3129:12)
#10     _HttpClientResponse.redirect (dart:_http/http_impl.dart:707:10)
#11     _HttpClientRequest._handleIncoming.<anonymous closure>
(dart:_http/http_impl.dart:1590:27)
<asynchronous suspension>
#12     _HttpClientRequest._handleIncoming.<anonymous closure>
(dart:_http/http_impl.dart:1608:7)
<asynchronous suspension>

Image provider: NetworkImage("https://picsum.photos/300/200", scale: 1.0)
Image key: NetworkImage("https://picsum.photos/300/200", scale: 1.0)
════════════════════════════════════════════════════════════════════════════════
════════════════════

Another exception was thrown: Incorrect use of ParentDataWidget.
Another exception was thrown: Incorrect use of ParentDataWidget.
Another exception was thrown: Incorrect use of ParentDataWidget.
W/Firestore(23312): (26.0.0) [Firestore]: Listen for Query(target=Query(posts where userId==kfL7MhEPcOfQXnNJlYak4no2HZF3 order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/chirp-d585d/firestore/indexes?create_composite=Cklwcm9qZWN0cy9jaGlycC1kNTg1ZC9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcG9zdHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg, cause=null}
E/flutter (23312): [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: [cloud_firestore/failed-precondition] The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/chirp-d585d/firestore/indexes?create_composite=Cklwcm9qZWN0cy9jaGlycC1kNTg1ZC9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcG9zdHMvaW5kZXhlcy9fEAEaCgoGdXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg
E/flutter (23312): #0      FirebaseFirestoreHostApi.queryGet (package:cloud_firestore_platform_interface/src/pigeon/messages.pigeon.dart:1153:7)
E/flutter (23312): <asynchronous suspension>
E/flutter (23312): #1      MethodChannelQuery.get (package:cloud_firestore_platform_interface/src/method_channel/method_channel_query.dart:118:11)
E/flutter (23312): <asynchronous suspension>
E/flutter (23312): #2      _JsonQuery.get (package:cloud_firestore/src/query.dart:426:9)
E/flutter (23312): <asynchronous suspension>
E/flutter (23312): #3      PostProvider.fetchMoreUserPosts (package:chirp/providers/post_provider.dart:201:13)
E/flutter (23312): <asynchronous suspension>
E/flutter (23312): #4      PostProvider.fetchInitialUserPosts (package:chirp/providers/post_provider.dart:177:5)
E/flutter (23312): <asynchronous suspension>
E/flutter (23312): 
Another exception was thrown: Incorrect use of ParentDataWidget.
Another exception was thrown: Incorrect use of ParentDataWidget.
Another exception was thrown: Incorrect use of ParentDataWidget.


 */