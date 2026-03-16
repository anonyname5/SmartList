import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartlist/models/item.dart';
import 'package:smartlist/models/project.dart';
import 'package:smartlist/providers/item_provider.dart';
import 'package:smartlist/providers/project_provider.dart';
import 'package:smartlist/screens/home_screen.dart';
import 'package:smartlist/screens/project_detail_screen.dart';

class FakeProjectActions implements ProjectActions {
  String? lastCreatedTitle;
  double? lastCreatedBudget;

  @override
  Future<void> create({required String title, double? budget}) async {
    lastCreatedTitle = title;
    lastCreatedBudget = budget;
  }

  @override
  Future<void> delete(int projectId) async {}

  @override
  Future<void> update({
    required int projectId,
    required String title,
    double? budget,
  }) async {}
}

class FakeItemActions implements ItemActions {
  FakeItemActions(List<Item> initialItems)
      : _items = [...initialItems],
        _nextId = (initialItems.map((item) => item.id).fold<int>(0, (a, b) => a > b ? a : b)) + 1;

  final List<Item> _items;
  final StreamController<List<Item>> _controller = StreamController<List<Item>>.broadcast();
  int _nextId;
  int addCalls = 0;
  int toggleCalls = 0;
  int toggleExcludedCalls = 0;

  Stream<List<Item>> get stream async* {
    yield List.unmodifiable(_items);
    yield* _controller.stream;
  }

  void dispose() {
    _controller.close();
  }

  void _emit() {
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> add({
    required int projectId,
    required String name,
    required double price,
    String? category,
  }) async {
    addCalls += 1;
    final item = Item(
      projectId: projectId,
      name: name,
      price: price,
      category: category,
      initialCreatedAt: DateTime.now(),
    )..id = _nextId++;
    _items.add(item);
    _emit();
  }

  @override
  Future<void> delete(int itemId) async {
    _items.removeWhere((item) => item.id == itemId);
    _emit();
  }

  @override
  Future<void> toggleChecked(Item item) async {
    toggleCalls += 1;
    final idx = _items.indexWhere((it) => it.id == item.id);
    if (idx >= 0) {
      _items[idx].isChecked = !_items[idx].isChecked;
      _emit();
    }
  }

  @override
  Future<void> toggleExcluded(Item item) async {
    toggleExcludedCalls += 1;
    final idx = _items.indexWhere((it) => it.id == item.id);
    if (idx >= 0) {
      _items[idx].isExcluded = !_items[idx].isExcluded;
      _emit();
    }
  }

  @override
  Future<void> update({
    required Item item,
    required String name,
    required double price,
    String? category,
  }) async {
    final idx = _items.indexWhere((it) => it.id == item.id);
    if (idx >= 0) {
      _items[idx]
        ..name = name
        ..price = price
        ..category = category;
      _emit();
    }
  }
}

Widget _wrap(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('Create project flow calls action with form values', (tester) async {
    final fakeActions = FakeProjectActions();

    await tester.pumpWidget(
      _wrap(
        const HomeScreen(),
        [
          projectsProvider.overrideWith((ref) => Stream.value([])),
          projectActionsProvider.overrideWithValue(fakeActions),
        ],
      ),
    );

    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Room Renovation');
    await tester.enterText(find.byType(TextFormField).at(1), '500');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(fakeActions.lastCreatedTitle, 'Room Renovation');
    expect(fakeActions.lastCreatedBudget, 500);
  });

  testWidgets('Add item flow adds an item and shows it', (tester) async {
    final project = Project(title: 'Test Project')..id = 1;
    final fakeItemActions = FakeItemActions([]);

    addTearDown(fakeItemActions.dispose);

    await tester.pumpWidget(
      _wrap(
        ProjectDetailScreen(project: project),
        [
          projectItemsProvider.overrideWith((ref, projectId) => fakeItemActions.stream),
          itemActionsProvider.overrideWithValue(fakeItemActions),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Item').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Paint');
    await tester.enterText(find.byType(TextFormField).at(1), '120');
    await tester.enterText(find.byType(TextFormField).at(2), 'Decoration');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fakeItemActions.addCalls, 1);
    expect(find.text('Paint'), findsOneWidget);
  });

  testWidgets('Toggling checkbox updates totals on screen', (tester) async {
    final project = Project(title: 'Totals Project')..id = 9;
    final initialItems = [
      Item(
        projectId: 9,
        name: 'Paint',
        price: 60,
        initialCreatedAt: DateTime(2026, 1, 1),
      )..id = 1,
      Item(
        projectId: 9,
        name: 'Lamp',
        price: 40,
        isChecked: true,
        initialCreatedAt: DateTime(2026, 1, 2),
      )..id = 2,
    ];
    final fakeItemActions = FakeItemActions(initialItems);

    addTearDown(fakeItemActions.dispose);

    await tester.pumpWidget(
      _wrap(
        ProjectDetailScreen(project: project),
        [
          projectItemsProvider.overrideWith((ref, projectId) => fakeItemActions.stream),
          itemActionsProvider.overrideWithValue(fakeItemActions),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Text boughtText = tester.widget<Text>(find.byKey(const ValueKey('summary-total-bought')));
    expect(boughtText.data ?? '', contains('40.00'));

    await tester.tap(find.text('Paint'));
    await tester.pumpAndSettle();

    expect(fakeItemActions.toggleCalls, 1);

    boughtText = tester.widget<Text>(find.byKey(const ValueKey('summary-total-bought')));
    final remainingText = tester.widget<Text>(find.byKey(const ValueKey('summary-remaining')));
    expect(boughtText.data ?? '', contains('100.00'));
    expect(remainingText.data ?? '', contains('0.00'));
  });

  testWidgets('Long press exclude removes item from totals', (tester) async {
    final project = Project(title: 'Exclude Project')..id = 11;
    final initialItems = [
      Item(
        projectId: 11,
        name: 'Paint',
        price: 60,
        initialCreatedAt: DateTime(2026, 1, 1),
      )..id = 1,
      Item(
        projectId: 11,
        name: 'Lamp',
        price: 40,
        initialCreatedAt: DateTime(2026, 1, 2),
      )..id = 2,
    ];
    final fakeItemActions = FakeItemActions(initialItems);
    addTearDown(fakeItemActions.dispose);

    await tester.pumpWidget(
      _wrap(
        ProjectDetailScreen(project: project),
        [
          projectItemsProvider.overrideWith((ref, projectId) => fakeItemActions.stream),
          itemActionsProvider.overrideWithValue(fakeItemActions),
        ],
      ),
    );
    await tester.pumpAndSettle();

    Text plannedText = tester.widget<Text>(find.byKey(const ValueKey('summary-total-planned')));
    expect(plannedText.data ?? '', contains('100.00'));

    await tester.longPress(find.text('Paint'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Exclude item'));
    await tester.pumpAndSettle();

    expect(fakeItemActions.toggleExcludedCalls, 1);
    plannedText = tester.widget<Text>(find.byKey(const ValueKey('summary-total-planned')));
    expect(plannedText.data ?? '', contains('40.00'));
  });
}
