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
    DateTime? targetDate,
  }) async {
    final item = Item(
      projectId: projectId,
      name: name.trim(),
      price: price,
      category: category?.trim().isEmpty == true ? null : category?.trim(),
      targetDate: targetDate,
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

  Future<void> toggleExcluded(Item item) async {
    await _isar.writeTxn(() async {
      item.isExcluded = !item.isExcluded;
      await _isar.items.put(item);
    });
  }

  Future<void> update({
    required Item item,
    required String name,
    required double price,
    String? category,
    DateTime? targetDate,
  }) async {
    await _isar.writeTxn(() async {
      item.name = name.trim();
      item.price = price;
      item.category = category?.trim().isEmpty == true ? null : category?.trim();
      item.targetDate = targetDate;
      await _isar.items.put(item);
    });
  }

  Future<void> delete(int itemId) async {
    await _isar.writeTxn(() async {
      await _isar.items.delete(itemId);
    });
  }
}
