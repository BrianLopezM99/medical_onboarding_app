import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';
import 'package:medical_onboarding_app/features/messaging/presentation/message_controller.dart';
import 'package:mime/mime.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;

  const MessageScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(messageControllerProvider(widget.customerId).notifier).send(text);
    _controller.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _statusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.received:
        return 'Recived';
      case MessageStatus.read:
        return 'Readed';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messageControllerProvider(widget.customerId));
    final isTyping = ref
        .read(messageControllerProvider(widget.customerId).notifier)
        .isTyping;

    _scrollToBottom();

    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.customerName}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message.sender == MessageSender.user;

                if (message.attachment != null) {
                  final attachment = message.attachment!;
                  final isImage = attachment.mimeType.startsWith('image/');

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (isImage)
                            attachment.bytes != null
                                ? Image.memory(
                                    attachment.bytes!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : !kIsWeb && attachment.filePath != null
                                ? Image.file(
                                    File(attachment.filePath!),
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : const Text('Image cannot be load'),
                          if (!isImage) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  attachment.fileName,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'File: ${attachment.mimeType}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isUser
                                    ? Colors.white70
                                    : Colors.grey[800],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          if (isUser)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: message.status == MessageStatus.sending
                                  ? const SizedBox(
                                      height: 12,
                                      width: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white70,
                                      ),
                                    )
                                  : Text(
                                      _statusText(message.status),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white70,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content ?? '',
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                        if (isUser)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: message.status == MessageStatus.sending
                                ? const SizedBox(
                                    height: 12,
                                    width: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                  )
                                : Text(
                                    _statusText(message.status),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white70,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'typing...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      withData: true,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      final file = result.files.single;

                      final bytes = file.bytes!;
                      final fileName = file.name;
                      final mimeType = lookupMimeType(fileName) ?? 'image/*';

                      ref
                          .read(
                            messageControllerProvider(
                              widget.customerId,
                            ).notifier,
                          )
                          .sendImageFromBytes(bytes, fileName, mimeType);
                    }
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      withData: true,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      final file = result.files.single;

                      final bytes = file.bytes!;
                      final fileName = file.name;
                      final mimeType =
                          lookupMimeType(fileName) ??
                          'application/octet-stream';

                      ref
                          .read(
                            messageControllerProvider(
                              widget.customerId,
                            ).notifier,
                          )
                          .sendAttachment(bytes, fileName, mimeType);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
