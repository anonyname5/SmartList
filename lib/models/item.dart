import 'package:isar/isar.dart';

import '../utils/money.dart';
import '../utils/sync_id.dart';

part 'item.g.dart';

@collection
class Item {
  Item({
    this.id = Isar.autoIncrement,
    required this.projectId,
    String? initialProjectSyncId,
    required this.name,
    required double price,
    this.isChecked = false,
    this.isExcluded = false,
    this.targetDate,
    DateTime? initialCreatedAt,
    String? initialSyncId,
    DateTime? initialUpdatedAt,
    this.deletedAt,
    this.category,
  })  : priceCents = toCents(price),
        createdAt = initialCreatedAt ?? DateTime.now(),
        projectSyncId = initialProjectSyncId ?? 'project-$projectId',
        syncId = initialSyncId ?? newSyncId(),
        updatedAt = initialUpdatedAt ?? DateTime.now();

  Id id;
  @Index(unique: true)
  String syncId;

  @Index()
  int projectId;
  @Index()
  String projectSyncId;

  String name;
  int priceCents;
  bool isChecked;
  bool isExcluded;
  DateTime? targetDate;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
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
