import 'package:flutter/material.dart';
import 'package:flutter_forum/screens/home_page_visitor.dart';
import 'package:flutter_forum/screens/home_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthService.currentUser != null;

    return MaterialApp(
      title: 'CineTalk Forum',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: isLoggedIn ? const HomePage() : const HomePageVisitor(),
    );
  }
}
