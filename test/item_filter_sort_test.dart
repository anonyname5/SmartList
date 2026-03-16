import 'package:flutter_test/flutter_test.dart';
import 'package:smartlist/models/item.dart';
import 'package:smartlist/utils/item_filter_sort.dart';

void main() {
  final items = [
    Item(
      projectId: 1,
      name: 'Paint',
      price: 120,
      category: 'Decoration',
      initialCreatedAt: DateTime(2026, 1, 1),
    ),
    Item(
      projectId: 1,
      name: 'Lamp',
      price: 45,
      isChecked: true,
      category: 'Lighting',
      initialCreatedAt: DateTime(2026, 1, 2),
    ),
    Item(
      projectId: 1,
      name: 'Curtain',
      price: 80,
      category: 'Decoration',
      initialCreatedAt: DateTime(2026, 1, 3),
    ),
  ];

  test('Filters by query against name', () {
    final result = applyItemSearchAndSort(
      items: items,
      query: 'lam',
      sortOption: ItemSortOption.newest,
    );

    expect(result.length, 1);
    expect(result.first.name, 'Lamp');
  });

  test('Filters by query against category', () {
    final result = applyItemSearchAndSort(
      items: items,
      query: 'deco',
      sortOption: ItemSortOption.newest,
    );

    expect(result.length, 2);
  });

  test('Filters by selected category chip', () {
    final result = applyItemSearchAndSort(
      items: items,
      query: '',
      sortOption: ItemSortOption.newest,
      selectedCategory: 'Lighting',
    );

    expect(result.length, 1);
    expect(result.first.name, 'Lamp');
  });

  test('Sorts by price low to high', () {
    final result = applyItemSearchAndSort(
      items: items,
      query: '',
      sortOption: ItemSortOption.priceLowToHigh,
    );

    expect(result.map((e) => e.name).toList(), ['Lamp', 'Curtain', 'Paint']);
  });

  test('Sorts purchased first', () {
    final result = applyItemSearchAndSort(
      items: items,
      query: '',
      sortOption: ItemSortOption.purchasedFirst,
    );

    expect(result.first.isChecked, true);
    expect(result.first.name, 'Lamp');
  });
}
