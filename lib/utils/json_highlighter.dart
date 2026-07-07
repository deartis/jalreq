import 'package:flutter/material.dart';

class JsonSyntaxHighlighter {
  static const Color keyColor = Color(0xFF60A5FA);
  static const Color stringColor = Color(0xFF34D399);
  static const Color numberColor = Color(0xFFFB923C);
  static const Color boolColor = Color(0xFFF472B6);
  static const Color nullColor = Color(0xFFA78BFA);
  static const Color defaultColor = Color(0xFFE0E0E0);

  static TextSpan highlight(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const TextSpan();

    if (!((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']')))) {
      return TextSpan(
        text: text,
        style: const TextStyle(color: defaultColor),
      );
    }

    final List<TextSpan> spans = [];
    final regExp = RegExp(
      r'("(?:\\u[0-9a-fA-F]{4}|\\[^u]|[^\\"])*"\s*:)|'
      r'("(?:\\u[0-9a-fA-F]{4}|\\[^u]|[^\\"])*")|'
      r'(-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)|'
      r'(true|false)|'
      r'(null)|'
      r'([\{\}\[\]\:,])',
      multiLine: true,
    );

    int lastIndex = 0;
    for (final match in regExp.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(color: defaultColor),
        ));
      }

      final matchText = match.group(0)!;
      if (match.group(1) != null) {
        final colonIdx = matchText.lastIndexOf(':');
        final keyPart = matchText.substring(0, colonIdx);
        final colonPart = matchText.substring(colonIdx);
        spans.add(TextSpan(text: keyPart, style: const TextStyle(color: keyColor)));
        spans.add(TextSpan(
            text: colonPart, style: const TextStyle(color: defaultColor)));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
            text: matchText, style: const TextStyle(color: stringColor)));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(
            text: matchText, style: const TextStyle(color: numberColor)));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(
            text: matchText, style: const TextStyle(color: boolColor)));
      } else if (match.group(5) != null) {
        spans.add(TextSpan(
            text: matchText, style: const TextStyle(color: nullColor)));
      } else {
        spans.add(TextSpan(
            text: matchText, style: const TextStyle(color: defaultColor)));
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(color: defaultColor),
      ));
    }

    return TextSpan(children: spans);
  }
}
