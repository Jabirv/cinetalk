class Comment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String content;
  final String createdAt;

  Comment({
    required this.id,
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

  // Convert Comment object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Include the id field
      'postId': postId,
      'userId': userId,
      'username': username,
      'content': content,
      'createdAt': createdAt,
    };
  }


  // Create a Comment object from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'], // Added to keep id consistent
      postId: json['postId'],
      userId: json['userId'],
      username: json['username'],
      content: json['content'],
      createdAt: json['createdAt'],
    );
  }
}
