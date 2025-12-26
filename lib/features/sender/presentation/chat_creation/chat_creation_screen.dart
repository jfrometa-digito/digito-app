import 'package:digito_app/domain/models/signature_request.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:digito_app/features/sender/presentation/chat_creation/sender_catalog.dart';
import 'package:digito_app/features/sender/providers/requests_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatCreationScreen extends ConsumerStatefulWidget {
  const ChatCreationScreen({super.key});

  @override
  ConsumerState<ChatCreationScreen> createState() => _ChatCreationScreenState();
}

class _ChatCreationScreenState extends ConsumerState<ChatCreationScreen> {
  final List<ChatBubbleModel> _bubbles = [];
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to after build to access ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFlow();
    });
  }

  void _initializeFlow() {
    if (_initialized) return;
    _initialized = true;

    // Check current state to decide where to start
    final draft = ref.read(activeDraftProvider);

    // Always start with a greeting
    setState(() {
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          text: 'Hello! I can help you create a new signature request.',
        ),
      );
    });

    if (draft == null ||
        (draft.title == 'Untitled Document' &&
            draft.type == SignatureRequestType.multiParty &&
            draft.recipients.isEmpty &&
            draft.filePath == null)) {
      // Clean slate or default init
      _showFlowSelector();
    } else {
      // Resume logic
      _resumeFlow(draft);
    }
  }

  void _resumeFlow(SignatureRequest draft) {
    // If type is set but file is missing
    final hasFile =
        (draft.filePath?.isNotEmpty ?? false) || draft.fileBytes != null;

    if (!hasFile) {
      _showFileUploader(draft.type);
    } else {
      // File exists, check recipients
      // For simplicity in resume, go to recipient manager
      _showRecipientManager();
    }
  }

  void _showFlowSelector() {
    setState(() {
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          text: 'What type of signature request do you need?',
        ),
      );
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          content: FlowSelectorWidget(onFlowSelected: _handleFlowSelected),
        ),
      );
    });
    _scrollToBottom();
  }

  void _handleFlowSelected(SignatureRequestType type) {
    String typeName = switch (type) {
      SignatureRequestType.selfSign => 'Sign Myself',
      SignatureRequestType.oneOnOne => 'One-on-One',
      SignatureRequestType.multiParty => 'Multi-Party',
    };

    setState(() {
      _bubbles.add(ChatBubbleModel(isUser: true, text: 'I want to $typeName'));
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          text: 'Great. Please upload the PDF document you want to sign.',
        ),
      );
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          content: FileUploaderWidget(onFileUploaded: _handleFileUploaded),
        ),
      );
    });
    _scrollToBottom();
  }

  void _showFileUploader(SignatureRequestType type) {
    setState(() {
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          text:
              'It looks like you started a request. Please upload the PDF document.',
        ),
      );
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          content: FileUploaderWidget(onFileUploaded: _handleFileUploaded),
        ),
      );
    });
    _scrollToBottom();
  }

  void _handleFileUploaded() {
    setState(() {
      _bubbles.add(ChatBubbleModel(isUser: true, text: 'File uploaded.'));
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          text: 'Got it. Now, let\'s add the recipients.',
        ),
      );
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          content: RecipientManagerWidget(
            onComplete: _handleRecipientsComplete,
          ),
        ),
      );
    });
    _scrollToBottom();
  }

  void _showRecipientManager() {
    setState(() {
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          text: 'Please manage the recipients for this request.',
        ),
      );
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          content: RecipientManagerWidget(
            onComplete: _handleRecipientsComplete,
          ),
        ),
      );
    });
    _scrollToBottom();
  }

  void _handleRecipientsComplete() {
    setState(() {
      _bubbles.add(ChatBubbleModel(isUser: true, text: 'Recipients are set.'));
      _bubbles.add(
        ChatBubbleModel(
          isUser: false,
          text:
              'Perfect. Here is the summary of your request. If everything looks good, you can send it.',
        ),
      );
      _bubbles.add(
        ChatBubbleModel(isUser: false, content: _buildSummaryWidget()),
      );
    });
    _scrollToBottom();
  }

  Widget _buildSummaryWidget() {
    // We wrap it in a Builder or Consumer to ensure it gets fresh data when built,
    // although DraftSummaryWidget is stateless, it relies on passed data.
    // Actually DraftSummaryWidget is stateless and we pass data.
    // BUT we need it to update if the underlying draft changes?
    // The previous implementation watched the draft in the parent or the widget.
    // DraftSummaryWidget is just a display.
    // So we should wrap it in a Consumer to pass the latest data.
    return Consumer(
      builder: (context, ref, _) {
        final draft = ref.watch(activeDraftProvider);
        if (draft == null) return const SizedBox.shrink();

        return DraftSummaryWidget(
          fileName: draft.title,
          recipientCount: draft.recipients.length,
          status: draft.status.name,
          flowType: draft.type.name,
          canSend: true, // Logic check can be added
          signUrl: draft.signUrl,
          onSend: _handleSend,
        );
      },
    );
  }

  Future<void> _handleSend() async {
    await ref.read(activeDraftProvider.notifier).markAsSent();

    final sentDraft = ref.read(activeDraftProvider);
    final signUrl = sentDraft?.signUrl;

    setState(() {
      _bubbles.add(ChatBubbleModel(isUser: true, text: 'Send Request'));

      if (signUrl != null) {
        _bubbles.add(
          ChatBubbleModel(
            isUser: false,
            text: 'Your request has been sent successfully!',
          ),
        );
        _bubbles.add(
          ChatBubbleModel(
            isUser: false,
            content: SigningLinkWidget(
              signUrl: signUrl,
              onOpenLink: () => _launchSignUrl(signUrl),
              onReset: _reset,
            ),
          ),
        );
      } else {
        _bubbles.add(
          ChatBubbleModel(
            isUser: false,
            text:
                'Your request has been sent, but I could not generate a link.',
          ),
        );
      }
    });
    _scrollToBottom();
  }

  Future<void> _launchSignUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch signing URL')),
        );
      }
    }
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

  void _reset() {
    ref.read(activeDraftProvider.notifier).clear();
    setState(() {
      _bubbles.clear();
      _initialized = false;
    });
    _initializeFlow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Request Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Agent',
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Bar
          _DraftStatusBar(),
          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _bubbles.length,
              itemBuilder: (context, index) {
                return _MessageBubble(bubble: _bubbles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Models & Widgets ---

class ChatBubbleModel {
  final bool isUser;
  final String? text;
  final Widget? content;

  ChatBubbleModel({required this.isUser, this.text, this.content});
}

class _MessageBubble extends StatelessWidget {
  final ChatBubbleModel bubble;

  const _MessageBubble({required this.bubble});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = bubble.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (bubble.text != null)
              Container(
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
                child: Text(
                  bubble.text!,
                  style: TextStyle(
                    color: isUser
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            if (bubble.content != null) ...[
              if (bubble.text != null) const SizedBox(height: 8),
              bubble.content!,
            ],
          ],
        ),
      ),
    );
  }
}

class _DraftStatusBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(activeDraftProvider);
    final theme = Theme.of(context);

    return Container(
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
