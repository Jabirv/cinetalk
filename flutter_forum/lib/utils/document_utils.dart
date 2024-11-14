import 'dart:convert';
import 'package:super_editor/super_editor.dart';

/// Converts a [MutableDocument] to a JSON string.
String documentToJson(MutableDocument document) {
  List<Map<String, dynamic>> nodes = [];

  for (final node in document.nodes) {
    if (node is ParagraphNode) {
      nodes.add({
        'type': 'paragraph',
        'text': node.text.text,
      });
    } else if (node is ImageNode) {
      nodes.add({
        'type': 'image',
        'url': node.imageUrl,
      });
    }
  }

  return jsonEncode({'nodes': nodes});
}

/// Converts a JSON string to a [MutableDocument].
MutableDocument jsonToDocument(String jsonString) {
  final Map<String, dynamic> jsonData = jsonDecode(jsonString);
  List<DocumentNode> nodes = [];

  for (final nodeData in jsonData['nodes']) {
    if (nodeData['type'] == 'paragraph') {
      nodes.add(ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(nodeData['text']),
      ));
    } else if (nodeData['type'] == 'image') {
      nodes.add(ImageNode(
        id: DocumentEditor.createNodeId(),
        imageUrl: nodeData['url'],
      ));
    }
  }

  return MutableDocument(nodes: nodes);
}
