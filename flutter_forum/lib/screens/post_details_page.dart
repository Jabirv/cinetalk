import 'package:flutter/material.dart';
import 'package:flutter_forum/services/database_service.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../embed_builder.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/auth_service.dart';
import '../widgets/EditButtonWidget.dart';

class PostDetailsPage extends StatefulWidget {
   Post post;

  PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<Comment> comments = [];
  bool isLoading = true;
  int upvotes = 0;
  int downvotes = 0;

  late quill.QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _loadRichContent();
    _loadVotes();
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

/// Reload the post details after editing
Future<void> _loadPostDetails() async {
  try {
    final updatedPost = await DatabaseService.getPostById(widget.post.id!);
    if (updatedPost != null) {
      setState(() {
        widget.post = widget.post.copyWith(
          title: updatedPost.title,
          category: updatedPost.category,
          richContent: updatedPost.richContent,
        );
        _loadRichContent();
      });
    }
  } catch (e) {
    print('Error loading updated post details: $e');
  }
}


/// Handle UI changes after deleting the post
void _handlePostDeletion() {
  Navigator.pop(context);
}

  /// Load comments along with usernames from Firestore
  Future<void> _loadComments() async {
    setState(() => isLoading = true);
    try {
      comments = await DatabaseService.getCommentsWithUsernames(widget.post.id!);
    } catch (e) {
      print('Error loading comments: $e');
    }
    setState(() => isLoading = false);
  }

  /// Load votes for the post
  Future<void> _loadVotes() async {
    try {
      final votes = await DatabaseService.getPostVotes(widget.post.id!);
      setState(() {
        upvotes = votes['upvotes'] ?? 0;
        downvotes = votes['downvotes'] ?? 0;
      });
    } catch (e) {
      print('Error loading votes: $e');
    }
  }

  /// Add a new comment with username to Firestore
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
      createdAt: DateTime.now().toIso8601String(),
      id: '',
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

  /// Upvote the post if the user is logged in and hasn't voted before
  Future<void> _upvotePost() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to upvote.')),
      );
      return;
    }

    bool hasVoted = await DatabaseService.hasUserVoted(widget.post.id!, userId);
    if (!hasVoted) {
      await DatabaseService.upvotePost(widget.post.id!, userId);
      setState(() {
        upvotes += 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already voted on this post.')),
      );
    }
  }

  /// Downvote the post if the user is logged in and hasn't voted before
  Future<void> _downvotePost() async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to downvote.')),
      );
      return;
    }

    bool hasVoted = await DatabaseService.hasUserVoted(widget.post.id!, userId);
    if (!hasVoted) {
      await DatabaseService.downvotePost(widget.post.id!, userId);
      setState(() {
        downvotes += 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already voted on this post.')),
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
        actions: [
          // Replacing individual edit and delete buttons with EditButtonsWidget
          EditButtonsWidget(
            post: widget.post,
            onUpdate: _loadPostDetails, // Define this function to reload the post details after editing
              onDelete: _handlePostDeletion,
          ),
        ],
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
            const SizedBox(height: 20),

            // Upvote and Downvote buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.amberAccent),
                      onPressed: _upvotePost,
                    ),
                    Text('$upvotes', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, color: Colors.amberAccent),
                      onPressed: _downvotePost,
                    ),
                    Text('$downvotes', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
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
