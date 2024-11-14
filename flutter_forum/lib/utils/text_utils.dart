import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

/// Helper function to extract plain text from rich content (Delta format)
String extractPlainText(String? richContent) {
  if (richContent == null || richContent.isEmpty) return '';

  try {
    final List<dynamic> jsonData = jsonDecode(richContent);
    final delta = Delta.fromJson(jsonData);
    final doc = Document.fromDelta(delta);
    return doc.toPlainText().trim();
  } catch (e) {
    print('Error extracting text: $e');
    return '';
  }
}
