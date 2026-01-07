import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/post/post_model.dart';
import '../../widgets/post_card.dart';
import '../../providers/post_provider.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> 
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();


  @override
  bool get wantKeepAlive => true;


  @override
  void initState() {
    super.initState();
    

    //NEW
    // Delay fetching until the widget tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      postProvider.fetchInitialFeed();

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          postProvider.fetchMoreFeed();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<PostProvider>();
    final posts = provider.feedPosts;

    if (provider.isFeedLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return const Center(child: Text("No posts yet. Be the first to post!"));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchInitialFeed(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(5),
        itemCount: posts.length + (provider.hasMoreFeed ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < posts.length) {
            final PostModel post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostCard(post: post),
            );
          } else {
            return const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(), // Loading indicator at the bottom.
                                                  // even if there are no more posts yet.
            ));
          }
        },
      ),
    );
  }
}





// W/System  ( 4030): Ignoring header X-Firebase-Locale because its value was null.
// W/LocalRequestInterceptor( 4030): Error getting App Check token; using placeholder token instead. Error: com.google.firebase.FirebaseException: No AppCheckProvider installed.