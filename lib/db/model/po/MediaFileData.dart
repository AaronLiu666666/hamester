class MediaFileData {
  int? id; // 如果是自增主键，可以为null
  String? path;
  String? fileName;
  String? fileAlias;
  String? fileMd5;
  String? sourceUrl;
  DateTime? createTime;
  DateTime? updateTime;

  MediaFileData({
    this.id,
    this.path,
    this.fileName,
    this.fileAlias,
    this.fileMd5,
    this.sourceUrl,
    this.createTime,
    this.updateTime,
  });

  // 将实体对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'file_name': fileName,
      'file_alias': fileAlias,
      'file_md5': fileMd5,
      'source_url': sourceUrl,
      'create_time': createTime?.toIso8601String(),
      'update_time': updateTime?.toIso8601String(),
    };
  }

  // 从Map中构建实体对象
  factory MediaFileData.fromMap(Map<String, dynamic> map) {
    return MediaFileData(
      id: map['id'],
      path: map['path'],
      fileName: map['file_name'],
      fileAlias: map['file_alias'],
      fileMd5: map['file_md5'],
      sourceUrl: map['source_url'],
      createTime: DateTime.tryParse(map['create_time']),
      updateTime: DateTime.tryParse(map['update_time']),
    );
  }
}
