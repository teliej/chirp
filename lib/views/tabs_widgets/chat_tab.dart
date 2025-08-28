import 'package:flutter/material.dart';
import '../screens/chat_page.dart';
import '../../model/chat.dart';
import '../../services/mock_data_service.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  String selectedFilter = 'All';

  List<Chat> filterChats(String filterName, List<Chat> allChats) {
    switch (filterName) {
      case 'Unread':
        return allChats.where((chat) => chat.unreadCount > 0).toList();
      case 'Favourites':
        return allChats.where((chat) => chat.isFavourite == true).toList();
      default:
        return allChats;
    }
  }

  void _sendPopup(BuildContext context, chat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Avatar Clicked'),
        content: Text('You clicked on ${chat.displayName}\'s avatar'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chats = MockDataService().chats;

    // sorting chats
    chats.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    final unreadCount = chats.where((chat) => chat.unreadCount > 0).length;
    final favouriteCount = chats.where((chat) => chat.isFavourite).length;

    final List<Map<String, String>> listOptions = [
      {'key': 'All', 'label': 'All'},
      {'key': 'Unread', 'label': 'Unread${unreadCount > 0 ? ' $unreadCount' : ''}'},
      {'key': 'Favourites', 'label': 'Favourites${favouriteCount > 0 ? ' $favouriteCount' : ''}'},
      {'key': 'Add', 'label': '+'},
    ];

    final filteredChats = filterChats(selectedFilter, chats);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
              child: CustomTextInput(
                hintText: 'Search',
                icon: Icons.search,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: listOptions.map((option) {
                    return Row(
                      children: [
                        ChoiceChip(
                          label: Text(option['label']!),
                          selected: selectedFilter == option['key'],
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = option['key']!;
                            });
                          },
                          selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                          backgroundColor: theme.scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: theme.hintColor, width: 0.5),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          labelStyle: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),

        ...filteredChats.map((chat) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            leading: GestureDetector(
              onTap: () => _sendPopup(context, chat),
              child: CircleAvatar(
                backgroundColor: theme.hintColor,
                child: Icon(Icons.person, color: theme.scaffoldBackgroundColor),
              ),
            ),
            title: Text(
              chat.displayName,
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              chat.lastMessage.content,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.lastMessage.formattedTime,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: chat.unreadCount > 0
                        ? theme.colorScheme.primary
                        : theme.hintColor,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chat.isMuted) ...[
                        Icon(Icons.notifications_off_sharp, size: 18, color: theme.hintColor),
                        const SizedBox(width: 2),
                      ],
                      if (chat.isPinned) ...[
                        Icon(Icons.push_pin, size: 18, color: theme.hintColor),
                        const SizedBox(width: 2),
                      ],
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${chat.unreadCount}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: theme.scaffoldBackgroundColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    displayName: chat.displayName,
                    chatId: chat.chatId,
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}


























class CustomTextInput extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const CustomTextInput({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      obscureText: obscureText,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.hintColor),
        hintText: hintText,
        hintStyle: TextStyle(color: theme.hintColor),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}