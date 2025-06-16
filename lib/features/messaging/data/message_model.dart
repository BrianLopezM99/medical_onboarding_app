import 'dart:convert';
import 'dart:typed_data';
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

  final String? bytesBase64;

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
    this.bytesBase64,
  });

  Uint8List? get bytes =>
      bytesBase64 != null ? base64Decode(bytesBase64!) : null;

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
    bytesBase64: m.attachment?.bytes != null
        ? base64Encode(m.attachment!.bytes!)
        : null,
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
            bytes: bytes,
          )
        : null,
    timestamp: DateTime.parse(timestamp),
    sender: MessageSender.values.firstWhere(
      (e) => e.name == sender,
      orElse: () {
        print('Warning: Unknown sender: $sender');
        return MessageSender.user;
      },
    ),

    status: MessageStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () {
        print('Warning: Unknown status: $status');
        return MessageStatus.sending;
      },
    ),
  );
}
