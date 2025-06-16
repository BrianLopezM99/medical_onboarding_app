import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';

class MessageModel {
  final String id;
  final String content;
  final String timestamp;
  final String sender;

  MessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.sender,
  });

  factory MessageModel.fromEntity(Message m) => MessageModel(
    id: m.id,
    content: m.content,
    timestamp: m.timestamp.toIso8601String(),
    sender: m.sender.name,
  );

  Message toEntity() => Message(
    id: id,
    content: content,
    timestamp: DateTime.parse(timestamp),
    sender: MessageSender.values.firstWhere((e) => e.name == sender),
  );
}
