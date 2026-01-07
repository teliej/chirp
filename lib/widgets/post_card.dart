import 'package:flutter/material.dart';
import 'dart:io';
import '../models/post/post_model.dart';
import '../views/screens/user_profile_page.dart';


import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
// --- Widgets ---

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isPreview;

  const PostCard({super.key, required this.post, this.isPreview = false});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  static const _brand = Color(0xFF3AA7FF);
  static const _borderRadius = 18.0;
  static const _mediaBorderRadius = 16.0;

  bool voted = false;
  late int voteCount;
  late final AnimationController _controller;
  late final Animation<double> _scale;
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    voted = false;
    voteCount = widget.post.likeCount;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleVote() {
    setState(() {
      voted = !voted;
      voteCount += voted ? 1 : -1;
    });
    _controller
      ..forward(from: 0.9)
      ..reverse();
  }

  String get timeAgo => _shortTimeAgo(widget.post.createdAt);

  String _shortTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y';
    return '${_monthAbbr(date.month)} ${date.day}';
  }

  String _monthAbbr(int month) =>
      ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][month];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final tagLabel = post.categories.isNotEmpty ? post.categories.first : null;
    // final userProvider = context.watch<UserProvider>();
    // final UserModel user = userProvider.getUserById(post.userId);
    // final isFollowing = userModel.isUserFollowing(post.userId);

    return Container(
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostHeader(
              postUserId: post.userId,
              timeAgo: timeAgo,
              isPreview: widget.isPreview
            ),
            if ((tagLabel ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _TagLabel(label: tagLabel!),
              ),
            const SizedBox(height: 10),
            Text(
              post.text,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.35,
                overflow: TextOverflow.visible,    
              ),
              softWrap: true
            ),
            if (post.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _MediaCarousel(
                mediaUrls: post.mediaUrls,
                currentIndex: _currentImageIndex,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                pageController: _pageController,
                borderRadius: _mediaBorderRadius,
                brand: _brand,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  icon: Icons.mode_comment_outlined, 
                  count: widget.isPreview ? 0 : post.replyCount, 
                  isPreview: widget.isPreview,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comming soon!')),
                    );
                  }
                ),

                _ActionButton(
                  icon: Icons.repeat, 
                  count: widget.isPreview ? 0 : post.rechirpCount,
                  isPreview: widget.isPreview,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comming soon!')),
                    );
                  }
                ),
                GestureDetector(
                  onTap: widget.isPreview ? null : _toggleVote,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: Icon(
                          Icons.eco_outlined,
                          size: 22,
                          color: voted ? _brand : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$voteCount',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: voted ? _brand : Colors.black87,
                          fontWeight: voted ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _ActionButton(
                  icon: Icons.ios_share_outlined, 
                  count: null, 
                  isPreview: widget.isPreview,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comming soon!')),
                    );
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}









class _PostHeader extends StatelessWidget {
  final String postUserId;
  final String timeAgo;
  final bool isPreview;

  const _PostHeader({
    required this.postUserId,
    required this.timeAgo,
    required this.isPreview
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final userProvider = context.watch<UserProvider>();
    final user = userProvider.getUserById(postUserId);

    if (user == null) {
      // trigger async fetch if not already cached
      context.watch<UserProvider>().fetchUser(postUserId);
      return CircularProgressIndicator();
    }

    final String avatarUrl = user.avatarUrl ?? '';
    final String displayName = user.name ?? 'Unknown';
    final String handle = user.username;
    

    // final String avatarUrl = 'https://picsum.photos/300/200';
    // final String displayName = 'Unknown';
    // final String handle = 'username';
    // // bool isFollowing = 


    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
        onTap: (){
          if (!isPreview){
            Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => UserProfilePage(userId: postUserId),
          ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
          children: [
            Flexible(
              child: Text(
            displayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text('· $timeAgo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            )),
          ],
            ),
            Text(
          handle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
            ),
          ],
        ),
          )
        ),
        FutureBuilder<bool>(
          future: userProvider.isUserFollowing(postUserId),
          builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            width: 88,
            height: 36,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ); // loading state (fixed size to avoid layout jumps)
        }

        // Use a local mutable variable inside a StatefulBuilder to provide
        // instant optimistic UI feedback when the user taps follow/unfollow.
        // It initializes from the async result, and toggles immediately on tap
        // while the provider call runs in the background.
        bool? localFollowing;
        return StatefulBuilder(
          builder: (context, setButtonState) {
            localFollowing ??= snapshot.data!;
            return OutlinedButton(
          onPressed: isPreview ? null : () {
            // optimistic UI update
            setButtonState(() => localFollowing = !localFollowing!);
            // inform provider (network/update happens inside)
            userProvider.toggleFollowUser(postUserId);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.textTheme.bodyMedium?.color,
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(localFollowing! ? 'Unfollow' : 'Follow'),
            );
          },
        );
          },
        ),
      ],
    );
  }
}

class _TagLabel extends StatelessWidget {
  final String label;
  const _TagLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F4FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_florist, size: 16, color: Color(0xFF3AA7FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF3AA7FF),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _MediaCarousel extends StatelessWidget {
  final List<String> mediaUrls;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final PageController pageController;
  final double borderRadius;
  final Color brand;

  const _MediaCarousel({
    required this.mediaUrls,
    required this.currentIndex,
    required this.onPageChanged,
    required this.pageController,
    required this.borderRadius,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              controller: pageController,
              itemCount: mediaUrls.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return mediaUrls[index].startsWith('http')
                  ? Image.network(
                    mediaUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  )
                  : Image.file(
                    File(mediaUrls[index]),
                    fit: BoxFit.cover,
                  );
              },
            ),
          ),
        ),
        if (mediaUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: _CarouselDots(
              count: mediaUrls.length,
              currentIndex: currentIndex,
              color: brand,
            ),
          ),
      ],
    );
  }
}

class _CarouselDots extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color color;

  const _CarouselDots({
    required this.count,
    required this.currentIndex,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index ? color : Colors.grey[300],
            border: Border.all(
              color: Colors.black12,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback onTap;
  final bool isPreview;

  const _ActionButton({
    required this.icon, 
    this.count, 
    required this.onTap,
    required this.isPreview
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: isPreview ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black54),
            if (count != null) ...[
              const SizedBox(width: 6),
              Text('$count', style: textStyle),
            ]
          ],
        ),
      ),
    );
  }
}