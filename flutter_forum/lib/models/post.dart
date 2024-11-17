class Post {
  final String? id;
  final String userId;
  final String username;
  final String title;
  final String content;
  final String? richContent;
  final String createdAt;
  final List<String>? attachments;
  final String category;
  int upvotes;
  int downvotes;

  Post({
    this.id,
    required this.userId,
    required this.username,
    required this.title,
    required this.content,
    this.richContent,
    required this.createdAt,
    this.attachments,
    required this.category,
    this.upvotes = 0,
    this.downvotes = 0,
  });

   // Define the copyWith method
  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? richContent,
    String? createdAt,
    List<String>? attachments,
    String? category,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username,
      title: title ?? this.title,
      content: content ?? this.content,
      richContent: richContent ?? this.richContent,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
      category: category ?? this.category,
    );
  }

  // Convert Post object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'title': title,
      'content': content,
      'richContent': richContent,
      'createdAt': createdAt,
      'attachments': attachments,
      'category': category,
      'upvotes': upvotes,
      'downvotes': downvotes,
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
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : [],
      category: json['category'] ?? 'Uncategorized',
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
    );
  }
}
