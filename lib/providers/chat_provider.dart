import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/chat/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final Map<String, List<Message>> _messages = {};
  final Map<String, StreamSubscription<List<Message>>> _msgSubs = {};
  StreamSubscription<List<Chat>>? _chatsSub;

  List<Chat> chats = [];
  String? currentChatId;
  bool loadingChats = false;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  /// Start listening for chats for the signed in user
  void init() {
    final myUid = uid;
    if (myUid == null) return;
    loadingChats = true;
    notifyListeners();
    _chatsSub = ChatService.streamChatsForUser(myUid).listen((list) {
      chats = list;
      loadingChats = false;
      notifyListeners();
    });
  }

  /// Open chat and start listening for messages (cancels previous)
  Future<void> openChat(String chatId) async {
    if (currentChatId == chatId) return;
    // cancel previous
    if (currentChatId != null && _msgSubs[currentChatId!] != null) {
      await _msgSubs[currentChatId!]!.cancel();
      _msgSubs.remove(currentChatId!);
    }

    currentChatId = chatId;
    _messages.putIfAbsent(chatId, () => []);
    final sub = ChatService.streamMessages(chatId).listen((list) {
      _messages[chatId] = list;
      notifyListeners();
    });
    _msgSubs[chatId] = sub;

    // mark as read
    if (uid != null) {
      await ChatService.markChatAsRead(chatId, uid!);
    }
  }

  List<Message> getMessages(String chatId) {
    return _messages[chatId] ?? [];
  }

  /// Convenience: returns a Chat if present
  Chat? getChat(String chatId) {
    try {
      return chats.firstWhere((c) => c.chatId == chatId);
    } on StateError {
      return null;
    }
  }

  /// Create or get chat id for two users and open it
  Future<String?> startDirectChatWith(String otherUserId,
      {String? displayName, String? profileImage}) async {
    final myUid = uid;
    if (myUid == null) return null;
    final chatId = await ChatService.createOrGetChat(myUid, otherUserId,
        displayName: displayName, profileImage: profileImage);
    await openChat(chatId);
    return chatId;
  }

  /// Send a text message
  Future<void> sendText(String chatId, String text) async {
    final myUid = uid;
    if (myUid == null) return;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final message = Message(
      messageId: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: myUid,
      content: text,
      type: 'text',
      timestamp: now,
      status: 'sent',
    );
    await ChatService.sendMessage(chatId, message);
  }

  /// Send media message (uploads then sends)
  Future<void> sendMedia(String chatId, File file, {String? mimeType}) async {
    final myUid = uid;
    if (myUid == null) return;
    final url = await ChatService.uploadMediaFile(file, pathPrefix: 'chat_media');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final message = Message(
      messageId: DateTime.now().microsecondsSinceEpoch.toString(),
      senderId: myUid,
      content: url,
      type: mimeType ?? 'image',
      timestamp: now,
      status: 'sent',
    );
    await ChatService.sendMessage(chatId, message);
  }

  /// Typing indicator
  Future<void> setTyping(String chatId, bool isTyping) async {
    final myUid = uid;
    if (myUid == null) return;
    await ChatService.setTyping(chatId, myUid, isTyping);
  }

  /// Close provider and cancel subscriptions
  @override
  void dispose() {
    for (final s in _msgSubs.values) {
      s.cancel();
    }
    _chatsSub?.cancel();
    super.dispose();
  }
}