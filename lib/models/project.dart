import 'package:isar/isar.dart';

part 'project.g.dart';

@collection
class Project {
  Project({
    this.id = Isar.autoIncrement,
    required this.title,
    this.budget,
    DateTime? initialCreatedDate,
  }) : createdDate = initialCreatedDate ?? DateTime.now();

  Id id;
  String title;
  double? budget;
  DateTime createdDate;

  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project title is required';
    }
    return null;
  }
}
