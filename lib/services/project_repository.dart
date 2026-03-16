import 'package:isar/isar.dart';

import '../models/item.dart';
import '../models/project.dart';

class ProjectRepository {
  ProjectRepository(this._isar);

  final Isar _isar;

  Stream<List<Project>> watchAll() {
    return _isar.projects.where().sortByCreatedDateDesc().watch(fireImmediately: true);
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

    await _isar.writeTxn(() async {
      await _isar.projects.put(project);
    });
  }

  Future<void> delete(int projectId) async {
    await _isar.writeTxn(() async {
      await _isar.items.filter().projectIdEqualTo(projectId).deleteAll();
      await _isar.projects.delete(projectId);
    });
  }
}
