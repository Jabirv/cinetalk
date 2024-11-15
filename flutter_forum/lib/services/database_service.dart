import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static Database? _database;

  /// Initialize or get the database
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // Initialize databaseFactory for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await openDatabase(
      join(await getDatabasesPath(), 'forum.db'),
      version: 4, // Updated version
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _migrateDatabase(db, oldVersion, newVersion);
      },
    );
    return _database!;
  }

  /// Method to handle migrations for schema changes
  static Future<void> _migrateDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE posts ADD COLUMN attachments TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE posts ADD COLUMN username TEXT');
      await db.execute('ALTER TABLE comments ADD COLUMN username TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE posts ADD COLUMN category TEXT'); // Add category column
    }
  }

  /// Create tables for the database
  static Future<void> _createTables(Database db) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Create Posts table with the new schema
    await db.execute('''
      CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        username TEXT,
        title TEXT,
        content TEXT,
        richContent TEXT,
        createdAt TEXT,
        attachments TEXT,
        category TEXT
      )
    ''');

    // Create Comments table with the new schema
    await db.execute('''
      CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        userId INTEGER,
        username TEXT,
        content TEXT,
        createdAt TEXT
      )
    ''');
  }

  /// Register a new user
  static Future<int> registerUser(User user) async {
    final db = await getDatabase();
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Login user
  static Future<User?> loginUser(String username, String password) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Insert a new post into the database
  static Future<int> insertPost(Post post) async {
    final db = await getDatabase();
    return await db.insert(
      'posts',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all posts with usernames
  static Future<List<Post>> getPosts() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT posts.*, users.username 
      FROM posts 
      JOIN users ON posts.userId = users.id 
      ORDER BY posts.createdAt DESC
    ''');
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  /// Fetch a limited number of posts
  static Future<List<Post>> getLimitedPosts({int limit = 5}) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      limit: limit,
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Post.fromMap(maps[i]));
  }

  /// Fetch a single post by ID
  static Future<Post?> getPostById(int postId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
    );
    if (maps.isNotEmpty) {
      return Post.fromMap(maps.first);
    }
    return null;
  }

  /// Insert a new comment into the database
  static Future<int> insertComment(Comment comment) async {
    final db = await getDatabase();
    return await db.insert(
      'comments',
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch a user by ID
  static Future<User?> getUserById(int userId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  /// Fetch all comments related to a specific post with usernames
  static Future<List<Comment>> getCommentsWithUsernames(int postId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT comments.*, users.username 
      FROM comments 
      JOIN users ON comments.userId = users.id 
      WHERE comments.postId = ? 
      ORDER BY comments.createdAt ASC
    ''', [postId]);

    return List.generate(maps.length, (i) {
      return Comment.fromMap(maps[i]);
    });
  }
}
