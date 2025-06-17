import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_onboarding_app/features/core/colors.dart';
import 'package:medical_onboarding_app/features/messaging/domain/message_entity.dart';
import 'package:medical_onboarding_app/features/messaging/presentation/message_controller.dart';
import 'package:mime/mime.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String customerName;
  final bool isAi;

  const MessageScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.isAi,
  });

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _initialMessageSent = false;

  void _sendInitialAiMessageIfNeeded() {
    if (!_initialMessageSent && widget.isAi) {
      _initialMessageSent = true;

      ref.read(
        messageControllerProvider(
          MessageControllerParams(
            customerId: widget.customerId,
            isAiChat: widget.isAi,
          ),
        ).notifier,
      );
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref
        .read(
          messageControllerProvider(
            MessageControllerParams(
              customerId: widget.customerId,
              isAiChat: widget.isAi,
            ),
          ).notifier,
        )
        .send(text);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(
      messageControllerProvider(
        MessageControllerParams(
          customerId: widget.customerId,
          isAiChat: widget.isAi,
        ),
      ),
    );

    final isTyping = ref
        .read(
          messageControllerProvider(
            MessageControllerParams(
              customerId: widget.customerId,
              isAiChat: widget.isAi,
            ),
          ).notifier,
        )
        .isTyping;

    _scrollToBottom();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialAiMessageIfNeeded();
    });

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    print(widget.isAi);
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

                final bubbleColor = isUser
                    ? ColorsCore.greenFive
                    : ColorsCore.greenOne;
                final textColor = isUser ? Colors.black : Colors.white;

                final avatar = isUser
                    ? null
                    : widget.isAi
                    ? SizedBox(
                        width: width * 0.1,
                        height: height * 0.1,
                        child: Image.asset('assets/images/pet_app.png'),
                      )
                    : Icon(Icons.person, size: 36);

                final screenWidth = MediaQuery.of(context).size.width;

                final messageWidget = Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isUser)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(2, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (message.attachment != null) ...[
                          IntrinsicWidth(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Attached file',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            message.attachment!.fileName,
                            style: TextStyle(
                              color: textColor,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else
                          Text(
                            message.content ?? '',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              height: 1.4,
                            ),
                          ),
                        if (isUser)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: message.status == MessageStatus.sending
                                ? const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black26,
                                    ),
                                  )
                                : Text(
                                    _statusText(message.status),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black54,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                );

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isUser)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Align(
                            alignment: Alignment.center,
                            child: avatar!,
                          ),
                        ),
                      messageWidget,
                    ],
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
                    textInputAction: TextInputAction.send,
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

                      final controller = ref.read(
                        messageControllerProvider(
                          MessageControllerParams(
                            customerId: widget.customerId,
                            isAiChat: widget.isAi,
                          ),
                        ).notifier,
                      );

                      final messages = ref.read(
                        messageControllerProvider(
                          MessageControllerParams(
                            customerId: widget.customerId,
                            isAiChat: widget.isAi,
                          ),
                        ),
                      );

                      final lastPrompt =
                          messages.reversed
                              .firstWhere(
                                (m) =>
                                    m.sender == MessageSender.user &&
                                    m.content != null,
                                orElse: () => Message(
                                  id: '0',
                                  content: '',
                                  timestamp: DateTime.now(),
                                  sender: MessageSender.user,
                                ),
                              )
                              .content ??
                          'Image upload';

                      await controller.sendImageFromBytes(
                        bytes,
                        fileName,
                        mimeType,
                        lastPrompt,
                      );
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

                      final controller = ref.read(
                        messageControllerProvider(
                          MessageControllerParams(
                            customerId: widget.customerId,
                            isAiChat: widget.isAi,
                          ),
                        ).notifier,
                      );

                      final messages = ref.read(
                        messageControllerProvider(
                          MessageControllerParams(
                            customerId: widget.customerId,
                            isAiChat: widget.isAi,
                          ),
                        ),
                      );

                      final lastPrompt =
                          messages
                              .where(
                                (m) =>
                                    m.sender == MessageSender.user &&
                                    m.content != null,
                              )
                              .lastOrNull
                              ?.content ??
                          'Document upload';

                      await controller.sendAttachment(
                        bytes,
                        fileName,
                        mimeType,
                        lastPrompt,
                      );
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
