import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../domain/models/placed_field.dart';
import '../providers/requests_provider.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _scrollController = ScrollController();

  void _onFieldDropped(FieldType type, Offset position, int pageNumber) {
    // We need to generate a unique ID.
    // In a real app we might verify if position is within bounds relative to PDF page size.
    final newField = PlacedField(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      position: position,
      pageNumber: pageNumber,
    );

    final currentFields = ref.read(activeDraftProvider)?.fields ?? [];
    final updatedFields = [...currentFields, newField];

    ref.read(activeDraftProvider.notifier).updateFields(updatedFields);
  }

  void _updateFieldPosition(String id, Offset newPosition) {
    final currentFields = ref.read(activeDraftProvider)?.fields ?? [];
    final updatedFields = currentFields.map((f) {
      if (f.id == id) {
        return f.copyWith(position: newPosition);
      }
      return f;
    }).toList();

    ref.read(activeDraftProvider.notifier).updateFields(updatedFields);
  }

  void _deleteField(String id) {
    final currentFields = ref.read(activeDraftProvider)?.fields ?? [];
    final updatedFields = currentFields.where((f) => f.id != id).toList();
    ref.read(activeDraftProvider.notifier).updateFields(updatedFields);
  }

  @override
  Widget build(BuildContext context) {
    final activeDraft = ref.watch(activeDraftProvider);
    final fields = activeDraft?.fields ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    // We assume 3 pages for the demo if not specified
    // In reality this would come from the PDF controller
    final int pageCount = 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prepare Document'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                context.pushNamed('review');
              },
              child: const Text('Review & Send'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          _buildToolbar(),
          const Divider(height: 1),
          // Document View
          Expanded(
            child: Container(
              color: colorScheme.surfaceVariant
                  .withOpacity(0.3), // Light gray background
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: pageCount,
                separatorBuilder: (ctx, i) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  // Filter fields for this page
                  final pageFields =
                      fields.where((f) => f.pageNumber == index).toList();
                  return _buildDocumentPage(index, pageFields);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _DraggableTool(
            type: FieldType.signature,
            icon: LucideIcons.penTool,
            label: 'Signature',
            color: Colors.indigo,
          ),
          _DraggableTool(
            type: FieldType.initials,
            icon: LucideIcons.type,
            label: 'Initials',
            color: Colors.orange,
          ),
          _DraggableTool(
            type: FieldType.date,
            icon: LucideIcons.calendar,
            label: 'Date',
            color: Colors.green,
          ),
          _DraggableTool(
            type: FieldType.text,
            icon: LucideIcons.textCursor,
            label: 'Text',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPage(int pageIndex, List<PlacedField> fields) {
    final colorScheme = Theme.of(context).colorScheme;
    // Aspect ratio of A4 usually, assuming width matches viewport minus padding
    // For drag targets to work, we need a known size or LayoutBuilder.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 1.414; // A4 Aspect Ratio

        return DragTarget<FieldType>(
          onAcceptWithDetails: (details) {
            // Convert global position to local position
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.offset);

            // Should probably center the field on the drop location
            // But for now, just use the raw local position
            _onFieldDropped(details.data, localPosition, pageIndex);
          },
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Placeholder for PDF content
                  Center(
                    child: Text(
                      'Page ${pageIndex + 1}',
                      style: TextStyle(
                        fontSize: 48,
                        color: colorScheme.onSurface.withOpacity(0.1),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // Render placed fields
                  ...fields.map((field) => Positioned(
                        left: field.position.dx,
                        top: field.position.dy,
                        child: GestureDetector(
                          onLongPress: () => _deleteField(field.id),
                          child: Draggable<String>(
                            data: field.id, // Dragging existing field
                            feedback: Material(
                              color: Colors.transparent,
                              child: _PlacedFieldWidget(field: field),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.5,
                              child: _PlacedFieldWidget(field: field),
                            ),
                            onDragEnd: (details) {
                              final RenderBox renderBox =
                                  context.findRenderObject() as RenderBox;
                              final localPosition =
                                  renderBox.globalToLocal(details.offset);
                              _updateFieldPosition(field.id, localPosition);
                            },
                            child: _PlacedFieldWidget(field: field),
                          ),
                        ),
                      )),
                  // Highlight on drag hover
                  if (candidateData.isNotEmpty)
                    Container(
                      color: colorScheme.primary.withOpacity(0.1),
                      child: Center(
                        child: Text(
                          'Drop here',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DraggableTool extends StatelessWidget {
  final FieldType type;
  final IconData icon;
  final String label;
  final Color color;

  const _DraggableTool({
    required this.type,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );

    return Draggable<FieldType>(
      data: type,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.8, child: child),
      ),
      child: child,
    );
  }
}

class _PlacedFieldWidget extends StatelessWidget {
  final PlacedField field;

  const _PlacedFieldWidget({required this.field});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (field.type) {
      case FieldType.signature:
        color = Colors.indigo;
        icon = LucideIcons.penTool;
        label = 'Signature';
        break;
      case FieldType.initials:
        color = Colors.orange;
        icon = LucideIcons.type;
        label = 'Initials';
        break;
      case FieldType.date:
        color = Colors.green;
        icon = LucideIcons.calendar;
        label = 'Date';
        break;
      case FieldType.text:
        color = Colors.blue;
        icon = LucideIcons.textCursor;
        label = 'Text';
        break;
    }

    return Container(
      width: 150,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
