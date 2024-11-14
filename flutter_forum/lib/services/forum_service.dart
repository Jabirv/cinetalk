import '../models/post.dart';

class ForumService {
  static final List<Post> _posts = [];

  static List<Post> getPosts() => _posts;

  static void addPost(Post post) {
    _posts.add(post);
  }
}
