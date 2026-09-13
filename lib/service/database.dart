import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/social_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('odi_turkana.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table for Posts
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        authorName TEXT,
        authorLocation TEXT,
        content TEXT,
        timestamp TEXT,
        likes INTEGER
      )
    ''');

    // Table for Comments
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId TEXT,
        commentText TEXT,
        FOREIGN KEY (postId) REFERENCES posts (id) ON DELETE CASCADE
      )
    ''');

    // Seed default post from Kakuma
    await db.insert('posts', {
      'id': 'post_kakuma_1',
      'authorName': 'Odi Wa Turkana',
      'authorLocation': 'Kakuma, Turkana',
      'content': 'Welcome to my official app! Streaming music straight from Kakuma to the world. 🇰🇪🎶',
      'timestamp': DateTime.now().toIso8601String(),
      'likes': 120,
    });
  }

  // --- Post Operations ---
  Future<void> insertPost(Post post) async {
    final db = await instance.database;
    await db.insert('posts', {
      'id': post.id,
      'authorName': post.authorName,
      'authorLocation': post.authorLocation,
      'content': post.content,
      'timestamp': post.timestamp.toIso8601String(),
      'likes': post.likes,
    });
  }

  Future<List<Post>> fetchPosts() async {
    final db = await instance.database;
    final postMaps = await db.query('posts', orderBy: 'timestamp DESC');

    List<Post> posts = [];
    for (var map in postMaps) {
      final comments = await fetchComments(map['id'] as String);
      posts.add(Post(
        id: map['id'] as String,
        authorName: map['authorName'] as String,
        authorLocation: map['authorLocation'] as String,
        content: map['content'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        likes: map['likes'] as int,
        comments: comments,
      ));
    }
    return posts;
  }

  Future<void> updateLikes(String postId, int likes) async {
    final db = await instance.database;
    await db.update('posts', {'likes': likes}, where: 'id = ?', whereArgs: [postId]);
  }

  // --- Comment Operations ---
  Future<void> insertComment(String postId, String commentText) async {
    final db = await instance.database;
    await db.insert('comments', {
      'postId': postId,
      'commentText': commentText,
    });
  }

  Future<List<String>> fetchComments(String postId) async {
    final db = await instance.database;
    final result = await db.query('comments', where: 'postId = ?', whereArgs: [postId]);
    return result.map((row) => row['commentText'] as String).toList();
  }
}