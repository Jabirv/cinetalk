import 'dart:convert';

class Post {
  final int? id;
  final int userId;
  final String username; // Field for the username
  final String title;
  final String content;
  final String? richContent;
  final String createdAt;
  final List<String>? attachments;
  final String category; // Updated field for the category

  Post({
    this.id,
    required this.userId,
    required this.username, // Include username
    required this.title,
    required this.content,
    this.richContent,
    required this.createdAt,
    this.attachments,
    required this.category, // Updated to be non-nullable
  });

  // Convert Post object to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username, // Include username
      'title': title,
      'content': content,
      'richContent': richContent,
      'createdAt': createdAt,
      'attachments': attachments != null ? jsonEncode(attachments) : null,
      'category': category, // Include category
    };
  }

  // Create a Post object from a map fetched from the database
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      username: map['username'] ?? 'Unknown', // Include username
      title: map['title'],
      content: map['content'],
      richContent: map['richContent'],
      createdAt: map['createdAt'],
      attachments: map['attachments'] != null
          ? List<String>.from(jsonDecode(map['attachments']))
          : [],
      category: map['category'] ?? 'Uncategorized', // Provide default value for category
    );
  }

  // Convert Post object to JSON for easier storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'title': title,
      'content': content,
      'richContent': richContent,
      'createdAt': createdAt,
      'attachments': attachments,
      'category': category, // Include category
    };
  }

  // Create a Post object from JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      username: json['username'] ?? 'Unknown',
      title: json['title'],
      content: json['content'],
      richContent: json['richContent'],
      createdAt: json['createdAt'],
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      category: json['category'] ?? 'Uncategorized', // Provide default value for category
    );
  }
}
