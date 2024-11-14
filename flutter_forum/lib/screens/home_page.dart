import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../widgets/post_item.dart';
import 'create_post_dialog.dart';
import 'post_details_page.dart';
import '../utils/text_utils.dart'; // Import the text utility

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// Fetch all posts from the database
  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      posts = await DatabaseService.getPosts();
    } catch (e) {
      print('Error loading posts: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  /// Filter posts based on search query
  List<Post> get filteredPosts {
    return posts.where((post) {
      final title = post.title.toLowerCase();
      final content = post.content.toLowerCase();
      return title.contains(searchQuery) || content.contains(searchQuery);
    }).toList();
  }

  /// Show dialog to create a new post and refresh the list after adding
  Future<void> _showCreatePostDialog() async {
    await showDialog(
      context: context,
      builder: (_) => const CreatePostDialog(),
    );
    await _loadPosts(); // Refresh posts after creating a new post
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Cine Talk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              AuthService.currentUser = null;
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),

          // List of Posts
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPosts.isEmpty
                    ? const Center(
                        child: Text(
                          'No posts found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];

                          // Extract plain text snippet from rich content
                          final contentSnippet = extractPlainText(post.richContent);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostDetailsPage(post: post),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display post title
                                    Text(
                                      post.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Display a short snippet of the rich content
                                    Text(
                                      contentSnippet,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Display user ID and creation date
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'By User ${post.userId}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          post.createdAt,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      // Floating Action Button to Create a New Post
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: Colors.teal,
        label: const Text('New Post'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
