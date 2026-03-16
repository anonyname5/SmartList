import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../services/item_repository.dart';
import '../utils/calculation.dart';
import 'database_provider.dart';

final projectItemsProvider = StreamProvider.family<List<Item>, int>((ref, projectId) async* {
  final isar = await ref.watch(databaseProvider.future);
  final repository = ItemRepository(isar);
  yield* repository.watchByProjectId(projectId);
});

final itemActionsProvider = Provider<ItemActions>((ref) {
  return ItemActionsImpl(ref);
});

abstract class ItemActions {
  Future<void> add({
    required int projectId,
    required String name,
    required double price,
    String? category,
  });

  Future<void> toggleChecked(Item item);

  Future<void> toggleExcluded(Item item);

  Future<void> update({
    required Item item,
    required String name,
    required double price,
    String? category,
  });

  Future<void> delete(int itemId);
}

class ItemActionsImpl implements ItemActions {
  ItemActionsImpl(this._ref);

  final Ref _ref;

  @override
  Future<void> add({
    required int projectId,
    required String name,
    required double price,
    String? category,
  }) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ItemRepository(isar);
    await repository.add(projectId: projectId, name: name, price: price, category: category);
  }

  @override
  Future<void> toggleChecked(Item item) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ItemRepository(isar);
    await repository.toggleChecked(item);
  }

  @override
  Future<void> toggleExcluded(Item item) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ItemRepository(isar);
    await repository.toggleExcluded(item);
  }

  @override
  Future<void> update({
    required Item item,
    required String name,
    required double price,
    String? category,
  }) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ItemRepository(isar);
    await repository.update(item: item, name: name, price: price, category: category);
  }

  @override
  Future<void> delete(int itemId) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ItemRepository(isar);
    await repository.delete(itemId);
  }
}

final totalPlannedProvider = Provider.family<double, int>((ref, projectId) {
  final itemsAsync = ref.watch(projectItemsProvider(projectId));
  return itemsAsync.maybeWhen(data: totalPlanned, orElse: () => 0.0);
});

final totalBoughtProvider = Provider.family<double, int>((ref, projectId) {
  final itemsAsync = ref.watch(projectItemsProvider(projectId));
  return itemsAsync.maybeWhen(data: totalBought, orElse: () => 0.0);
});

final remainingProvider = Provider.family<double, int>((ref, projectId) {
  final itemsAsync = ref.watch(projectItemsProvider(projectId));
  return itemsAsync.maybeWhen(data: remaining, orElse: () => 0.0);
});
