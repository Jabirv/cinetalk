import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../embed_builder.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class PostDetailsPage extends StatefulWidget {
  final Post post;

  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<Comment> comments = [];
  bool isLoading = true;

  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadRichContent();
  }

  /// Load the rich content into the Quill editor
  void _loadRichContent() {
    if (widget.post.richContent != null && widget.post.richContent!.isNotEmpty) {
      final documentJson = jsonDecode(widget.post.richContent!);
      final doc = quill.Document.fromJson(documentJson);
      _quillController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    } else {
      _quillController = quill.QuillController.basic();
    }
  }

  /// Load comments along with usernames
  Future<void> _loadComments() async {
    setState(() => isLoading = true);
    try {
      comments = await DatabaseService.getCommentsWithUsernames(widget.post.id!);
    } catch (e) {
      print('Error loading comments: $e');
    }
    setState(() => isLoading = false);
  }

  /// Add a new comment with username
  Future<void> _addComment() async {
    final userId = AuthService.currentUser?.id;
    final commentText = _commentController.text.trim();

    if (commentText.isEmpty || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    final currentUser = await DatabaseService.getUserById(userId);
    final username = currentUser?.username ?? 'Unknown';

    final newComment = Comment(
      postId: widget.post.id!,
      userId: userId,
      username: username,
      content: commentText,
      createdAt: DateTime.now().toString(),
    );

    await DatabaseService.insertComment(newComment);
    _commentController.clear();
    FocusScope.of(context).unfocus();
    await _loadComments();
  }

  /// Open the file from the attachment list
  Future<void> _openFile(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: $filePath')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          widget.post.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display rich text content using QuillEditor with updated configurations
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E3A),
                border: Border.all(color: Colors.amberAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: quill.QuillEditor(
                controller: _quillController,
                scrollController: _scrollController,
                focusNode: _focusNode,
                configurations: quill.QuillEditorConfigurations(
                  embedBuilders: [ImageEmbedBuilder()],
                  padding: const EdgeInsets.all(16),
                  showCursor: false,
                  autoFocus: false,
                  readOnlyMouseCursor: SystemMouseCursors.text,
                  checkBoxReadOnly: true,
                  enableInteractiveSelection: true,
                  disableClipboard: true,
                  textSelectionThemeData: const TextSelectionThemeData(
                    cursorColor: Colors.amberAccent,
                    selectionColor: Color(0xFF3E3E4A),
                    selectionHandleColor: Colors.amberAccent,
                  ),
                  customStyles: quill.DefaultStyles(
                    paragraph: quill.DefaultTextBlockStyle(
                      const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
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
            const SizedBox(height: 30),

            // Display attachments
            if (widget.post.attachments != null && widget.post.attachments!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.post.attachments!.map((filePath) {
                  return ListTile(
                    leading: const Icon(Icons.attach_file, color: Colors.blue),
                    title: Text(filePath.split('/').last, style: const TextStyle(color: Colors.white70)),
                    onTap: () => _openFile(filePath),
                  );
                }).toList(),
              ),
            const Divider(height: 32, color: Colors.grey),

            // Comments section
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
                : comments.isEmpty
                    ? const Center(child: Text('No comments yet.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Card(
                            color: const Color(0xFF2E2E3A),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(comment.content, style: const TextStyle(color: Colors.white70)),
                              subtitle: Text(
                                '${comment.username} - ${comment.createdAt}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 20),

            // Input for adding a new comment
            AuthService.currentUser != null
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Add a comment',
                            labelStyle: const TextStyle(color: Colors.grey),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.amberAccent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.amberAccent),
                            ),
                          ),
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.amberAccent),
                        onPressed: _addComment,
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      'If you want to comment, you should sign up!',
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
