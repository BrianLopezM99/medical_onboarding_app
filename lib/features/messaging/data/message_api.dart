import 'dart:convert';
import 'package:medical_onboarding_app/features/messaging/data/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageApi {
  static const _key = 'messages';

  Future<List<MessageModel>> fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded
        .map(
          (e) => MessageModel(
            id: e['id'],
            content: e['content'],
            timestamp: e['timestamp'],
            sender: e['sender'],
          ),
        )
        .toList();
  }

  Future<void> saveMessages(List<MessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      messages
          .map(
            (m) => {
              'id': m.id,
              'content': m.content,
              'timestamp': m.timestamp,
              'sender': m.sender,
            },
          )
          .toList(),
    );
    await prefs.setString(_key, encoded);
  }
}
