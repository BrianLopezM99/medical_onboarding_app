import 'dart:typed_data';

class Message {
  final String id;
  final String? content;
  final DateTime timestamp;
  final MessageSender sender;
  MessageStatus status;

  final String? imageUrl;
  final MessageAttachment? attachment;

  Message({
    required this.id,
    this.content,
    required this.timestamp,
    required this.sender,
    this.status = MessageStatus.read,
    this.imageUrl,
    this.attachment,
  });
}

enum MessageSender { user, agent }

enum MessageStatus { sending, received, read }

class MessageAttachment {
  final String fileName;
  final String mimeType;
  final String? filePath;
  final Uint8List? bytes;

  MessageAttachment({
    required this.fileName,
    required this.mimeType,
    this.filePath,
    this.bytes,
  });
}
