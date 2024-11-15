import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../widgets/post_item.dart';
import 'create_post_dialog.dart';
import 'post_details_page.dart';
import '../utils/text_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Post> posts = [];
  bool isLoading = true;

  final List<String> categories = [
    'All',
    'Action & Adventure',
    'Drama',
    'Comedy',
    'Science Fiction & Fantasy',
    'Horror & Thriller',
    'Romance',
    'Documentaries',
    'Classics',
    'Independent Films',
    'Directors & Filmmaking',
    'Awards & Festivals'
  ];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// Fetch all posts from the database, including the username
  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      posts = await DatabaseService.getPosts(); // Updated to include usernames
    } catch (e) {
      print('Error loading posts: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  /// Filter posts based on search query and selected category
  List<Post> get filteredPosts {
    return posts.where((post) {
      final title = post.title.toLowerCase();
      final content = post.content.toLowerCase();
      final categoryMatches = selectedCategory == 'All' ||
          post.category?.toLowerCase() == selectedCategory.toLowerCase();
      return categoryMatches &&
          (title.contains(searchQuery) || content.contains(searchQuery));
    }).toList();
  }

  /// Show dialog to create a new post and refresh the list after adding
  Future<void> _showCreatePostDialog() async {
    await showDialog(
      context: context,
      builder: (_) => const CreatePostDialog(),
    );
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'CineTalk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.amberAccent),
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
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.amberAccent),
                filled: true,
                fillColor: const Color(0xFF2E2E3A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          // Category Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                      selected: selectedCategory == category,
                      backgroundColor: const Color(0xFF2E2E3A),
                      selectedColor: Colors.amberAccent,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // List of Posts
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amberAccent),
                  )
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
                                  builder: (context) => PostDetailsPage(post: post),
                                ),
                              );
                            },
                            child: Card(
                              color: const Color(0xFF2E2E3A),
                              elevation: 5,
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
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amberAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Display a short snippet of the rich content
                                    Text(
                                      contentSnippet,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Display category
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(post.category ?? ''),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          post.category ?? '',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Display username and creation date
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                color: Colors.grey, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              'By ${post.username}', // Display the username
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                color: Colors.grey, size: 16),
                                            const SizedBox(width: 4),
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
        backgroundColor: Colors.amberAccent,
        label: const Text(
          'New Post',
          style: TextStyle(color: Colors.black),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'action & adventure':
        return const Color(0xFFEF5350);
      case 'drama':
        return const Color(0xFF5C6BC0);
      case 'comedy':
        return const Color(0xFFFFA726);
      case 'science fiction & fantasy':
        return const Color(0xFF29B6F6);
      case 'horror & thriller':
        return const Color(0xFFD32F2F);
      case 'romance':
        return const Color(0xFFF48FB1);
      case 'documentaries':
        return const Color(0xFF8BC34A);
      case 'classics':
        return const Color(0xFF795548);
      case 'independent films':
        return const Color(0xFF9E9E9E);
      case 'directors & filmmaking':
        return const Color(0xFF7B1FA2);
      case 'awards & festivals':
        return const Color(0xFFFFD54F);
      default:
        return Colors.grey;
    }
  }
}
