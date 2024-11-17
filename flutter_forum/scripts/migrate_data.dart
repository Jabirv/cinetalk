import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_forum/firebase_options.dart';
import 'package:flutter_forum/models/user.dart';
import 'package:flutter_forum/models/post.dart';
import 'package:flutter_forum/models/comment.dart';
import 'package:flutter_forum/services/database_service.dart';

Future<void> migrateDataToFirestore() async {
  // Get the local SQLite database
  final db = await DatabaseService.getDatabase();

  // Migrate Users
  final users = await db.query('users');
  for (final userMap in users) {
    final user = User.fromMap(userMap);
    await FirebaseFirestore.instance.collection('users').doc(user.id.toString()).set(user.toJson());
  }

  // Migrate Posts
  final posts = await db.query('posts');
  for (final postMap in posts) {
    final post = Post.fromMap(postMap);
    await FirebaseFirestore.instance.collection('posts').doc(post.id.toString()).set(post.toJson());
  }

  // Migrate Comments
  final comments = await db.query('comments');
  for (final commentMap in comments) {
    final comment = Comment.fromMap(commentMap);
    await FirebaseFirestore.instance.collection('comments').doc(comment.id.toString()).set(comment.toJson());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that binding is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await migrateDataToFirestore();
  print("Data migration complete.");
}
