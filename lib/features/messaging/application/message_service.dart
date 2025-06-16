import 'dart:math';
import 'dart:async';

import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';
import 'package:medical_onboarding_app/features/messaging/domain/message_repository.dart';

class MessageService {
  final MessageRepository repo;

  MessageService(this.repo);

  Future<List<Message>> fetch(String customerId) =>
      repo.getMessages(customerId);

  Future<void> sendMessage(String customerId, String content) async {
    final now = DateTime.now();

    // 📨 Create user msg
    final userMessage = Message(
      id: now.microsecondsSinceEpoch.toString(),
      content: content,
      timestamp: now,
      sender: MessageSender.user,
    );

    //Get current msg & add new
    final messages = await repo.getMessages(customerId);
    final updatedMessages = [...messages, userMessage];

    //save user msg
    await repo.saveMessages(customerId, updatedMessages);

    final delaySeconds = 2 + Random().nextInt(3);
    await Future.delayed(Duration(seconds: delaySeconds));

    // agent msg
    final agentMessage = Message(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      content: 'Simulación de respuesta automática.',
      timestamp: DateTime.now(),
      sender: MessageSender.agent,
    );

    // msg agent save
    final finalMessages = [...updatedMessages, agentMessage];
    await repo.saveMessages(customerId, finalMessages);
  }
}
