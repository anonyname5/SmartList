import 'package:isar/isar.dart';

import '../utils/money.dart';

part 'project.g.dart';

@collection
class Project {
  Project({
    this.id = Isar.autoIncrement,
    required this.title,
    double? budget,
    DateTime? initialCreatedDate,
  })  : budgetCents = budget == null ? null : toCents(budget),
        createdDate = initialCreatedDate ?? DateTime.now();

  Id id;
  String title;
  int? budgetCents;
  DateTime createdDate;

  double? get budget => budgetCents == null ? null : fromCents(budgetCents!);

  set budget(double? value) {
    budgetCents = value == null ? null : toCents(value);
  }

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project title is required';
    }
    return null;
  }

  static String? validateBudget(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text);
    if (parsed == null || parsed < 0) {
      return 'Enter a valid budget';
    }
    return null;
  }
}
