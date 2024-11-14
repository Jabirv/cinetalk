import 'package:flutter/material.dart';
import '../models/post.dart';
import '../screens/post_details_page.dart';

class PostItem extends StatelessWidget {
  final Post post;

  const PostItem({super.key, required this.post});

  void _showPostDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PostDetailsPage(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(post.title),
      subtitle: Text(post.content),
      onTap: () => _showPostDetails(context),
    );
  }
}
