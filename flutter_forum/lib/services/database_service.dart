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
      version: 2, // Incremented version for schema change
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE posts ADD COLUMN attachments TEXT');
        }
      },
    );
    return _database!;
  }

  /// Create tables for the database
  static Future<void> _createTables(Database db) async {
    // Create Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // Create Posts table with attachments column
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        content TEXT,
        richContent TEXT,
        createdAt TEXT,
        attachments TEXT
      )
    ''');

    // Create Comments table
    await db.execute('''
      CREATE TABLE comments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER,
        userId INTEGER,
        content TEXT,
        createdAt TEXT
      )
    ''');
  }

  // Register a new user
  static Future<int> registerUser(User user) async {
    final db = await getDatabase();
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Login user
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

  /// Insert a new post with attachments into the database
  static Future<int> insertPost(Post post) async {
    final db = await getDatabase();
    return await db.insert(
      'posts',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Fetch all posts from the database
  static Future<List<Post>> getPosts() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query('posts');
    return List.generate(
      maps.length,
      (i) => Post.fromMap(maps[i]),
    );
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

  // Insert a new comment into the database
  static Future<int> insertComment(Comment comment) async {
    final db = await getDatabase();
    return await db.insert(
      'comments',
      comment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all comments related to a specific post
  static Future<List<Comment>> getComments(int postId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
    );
    return List.generate(
      maps.length,
      (i) => Comment.fromMap(maps[i]),
    );
  }
}
