
class Message {
  final String messageId;
  final String senderId;
  final String content;
  final String type; // 'text', 'image', 'video', etc.
  final int timestamp;
  final String status; // 'sent', 'delivered', 'read'

  Message({
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
  });



  /// new helper functions installed below
  /// 
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      senderId: json['senderId'],
      content: json['content'],
      type: json['type'],
      timestamp: json['timestamp'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'content': content,
        'type': type,
        'timestamp': timestamp,
        'status': status,
  };

    /// Converts timestamp to human-readable time
  String get formattedTime {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }


  /// Returns true if message is empty
  bool get isEmpty => content.trim().isEmpty;
}

class Chat {
  final String chatId;
  final bool isGroup;
  final String displayName;
  final String profileImage;
  final Message lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isFavourite;
  final bool archived;
  final bool isMuted;

  Chat({
    required this.chatId,
    required this.isGroup,
    required this.displayName,
    required this.profileImage,
    required this.lastMessage,
    required this.unreadCount,
    required this.isPinned,
    required this.isFavourite,
    required this.archived,
    required this.isMuted,
  });



  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'],
      isGroup: json['isGroup'] ?? false,
      displayName: json['displayName'] ?? '',
      profileImage: json['profileImage'],
      lastMessage: Message.fromJson(json['lastMessage']),
      unreadCount: json['unreadCount'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      isFavourite: json['isFavourite'] ?? false,
      archived: json['archived'],
      isMuted: json['isMuted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'isGroup': isGroup,
        'displayName': displayName,
        'profileImage': profileImage,
        'lastMessage': lastMessage.toJson(),
        'unreadCount': unreadCount,
        'isPinned': isPinned,
        'isFavourite': isFavourite,
        'archived': archived,
        'isMuted': isMuted,
  };
}

