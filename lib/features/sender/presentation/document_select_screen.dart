import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/requests_provider.dart';

class DocumentSelectScreen extends ConsumerStatefulWidget {
  const DocumentSelectScreen({super.key});

  @override
  ConsumerState<DocumentSelectScreen> createState() =>
      _DocumentSelectScreenState();
}

class _DocumentSelectScreenState extends ConsumerState<DocumentSelectScreen> {
  bool _isLoading = false;

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = result.files.first;
        // In a real app we'd save the file to app storage.
        // For this demo, we assume the path/name is sufficient or we use bytes if web (not handled here)
        await ref
            .read(activeDraftProvider.notifier)
            .updateFile(file.path ?? '', file.name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearFile() {
    ref.read(activeDraftProvider.notifier).updateFile('', '');
  }

  void _onNext() {
    final activeDraft = ref.read(activeDraftProvider);
    if (activeDraft?.filePath?.isNotEmpty == true) {
      context.pushNamed('recipients');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeDraft = ref.watch(activeDraftProvider);
    final hasFile = activeDraft?.filePath?.isNotEmpty == true;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select the document you want to send for signature.',
              style:
                  TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: !hasFile
                  ? _buildUploadArea()
                  : _buildFilePreview(activeDraft?.title ?? 'Document', 'PDF'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: hasFile ? _onNext : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Next: Add Recipients'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _pickFile,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [8, 4],
        color: colorScheme.outline,
        strokeWidth: 2,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.uploadCloud,
                    size: 48, color: colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Tap to upload PDF',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Maximum file size: 10MB',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(String fileName, String fileSize) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(LucideIcons.fileText, size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                fileName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                fileSize,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        TextButton.icon(
          onPressed: _clearFile,
          icon: Icon(LucideIcons.trash2, color: colorScheme.error),
          label:
              Text('Remove file', style: TextStyle(color: colorScheme.error)),
        ),
      ],
    );
  }
}
