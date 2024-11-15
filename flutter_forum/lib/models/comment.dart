class Comment {
  final int? id;
  final int postId;
  final int userId;
  final String username; // New field
  final String content;
  final String createdAt;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  // Convert Comment object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': createdAt,
    };
  }

  // Create a Comment object from a map
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['postId'],
      userId: map['userId'],
      username: map['username'],
      content: map['content'],
      createdAt: map['createdAt'],
    );
  }
}
