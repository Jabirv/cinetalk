class Comment {
  final int? id;
  final int postId;
  final int userId;
  final String content;
  final String createdAt;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['postId'],
      userId: map['userId'],
      content: map['content'],
      createdAt: map['createdAt'],
    );
  }
}
