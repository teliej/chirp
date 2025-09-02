import 'package:flutter/material.dart';
import 'package:chirp/services/mock_data_service.dart';
import '../../models/chat_model.dart';
import '../../widgets/message_bubble.dart';



class ChatPage extends StatefulWidget {
  final String displayName;
  final String chatId;

  const ChatPage({super.key, required this.displayName, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Message> messages;

  @override
  void initState() {
    super.initState();
    messages = MockDataService().messagesByChatId[widget.chatId] ?? [];
  }
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final message = Message(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me', // You can change this depending on user logic
        content: text,
        type: 'text',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        status: 'sent',
      );

      setState(() {
        messages.add(message);
        _messageController.clear();
      });

      // Scroll to bottom
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }


  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    // if (now.difference(dt).inDays == 0) {
    //   return "$hour:$minute $period";
    // } else {
    //   return "${dt.day}/${dt.month}/${dt.year}";
    // }

    if (now.difference(dt).inDays == 0) {
      return "$hour:$minute $period";
    } else {
      return "$hour:$minute $period";
    }
  }




  @override
  Widget build(BuildContext context) {
    // final customColors = Theme.of(context).extension<CustomColors>()!;
    final theme = Theme.of(context);

    bool isTyping = _messageController.text.trim().isNotEmpty;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
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
              backgroundColor: theme.textTheme.bodyMedium?.color,
              child: Icon(Icons.person, color: theme.scaffoldBackgroundColor,)
            ),
            SizedBox(width: 8),
            Text(
              widget.displayName, 
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18, 
                fontWeight: FontWeight.w400,)),
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: theme.textTheme.bodyLarge?.color),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, color: theme.textTheme.bodyLarge?.color),
            onPressed: () {},
          ),
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
                      'Search',
                      'New Group',
                      'Media, links and docs',
                      'Mute notification',
                      'Disappearing messages', 
                      'Chat theme', 
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
      body: Column(
        children: [
          // 🧱 Messages List
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isMe = message.senderId == 'me';

                return MessageBubble(
                  message: message.content,
                  timestamp: _formatTimestamp(message.timestamp),
                  isMe: isMe
                );
              },
            ),
          ),

          // 🧠 Typing Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            // color: Colors.grey[100],
            // color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: CustomTextInput(
                    // controller: _messageController,
                    hintText: "Type a message",
                    icon: Icons.emoji_emotions_outlined,
                    rightIcons: [
                                Icon(Icons.attach_file),
                                SizedBox(width: 10,),
                                Icon(Icons.camera_alt_outlined),
                                SizedBox(width: 20,),
                                ],
                    
                    controller: _messageController,
                    onChanged: (_) => setState(() {}),
                    // decoration: const InputDecoration(
                    //   hintText: "Type a message",
                    //   border: InputBorder.none,
                    // ),
                  ),
                ),
                SizedBox(width: 5,),
                GestureDetector(
                  onTap: isTyping ? _sendMessage : null,
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Icon(
                      isTyping ? Icons.send : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



















class CustomTextInput extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final List<Widget> rightIcons;
  final bool obscureText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const CustomTextInput({
    super.key,
    required this.hintText,
    required this.icon,
    this.rightIcons = const [],
    this.obscureText = false,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      onChanged: onChanged,

      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.textTheme.bodyLarge?.color),
        suffixIcon: rightIcons.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: rightIcons,
              )
            : null,
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