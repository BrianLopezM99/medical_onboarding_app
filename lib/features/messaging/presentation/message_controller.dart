import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/messaging/application/message_service.dart';
import 'package:medical_onboarding_app/features/messaging/data/message_api.dart';
import 'package:medical_onboarding_app/features/messaging/data/message_repository_impl.dart';
import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';

final messageControllerProvider =
    StateNotifierProvider.family<
      MessageController,
      List<Message>,
      MessageControllerParams
    >((ref, params) {
      final repo = MessageRepositoryImpl(MessageApi());
      final service = MessageService(repo);
      return MessageController(
        service,
        params.customerId,
        isAiChat: params.isAiChat,
      );
    });

class MessageControllerParams {
  final String customerId;
  final bool isAiChat;

  MessageControllerParams({required this.customerId, required this.isAiChat});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageControllerParams &&
          runtimeType == other.runtimeType &&
          customerId == other.customerId &&
          isAiChat == other.isAiChat;

  @override
  int get hashCode => customerId.hashCode ^ isAiChat.hashCode;
}

class MessageController extends StateNotifier<List<Message>> {
  final MessageService service;
  final String customerId;
  final bool isAiChat;
  bool isTyping = false;
  int _promptIndex = 0;

  bool _waitingUserInput = true;

  final List<String> _orderedPrompts = [
    'Hello. Please upload your insurance card.',
    'Can you provide your last medical report?',
    'Is your COVID vaccine certificate available?',
    'Please share any allergy documentation if available.',
    'Now send your ID to complete the registration.',
  ];

  MessageController(this.service, this.customerId, {this.isAiChat = false})
    : super([]) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await service.fetch(customerId);

    if (messages.isEmpty && isAiChat) {
      final welcomeMessage = Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: _orderedPrompts[_promptIndex++],
        timestamp: DateTime.now(),
        sender: MessageSender.agent,
      );
      await service.repo.saveMessages(customerId, [welcomeMessage]);
      state = [welcomeMessage];

      _waitingUserInput = true;
    } else {
      state = messages;
    }
  }

  // String _getNextPrompt() {
  //   if (_promptIndex >= _orderedPrompts.length) {
  //     return 'Thank you! All required documents have been collected.';
  //   }
  //   return _orderedPrompts[_promptIndex++];
  // }

  List<String> _generateAiResponses(String userInput) {
    userInput = userInput.toLowerCase();
    final responses = <String>[];

    if (userInput.contains('insurance')) {
      responses.add(
        'Thanks for the insurance card! I’ve successfully extracted your insurance provider and policy number.',
      );
    }
    if (userInput.contains('medical report')) {
      responses.add('Thanks! I’ve reviewed your medical report.');
    }
    if (userInput.contains('covid')) {
      responses.add(
        'COVID vaccine certificate received. Your vaccination status has been noted.',
      );
    }
    if (userInput.contains('allergy')) {
      responses.add(
        'Allergy documentation received. This helps us ensure safe care.',
      );
    }
    if (userInput.contains('id')) {
      responses.add(
        'ID received. Registration is now complete. if you want to register another customer, ',
      );

      _promptIndex = 0;
      responses.add(_orderedPrompts[_promptIndex++]);

      return responses;
    }

    if (_promptIndex < _orderedPrompts.length) {
      responses.add(_orderedPrompts[_promptIndex++]);
    }

    return responses;
  }

  Future<void> send(String content) async {
    print('send called with content: $content');

    if (_orderedPrompts.contains(content) ||
        content == 'Thank you! All required documents have been collected.') {
      return;
    }

    if (!_waitingUserInput) {
      print('Still waiting for AI response to previous message.');
      return;
    }

    _waitingUserInput = false;

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
    state = List.from(state);

    final responses = isAiChat
        ? _generateAiResponses(content)
        : ['Simulación de respuesta automática.'];

    for (final text in responses) {
      await Future.delayed(Duration(seconds: 2 + Random().nextInt(2)));

      final agentMessage = Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content: text,
        timestamp: DateTime.now(),
        sender: MessageSender.agent,
      );

      final currentMessages = await service.repo.getMessages(customerId);
      final finalMessages = [...currentMessages, agentMessage];
      await service.repo.saveMessages(customerId, finalMessages);

      state = finalMessages;
    }

    isTyping = false;
    _waitingUserInput = true;
    state = List.from(state);
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
    Uint8List bytes,
    String fileName,
    String mimeType,
    String lastPrompt,
  ) async {
    if (isTyping) return;
    final now = DateTime.now();

    final fileMessage = Message(
      id: now.microsecondsSinceEpoch.toString(),
      timestamp: now,
      sender: MessageSender.user,
      attachment: MessageAttachment(
        fileName: fileName,
        filePath: '',
        mimeType: mimeType,
        bytes: bytes,
      ),
      status: MessageStatus.sending,
    );

    state = [...state, fileMessage];

    final storedMessages = await service.repo.getMessages(customerId);
    final updatedMessages = [...storedMessages, fileMessage];
    await service.repo.saveMessages(customerId, updatedMessages);

    Future.delayed(const Duration(seconds: 3), () {
      _updateMessageStatus(fileMessage.id, MessageStatus.received);

      Future.delayed(const Duration(seconds: 1), () {
        _updateMessageStatus(fileMessage.id, MessageStatus.read);
      });
    });

    await Future.delayed(const Duration(seconds: 5));
    isTyping = true;
    state = List.from(state);

    // first msg from agent
    await Future.delayed(Duration(seconds: 2 + Random().nextInt(3)));

    final agentMessage = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      content: 'I have received the "$fileName" file, thank you.',
      timestamp: DateTime.now(),
      sender: MessageSender.agent,
    );

    final currentMessages = await service.repo.getMessages(customerId);
    final finalMessages = [...currentMessages, agentMessage];
    await service.repo.saveMessages(customerId, finalMessages);

    state = finalMessages;

    if (isAiChat) {
      // Fake AI
      await Future.delayed(const Duration(seconds: 2));
      final simulatedData = _simulateExtractedData(fileName, lastPrompt);

      final agentJsonMessage = Message(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        content:
            'Data extracted from the document:\n${_prettyPrintJson(simulatedData)}',
        timestamp: DateTime.now(),
        sender: MessageSender.agent,
      );

      final withExtracted = [...finalMessages, agentJsonMessage];
      await service.repo.saveMessages(customerId, withExtracted);
      state = withExtracted;

      final responses = _generateAiResponses(fileName);
      for (final response in responses) {
        await Future.delayed(Duration(seconds: 2 + Random().nextInt(2)));

        final responseMessage = Message(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          content: response,
          timestamp: DateTime.now(),
          sender: MessageSender.agent,
        );

        final updatedMessages = await service.repo.getMessages(customerId);
        final finalList = [...updatedMessages, responseMessage];
        await service.repo.saveMessages(customerId, finalList);

        state = finalList;
      }
    }
    isTyping = false;
    state = List.from(state);
  }

  Future<void> sendImageFromBytes(
    Uint8List bytes,
    String fileName,
    String mimeType,
    String lastPrompt,
  ) async {
    await sendAttachment(bytes, fileName, mimeType, lastPrompt);
  }

  Map<String, dynamic> _simulateExtractedData(
    String fileName,
    String lastPrompt,
  ) {
    final file = fileName.toLowerCase();

    if (file.contains("insurance card")) {
      return {
        "insuranceProvider": "Blue Shield",
        "policyNumber": "1234567890",
        "groupNumber": "BSH123",
      };
    } else if (file.contains("medical")) {
      return {
        "reportDate": "2025-06-10",
        "doctorName": "Dr. Smith",
        "diagnosis": "Mild asthma",
      };
    } else if (file.contains("covid")) {
      return {
        "vaccineType": "Pfizer",
        "doses": 2,
        "lastDoseDate": "2024-12-15",
      };
    } else if (file.contains("allergy")) {
      return {
        "allergies": ["Penicillin", "Peanuts"],
        "notes": "Carry an EpiPen at all times.",
      };
    } else if (file.contains("send your id")) {
      return {
        "fullName": "John Doe",
        "idNumber": "ID2025001",
        "dateOfBirth": "1990-05-12",
      };
    }

    return {
      "note":
          "No se pudo extraer información específica del archivo \"$fileName\".",
    };
  }

  String _prettyPrintJson(Map<String, dynamic> json) {
    return json.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
