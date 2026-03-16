import 'package:flutter_test/flutter_test.dart';
import 'package:smartlist/models/item.dart';
import 'package:smartlist/models/project.dart';
import 'package:smartlist/utils/calculation.dart';
import 'package:smartlist/utils/money.dart';

void main() {
  test('Money conversion to cents is stable', () {
    expect(toCents(12.345), 1235);
    expect(toCents(10.999), 1100);
    expect(fromCents(1999), 19.99);
  });

  test('Item price stores as cents', () {
    final item = Item(projectId: 1, name: 'Cable', price: 12.345);
    expect(item.priceCents, 1235);
    expect(item.price, 12.35);
  });

  test('Project budget stores as cents', () {
    final project = Project(title: 'Budget Test', budget: 99.995);
    expect(project.budgetCents, 10000);
    expect(project.budget, 100.0);
  });

  test('Calculation logic remains correct with cent-backed model', () {
    final items = [
      Item(projectId: 1, name: 'Paint', price: 120),
      Item(projectId: 1, name: 'Curtain', price: 80.155),
      Item(projectId: 1, name: 'Lamp', price: 45, isChecked: true),
    ];

    expect(totalPlanned(items), 245.16);
    expect(totalBought(items), 45);
    expect(remaining(items), 200.16);
  });

  test('Excluded items are ignored in totals', () {
    final items = [
      Item(projectId: 1, name: 'Paint', price: 120),
      Item(projectId: 1, name: 'Curtain', price: 80, isExcluded: true),
      Item(projectId: 1, name: 'Lamp', price: 45, isChecked: true),
    ];

    expect(totalPlanned(items), 165);
    expect(totalBought(items), 45);
    expect(remaining(items), 120);
  });
}
