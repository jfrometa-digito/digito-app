import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A reusable widget that makes its child text selectable.
///
/// Since the entire app is wrapped in [SelectionArea] in app_router.dart,
/// most [Text] widgets are already selectable. Use this widget
/// if you want to explicitly define a selection region or
/// add custom selection behavior.
class AppSelectableArea extends StatelessWidget {
  final Widget child;
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  const AppSelectableArea({
    super.key,
    required this.child,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionArea(onSelectionChanged: onSelectionChanged, child: child);
  }
}

/// A specialized text widget that explicitly ensures selection is enabled.
/// This can be used as a drop-in replacement for [Text] when selection
/// logic needs to be isolated or enhanced.
class AppSelectableText extends StatelessWidget {
  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppSelectableText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : textSpan = null;

  const AppSelectableText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : data = null;

  @override
  Widget build(BuildContext context) {
    // We use SelectionArea to wrap the text.
    // This is more flexible than SelectableText for many layouts.
    return SelectionArea(
      child: data != null
          ? Text(
              data!,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            )
          : Text.rich(
              textSpan!,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            ),
    );
  }
}
