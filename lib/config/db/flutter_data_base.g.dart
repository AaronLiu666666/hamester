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

  TagInfoDao? _tagInfoDaoInstance;

  MediaTagRelationDao? _mediaTagRelationDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `media_file_data` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `path` TEXT, `file_name` TEXT, `file_alias` TEXT, `file_md5` TEXT, `source_url` TEXT, `memo` TEXT, `cover` TEXT, `last_play_moment` INTEGER, `last_play_time` INTEGER, `play_num` INTEGER, `file_create_time` INTEGER, `create_time` INTEGER, `update_time` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `tag_info` (`id` TEXT, `tag_name` TEXT, `tag_desc` TEXT, `tag_pic` TEXT, `create_time` INTEGER, `update_time` INTEGER, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `r_media_tag` (`id` TEXT, `media_id` INTEGER, `tag_id` TEXT, `media_moment` INTEGER, `relation_desc` TEXT, `media_moment_pic` TEXT, `create_time` INTEGER, `update_time` INTEGER, PRIMARY KEY (`id`))');

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

  @override
  TagInfoDao get tagInfoDao {
    return _tagInfoDaoInstance ??= _$TagInfoDao(database, changeListener);
  }

  @override
  MediaTagRelationDao get mediaTagRelationDao {
    return _mediaTagRelationDaoInstance ??=
        _$MediaTagRelationDao(database, changeListener);
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
                  'file_create_time': item.fileCreateTime,
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
            row['path'] as String?,
            row['file_name'] as String?,
            row['file_alias'] as String?,
            row['file_md5'] as String?,
            row['memo'] as String?,
            row['cover'] as String?,
            row['source_url'] as String?,
            row['last_play_moment'] as int?,
            row['last_play_time'] as int?,
            row['play_num'] as int?,
            row['create_time'] as int?,
            row['update_time'] as int?));
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

class _$TagInfoDao extends TagInfoDao {
  _$TagInfoDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _tagInfoInsertionAdapter = InsertionAdapter(
            database,
            'tag_info',
            (TagInfo item) => <String, Object?>{
                  'id': item.id,
                  'tag_name': item.tagName,
                  'tag_desc': item.tagDesc,
                  'tag_pic': item.tagPic,
                  'create_time': item.createTime,
                  'update_time': item.updateTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TagInfo> _tagInfoInsertionAdapter;

  @override
  Future<List<TagInfo>> queryTagsByTagName(String tagName) async {
    return _queryAdapter.queryList('SELECT * FROM tag_info WHERE tag_name = ?1',
        mapper: (Map<String, Object?> row) => TagInfo(
            id: row['id'] as String?,
            tagName: row['tag_name'] as String?,
            tagDesc: row['tag_desc'] as String?,
            tagPic: row['tag_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?),
        arguments: [tagName]);
  }

  @override
  Future<void> insertOne(TagInfo tagInfo) async {
    await _tagInfoInsertionAdapter.insert(tagInfo, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertList(List<TagInfo> list) async {
    await _tagInfoInsertionAdapter.insertList(list, OnConflictStrategy.abort);
  }
}

class _$MediaTagRelationDao extends MediaTagRelationDao {
  _$MediaTagRelationDao(
    this.database,
    this.changeListener,
  ) : _mediaTagRelationInsertionAdapter = InsertionAdapter(
            database,
            'r_media_tag',
            (MediaTagRelation item) => <String, Object?>{
                  'id': item.id,
                  'media_id': item.mediaId,
                  'tag_id': item.tagId,
                  'media_moment': item.mediaMoment,
                  'relation_desc': item.relationDesc,
                  'media_moment_pic': item.mediaMomentPic,
                  'create_time': item.createTime,
                  'update_time': item.updateTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<MediaTagRelation> _mediaTagRelationInsertionAdapter;

  @override
  Future<void> insertOne(MediaTagRelation mediaTagRelation) async {
    await _mediaTagRelationInsertionAdapter.insert(
        mediaTagRelation, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertList(List<MediaTagRelation> list) async {
    await _mediaTagRelationInsertionAdapter.insertList(
        list, OnConflictStrategy.abort);
  }
}
