import 'package:isar/isar.dart';

import '../models/item.dart';
import '../models/project.dart';

class ItemRepository {
  ItemRepository(this._isar);

  final Isar _isar;

  Stream<List<Item>> watchAll() {
    return _isar.items.filter().deletedAtIsNull().sortByCreatedAt().watch(fireImmediately: true);
  }

  Stream<List<Item>> watchByProjectId(int projectId) {
    return _isar.items
        .filter()
        .projectIdEqualTo(projectId)
        .and()
        .deletedAtIsNull()
        .sortByCreatedAt()
        .watch(fireImmediately: true);
  }

  Future<void> add({
    required int projectId,
    required String name,
    required double price,
    String? category,
    DateTime? targetDate,
  }) async {
    final project = await _isar.projects.get(projectId);
    if (project == null) return;

    final item = Item(
      projectId: projectId,
      initialProjectSyncId: project.syncId,
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
      item.updatedAt = DateTime.now();
      await _isar.items.put(item);
    });
  }

  Future<void> toggleExcluded(Item item) async {
    await _isar.writeTxn(() async {
      item.isExcluded = !item.isExcluded;
      item.updatedAt = DateTime.now();
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
      item.updatedAt = DateTime.now();
      await _isar.items.put(item);
    });
  }

  Future<void> delete(int itemId) async {
    final item = await _isar.items.get(itemId);
    if (item == null) return;

    await _isar.writeTxn(() async {
      item.deletedAt = DateTime.now();
      item.updatedAt = DateTime.now();
      await _isar.items.put(item);
    });
  }
}
