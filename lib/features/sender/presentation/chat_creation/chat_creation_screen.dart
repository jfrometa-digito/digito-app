import 'package:digito_app/features/sender/presentation/chat_creation/sender_catalog.dart';
import 'package:digito_app/features/sender/presentation/chat_creation/chat_tools.dart';

import 'package:digito_app/features/sender/providers/requests_provider.dart';

import 'package:file_picker/file_picker.dart';
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

  static const String systemInstruction =
      'You are a helpful assistant for creating document signature requests. '
      'Your workflow must follow these steps strictly:\n'
      '1. Start by asking the user which flow they want to use: Self-Sign, One-on-One, or Multi-Party. Use the "flowSelector" component for this. '
      'When the user selects a flow, use the "setRequestType" tool to update the draft.\n'
      '2. Once a flow is selected, ask the user to upload the document. Use the "fileUploader" component for this.\n'
      '3. After the file is uploaded, prompt the user to clarify who is signing:\n'
      '   - If "Self-Sign": Confirm they are the signer.\n'
      '   - If "One-on-One" or "Multi-Party": Ask if they (the sender) are also signing. If yes, add them as the first recipient using the "addRecipient" tool.\n'
      '4. Then ask for any other details like additional recipients if needed (for One-on-One/Multi-Party). Use "addRecipient" tool for each one.\n'
      '5. Finally, show a summary using "draftSummary" and ask to review.\n\n'
      'Always prefer showing the components (`flowSelector`, `fileUploader`, `recipientList`, `draftSummary`) over asking text-based questions for these tasks.';

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

    final catalog = createSenderCatalog(
      onMessageSent: (message) {
        _textController.text = message;
        _handleSend();
      },
      onUploadPressed: () async {
        // Trigger file picker
        final file = await _pickFile();
        if (file != null) {
          // Update provider
          await ref.read(activeDraftProvider.notifier).updateFile(
                file.path!,
                file.name,
                fileBytes: file.bytes,
              );
          // Notify AI
          if (mounted) {
            _textController.text = "Uploaded ${file.name}";
            _handleSend();
          }
        }
      },
    );

    // Watch the active draft notifier to pass to tools
    final activeDraftNotifier = ref.read(activeDraftProvider.notifier);

    // Define tools
    final tools = [
      SetRequestTypeTool(activeDraftNotifier),
      AddRecipientTool(activeDraftNotifier),
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
            'GEMINI_API_KEY not found. Please run with --dart-define=GEMINI_API_KEY=your_key');
      }

      generator = GoogleGenerativeAiContentGenerator(
        apiKey: apiKey,
        modelName: 'gemini-1.5-flash',
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
          _bubbles.add(ChatBubbleModel(
            isUser: false,
            surfaceId: event.surfaceId,
          ));
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
        logger.error('GenUI conversation error', error);
        String errorMessage = 'An error occurred. Please try again.';

        if (error.toString().contains('XmlHttpRequest error')) {
          errorMessage =
              'Connection failed. Check your API Key permissions and CORS settings.';
        } else if (error.toString().contains('ContentGeneratorError')) {
          errorMessage =
              'The AI model encountered an error generating content. Check API key quota or safety settings.';
        } else if (apiKey.isEmpty && !kIsWeb) {
          errorMessage = 'API Key is missing. Please configure GEMINI_API_KEY.';
        } else {
          errorMessage = error.toString();
        }

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

  // ignore: unused_element
  Future<PlatformFile?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    return result?.files.singleOrNull;
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

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatusItem(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant)),
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
              GenUiSurface(
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
