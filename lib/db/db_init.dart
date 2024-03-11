import 'package:sqflite/sqflite.dart';

class DbInit {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE media_file_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT,
        file_name TEXT,
        file_alias TEXT,
        file_md5 TEXT,
        source_url TEXT,
        create_time DATETIME,
        update_time DATETIME
      )
    ''');
  }

  static Future<void> dropTable(Database db) async {
    await db.execute('DROP TABLE IF EXISTS media_file_data');
  }


}