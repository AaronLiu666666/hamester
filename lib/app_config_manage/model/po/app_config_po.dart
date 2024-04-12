import 'package:floor/floor.dart';

/**
 * 应用配置表
 */
@Entity(tableName: "app_config")
class AppConfig {

  /**
   * id
   */
  @PrimaryKey(autoGenerate: true)
  final int? id;

  /**
   * 配置类型
   */
  @ColumnInfo(name: "type")
  String? type;

  /**
   * 配置内容
   */
  @ColumnInfo(name: "content")
  String? content;

  /**
   * 配置创建时间
   */
  @ColumnInfo(name: "createTime")
  int? createTime;

  /**
   * 配置更新时间
   */
  @ColumnInfo(name: "updateTime")
  int? updateTime;

  AppConfig(
      {this.id, this.type, this.content, this.createTime, this.updateTime});
}
