import 'package:isar/isar.dart';

import '../utils/money.dart';

part 'item.g.dart';

@collection
class Item {
  Item({
    this.id = Isar.autoIncrement,
    required this.projectId,
    required this.name,
    required double price,
    this.isChecked = false,
    this.isExcluded = false,
    DateTime? initialCreatedAt,
    this.category,
  })  : priceCents = toCents(price),
        createdAt = initialCreatedAt ?? DateTime.now();

  Id id;

  @Index()
  int projectId;

  String name;
  int priceCents;
  bool isChecked;
  bool isExcluded;
  DateTime createdAt;
  String? category;

  double get price => fromCents(priceCents);

  set price(double value) {
    priceCents = toCents(value);
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Item name is required';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null) {
      return 'Enter a valid price';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid price';
    }
    if (parsed < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }
}
