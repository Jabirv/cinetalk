import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:url_launcher/url_launcher.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'dart:convert';

class PostDetailsPage extends StatefulWidget {
  final Post post;

  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> comments = [];
  bool isLoading = true;
  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadRichContent();
  }

  void _loadRichContent() {
    if (widget.post.richContent != null && widget.post.richContent!.isNotEmpty) {
      final documentJson = jsonDecode(widget.post.richContent!);
      final doc = quill.Document.fromJson(documentJson);
      _quillController = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } else {
      _quillController = quill.QuillController.basic();
    }
  }

  Future<void> _loadComments() async {
    setState(() => isLoading = true);
    try {
      comments = await DatabaseService.getComments(widget.post.id!);
    } catch (e) {
      print('Error loading comments: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _addComment() async {
    final userId = AuthService.currentUser?.id;
    final commentText = _commentController.text.trim();

    if (commentText.isEmpty || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    final newComment = Comment(
      postId: widget.post.id!,
      userId: userId,
      content: commentText,
      createdAt: DateTime.now().toIso8601String(),
    );

    await DatabaseService.insertComment(newComment);
    _commentController.clear();
    FocusScope.of(context).unfocus();
    await _loadComments();
  }

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
      appBar: AppBar(
        title: Text(widget.post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display rich text content
            quill.QuillEditor.basic(
              controller: _quillController,
            ),
            const SizedBox(height: 16),

            // Display attachments
            if (widget.post.attachments != null && widget.post.attachments!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.post.attachments!.map((filePath) {
                  return ListTile(
                    leading: const Icon(Icons.attach_file, color: Colors.blue),
                    title: Text(filePath.split('/').last),
                    onTap: () => _openFile(filePath),
                  );
                }).toList(),
              ),

            const Divider(height: 32),

            // Comments section
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? const Center(child: Text('No comments yet.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(comments[index].content),
                              subtitle: Text('User ${comments[index].userId} - ${comments[index].createdAt}'),
                            ),
                          );
                        },
                      ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Add a comment',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}