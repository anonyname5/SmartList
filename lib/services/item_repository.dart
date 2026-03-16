import 'package:isar/isar.dart';

import '../models/item.dart';

class ItemRepository {
  ItemRepository(this._isar);

  final Isar _isar;

  Stream<List<Item>> watchByProjectId(int projectId) {
    return _isar.items.filter().projectIdEqualTo(projectId).sortByCreatedAt().watch(fireImmediately: true);
  }

  Future<void> add({
    required int projectId,
    required String name,
    required double price,
    String? category,
  }) async {
    final item = Item(
      projectId: projectId,
      name: name.trim(),
      price: price,
      category: category?.trim().isEmpty == true ? null : category?.trim(),
    );

    await _isar.writeTxn(() async {
      await _isar.items.put(item);
    });
  }

  Future<void> toggleChecked(Item item) async {
    await _isar.writeTxn(() async {
      item.isChecked = !item.isChecked;
      await _isar.items.put(item);
    });
  }

  Future<void> delete(int itemId) async {
    await _isar.writeTxn(() async {
      await _isar.items.delete(itemId);
    });
  }
}
