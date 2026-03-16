import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import '../services/project_repository.dart';
import 'database_provider.dart';

final projectsProvider = StreamProvider<List<Project>>((ref) async* {
  final isar = await ref.watch(databaseProvider.future);
  final repository = ProjectRepository(isar);
  yield* repository.watchAll();
});

final projectActionsProvider = Provider<ProjectActions>((ref) {
  return ProjectActionsImpl(ref);
});

abstract class ProjectActions {
  Future<void> create({
    required String title,
    double? budget,
  });

  Future<void> update({
    required int projectId,
    required String title,
    double? budget,
  });

  Future<void> delete(int projectId);
}

class ProjectActionsImpl implements ProjectActions {
  ProjectActionsImpl(this._ref);

  final Ref _ref;

  @override
  Future<void> create({
    required String title,
    double? budget,
  }) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ProjectRepository(isar);
    await repository.create(title: title, budget: budget);
  }

  @override
  Future<void> update({
    required int projectId,
    required String title,
    double? budget,
  }) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ProjectRepository(isar);
    await repository.update(projectId: projectId, title: title, budget: budget);
  }

  @override
  Future<void> delete(int projectId) async {
    final isar = await _ref.read(databaseProvider.future);
    final repository = ProjectRepository(isar);
    await repository.delete(projectId);
  }
}
