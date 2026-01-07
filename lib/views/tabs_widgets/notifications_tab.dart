import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/notification_service.dart';
import '../../widgets/lottie_animation.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final List<Map<String, dynamic>> allNotifications = [
    {
      "username": "Kattie",
      "action": "comment on your latest post",
      "time": "now",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
    {
      "username": "Celeb",
      "action": "has replied to your comment",
      "time": "1min",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
    {
      "username": "John",
      "action": "floats and comment on your recent post",
      "time": "2min",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
    {
      "username": "Nike",
      "action": "has started following you",
      "time": "34min",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
    {
      "username": "Chirp",
      "action": "welcomes you to the platform",
      "time": "2d",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
  ];

  final List<Map<String, dynamic>> mentions = [];
  
  final List<Map<String, dynamic>> activity = [
    {
      "username": "Kattie",
      "action": "comment on your post",
      "time": "now",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
    {
      "username": "Celeb",
      "action": "has replied to your comment",
      "time": "1min",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
    {
      "username": "John",
      "action": "floats your post",
      "time": "2min",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
    {
      "username": "Nike",
      "action": "followed you",
      "time": "34min",
      "avatar": "https://thispersondoesnotexit.com",
      "media": null 
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listen for taps on local notifications
    NotificationService.onNotificationTap = (data) {
      final payload = data["payload"] ?? "all";
      _navigateToTab(payload);
    };

    _initFirebaseMessaging();
  }

  void _navigateToTab(String payload) {
    if (payload == "mentions") {
      _tabController.index = 2;
    } else if (payload == "activity") {
      _tabController.index = 1;
    } else {
      _tabController.index = 0;
    }
  }

  Future<void> _initFirebaseMessaging() async {
    await _messaging.requestPermission();
    String? token = await _messaging.getToken();
    debugPrint("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);

      // Decide payload based on action
      final action = message.notification?.body?.toLowerCase() ?? "";
      String payload = "all";
      if (action.contains("mention")) payload = "mentions";
      if (action.contains("follow") || action.contains("like")) payload = "activity";

      NotificationService.showNotification(
        title: message.notification?.title ?? "New Notification",
        body: message.notification?.body ?? "",
        payload: payload,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleMessage(initialMessage);
  }

  void _handleMessage(RemoteMessage message) {
    final data = {
      "username": message.data["username"] ?? "Someone",
      "action": message.notification?.body ?? "sent you a notification",
      "time": "now",
      "avatar": message.data["avatar"] ??
          "https://i.pravatar.cc/150?img=10",
      "media": message.data["media"],
    };

    setState(() {
      allNotifications.insert(0, data);

      if (data["action"].toString().contains("mentioned")) {
        mentions.insert(0, data);
      } else {
        activity.insert(0, data);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildNotificationItem(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    return ListTile(
      // leading: CircleAvatar(
      //   backgroundImage: NetworkImage(data["avatar"]),
      //   radius: 22,
      // ),
      leading: CircleAvatar(
        backgroundColor: theme.primaryColor,
        child: Icon( Icons.person, color: theme.scaffoldBackgroundColor),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.unselectedWidgetColor,
          dividerColor: theme.textTheme.bodyMedium?.color,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Activity"),
            Tab(text: "Mentions"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              allNotifications.isNotEmpty 
                ? ListView.builder(
                    itemCount: allNotifications.length,
                    itemBuilder: (context, index) =>
                        buildNotificationItem(allNotifications[index]),
                  )
                : EmptyState(
                    file: 'assets/emptyState.json',
                    label: 'Nothing here yet!',
                  ),

              activity.isNotEmpty
                ? ListView.builder(
                    itemCount: activity.length,
                    itemBuilder: (context, index) =>
                        buildNotificationItem(activity[index]),
                  )
                : EmptyState(
                    file: 'assets/emptyState.json',
                    label: 'Nothing here yet!',
                  ),

              mentions.isNotEmpty
                ? ListView.builder(
                    itemCount: mentions.length,
                    itemBuilder: (context, index) =>
                        buildNotificationItem(mentions[index]),
                  )
                : EmptyState(
                    file: 'assets/emptyState.json',
                    label: 'Nothing here yet!',
                  ),
            ],
          ),
        ),
      ],
    );
  }
}




// this code also handles push notification directly from the server and display it on the tabs.