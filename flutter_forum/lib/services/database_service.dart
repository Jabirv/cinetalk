import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register a new user
  static Future<void> registerUser(User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  /// Login user
  static Future<User?> loginUser(String username, String password) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docData = querySnapshot.docs.first.data();
      return User.fromJson({...docData, 'id': querySnapshot.docs.first.id});
    }
    return null;
  }

  /// Insert a new post into the database
  static Future<void> insertPost(Post post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toJson());
  }

  /// Update a post
  static Future<void> updatePost(Post post) async {
    await _firestore.collection('posts').doc(post.id).update(post.toJson());
  }

  /// Delete a post
  static Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  /// Fetch all posts with usernames
  static Future<List<Post>> getPosts() async {
    final querySnapshot = await _firestore.collection('posts').orderBy('createdAt', descending: true).get();
    return querySnapshot.docs.map((doc) => Post.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  /// Fetch a limited number of posts
  static Future<List<Post>> getLimitedPosts({int limit = 5}) async {
    final querySnapshot = await _firestore.collection('posts').orderBy('createdAt', descending: true).limit(limit).get();
    return querySnapshot.docs.map((doc) => Post.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  static Future<Post?> getPostById(String postId) async {
    final docSnapshot = await _firestore.collection('posts').doc(postId).get();
    if (docSnapshot.exists) {
      return Post.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
    }
    return null;
  }

  /// Update post votes
  static Future<void> updatePostVotes({required String postId, required int upvotes, required int downvotes}) async {
    await _firestore.collection('posts').doc(postId).update({
      'upvotes': upvotes,
      'downvotes': downvotes,
    });
  }

  /// Get post votes
  static Future<Map<String, int>> getPostVotes(String postId) async {
    final docSnapshot = await _firestore.collection('posts').doc(postId).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      return {
        'upvotes': data?['upvotes'] ?? 0,
        'downvotes': data?['downvotes'] ?? 0,
      };
    }
    return {'upvotes': 0, 'downvotes': 0};
  }

  /// Insert a new comment into the database
  static Future<void> insertComment(Comment comment) async {
    await _firestore
        .collection('comments')
        .doc(Uuid().v4())
        .set(comment.toJson());
  }

  /// Update a comment
  static Future<void> updateComment(Comment comment) async {
    await _firestore.collection('comments').doc(comment.id).update(comment.toJson());
  }

  /// Delete a comment
  static Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }

  /// Fetch a user by ID
  static Future<User?> getUserById(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    if (docSnapshot.exists) {
      return User.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
    }
    return null;
  }

  /// Fetch all comments related to a specific post with usernames
  static Future<List<Comment>> getCommentsWithUsernames(String postId) async {
    final querySnapshot = await _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .get();

    return querySnapshot.docs.map((doc) => Comment.fromJson({...doc.data(), 'id': doc.id})).toList();
  }

  /// Check if user has voted on a post
  static Future<bool> hasUserVoted(String postId, String userId) async {
    final voteDoc = await _firestore.collection('posts').doc(postId).collection('votes').doc(userId).get();
    return voteDoc.exists;
  }

  /// Record user vote
  static Future<void> recordUserVote(String postId, String userId, bool isUpvote) async {
    await _firestore.collection('posts').doc(postId).collection('votes').doc(userId).set({'isUpvote': isUpvote});
  }

  /// Upvote post with user check
  static Future<void> upvotePost(String postId, String userId) async {
    bool hasVoted = await hasUserVoted(postId, userId);
    if (!hasVoted) {
      final postVotes = await getPostVotes(postId);
      await updatePostVotes(postId: postId, upvotes: postVotes['upvotes']! + 1, downvotes: postVotes['downvotes']!);
      await recordUserVote(postId, userId, true);
    }
  }

  /// Downvote post with user check
  static Future<void> downvotePost(String postId, String userId) async {
    bool hasVoted = await hasUserVoted(postId, userId);
    if (!hasVoted) {
      final postVotes = await getPostVotes(postId);
      await updatePostVotes(postId: postId, upvotes: postVotes['upvotes']!, downvotes: postVotes['downvotes']! + 1);
      await recordUserVote(postId, userId, false);
    }
  }

  /// Update a post or comment with user check
  static Future<void> updatePostOrComment(String id, Map<String, dynamic> data, String collection) async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    final docSnapshot = await _firestore.collection(collection).doc(id).get();
    if (docSnapshot.exists && docSnapshot.data()?['userId'] == userId) {
      await _firestore.collection(collection).doc(id).update(data);
    } else {
      throw Exception('Unauthorized or document does not exist');
    }
  }

  /// Delete a post or comment with user check
  static Future<void> deletePostOrComment(String id, String collection) async {
    final userId = AuthService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in');
    }
    final docSnapshot = await _firestore.collection(collection).doc(id).get();
    if (docSnapshot.exists && docSnapshot.data()?['userId'] == userId) {
      await _firestore.collection(collection).doc(id).delete();
    } else {
      throw Exception('Unauthorized or document does not exist');
    }
  }
}
