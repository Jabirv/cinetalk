class Post {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final String? richContent; // For storing rich text content
  final String createdAt;
  final List<String>? attachments; // List of file paths

  Post({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.richContent,
    required this.createdAt,
    this.attachments,
  });

  // Convert Post object to a map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'richContent': richContent,
      'createdAt': createdAt,
      'attachments': attachments != null ? attachments!.join(',') : '',
    };
  }

  // Create a Post object from a map fetched from the database
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      richContent: map['richContent'],
      createdAt: map['createdAt'],
      attachments: map['attachments'] != null
          ? (map['attachments'] as String).split(',')
          : [],
    );
  }
}
