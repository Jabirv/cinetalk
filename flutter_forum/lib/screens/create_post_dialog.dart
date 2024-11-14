import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/post.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../embed_builder.dart';
import '../custom_block_embed.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _quillController = QuillController.basic();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
  }

  /// Method to insert an image into the Quill editor
  Future<void> _insertImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final imagePath = file.path;

      if (imagePath != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagesDir = Directory(path.join(directory.path, 'images'));
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }

        final fileName = path.basename(imagePath);
        final newFilePath = path.join(imagesDir.path, fileName);
        await File(imagePath).copy(newFilePath);

        final embed = BlockEmbed.custom(
          ImageBlockEmbed.fromUrl(Uri.file(newFilePath).toString()),
        );
        final index = _quillController.selection.baseOffset;
        _quillController.document.insert(index, embed);
      }
    }
  }

  /// Save the rich text content as JSON
  String _getRichContentAsJson() {
    return jsonEncode(_quillController.document.toDelta().toJson());
  }

  /// Copy selected files to a permanent directory and return their paths
  Future<List<String>> _saveFilesToLocalDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    List<String> filePaths = [];

    for (var file in _selectedFiles) {
      final originalFilePath = file.path;
      if (originalFilePath != null) {
        final fileName = path.basename(originalFilePath);
        final newFilePath = path.join(directory.path, fileName);
        await File(originalFilePath).copy(newFilePath);
        filePaths.add(newFilePath);
      }
    }
    return filePaths;
  }

  /// Method to select files for attachments
  Future<void> _selectFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  /// Method to add a new post to the database
  Future<void> _addPost() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final attachments = await _saveFilesToLocalDirectory();
    final richContent = _getRichContentAsJson();

    final newPost = Post(
      userId: userId,
      title: _titleController.text,
      content: '',
      richContent: richContent,
      createdAt: DateTime.now().toIso8601String(),
      attachments: attachments,
    );

    final postId = await DatabaseService.insertPost(newPost);
    if (postId > 0) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Input Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),

            // Rich Text Editor Toolbar
            QuillToolbar.simple(
              controller: _quillController,
            ),

            const SizedBox(height: 10),

            // Rich Text Editor with improved handling
            Container(
              height: 300,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QuillEditor(
                controller: _quillController,
                scrollController: _scrollController,
                focusNode: _focusNode,
                configurations: QuillEditorConfigurations(
                  embedBuilders: [
                    ImageEmbedBuilder(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Button to Insert Images
            ElevatedButton.icon(
              onPressed: _insertImage,
              icon: const Icon(Icons.image),
              label: const Text('Insert Image'),
            ),

            const SizedBox(height: 10),

            // Button to Attach Files
            ElevatedButton.icon(
              onPressed: _selectFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach Files'),
            ),

            const SizedBox(height: 10),

            // Display Attached Files
            if (_selectedFiles.isNotEmpty)
              Column(
                children: _selectedFiles.map((file) {
                  return ListTile(
                    title: Text(file.name),
                    subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addPost,
          child: const Text('Add Post'),
        ),
      ],
    );
  }
}
