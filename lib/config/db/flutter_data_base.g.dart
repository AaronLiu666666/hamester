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

  AppConfigDao? _appConfigDaoInstance;

  BrilliantTimeDao? _brilliantDaoInstance;

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
            'CREATE TABLE IF NOT EXISTS `r_media_tag` (`id` TEXT, `media_id` INTEGER, `tag_id` TEXT, `media_moment` INTEGER, `relation_desc` TEXT, `media_moment_pic` TEXT, `create_time` INTEGER, `update_time` INTEGER, `tagName` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `app_config` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `type` TEXT, `content` TEXT, `createTime` INTEGER, `updateTime` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `brilliant_time` (`id` TEXT, `type` INTEGER, `brilliant_desc` TEXT, `brilliant_pic` TEXT, `begin_moment` INTEGER NOT NULL, `end_moment` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await database.execute(
            'CREATE VIEW IF NOT EXISTS `myJoinedObject` AS     SELECT\n      r.*, t.tag_name as tagName, m.path as mediaPath\n    FROM\n      r_media_tag r\n      LEFT JOIN tag_info t ON r.tag_id = t.id \n      LEFT JOIN media_file_data m ON r.media_id = m.id\n      ');

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

  @override
  AppConfigDao get appConfigDao {
    return _appConfigDaoInstance ??= _$AppConfigDao(database, changeListener);
  }

  @override
  BrilliantTimeDao get brilliantDao {
    return _brilliantDaoInstance ??=
        _$BrilliantTimeDao(database, changeListener);
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
                }),
        _mediaFileDataUpdateAdapter = UpdateAdapter(
            database,
            'media_file_data',
            ['id'],
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

  final UpdateAdapter<MediaFileData> _mediaFileDataUpdateAdapter;

  @override
  Future<List<MediaFileData>> queryAllMediaFileDataList() async {
    return _queryAdapter.queryList('select * from media_file_data',
        mapper: (Map<String, Object?> row) => MediaFileData(
            id: row['id'] as int?,
            path: row['path'] as String?,
            fileName: row['file_name'] as String?,
            fileAlias: row['file_alias'] as String?,
            fileMd5: row['file_md5'] as String?,
            memo: row['memo'] as String?,
            cover: row['cover'] as String?,
            sourceUrl: row['source_url'] as String?,
            lastPlayMoment: row['last_play_moment'] as int?,
            lastPlayTime: row['last_play_time'] as int?,
            playNum: row['play_num'] as int?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?));
  }

  @override
  Future<List<MediaFileData>> queryDatasByIds(List<int> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM media_file_data WHERE id IN (' +
            _sqliteVariablesForIds +
            ')',
        mapper: (Map<String, Object?> row) => MediaFileData(
            id: row['id'] as int?,
            path: row['path'] as String?,
            fileName: row['file_name'] as String?,
            fileAlias: row['file_alias'] as String?,
            fileMd5: row['file_md5'] as String?,
            memo: row['memo'] as String?,
            cover: row['cover'] as String?,
            sourceUrl: row['source_url'] as String?,
            lastPlayMoment: row['last_play_moment'] as int?,
            lastPlayTime: row['last_play_time'] as int?,
            playNum: row['play_num'] as int?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?),
        arguments: [...ids]);
  }

  @override
  Future<MediaFileData?> queryMediaDataById(int id) async {
    return _queryAdapter.query('SELECT * FROM media_file_data WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MediaFileData(
            id: row['id'] as int?,
            path: row['path'] as String?,
            fileName: row['file_name'] as String?,
            fileAlias: row['file_alias'] as String?,
            fileMd5: row['file_md5'] as String?,
            memo: row['memo'] as String?,
            cover: row['cover'] as String?,
            sourceUrl: row['source_url'] as String?,
            lastPlayMoment: row['last_play_moment'] as int?,
            lastPlayTime: row['last_play_time'] as int?,
            playNum: row['play_num'] as int?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?),
        arguments: [id]);
  }

  @override
  Future<List<MediaFileData>> searchMedia(String content) async {
    return _queryAdapter.queryList(
        'SELECT mfd.*   FROM media_file_data mfd   LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id \tLEFT JOIN tag_info ti ON mtr.tag_id = ti.id   WHERE mfd.file_name LIKE \'%\' || ?1 || \'%\'      OR mfd.file_alias LIKE \'%\' || ?1 || \'%\'      OR mfd.memo LIKE \'%\' || ?1 || \'%\'      OR ti.tag_name LIKE \'%\' || ?1 || \'%\'      OR ti.tag_desc LIKE \'%\' || ?1 || \'%\'      OR mtr.relation_desc LIKE \'%\' || ?1 || \'%\'',
        mapper: (Map<String, Object?> row) => MediaFileData(id: row['id'] as int?, path: row['path'] as String?, fileName: row['file_name'] as String?, fileAlias: row['file_alias'] as String?, fileMd5: row['file_md5'] as String?, memo: row['memo'] as String?, cover: row['cover'] as String?, sourceUrl: row['source_url'] as String?, lastPlayMoment: row['last_play_moment'] as int?, lastPlayTime: row['last_play_time'] as int?, playNum: row['play_num'] as int?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?),
        arguments: [content]);
  }

  @override
  Future<List<MediaFileData>> searchMediaPage(
    String content,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT mfd.*   FROM media_file_data mfd   LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id \tLEFT JOIN tag_info ti ON mtr.tag_id = ti.id   WHERE      (?1 IS NULL OR mfd.file_name LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR mfd.file_alias LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR mfd.memo LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR ti.tag_name LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR ti.tag_desc LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR mtr.relation_desc LIKE \'%\' || ?1 || \'%\')     group by mfd.id     order by mfd.create_time,mfd.id   LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => MediaFileData(id: row['id'] as int?, path: row['path'] as String?, fileName: row['file_name'] as String?, fileAlias: row['file_alias'] as String?, fileMd5: row['file_md5'] as String?, memo: row['memo'] as String?, cover: row['cover'] as String?, sourceUrl: row['source_url'] as String?, lastPlayMoment: row['last_play_moment'] as int?, lastPlayTime: row['last_play_time'] as int?, playNum: row['play_num'] as int?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?),
        arguments: [content, limit, offset]);
  }

  @override
  Future<List<MediaFileData>> searchMediaPageWithoutTag(
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT mfd.*   FROM media_file_data mfd   LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id \tLEFT JOIN tag_info ti ON mtr.tag_id = ti.id \twhere ti.id is null     group by mfd.id     order by mfd.create_time,mfd.id   LIMIT ?1 OFFSET ?2',
        mapper: (Map<String, Object?> row) => MediaFileData(id: row['id'] as int?, path: row['path'] as String?, fileName: row['file_name'] as String?, fileAlias: row['file_alias'] as String?, fileMd5: row['file_md5'] as String?, memo: row['memo'] as String?, cover: row['cover'] as String?, sourceUrl: row['source_url'] as String?, lastPlayMoment: row['last_play_moment'] as int?, lastPlayTime: row['last_play_time'] as int?, playNum: row['play_num'] as int?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?),
        arguments: [limit, offset]);
  }

  @override
  Future<List<MediaFileData>> searchMediaPageWithTag(
    String tag,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT mfd.*   FROM media_file_data mfd   LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id \tLEFT JOIN tag_info ti ON mtr.tag_id = ti.id \twhere  \t  ti.tag_name like ?1 || \'%\'     group by mfd.id     order by mfd.create_time,mfd.id   LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => MediaFileData(id: row['id'] as int?, path: row['path'] as String?, fileName: row['file_name'] as String?, fileAlias: row['file_alias'] as String?, fileMd5: row['file_md5'] as String?, memo: row['memo'] as String?, cover: row['cover'] as String?, sourceUrl: row['source_url'] as String?, lastPlayMoment: row['last_play_moment'] as int?, lastPlayTime: row['last_play_time'] as int?, playNum: row['play_num'] as int?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?),
        arguments: [tag, limit, offset]);
  }

  @override
  Future<int?> searchMediaCount(String content) async {
    return _queryAdapter.query(
        'SELECT count(DISTINCT mfd.id)   FROM media_file_data mfd   LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id \tLEFT JOIN tag_info ti ON mtr.tag_id = ti.id   WHERE      (?1 IS NULL OR mfd.file_name LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR mfd.file_alias LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR mfd.memo LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR ti.tag_name LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR ti.tag_desc LIKE \'%\' || ?1 || \'%\') OR     (?1 IS NULL OR mtr.relation_desc LIKE \'%\' || ?1 || \'%\')',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [content]);
  }

  @override
  Future<int?> searchMediaPageWithoutTagCount() async {
    return _queryAdapter.query(
        'SELECT count(DISTINCT mfd.id)   FROM media_file_data mfd   LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id \tLEFT JOIN tag_info ti ON mtr.tag_id = ti.id   WHERE      ti.id is null',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> searchMediaPageWithTagCount(String tag) async {
    return _queryAdapter.query(
        'SELECT count(DISTINCT mfd.id)   FROM media_file_data mfd   LEFT JOIN r_media_tag mtr ON mfd.id = mtr.media_id \tLEFT JOIN tag_info ti ON mtr.tag_id = ti.id   WHERE      ti.tag_name like ?1 || \'%\'',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [tag]);
  }

  @override
  Future<void> deleteMediaFileData(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM media_file_data WHERE id = ?1',
        arguments: [id]);
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

  @override
  Future<void> updateData(MediaFileData mediaFileData) async {
    await _mediaFileDataUpdateAdapter.update(
        mediaFileData, OnConflictStrategy.abort);
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
                }),
        _tagInfoUpdateAdapter = UpdateAdapter(
            database,
            'tag_info',
            ['id'],
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

  final UpdateAdapter<TagInfo> _tagInfoUpdateAdapter;

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
  Future<List<TagInfo>> queryAllDataList() async {
    return _queryAdapter.queryList('select * from tag_info',
        mapper: (Map<String, Object?> row) => TagInfo(
            id: row['id'] as String?,
            tagName: row['tag_name'] as String?,
            tagDesc: row['tag_desc'] as String?,
            tagPic: row['tag_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?));
  }

  @override
  Future<TagInfo?> queryDataById(String id) async {
    return _queryAdapter.query('select * from tag_info where id = ?1',
        mapper: (Map<String, Object?> row) => TagInfo(
            id: row['id'] as String?,
            tagName: row['tag_name'] as String?,
            tagDesc: row['tag_desc'] as String?,
            tagPic: row['tag_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?),
        arguments: [id]);
  }

  @override
  Future<List<TagInfo>> queryTagsByMediaId(int mediaId) async {
    return _queryAdapter.queryList(
        'SELECT      t.*     FROM       r_media_tag r       LEFT JOIN tag_info t ON r.tag_id = t.id      WHERE       r.media_id = ?1        group by r.tag_id       order by r.create_time',
        mapper: (Map<String, Object?> row) => TagInfo(id: row['id'] as String?, tagName: row['tag_name'] as String?, tagDesc: row['tag_desc'] as String?, tagPic: row['tag_pic'] as String?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?),
        arguments: [mediaId]);
  }

  @override
  Future<int?> searchTagCount(String content) async {
    return _queryAdapter.query(
        'select count(*) from tag_info where    (?1 IS NULL OR tag_name LIKE \'%\' || ?1 || \'%\') or (?1 IS NULL OR tag_desc LIKE \'%\' || ?1 || \'%\')',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [content]);
  }

  @override
  Future<List<TagInfo>> searchTagInfoPage(
    String content,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'select * from tag_info where      (?1 IS NULL OR tag_name LIKE \'%\' || ?1 || \'%\') or (?1 IS NULL OR tag_desc LIKE \'%\' || ?1 || \'%\')     order by create_time,id     LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => TagInfo(id: row['id'] as String?, tagName: row['tag_name'] as String?, tagDesc: row['tag_desc'] as String?, tagPic: row['tag_pic'] as String?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?),
        arguments: [content, limit, offset]);
  }

  @override
  Future<List<TagInfo>> searchTagInfoListByTagName(String tagName) async {
    return _queryAdapter.queryList(
        'select * from tag_info where      (tag_name LIKE \'%\' || ?1 || \'%\')     order by create_time,id',
        mapper: (Map<String, Object?> row) => TagInfo(id: row['id'] as String?, tagName: row['tag_name'] as String?, tagDesc: row['tag_desc'] as String?, tagPic: row['tag_pic'] as String?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?),
        arguments: [tagName]);
  }

  @override
  Future<void> deleteTagById(String tagId) async {
    await _queryAdapter.queryNoReturn('delete from tag_info where id = ?1',
        arguments: [tagId]);
  }

  @override
  Future<void> insertOne(TagInfo tagInfo) async {
    await _tagInfoInsertionAdapter.insert(tagInfo, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertList(List<TagInfo> list) async {
    await _tagInfoInsertionAdapter.insertList(list, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateData(TagInfo tagInfo) async {
    await _tagInfoUpdateAdapter.update(tagInfo, OnConflictStrategy.abort);
  }
}

class _$MediaTagRelationDao extends MediaTagRelationDao {
  _$MediaTagRelationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _mediaTagRelationInsertionAdapter = InsertionAdapter(
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
                  'update_time': item.updateTime,
                  'tagName': item.tagName
                }),
        _mediaTagRelationUpdateAdapter = UpdateAdapter(
            database,
            'r_media_tag',
            ['id'],
            (MediaTagRelation item) => <String, Object?>{
                  'id': item.id,
                  'media_id': item.mediaId,
                  'tag_id': item.tagId,
                  'media_moment': item.mediaMoment,
                  'relation_desc': item.relationDesc,
                  'media_moment_pic': item.mediaMomentPic,
                  'create_time': item.createTime,
                  'update_time': item.updateTime,
                  'tagName': item.tagName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MediaTagRelation> _mediaTagRelationInsertionAdapter;

  final UpdateAdapter<MediaTagRelation> _mediaTagRelationUpdateAdapter;

  @override
  Future<List<MediaTagRelation>> queryAllDataList() async {
    return _queryAdapter.queryList('select * from r_media_tag',
        mapper: (Map<String, Object?> row) => MediaTagRelation(
            id: row['id'] as String?,
            mediaId: row['media_id'] as int?,
            tagId: row['tag_id'] as String?,
            mediaMoment: row['media_moment'] as int?,
            relationDesc: row['relation_desc'] as String?,
            mediaMomentPic: row['media_moment_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?,
            tagName: row['tagName'] as String?));
  }

  @override
  Future<List<MediaTagRelation>> queryAllDataListWithMediaPath() async {
    return _queryAdapter.queryList(
        'SELECT       r.*,m.path as mediaPath     FROM       r_media_tag r       LEFT JOIN media_file_data m on r.media_id = m.id',
        mapper: (Map<String, Object?> row) => MediaTagRelation(
            id: row['id'] as String?,
            mediaId: row['media_id'] as int?,
            tagId: row['tag_id'] as String?,
            mediaMoment: row['media_moment'] as int?,
            relationDesc: row['relation_desc'] as String?,
            mediaMomentPic: row['media_moment_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?,
            tagName: row['tagName'] as String?));
  }

  @override
  Future<List<MediaTagRelation>> queryRelationsByTagId(String tagId) async {
    return _queryAdapter.queryList(
        'select * from r_media_tag where tag_id = ?1',
        mapper: (Map<String, Object?> row) => MediaTagRelation(
            id: row['id'] as String?,
            mediaId: row['media_id'] as int?,
            tagId: row['tag_id'] as String?,
            mediaMoment: row['media_moment'] as int?,
            relationDesc: row['relation_desc'] as String?,
            mediaMomentPic: row['media_moment_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?,
            tagName: row['tagName'] as String?),
        arguments: [tagId]);
  }

  @override
  Future<List<MediaTagRelation>> queryRelationsByMediaId(int mediaId) async {
    return _queryAdapter.queryList(
        'select r.*,t.tag_name tagName, m.path as mediaPath       from r_media_tag r LEFT JOIN tag_info t on r.tag_id = t.id left join media_file_data m on r.media_id = m.id     where        r.media_id = ?1        order by media_moment',
        mapper: (Map<String, Object?> row) => MediaTagRelation(id: row['id'] as String?, mediaId: row['media_id'] as int?, tagId: row['tag_id'] as String?, mediaMoment: row['media_moment'] as int?, relationDesc: row['relation_desc'] as String?, mediaMomentPic: row['media_moment_pic'] as String?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?, tagName: row['tagName'] as String?),
        arguments: [mediaId]);
  }

  @override
  Future<List<MediaTagRelation>> queryRelationsByTagIdWithMediaPath(
      String tagId) async {
    return _queryAdapter.queryList(
        'select r.*, m.path as mediaPath       from        r_media_tag r left join media_file_data m on r.media_id = m.id         where tag_id = ?1',
        mapper: (Map<String, Object?> row) => MediaTagRelation(id: row['id'] as String?, mediaId: row['media_id'] as int?, tagId: row['tag_id'] as String?, mediaMoment: row['media_moment'] as int?, relationDesc: row['relation_desc'] as String?, mediaMomentPic: row['media_moment_pic'] as String?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?, tagName: row['tagName'] as String?),
        arguments: [tagId]);
  }

  @override
  Future<MediaTagRelation?> queryRelationById(String id) async {
    return _queryAdapter.query('select * from r_media_tag where id = ?1',
        mapper: (Map<String, Object?> row) => MediaTagRelation(
            id: row['id'] as String?,
            mediaId: row['media_id'] as int?,
            tagId: row['tag_id'] as String?,
            mediaMoment: row['media_moment'] as int?,
            relationDesc: row['relation_desc'] as String?,
            mediaMomentPic: row['media_moment_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?,
            tagName: row['tagName'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<MediaTagRelation>> queryAllDataListWithTagName() async {
    return _queryAdapter.queryList(
        'select r.*,t.tag_name as tagName from r_media_tag r LEFT JOIN tag_info t on r.tag_id = t.id',
        mapper: (Map<String, Object?> row) => MediaTagRelation(
            id: row['id'] as String?,
            mediaId: row['media_id'] as int?,
            tagId: row['tag_id'] as String?,
            mediaMoment: row['media_moment'] as int?,
            relationDesc: row['relation_desc'] as String?,
            mediaMomentPic: row['media_moment_pic'] as String?,
            createTime: row['create_time'] as int?,
            updateTime: row['update_time'] as int?,
            tagName: row['tagName'] as String?));
  }

  @override
  Future<int?> searchRelationCount(String content) async {
    return _queryAdapter.query(
        'SELECT     count(r.id)    FROM     r_media_tag r     LEFT JOIN tag_info t ON r.tag_id = t.id    WHERE    (?1 IS NULL OR r.relation_desc LIKE \'%\' || ?1 || \'%\') OR    (?1 IS NULL OR t.tag_name LIKE \'%\' || ?1 || \'%\') OR    (?1 IS NULL OR t.tag_desc LIKE \'%\' || ?1 || \'%\')',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [content]);
  }

  @override
  Future<List<MediaTagRelation>> searchRelationPage(
    String content,
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT     r.*,t.tag_name as tagName,m.path as mediaPath   FROM     r_media_tag r     LEFT JOIN tag_info t ON r.tag_id = t.id      LEFT JOIN media_file_data m on r.media_id = m.id   WHERE    (?1 IS NULL OR r.relation_desc LIKE \'%\' || ?1 || \'%\') OR    (?1 IS NULL OR t.tag_name LIKE \'%\' || ?1 || \'%\') OR    (?1 IS NULL OR t.tag_desc LIKE \'%\' || ?1 || \'%\')     order by r.create_time,r.id     LIMIT ?2 OFFSET ?3',
        mapper: (Map<String, Object?> row) => MediaTagRelation(id: row['id'] as String?, mediaId: row['media_id'] as int?, tagId: row['tag_id'] as String?, mediaMoment: row['media_moment'] as int?, relationDesc: row['relation_desc'] as String?, mediaMomentPic: row['media_moment_pic'] as String?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?, tagName: row['tagName'] as String?),
        arguments: [content, limit, offset]);
  }

  @override
  Future<List<MediaTagRelationWithTagName>> findAllMediaTagRelations() async {
    return _queryAdapter.queryList('SELECT * from myJoinedObject',
        mapper: (Map<String, Object?> row) => MediaTagRelationWithTagName(
            id: row['id'] as String?,
            mediaId: row['mediaId'] as int?,
            tagId: row['tagId'] as String?,
            mediaMoment: row['mediaMoment'] as int?,
            relationDesc: row['relationDesc'] as String?,
            mediaMomentPic: row['mediaMomentPic'] as String?,
            createTime: row['createTime'] as int?,
            updateTime: row['updateTime'] as int?,
            tagName: row['tagName'] as String?,
            mediaPath: row['mediaPath'] as String?));
  }

  @override
  Future<void> deleteRelationByMediaId(int mediaId) async {
    await _queryAdapter.queryNoReturn(
        'delete from r_media_tag where media_id = ?1',
        arguments: [mediaId]);
  }

  @override
  Future<void> deleteRelationByTagId(String tagId) async {
    await _queryAdapter.queryNoReturn(
        'delete from r_media_tag where tag_id = ?1',
        arguments: [tagId]);
  }

  @override
  Future<void> deleteRelationById(String relationId) async {
    await _queryAdapter.queryNoReturn('delete from r_media_tag where id = ?1',
        arguments: [relationId]);
  }

  @override
  Future<List<MediaTagRelation>> queryRelationsByTagNameLeftLike(
      String tagName) async {
    return _queryAdapter.queryList(
        'SELECT       r.*      FROM       tag_info t       LEFT JOIN r_media_tag r ON t.id = r.tag_id      WHERE       t.tag_name LIKE ?1 || \'%\'',
        mapper: (Map<String, Object?> row) => MediaTagRelation(id: row['id'] as String?, mediaId: row['media_id'] as int?, tagId: row['tag_id'] as String?, mediaMoment: row['media_moment'] as int?, relationDesc: row['relation_desc'] as String?, mediaMomentPic: row['media_moment_pic'] as String?, createTime: row['create_time'] as int?, updateTime: row['update_time'] as int?, tagName: row['tagName'] as String?),
        arguments: [tagName]);
  }

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

  @override
  Future<void> updateRelation(MediaTagRelation relation) async {
    await _mediaTagRelationUpdateAdapter.update(
        relation, OnConflictStrategy.abort);
  }
}

class _$AppConfigDao extends AppConfigDao {
  _$AppConfigDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _appConfigInsertionAdapter = InsertionAdapter(
            database,
            'app_config',
            (AppConfig item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'content': item.content,
                  'createTime': item.createTime,
                  'updateTime': item.updateTime
                }),
        _appConfigUpdateAdapter = UpdateAdapter(
            database,
            'app_config',
            ['id'],
            (AppConfig item) => <String, Object?>{
                  'id': item.id,
                  'type': item.type,
                  'content': item.content,
                  'createTime': item.createTime,
                  'updateTime': item.updateTime
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppConfig> _appConfigInsertionAdapter;

  final UpdateAdapter<AppConfig> _appConfigUpdateAdapter;

  @override
  Future<AppConfig?> selectAppConfigByType(String configType) async {
    return _queryAdapter.query(
        'select * from app_config where type = ?1 limit 1',
        mapper: (Map<String, Object?> row) => AppConfig(
            id: row['id'] as int?,
            type: row['type'] as String?,
            content: row['content'] as String?,
            createTime: row['createTime'] as int?,
            updateTime: row['updateTime'] as int?),
        arguments: [configType]);
  }

  @override
  Future<void> insertAppConfig(AppConfig appConfig) async {
    await _appConfigInsertionAdapter.insert(
        appConfig, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateAppConfig(AppConfig appConfig) async {
    await _appConfigUpdateAdapter.update(appConfig, OnConflictStrategy.abort);
  }
}

class _$BrilliantTimeDao extends BrilliantTimeDao {
  _$BrilliantTimeDao(
    this.database,
    this.changeListener,
  );

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;
}
