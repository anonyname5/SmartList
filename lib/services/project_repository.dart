import 'package:isar/isar.dart';

import '../models/item.dart';
import '../models/project.dart';

class ProjectRepository {
  ProjectRepository(this._isar);

  final Isar _isar;

  Stream<List<Project>> watchAll() {
    return _isar.projects.filter().deletedAtIsNull().sortByCreatedDateDesc().watch(fireImmediately: true);
  }

  Future<void> create({required String title, double? budget}) async {
    final project = Project(title: title.trim(), budget: budget);
    await _isar.writeTxn(() async {
      await _isar.projects.put(project);
    });
  }

  Future<void> update({
    required int projectId,
    required String title,
    double? budget,
  }) async {
    final project = await _isar.projects.get(projectId);
    if (project == null) return;

    project.title = title.trim();
    project.budget = budget;
    project.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.projects.put(project);
    });
  }

  Future<void> delete(int projectId) async {
    final project = await _isar.projects.get(projectId);
    if (project == null) return;
    final now = DateTime.now();

    await _isar.writeTxn(() async {
      final items = await _isar.items.filter().projectIdEqualTo(projectId).findAll();
      for (final item in items) {
        item.deletedAt = now;
        item.updatedAt = now;
        await _isar.items.put(item);
      }
      project.deletedAt = now;
      project.updatedAt = now;
      await _isar.projects.put(project);
    });
  }
}
