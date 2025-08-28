import 'package:flutter/material.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> allNotifications = [
    {
      "username": "alex_j",
      "action": "liked your post",
      "time": "2m",
      "avatar": "https://i.pravatar.cc/150?img=1",
      "media": null
      // "media": "https://placekitten.com/100/100"
    },
    {
      "username": "marie_88",
      "action": "mentioned you in a comment",
      "time": "10m",
      "avatar": "https://i.pravatar.cc/150?img=2",
      "media": null
    },
    {
      "username": "johnny",
      "action": "started following you",
      "time": "1h",
      "avatar": "https://i.pravatar.cc/150?img=3",
      "media": null
    },
  ];

  final List<Map<String, dynamic>> mentions = [
    {
      "username": "marie_88",
      "action": "mentioned you in a comment",
      "time": "10m",
      "avatar": "https://i.pravatar.cc/150?img=2",
      "media": null
    },
  ];

  final List<Map<String, dynamic>> activity = [
    {
      "username": "johnny",
      "action": "started following you",
      "time": "1h",
      "avatar": "https://i.pravatar.cc/150?img=3",
      "media": null
    },
    {
      "username": "alex_j",
      "action": "liked your post",
      "time": "2m",
      "avatar": "https://i.pravatar.cc/150?img=1",
      "media": "https://placekitten.com/100/100"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildNotificationItem(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(data["avatar"]),
        radius: 22,
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: data["username"],
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const TextSpan(text: " "),
            TextSpan(
              text: data["action"],
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
      subtitle: Text(
        data["time"],
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: theme.hintColor,
        ),
      ),
      trailing: data["media"] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                data["media"],
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
          : null,
      onTap: () {
        // Handle tap to navigate to post/profile
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.unselectedWidgetColor,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Mentions"),
            Tab(text: "Activity"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ListView.builder(
                itemCount: allNotifications.length,
                itemBuilder: (context, index) =>
                    buildNotificationItem(allNotifications[index]),
              ),
              ListView.builder(
                itemCount: mentions.length,
                itemBuilder: (context, index) =>
                    buildNotificationItem(mentions[index]),
              ),
              ListView.builder(
                itemCount: activity.length,
                itemBuilder: (context, index) =>
                    buildNotificationItem(activity[index]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}