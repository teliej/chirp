import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat/chat_model.dart';

class ChatService {
  static final FirebaseFirestore _fs = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Uuid _uuid = const Uuid();

  /// Create or return deterministic chatId for a 1:1 chat
  static String chatIdForUsers(String a, String b) {
    final ids = [a, b]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  /// Ensure chat doc exists (creates minimal doc with a placeholder lastMessage)
  static Future<String> createOrGetChat(String userA, String userB,
      {String? displayName, String? profileImage}) async {
    final id = chatIdForUsers(userA, userB);
    final docRef = _fs.collection('chats').doc(id);
    final doc = await docRef.get();
    if (doc.exists) return id;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final placeholderMessage = Message(
      messageId: _uuid.v4(),
      senderId: userA,
      content: '',
      type: 'text',
      timestamp: now,
      status: 'sent',
    );

    await docRef.set({
      'chatId': id,
      'isGroup': false,
      'participants': [userA, userB],
      'displayName': displayName ?? '',
      'profileImage': profileImage ?? '',
      'lastMessage': placeholderMessage.toJson(),
      'unreadCounts': {userA: 0, userB: 0},
      'typing': {},
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  /// Send a message object into the messages subcollection and update chat meta
  static Future<void> sendMessage(String chatId, Message message) async {
    final batch = _fs.batch();
    final messagesRef =
        _fs.collection('chats').doc(chatId).collection('messages').doc(message.messageId);
    batch.set(messagesRef, message.toJson());

    final chatRef = _fs.collection('chats').doc(chatId);

    // Update lastMessage and increment unread counter(s)
    final chatSnap = await chatRef.get();
    Map<String, dynamic> unreadCounts = {};
    if (chatSnap.exists) {
      final data = chatSnap.data()!;
      if (data['unreadCounts'] is Map<String, dynamic>) {
        unreadCounts = Map<String, dynamic>.from(data['unreadCounts']);
      }
      final participants = List<String>.from(data['participants'] ?? []);
      for (final p in participants) {
        if (p != message.senderId) {
          unreadCounts[p] = (unreadCounts[p] ?? 0) + 1;
        }
      }
    }

    batch.update(chatRef, {
      'lastMessage': message.toJson(),
      'unreadCounts': unreadCounts,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Upload media file to firebase storage and return download URL
  static Future<String> uploadMediaFile(File file, {String? pathPrefix}) async {
    final id = _uuid.v4();
    final path = '${pathPrefix ?? "chat_media"}/$id';
    final ref = _storage.ref().child(path);
    final task = ref.putFile(file);
    final snap = await task.whenComplete(() {});
    final url = await snap.ref.getDownloadURL();
    return url;
  }

  /// Stream of chats for a user ordered by last message desc
  static Stream<List<Chat>> streamChatsForUser(String userId) {
    return _fs
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        final lastMsgMap = Map<String, dynamic>.from(data['lastMessage'] ?? {});
        final lastMessage = Message.fromJson({
          'messageId': lastMsgMap['messageId'] ?? '',
          'senderId': lastMsgMap['senderId'] ?? '',
          'content': lastMsgMap['content'] ?? '',
          'type': lastMsgMap['type'] ?? 'text',
          'timestamp': lastMsgMap['timestamp'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          'status': lastMsgMap['status'] ?? 'sent',
        });

        return Chat(
          chatId: d.id,
          isGroup: data['isGroup'] ?? false,
          displayName: data['displayName'] ?? '',
          profileImage: data['profileImage'] ?? '',
          lastMessage: lastMessage,
          unreadCount: (data['unreadCounts'] is Map && (data['unreadCounts'][userId] != null))
              ? (data['unreadCounts'][userId] as int)
              : 0,
          isPinned: data['isPinned'] ?? false,
          isFavourite: data['isFavourite'] ?? false,
          archived: data['archived'] ?? false,
          isMuted: data['isMuted'] ?? false,
        );
      }).toList();
    });
  }

  /// Stream of messages for a chat (real-time). Orders newest last for UI convenience.
  static Stream<List<Message>> streamMessages(String chatId, {int limit = 50}) {
    return _fs
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final m = Map<String, dynamic>.from(d.data());
        return Message.fromJson({
          'messageId': m['messageId'] ?? d.id,
          'senderId': m['senderId'] ?? '',
          'content': m['content'] ?? '',
          'type': m['type'] ?? 'text',
          'timestamp': m['timestamp'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          'status': m['status'] ?? 'sent',
        });
      }).toList();
    });
  }

  /// Mark messages as read by setting unreadCounts for user to 0 and optionally updating statuses
  static Future<void> markChatAsRead(String chatId, String userId) async {
    final chatRef = _fs.collection('chats').doc(chatId);
    await chatRef.update({
      'unreadCounts.$userId': 0,
    });
    // Optionally update message statuses in messages subcollection for this user
  }

  /// Set typing indicator for a user in a chat
  static Future<void> setTyping(String chatId, String userId, bool isTyping) async {
    final chatRef = _fs.collection('chats').doc(chatId);
    await chatRef.update({
      'typing.$userId': isTyping,
    });
  }
}