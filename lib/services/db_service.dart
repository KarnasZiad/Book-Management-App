import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DBService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'books.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE books (
          id TEXT PRIMARY KEY,
          title TEXT,
          author TEXT,
          thumbnail TEXT
        )
      ''');
    });
  }

  static Future<void> insertItem(Book book) async {
    final dbClient = await db;
    await dbClient.insert('books', book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Book>> getItems() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('books');
    return List.generate(maps.length, (i) {
      return Book(
        id: maps[i]['id'],
        title: maps[i]['title'],
        author: maps[i]['author'],
        thumbnail: maps[i]['thumbnail'],
      );
    });
  }

  static Future<void> deleteItem(String id) async {
    final dbClient = await db;
    await dbClient.delete('books', where: 'id = ?', whereArgs: [id]);
  }
}
