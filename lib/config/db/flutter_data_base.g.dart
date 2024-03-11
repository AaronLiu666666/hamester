// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flutter_data_base.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorFlutterDataBase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDataBaseBuilder databaseBuilder(String name) =>
      _$FlutterDataBaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$FlutterDataBaseBuilder inMemoryDatabaseBuilder() =>
      _$FlutterDataBaseBuilder(null);
}

class _$FlutterDataBaseBuilder {
  _$FlutterDataBaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$FlutterDataBaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$FlutterDataBaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<FlutterDataBase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$FlutterDataBase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$FlutterDataBase extends FlutterDataBase {
  _$FlutterDataBase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MediaFileDataDao? _mediaFileDataDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `media_file_data` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `path` TEXT NOT NULL, `file_name` TEXT NOT NULL, `file_alias` TEXT NOT NULL, `file_md5` TEXT NOT NULL, `source_url` TEXT NOT NULL, `memo` TEXT NOT NULL, `cover` TEXT NOT NULL, `last_play_moment` INTEGER NOT NULL, `last_play_time` INTEGER NOT NULL, `play_num` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MediaFileDataDao get mediaFileDataDao {
    return _mediaFileDataDaoInstance ??=
        _$MediaFileDataDao(database, changeListener);
  }
}

class _$MediaFileDataDao extends MediaFileDataDao {
  _$MediaFileDataDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mediaFileDataInsertionAdapter = InsertionAdapter(
            database,
            'media_file_data',
            (MediaFileData item) => <String, Object?>{
                  'id': item.id,
                  'path': item.path,
                  'file_name': item.fileName,
                  'file_alias': item.fileAlias,
                  'file_md5': item.fileMd5,
                  'source_url': item.sourceUrl,
                  'memo': item.memo,
                  'cover': item.cover,
                  'last_play_moment': item.lastPlayMoment,
                  'last_play_time': item.lastPlayTime,
                  'play_num': item.playNum,
                  'create_time': item.createTime,
                  'update_time': item.updateTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MediaFileData> _mediaFileDataInsertionAdapter;

  @override
  Future<List<MediaFileData>> queryAllMediaFileDataList() async {
    return _queryAdapter.queryList('select * from media_file_data',
        mapper: (Map<String, Object?> row) => MediaFileData(
            row['id'] as int?,
            row['path'] as String,
            row['file_name'] as String,
            row['file_alias'] as String,
            row['file_md5'] as String,
            row['memo'] as String,
            row['cover'] as String,
            row['source_url'] as String,
            row['last_play_moment'] as int,
            row['last_play_time'] as int,
            row['play_num'] as int,
            row['create_time'] as int,
            row['update_time'] as int));
  }

  @override
  Future<void> insertMember(MediaFileData data) async {
    await _mediaFileDataInsertionAdapter.insert(data, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertMembers(List<MediaFileData> list) async {
    await _mediaFileDataInsertionAdapter.insertList(
        list, OnConflictStrategy.abort);
  }
}
