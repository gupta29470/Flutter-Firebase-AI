import 'package:flutter/material.dart';

extension StringExtension on String {
  TextSpan parseBoldText() {
    final boldRegex = RegExp(r'\*\*(.+?)\*\*');
    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in boldRegex.allMatches(this)) {
      // Add normal text before match
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: substring(currentIndex, match.start)));
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining normal text
    if (currentIndex < length) {
      spans.add(TextSpan(text: substring(currentIndex)));
    }

    return TextSpan(children: spans);
  }
}
