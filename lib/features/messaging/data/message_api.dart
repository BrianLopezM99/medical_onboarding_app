import 'dart:convert';

import 'package:medical_onboarding_app/features/messaging/data/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageApi {
  static const _prefix = 'messages_';

  Future<List<MessageModel>> fetchMessages(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$customerId');
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded
        .map(
          (e) => MessageModel(
            id: e['id'],
            content: e['content'],
            imageUrl: e['imageUrl'],
            fileName: e['fileName'],
            filePath: e['filePath'],
            mimeType: e['mimeType'],
            timestamp: e['timestamp'],
            sender: e['sender'],
            status: e['status'] ?? 'sending',
            bytesBase64: e['bytesBase64'],
          ),
        )
        .toList();
  }

  Future<void> saveMessages(
    String customerId,
    List<MessageModel> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      messages
          .map(
            (m) => {
              'id': m.id,
              'content': m.content,
              'imageUrl': m.imageUrl,
              'fileName': m.fileName,
              'filePath': m.filePath,
              'mimeType': m.mimeType,
              'timestamp': m.timestamp,
              'sender': m.sender,
              'status': m.status,
              'bytesBase64': m.bytesBase64,
            },
          )
          .toList(),
    );
    await prefs.setString('$_prefix$customerId', encoded);
  }
}
