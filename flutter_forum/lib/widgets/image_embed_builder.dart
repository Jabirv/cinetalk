import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CustomImageEmbedBuilder extends EmbedBuilder {
  @override
  Widget build(
    BuildContext context,
    QuillController controller,
    Embed embed,
    bool readOnly,
    bool isInline,
    TextStyle textStyle,
  ) {
    if (embed.value.type == 'image') {
      final String imageUrl = embed.value.data;

      // Handle network and local file images
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.contain,
        );
      } else {
        return Image.file(
          File(Uri.parse(imageUrl).path),
          fit: BoxFit.contain,
        );
      }
    }
    return const SizedBox.shrink();
  }

  @override
  String get key => 'image';
}
