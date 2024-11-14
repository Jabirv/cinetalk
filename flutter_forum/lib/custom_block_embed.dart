import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

/// Custom Block Embed for handling embedded images
class ImageBlockEmbed extends CustomBlockEmbed {
  const ImageBlockEmbed(String value) : super(imageType, value);

  static const String imageType = 'image';

  /// Create an ImageBlockEmbed from a URL
  static ImageBlockEmbed fromUrl(String imageUrl) =>
      ImageBlockEmbed(jsonEncode({'url': imageUrl}));

  /// Extract the image URL from the embedded data
  String get imageUrl => jsonDecode(data)['url'];
}
