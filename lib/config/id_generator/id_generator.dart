import 'package:uuid/uuid.dart';

class UuidGenerator {
  static final Uuid _uuid = Uuid();

  UuidGenerator._internal();

  static String generateUuid() {
    return _uuid.v4();
  }
}
