import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/item.dart';
import '../models/project.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Isar? _isar;

  Future<Isar> open() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ProjectSchema, ItemSchema],
      directory: dir.path,
      name: 'smartlist_db',
    );
    return _isar!;
  }

  Future<void> close() async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      await isar.close();
      _isar = null;
    }
  }
}
