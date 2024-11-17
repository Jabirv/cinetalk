// EditButtonsWidget.dart
import 'package:flutter/material.dart';
import 'package:flutter_forum/services/database_service.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'dart:convert';
import '../embed_builder.dart';

class EditButtonsWidget extends StatefulWidget {
  final Post post;
  final Function onUpdate;
  final Function onDelete;

  const EditButtonsWidget({
    Key? key,
    required this.post,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<EditButtonsWidget> createState() => _EditButtonsWidgetState();
}

class _EditButtonsWidgetState extends State<EditButtonsWidget> {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _quillController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<String> categories = [
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
  String? selectedCategory;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    selectedCategory = widget.post.category;
    _quillController = quill.QuillController(
      document: widget.post.richContent != null && widget.post.richContent!.isNotEmpty
          ? quill.Document.fromJson(jsonDecode(widget.post.richContent!))
          : quill.Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _editPost() async {
    final userId = AuthService.currentUser?.id;
    if (userId == widget.post.userId) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFF2E2E3A),
                title: const Text(
                  'Edit Post',
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
                          fillColor: const Color(0xFF3E2E3A),
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
                        dropdownColor: const Color(0xFF3E2E3A),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFF3E2E3A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Rich Text Editor
                      Container(
                        height: 400,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E3A),
                          border: Border.all(color: Colors.amberAccent),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: quill.QuillEditor(
                            controller: _quillController,
                            scrollController: _scrollController,
                            focusNode: _focusNode,
                            configurations: quill.QuillEditorConfigurations(
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
                                selectionColor: Color(0xFF3E2E3A),
                                selectionHandleColor: Colors.amberAccent,
                              ),
                              customStyles: quill.DefaultStyles(
                                paragraph: quill.DefaultTextBlockStyle(
                                  const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                                  const quill.HorizontalSpacing(8, 0),
                                  const quill.VerticalSpacing(8, 8),
                                  const quill.VerticalSpacing(4, 4),
                                  null,
                                ),
                                bold: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                italic: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                underline: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  isSaving
                      ? const CircularProgressIndicator(color: Colors.amberAccent)
                      : ElevatedButton(
                          onPressed: () async {
                            final updatedTitle = _titleController.text.trim();
                            if (updatedTitle.isEmpty || selectedCategory == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Title and category cannot be empty')),
                              );
                              return;
                            }
                            final updatedRichContent =
                                jsonEncode(_quillController.document.toDelta().toJson());

                            setState(() {
                              isSaving = true; // Set loading indicator to true when saving starts
                            });

                            await DatabaseService.updatePost(
                              widget.post.copyWith(
                                title: updatedTitle,
                                category: selectedCategory!,
                                richContent: updatedRichContent,
                              ),
                            );

                            setState(() {
                              isSaving = false; // Reset loading indicator
                            });

                            Navigator.pop(context);
                            widget.onUpdate(); // Refresh the post details page after editing
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Save', style: TextStyle(color: Colors.black)),
                        ),
                ],
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only edit your own post.')),
      );
    }
  }

  Future<void> _deletePost() async {
    final userId = AuthService.currentUser?.id;
    if (userId == widget.post.userId) {
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF2E2E3A),
            title: const Text('Delete Post', style: TextStyle(color: Colors.redAccent)),
            content: const Text('Are you sure you want to delete this post?',
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Delete', style: TextStyle(color: Colors.black)),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await DatabaseService.deletePost(widget.post.id!);
        widget.onDelete(); // Refresh the UI after deleting the post
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own post.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.amberAccent),
          onPressed: _editPost,
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: _deletePost,
        ),
      ],
    );
  }
}
