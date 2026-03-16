import 'package:isar/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Item({
    this.id = Isar.autoIncrement,
    required this.projectId,
    required this.name,
    required this.price,
    this.isChecked = false,
    DateTime? initialCreatedAt,
    this.category,
  }) : createdAt = initialCreatedAt ?? DateTime.now();

  Id id;

  @Index()
  int projectId;

  String name;
  double price;
  bool isChecked;
  DateTime createdAt;
  String? category;

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
