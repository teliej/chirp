import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/user_provider.dart';
import '../../utils/format_num.dart';
import 'user_profile_page.dart';
// import '../../widgets/lottie_animation.dart';

class EngagementsPage extends StatefulWidget {
  final String userId;
  final String getType;

  const EngagementsPage({super.key, required this.userId, this.getType = 'followers'});

  @override
  State<EngagementsPage> createState() => _EngagementsPageState();
}

class _EngagementsPageState extends State<EngagementsPage>
    with SingleTickerProviderStateMixin {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    String? userId = widget.userId;
    String? type = widget.getType;

    context.read<UserProvider>().getInitialUsers(userId, type: type);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
          context.read<UserProvider>().getMoreUsers(userId, type: type); 
      }
    });
  }




  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context);
    final provider = context.watch<UserProvider>();
    final currentUser = provider.currentUser;
    final users = provider.users; 


    if (currentUser == null){
      return const Center(child: Text('User Not loged in'));
    }

    if (users.isEmpty){
      return const Center(child: Text('Nothing here.'));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // keep transparent, content goes behind
          statusBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: theme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness:
              theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ),
      );
    });


    final engageCount = widget.getType == 'followers' ? currentUser.followersCount : currentUser.followingCount;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.textTheme.bodyMedium?.color, // fallback bg
              backgroundImage: currentUser.avatarUrl != null && currentUser.avatarUrl!.isNotEmpty
                  ? NetworkImage(currentUser.avatarUrl!)
                  : null,
              child: (currentUser.avatarUrl == null || currentUser.avatarUrl!.isEmpty)
                  ? Icon(Icons.person, color: theme.scaffoldBackgroundColor)
                  : null,
            ),
            SizedBox(width: 8),
            Column(
              children: [
                Text(
                  currentUser.username,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18, 
                    fontWeight: FontWeight.w400,)),

                SizedBox(height: 2),

                Text(
                    '${formatNumber(currentUser.followersCount)} ${widget.getType[0].toUpperCase()}${widget.getType.substring(1)}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12, 
                  )),
              ],
            ),
          ],
        ),
        elevation: 8,
        actions: [
          // Chip(label: Text('Follow')),
          PopupMenuButton<String>(
            color: theme.scaffoldBackgroundColor,
            elevation: 8,
            constraints: BoxConstraints(
              minWidth: 100, // set min width
              maxWidth: 200, // optional max width
              minHeight: 0,  // not really needed, but you can control height too
              maxHeight: 400, // useful if many items
            ),
            shape: RoundedRectangleBorder( // rounded corners
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'Toggle Theme') {
                // Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              }
            },
            itemBuilder: (BuildContext context) {
              return ['View contact',
                      'Profile',
                      'Filter',
                      'Discover',
                      'More'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.getInitialUsers(widget.userId, type: widget.getType),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(5),
          itemCount: users.length + ((users.length < engageCount) ? 1 : 0),
          itemBuilder:(context, index) {
            final user = users[index];
            return ListTile(
                onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => UserProfilePage(userId: user.id),
                  ),
                );
                },

              leading: CircleAvatar(
                radius: 18,
                backgroundColor: theme.textTheme.bodyMedium?.color, // fallback bg
                backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? Icon(Icons.person, color: theme.scaffoldBackgroundColor)
                    : null,
              ),

              title: Text(user.username),

              subtitle: Text('${formatNumber(user.followersCount)} Followers'),

              trailing: FutureBuilder<bool>(
                future: provider.isUserFollowing(user.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(); // loading state
                  }

                  bool isFollowing = snapshot.data!;
                  return OutlinedButton(
                    onPressed:() {
                      if (!isFollowing) {
                        isFollowing = !isFollowing;
                        provider.toggleFollowUser(user.id);
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Messaging comming soon!")),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.textTheme.bodyMedium?.color,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isFollowing ? 'Message' : 'Follow'),
                  );
                },
              ),
            );
          },
        )
      )
    );
  }
}