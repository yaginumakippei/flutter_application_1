import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TextAudioDatabase {
  static final TextAudioDatabase instance = TextAudioDatabase._internal();
  Database? _db;

  TextAudioDatabase._internal();

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'text_input.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            inputText TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertEntry(String inputText, String audioFile) async {
    await _db?.insert('entries', {
      'inputText': inputText,
    });
  }

  Future<List<Map<String, dynamic>>> getAllEntries() async {
    return await _db?.query('entries', orderBy: 'id DESC') ?? [];
  }
}
