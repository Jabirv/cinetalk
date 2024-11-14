import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class ImageBlockEmbed extends CustomBlockEmbed {
  const ImageBlockEmbed(String value) : super(imageType, value);

  static const String imageType = 'image';

  // Create an ImageBlockEmbed from a file path or URL
  static ImageBlockEmbed fromImagePath(String imagePath) =>
      ImageBlockEmbed(jsonEncode({'src': imagePath}));

  // Extract the image path from the JSON data
  String get imageUrl => jsonDecode(data)['src'];
}
