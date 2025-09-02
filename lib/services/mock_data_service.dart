import '../models/chat_model.dart';
import 'mock_loader.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  List<Chat> chats = [];
  // List<Message> messages = [];
  List<Message> messages = [];
  Map<String, List<Message>> messagesByChatId = {};

  Future<void> loadAllData() async {
    chats = await loadMockChats();
    // messages = await loadMockMessages();
    messages = await loadMockMessages(); // ✅ List<Message>
    messagesByChatId = await loadMockMessagesGrouped();

  }
}