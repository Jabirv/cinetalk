import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:tuple/tuple.dart';
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
  String? selectedCategory;

  final List<String> categories = [
    'Action & Adventure',
    'Drama',
    'Comedy',
    'Science Fiction & Fantasy',
    'Horror & Thriller',
    'Romance',
    'Documentaries',
    'Classics',
    'Independent Films',
    'Directors & Filmmaking',
    'Awards & Festivals'
  ];

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
    if (userId == null || _titleController.text.isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and category cannot be empty')),
      );
      return;
    }

    final attachments = await _saveFilesToLocalDirectory();
    final richContent = _getRichContentAsJson();
    final category = selectedCategory!; // Safely assign it here

    final newPost = Post(
      userId: userId,
      username: AuthService.currentUser?.username ?? 'Unknown',
      title: _titleController.text,
      content: '',
      richContent: richContent,
      createdAt: DateTime.now().toIso8601String(),
      attachments: attachments,
      category: category, // Use non-nullable value here
    );

    final postId = await DatabaseService.insertPost(newPost);
    if (postId > 0) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2E2E3A),
      title: const Text(
        'Create New Post',
        style: TextStyle(color: Colors.amberAccent),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Input Field
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF3E3E4A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              dropdownColor: const Color(0xFF3E3E4A),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF3E3E4A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quill Toolbar
            QuillToolbar.simple(
              controller: _quillController,
              configurations: QuillSimpleToolbarConfigurations(
                toolbarSectionSpacing: 8.0,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showInlineCode: true,
                showColorButton: true,
                showBackgroundColorButton: true,
                showClearFormat: true,
                showListNumbers: true,
                showListBullets: true,
                showHeaderStyle: true,
                showCodeBlock: true,
                showQuote: true,
                showLink: true,
                showUndo: true,
                showRedo: true,
                toolbarIconAlignment: WrapAlignment.start,
                color: const Color.fromARGB(255, 209, 193, 193),
                sectionDividerColor: Colors.amberAccent,
                sharedConfigurations: const QuillSharedConfigurations(),
              ),
            ),
            const SizedBox(height: 20),

            // Rich Text Editor
            Container(
              height: 400,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E3A), // Dark background
                border: Border.all(color: Colors.amberAccent),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: QuillEditor(
                  controller: _quillController,
                  scrollController: _scrollController,
                  focusNode: _focusNode,
                  configurations: QuillEditorConfigurations(
                    padding: const EdgeInsets.all(16),
                    embedBuilders: [ImageEmbedBuilder()],
                    showCursor: true,
                    autoFocus: true,
                    readOnlyMouseCursor: SystemMouseCursors.text,
                    checkBoxReadOnly: false,
                    enableInteractiveSelection: true,
                    disableClipboard: false,
                    textSelectionThemeData: const TextSelectionThemeData(
                      cursorColor: Colors.amberAccent,
                      selectionColor: Color(0xFF3E3E4A),
                      selectionHandleColor: Colors.amberAccent,
                    ),
                    customStyles: DefaultStyles(
                      paragraph: DefaultTextBlockStyle(
                        const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                        const HorizontalSpacing(8, 0),
                        const VerticalSpacing(8, 8),
                        const VerticalSpacing(4, 4),
                        null,
                      ),
                      bold: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                      italic: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                      underline: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.amberAccent,
                      ),
                      code: DefaultTextBlockStyle(
                        const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                        const HorizontalSpacing(8, 0),
                        const VerticalSpacing(8, 8),
                        const VerticalSpacing(4, 4),
                        const BoxDecoration(
                          color: Color(0xFF1E1E2C),
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                    minHeight: 300,
                    maxHeight: 600,
                    detectWordBoundary: true,
                    floatingCursorDisabled: false,
                    enableAlwaysIndentOnTab: true,
                    onTapOutside: (event, focusNode) {
                      focusNode.unfocus();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Button to Insert Images
            ElevatedButton.icon(
              onPressed: _insertImage,
              icon: const Icon(Icons.image, color: Colors.black),
              label: const Text('Insert Image', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _addPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amberAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Add Post', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
