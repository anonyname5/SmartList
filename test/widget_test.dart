// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:smartlist/models/item.dart';
import 'package:smartlist/utils/calculation.dart';

void main() {
  test('Calculation logic computes totals correctly', () {
    final items = [
      Item(projectId: 1, name: 'Paint', price: 120),
      Item(projectId: 1, name: 'Curtain', price: 80),
      Item(projectId: 1, name: 'Lamp', price: 45, isChecked: true),
    ];

    expect(totalPlanned(items), 245);
    expect(totalBought(items), 45);
    expect(remaining(items), 200);
  });
}
