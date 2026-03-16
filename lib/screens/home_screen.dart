import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/item.dart';
import '../models/project.dart';
import '../providers/item_provider.dart';
import '../providers/project_provider.dart';
import '../providers/theme_provider.dart';
import '../services/home_widget_service.dart';
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
  late final ProviderSubscription<AsyncValue<List<Item>>> _widgetSyncSubscription;

  String get _title => _tabIndex == 0 ? 'SmartList' : 'Calendar';

  @override
  void initState() {
    super.initState();
    _widgetSyncSubscription = ref.listenManual<AsyncValue<List<Item>>>(
      allItemsProvider,
      (previous, next) {
        next.whenData(HomeWidgetService.updateFromItems);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _widgetSyncSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Theme mode',
            icon: const Icon(Icons.palette_outlined),
            initialValue: ref.watch(themeModeProvider),
            onSelected: (mode) => ref.read(themeModeProvider.notifier).state = mode,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
          ),
        ],
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
  DateTime _focusedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Item> _itemsForDay(List<Item> items, DateTime day) {
    return items.where((item) => item.targetDate != null && _isSameDay(item.targetDate!, day)).toList();
  }

  bool _isBeforeToday(DateTime date, DateTime today) {
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    return d.isBefore(t);
  }

  Color _markerColorForDay({
    required DateTime day,
    required List<Item> dayItems,
    required ColorScheme scheme,
  }) {
    final now = DateTime.now();
    final hasOverdue = dayItems.any((item) {
      final target = item.targetDate;
      return target != null && _isBeforeToday(target, now) && !item.isChecked && !item.isExcluded;
    });
    if (hasOverdue) {
      return const Color(0xFFE11D48); // red-ish
    }

    final isToday = _isSameDay(day, now);
    if (isToday) {
      return const Color(0xFFF59E0B); // amber
    }

    return scheme.tertiary; // future/default
  }

  _CalendarBucket _bucketForDate(DateTime date, DateTime today) {
    if (_isBeforeToday(date, today)) return _CalendarBucket.overdue;
    if (_isSameDay(date, today)) return _CalendarBucket.today;
    return _CalendarBucket.upcoming;
  }

  String _bucketTitle(_CalendarBucket bucket) {
    switch (bucket) {
      case _CalendarBucket.overdue:
        return 'Overdue';
      case _CalendarBucket.today:
        return 'Today';
      case _CalendarBucket.upcoming:
        return 'Upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final itemsAsync = ref.watch(allItemsProvider);

    return projectsAsync.when(
      data: (projects) => itemsAsync.when(
        data: (items) {
          final dateItems = _itemsForDay(items, _selectedDate)
            ..sort((a, b) => a.targetDate!.compareTo(b.targetDate!));
          final projectMap = {for (final project in projects) project.id: project.title};
          final now = DateTime.now();
          final grouped = {
            _CalendarBucket.overdue: <Item>[],
            _CalendarBucket.today: <Item>[],
            _CalendarBucket.upcoming: <Item>[],
          };
          for (final item in dateItems) {
            final target = item.targetDate;
            if (target == null) continue;
            grouped[_bucketForDate(target, now)]!.add(item);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TableCalendar<Item>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  focusedDay: _focusedDate,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  eventLoader: (day) => _itemsForDay(items, day),
                  calendarFormat: CalendarFormat.month,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focusedDate = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDate = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, dayItems) {
                      if (dayItems.isEmpty) return const SizedBox.shrink();
                      final color = _markerColorForDay(
                        day: day,
                        dayItems: dayItems,
                        scheme: Theme.of(context).colorScheme,
                      );

                      return Positioned(
                        bottom: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            dayItems.length > 3 ? 3 : dayItems.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    _LegendDot(color: Color(0xFFE11D48), label: 'Overdue'),
                    SizedBox(width: 12),
                    _LegendDot(color: Color(0xFFF59E0B), label: 'Today'),
                    SizedBox(width: 12),
                    _LegendDot(color: Color(0xFF2A9D8F), label: 'Upcoming'),
                  ],
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
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final bucket in [
                            _CalendarBucket.overdue,
                            _CalendarBucket.today,
                            _CalendarBucket.upcoming,
                          ]) ...[
                            if (grouped[bucket]!.isNotEmpty) ...[
                              Text(
                                _bucketTitle(bucket),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              for (final item in grouped[bucket]!) ...[
                                Card(
                                  child: ListTile(
                                    title: Text(item.name),
                                    subtitle: Text(
                                      '${projectMap[item.projectId] ?? 'Unknown Project'}${item.isExcluded ? ' • Excluded' : ''}',
                                    ),
                                    trailing: Text(
                                      formatCurrency(item.price),
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ],
                        ],
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

enum _CalendarBucket {
  overdue,
  today,
  upcoming,
}
