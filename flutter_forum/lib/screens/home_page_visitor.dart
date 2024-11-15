import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post.dart';
import '../services/database_service.dart';
import 'post_details_page.dart';
import 'login_page.dart';
import 'register_page.dart';

class HomePageVisitor extends StatefulWidget {
  const HomePageVisitor({super.key});

  @override
  State<HomePageVisitor> createState() => _HomePageVisitorState();
}

class _HomePageVisitorState extends State<HomePageVisitor> {
  List<Post> posts = [];
  bool isLoading = true;

  final List<String> categories = [
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

  /// Fetch a limited number of posts to showcase
  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      posts = await DatabaseService.getLimitedPosts(limit: 5);
    } catch (e) {
      print('Error loading posts: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark background color for cinematic feel
      appBar: AppBar(
        title: Text(
          'CineTalk',
          style: GoogleFonts.lobster(
            fontSize: 28,
            color: Colors.amberAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Section
            Text(
              "Explore Categories",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: categories.map((category) {
                return _buildCategoryChip(category, _getCategoryColor(category));
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Welcome Section with Gradient Background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A3A52), Color(0xFF2B2B44)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to CineTalk!",
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your go-to forum for all things cinema! Join discussions on your favorite movies, directors, genres, and more.",
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Recent Discussions Section
            Text(
              "Recent Discussions",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent,
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amberAccent),
                  )
                : posts.isEmpty
                    ? const Center(
                        child: Text(
                          'No posts found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Card(
                            color: const Color(0xFF2E2E3A),
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Post Title
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amberAccent,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Post Content (Snippet)
                                  Text(
                                    post.content,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 10),

                                  // Display Category
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(post.category ?? ''),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        post.category ?? 'Uncategorized',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // On Tap Navigation to Post Details
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailsPage(post: post),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Read more',
                                      style: TextStyle(
                                          color: Colors.amberAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 30),

            // Call-to-action for new users to join the forum
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Join CineTalk",
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amberAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Log In',
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, Color color) {
    return GestureDetector(
      onTap: () {
        // Handle category selection
        print('Selected category: $category');
      },
      child: Chip(
        label: Text(
          category,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
