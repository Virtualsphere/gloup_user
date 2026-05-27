import 'package:flutter/material.dart';

/// Single- or multi-line text that ellipsizes overflow and shows full text on long-press.
class ResponsiveEllipsisText extends StatelessWidget {
  const ResponsiveEllipsisText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.textAlign,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign? textAlign;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return Text(
        '—',
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      );
    }

    final child = Text(
      trimmed,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );

    return Tooltip(
      message: trimmed,
      waitDuration: const Duration(milliseconds: 400),
      child: Semantics(
        label: semanticsLabel ?? trimmed,
        child: child,
      ),
    );
  }
}
