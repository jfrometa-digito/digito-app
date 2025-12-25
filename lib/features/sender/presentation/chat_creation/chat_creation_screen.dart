import 'package:digito_app/features/sender/presentation/chat_creation/sender_catalog.dart';
import 'package:digito_app/features/sender/presentation/chat_creation/chat_tools.dart';

import 'package:digito_app/features/sender/providers/requests_provider.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

// Platform-specific imports
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:digito_app/core/providers/logger_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatCreationScreen extends ConsumerStatefulWidget {
  const ChatCreationScreen({super.key});

  static const String systemInstruction = '''
You are the Digito Document Signing Orchestration Agent.
State source of truth is the draft managed by tools. Always call `getDraftState` first each turn and after handling a userAction event.
Flows and constraints:
- selfSign -> minRecipients=1, maxRecipients=1
- oneOnOne -> minRecipients=2, maxRecipients=2
- multiParty -> minRecipients=3, maxRecipients=10
Policy:
1) If flowType is not set, render `flowSelector` surface. When you receive a userAction `flowSelected`, call `setRequestType` with the given type, then refresh state.
2) If no document is present (filePath/fileBytes missing), render `fileUploader` surface. When you get `fileUploaded`, refresh state.
3) After flow + document, collect recipients. Render `recipientManager` with the min/max constraints from state. Do NOT ask for more than max; keep the surface visible until min is satisfied.
   The recipientManager emits userAction events: `recipientAdded`, `recipientRemoved`, and `recipientCollectionComplete`. After any of these, refresh state.
4) When recipients satisfy constraints and a file exists, render `draftSummary` with canSend=true. Otherwise set canSend=false and explain what is missing.
5) When you receive userAction `sendRequest`, call `sendRequest` tool. Show the returned signUrl in a final summary. Do not invent URLs.
6) Never request or send raw PDF content; only use metadata returned by tools.
Use short, guiding text plus the provided surfaces. Prefer tool calls over free-form text when changing state.
''';

  @override
  ConsumerState<ChatCreationScreen> createState() => _ChatCreationScreenState();
}

class _ChatCreationScreenState extends ConsumerState<ChatCreationScreen> {
  late final GenUiConversation _conversation;
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
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final logger = ref.read(loggerProvider);
    final catalog = createSenderCatalog();

    // Define tools
    final tools = [
      SetRequestTypeTool(ref.read(activeDraftProvider.notifier)),
      AddRecipientTool(ref.read(activeDraftProvider.notifier)),
      GetDraftStateTool(ref.read(activeDraftProvider.notifier)),
      SendRequestTool(ref.read(activeDraftProvider.notifier)),
    ];

    // Create platform-specific ContentGenerator
    final ContentGenerator generator;

    if (kIsWeb) {
      // Web: Use Firebase AI to avoid CORS issues
      generator = FirebaseAiContentGenerator(
        catalog: catalog,
        systemInstruction: ChatCreationScreen.systemInstruction,
        additionalTools: tools,
      );
    } else {
      // Mobile (iOS/Android): Use Google Generative AI directly (no CORS issues)
      if (apiKey.isEmpty) {
        logger.error(
          'GEMINI_API_KEY not found. Please run with --dart-define=GEMINI_API_KEY=your_key',
        );
      }

      generator = FirebaseAiContentGenerator(
        systemInstruction: ChatCreationScreen.systemInstruction,
        catalog: catalog,
        additionalTools: tools,
      );
    }

    _conversation = GenUiConversation(
      contentGenerator: generator,
      a2uiMessageProcessor: A2uiMessageProcessor(catalogs: [catalog]),
      onSurfaceAdded: (SurfaceAdded event) {
        setState(() {
          _bubbles.add(
            ChatBubbleModel(isUser: false, surfaceId: event.surfaceId),
          );
        });
        _scrollToBottom();
      },
      onTextResponse: (text) {
        setState(() {
          _bubbles.add(ChatBubbleModel(isUser: false, text: text));
        });
        _scrollToBottom();
      },
      onError: (error) {
        logger.error('GenUI conversation error', error.error.toString());
        String errorMessage = error.error.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _initializeConversation(),
              textColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        );
      },
    );

    // Initial greeting
    _conversation.sendRequest(UserMessage([const TextPart('Hello!')]));
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

    await _conversation.sendRequest(UserMessage([TextPart(text)]));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the active draft to rebuild UI when it changes
    final draft = ref.watch(activeDraftProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(activeDraftProvider.notifier).clear();
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainer,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusItem(
                        icon: Icons.description,
                        label: 'Document:',
                        value: draft?.title ?? 'Not selected',
                      ),
                      const SizedBox(height: 4),
                      _StatusItem(
                        icon: Icons.people,
                        label: 'Recipients:',
                        value: (draft?.recipients ?? []).isEmpty
                            ? 'None added'
                            : (draft?.recipients ?? [])
                                  .map((e) => e.email)
                                  .join(', '),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _bubbles.length,
              itemBuilder: (context, index) {
                final bubble = _bubbles[index];
                return _MessageBubble(bubble: bubble, host: _conversation.host);
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _ChatInput(controller: _textController, onSend: _handleSend),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: theme.colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

// --- UI Helper Widgets (reused from SigningScreen) ---

class ChatBubbleModel {
  final bool isUser;
  final String? text;
  final String? surfaceId;

  ChatBubbleModel({required this.isUser, this.text, this.surfaceId});
}

class _MessageBubble extends StatelessWidget {
  final ChatBubbleModel bubble;
  final GenUiHost host;

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
              : theme.colorScheme.surfaceContainerHighest,
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
                      : theme.colorScheme.onSurface,
                ),
              ),
            if (bubble.surfaceId != null)
              GenUiSurface(host: host, surfaceId: bubble.surfaceId!),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({required this.controller, required this.onSend});

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
                  fillColor: theme.colorScheme.surfaceContainerHighest,
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
