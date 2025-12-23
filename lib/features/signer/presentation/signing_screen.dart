import 'package:flutter/material.dart';
import 'package:genui/genui.dart' as genui;
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';

import 'signing_catalog.dart';

class SigningScreen extends StatefulWidget {
  const SigningScreen({super.key, required String requestId});

  @override
  State<SigningScreen> createState() => _SigningScreenState();
}

class _SigningScreenState extends State<SigningScreen> {
  late final genui.GenUiConversation _conversation;
  final List<ChatBubbleModel> _bubbles = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  void _initializeConversation() {
    final generator = GoogleGenerativeAiContentGenerator(
      apiKey: 'YOUR_API_KEY',
      systemInstruction:
          'You are a helpful Legal Signing Assistant for Digito. '
          'Guide the user through signing their documents. '
          'Use the catalog items to display document info and signature pads.',
      catalog: signingCatalog,
    );

    // GenUiConversation in recent versions takes a2uiMessageProcessor.
    // If the lint says catalog/catalogs is required, it might be an older or different version.
    // But based on our research, it takes a2uiMessageProcessor.
    // Let's adjust based on the lint feedback which said 'catalog' is required for the GenUiConversation constructor.
    _conversation = genui.GenUiConversation(
      contentGenerator: generator,
      a2uiMessageProcessor:
          genui.A2uiMessageProcessor(catalogs: [signingCatalog]),
      onSurfaceAdded: (genui.SurfaceAdded event) {
        setState(() {
          _bubbles.add(ChatBubbleModel(
            isUser: false,
            surfaceId: event.surfaceId,
          ));
        });
        _scrollToBottom();
      },
      onTextResponse: (text) {
        setState(() {
          _bubbles.add(ChatBubbleModel(
            isUser: false,
            text: text,
          ));
        });
        _scrollToBottom();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );

    // Initial greeting
    _conversation.sendRequest(genui.UserMessage(
        [const genui.TextPart('Hello! I am ready to sign.')]));
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

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _bubbles.add(ChatBubbleModel(isUser: true, text: text));
      _isProcessing = true;
    });
    _scrollToBottom();

    await _conversation.sendRequest(genui.UserMessage([genui.TextPart(text)]));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signing Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _bubbles.clear();
                _initializeConversation();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _bubbles.length,
              itemBuilder: (context, index) {
                final bubble = _bubbles[index];
                return _MessageBubble(
                  bubble: bubble,
                  host: _conversation.host,
                );
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _ChatInput(
            controller: _textController,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}

class ChatBubbleModel {
  final bool isUser;
  final String? text;
  final String? surfaceId;

  ChatBubbleModel({required this.isUser, this.text, this.surfaceId});
}

class _MessageBubble extends StatelessWidget {
  final ChatBubbleModel bubble;
  final genui.GenUiHost host;

  const _MessageBubble({required this.bubble, required this.host});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = bubble.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bubble.text != null)
              Text(
                bubble.text!,
                style: TextStyle(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (bubble.surfaceId != null)
              genui.GenUiSurface(
                host: host,
                surfaceId: bubble.surfaceId!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onSend,
              icon: const Icon(Icons.send),
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
