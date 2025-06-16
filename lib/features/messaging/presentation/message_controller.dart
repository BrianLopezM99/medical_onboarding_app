import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/messaging/application/message_service.dart';
import 'package:medical_onboarding_app/features/messaging/data/message_api.dart';
import 'package:medical_onboarding_app/features/messaging/data/message_repository_impl.dart';
import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';

final messageControllerProvider =
    StateNotifierProvider.family<MessageController, List<Message>, String>((
      ref,
      customerId,
    ) {
      final repo = MessageRepositoryImpl(MessageApi());
      final service = MessageService(repo);
      return MessageController(service, customerId);
    });

class MessageController extends StateNotifier<List<Message>> {
  final MessageService service;
  final String customerId;
  bool isTyping = false;

  MessageController(this.service, this.customerId) : super([]) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await service.fetch(customerId);
    state = messages;
  }

  Future<void> send(String content) async {
    final now = DateTime.now();

    final userMessage = Message(
      id: now.microsecondsSinceEpoch.toString(),
      content: content,
      timestamp: now,
      sender: MessageSender.user,
      status: MessageStatus.sending,
    );

    state = [...state, userMessage];

    final storedMessages = await service.repo.getMessages(customerId);
    final updatedMessages = [...storedMessages, userMessage];
    await service.repo.saveMessages(customerId, updatedMessages);

    Future.delayed(Duration(seconds: 3), () {
      _updateMessageStatus(userMessage.id, MessageStatus.received);

      Future.delayed(Duration(seconds: 1), () {
        _updateMessageStatus(userMessage.id, MessageStatus.read);
      });
    });

    await Future.delayed(Duration(seconds: 5));

    isTyping = true;
    state = List.from(state); // UI update

    Future.delayed(Duration(seconds: 2 + Random().nextInt(3)), () async {
      final agentMessage = Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: 'Simulación de respuesta automática.',
        timestamp: DateTime.now(),
        sender: MessageSender.agent,
      );

      final currentMessages = await service.repo.getMessages(customerId);
      final finalMessages = [...currentMessages, agentMessage];
      await service.repo.saveMessages(customerId, finalMessages);

      state = finalMessages;

      isTyping = false;
      state = List.from(state); // Update UI for quit "typing..."
    });
  }

  void _updateMessageStatus(String messageId, MessageStatus newStatus) async {
    final updatedList = state.map((msg) {
      if (msg.id == messageId) {
        return Message(
          id: msg.id,
          content: msg.content,
          imageUrl: msg.imageUrl,
          attachment: msg.attachment,
          timestamp: msg.timestamp,
          sender: msg.sender,
          status: newStatus,
        );
      }
      return msg;
    }).toList();

    state = updatedList;

    await service.repo.saveMessages(customerId, updatedList);
  }

  Future<void> sendImage(String imagePath) async {
    final now = DateTime.now();

    final imageMessage = Message(
      id: now.microsecondsSinceEpoch.toString(),
      imageUrl: imagePath,
      timestamp: now,
      sender: MessageSender.user,
      status: MessageStatus.sending,
    );

    state = [...state, imageMessage];

    final storedMessages = await service.repo.getMessages(customerId);
    final updatedMessages = [...storedMessages, imageMessage];
    await service.repo.saveMessages(customerId, updatedMessages);

    Future.delayed(Duration(seconds: 3), () {
      _updateMessageStatus(imageMessage.id, MessageStatus.received);

      Future.delayed(const Duration(seconds: 1), () {
        _updateMessageStatus(imageMessage.id, MessageStatus.read);
      });
    });
  }

  Future<void> sendAttachment(
    String filePath,
    String fileName,
    String mimeType,
  ) async {
    final now = DateTime.now();

    final fileMessage = Message(
      id: now.microsecondsSinceEpoch.toString(),
      timestamp: now,
      sender: MessageSender.user,
      attachment: MessageAttachment(
        fileName: fileName,
        filePath: filePath,
        mimeType: mimeType,
      ),
      status: MessageStatus.sending,
    );

    state = [...state, fileMessage];

    final storedMessages = await service.repo.getMessages(customerId);
    final updatedMessages = [...storedMessages, fileMessage];
    await service.repo.saveMessages(customerId, updatedMessages);

    Future.delayed(Duration(seconds: 3), () {
      _updateMessageStatus(fileMessage.id, MessageStatus.received);

      Future.delayed(const Duration(seconds: 1), () {
        _updateMessageStatus(fileMessage.id, MessageStatus.read);
      });
    });
  }
}
