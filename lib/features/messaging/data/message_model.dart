import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';

class MessageModel {
  final String id;
  final String? content;
  final String? imageUrl;
  final String? fileName;
  final String? filePath;
  final String? mimeType;
  final String timestamp;
  final String sender;
  final String status;

  MessageModel({
    required this.id,
    this.content,
    this.imageUrl,
    this.fileName,
    this.filePath,
    this.mimeType,
    required this.timestamp,
    required this.sender,
    required this.status,
  });

  factory MessageModel.fromEntity(Message m) => MessageModel(
    id: m.id,
    content: m.content,
    imageUrl: m.imageUrl,
    fileName: m.attachment?.fileName,
    filePath: m.attachment?.filePath,
    mimeType: m.attachment?.mimeType,
    timestamp: m.timestamp.toIso8601String(),
    sender: m.sender.name,
    status: m.status.name,
  );

  Message toEntity() => Message(
    id: id,
    content: content,
    imageUrl: imageUrl,
    attachment: (fileName != null && filePath != null && mimeType != null)
        ? MessageAttachment(
            fileName: fileName!,
            filePath: filePath!,
            mimeType: mimeType!,
          )
        : null,
    timestamp: DateTime.parse(timestamp),
    sender: MessageSender.values.firstWhere(
      (e) => e.name == sender,
      orElse: () {
        print('Warning: sender desconocido: $sender');
        return MessageSender.user;
      },
    ),

    status: MessageStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () {
        print('Warning: status desconocido: $status');
        return MessageStatus.sending;
      },
    ),
  );
}
