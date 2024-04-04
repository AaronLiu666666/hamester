import 'flutter_data_base.dart';
import 'flutter_database_manager.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._();

  factory DatabaseProvider() => _instance;

  late final FlutterDataBase _database;

  DatabaseProvider._();

  Future<void> initializeDatabase() async {
    _database = await FlutterDataBaseManager.database();
  }

  FlutterDataBase get database => _database;
}