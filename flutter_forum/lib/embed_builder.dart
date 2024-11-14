import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'custom_block_embed.dart';

class ImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed embed,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    final imageUrl = embed.value.data;

    if (imageUrl.startsWith('file://')) {
      return Image.file(
        File(Uri.parse(imageUrl).path),
        fit: BoxFit.cover,
      );
    } else if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
      );
    } else {
      return const Text('Unsupported image format');
    }
  }
}
