import 'package:flutter/material.dart';
import 'package:flutter_forum/screens/home_page_visitor.dart';
import 'package:flutter_forum/screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart'; // Import the generated file for FirebaseOptions

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // This ensures all necessary bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
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
