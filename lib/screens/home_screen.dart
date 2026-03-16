import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/project.dart';
import '../providers/item_provider.dart';
import '../providers/project_provider.dart';
import '../utils/calculation.dart';
import '../utils/currency.dart';
import '../widgets/create_project_dialog.dart';
import 'project_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  String get _title => _tabIndex == 0 ? 'SmartList' : 'Calendar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: _tabIndex == 0 ? const _ProjectsTab() : const _CalendarTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const CreateProjectDialog(),
              ),
              label: const Text('Create Project'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _ProjectsTab extends ConsumerWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No projects yet.\nTap "Create Project" to get started.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ProjectCard(
            project: projects[index],
            index: index,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load projects: $error'),
        ),
      ),
    );
  }
}

class _CalendarTab extends ConsumerStatefulWidget {
  const _CalendarTab();

  @override
  ConsumerState<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends ConsumerState<_CalendarTab> {
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final itemsAsync = ref.watch(allItemsProvider);

    return projectsAsync.when(
      data: (projects) => itemsAsync.when(
        data: (items) {
          final dateItems = items.where((item) => item.targetDate != null && _isSameDay(item.targetDate!, _selectedDate)).toList()
            ..sort((a, b) => a.targetDate!.compareTo(b.targetDate!));
          final projectMap = {for (final project in projects) project.id: project.title};

          return Column(
            children: [
              CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                onDateChanged: (date) => setState(() => _selectedDate = date),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Items on ${DateFormat.yMMMd().format(_selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: dateItems.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No target items for this date.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: dateItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = dateItems[index];
                          final projectTitle = projectMap[item.projectId] ?? 'Unknown Project';
                          return Card(
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Text(
                                '$projectTitle${item.isExcluded ? ' • Excluded' : ''}',
                              ),
                              trailing: Text(
                                formatCurrency(item.price),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load items: $error'),
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Failed to load projects: $error'),
        ),
      ),
    );
  }
}

class _ProjectCard extends ConsumerWidget {
  const _ProjectCard({
    required this.project,
    required this.index,
  });

  final Project project;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(projectItemsProvider(project.id));

    final itemCount = itemsAsync.maybeWhen(data: (items) => items.length, orElse: () => 0);
    final planned = itemsAsync.maybeWhen(data: totalPlanned, orElse: () => 0.0);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit project',
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => CreateProjectDialog(project: project),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete project',
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete project?'),
                          content: Text('Delete "${project.title}" and all its items?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        await ref.read(projectActionsProvider).delete(project.id);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Total Planned: ${formatCurrency(planned)}'),
              Text('Items: $itemCount'),
              if (project.budget != null) ...[
                const SizedBox(height: 4),
                Text('Budget: ${formatCurrency(project.budget!)}'),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 45 * index))
        .fadeIn(duration: 260.ms)
        .slideY(begin: 0.08, end: 0, duration: 260.ms, curve: Curves.easeOutCubic);
  }
}
