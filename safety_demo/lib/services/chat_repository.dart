import 'package:hive_flutter/hive_flutter.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  static const String _boxName = 'chat_messages';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatMessageModelAdapter());
    }
  }

  static Future<Box<ChatMessageModel>> getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<ChatMessageModel>(_boxName);
    }
    return Hive.box<ChatMessageModel>(_boxName);
  }

  static Future<void> saveMessage(ChatMessageModel message) async {
    final box = await getBox();
    await box.put(message.id, message);
  }

  static Future<List<ChatMessageModel>> getAllMessages() async {
    final box = await getBox();
    return box.values.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  static Future<List<ChatMessageModel>> getMessagesBySender(String senderRole) async {
    final allMessages = await getAllMessages();
    return allMessages.where((msg) => msg.senderRole == senderRole).toList();
  }

  static Stream<List<ChatMessageModel>> watchMessages() async* {
    final box = await getBox();
    yield* box.watch().map((event) {
      return box.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }
}

