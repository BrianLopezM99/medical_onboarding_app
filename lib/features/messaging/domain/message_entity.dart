class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final MessageSender sender;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.sender,
  });
}

enum MessageSender { user, agent }
