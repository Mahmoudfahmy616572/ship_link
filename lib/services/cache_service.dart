import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._();
  factory CacheService() => _instance;
  CacheService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'shiplink_cache.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache (
            key TEXT PRIMARY KEY,
            data TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> put(String key, dynamic data, {Duration ttl = const Duration(minutes: 30)}) async {
    final db = await database;
    await db.insert('cache', {
      'key': key,
      'data': jsonEncode(data),
      'timestamp': DateTime.now().millisecondsSinceEpoch + ttl.inMilliseconds,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<dynamic> get(String key) async {
    final db = await database;
    final rows = await db.query('cache', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final expiry = row['timestamp'] as int;
    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      await db.delete('cache', where: 'key = ?', whereArgs: [key]);
      return null;
    }
    return jsonDecode(row['data'] as String);
  }

  Future<void> remove(String key) async {
    final db = await database;
    await db.delete('cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('cache');
  }
}

class CredentialsService {
  static final CredentialsService _instance = CredentialsService._();
  factory CredentialsService() => _instance;
  CredentialsService._();

  Future<void> save(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_email');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
  }
}
