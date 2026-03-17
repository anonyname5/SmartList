import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';

import '../models/item.dart';
import '../models/project.dart';
import 'auth_service.dart';

class SyncSummary {
  const SyncSummary({
    required this.uploadedProjects,
    required this.uploadedItems,
    required this.downloadedProjects,
    required this.downloadedItems,
  });

  final int uploadedProjects;
  final int uploadedItems;
  final int downloadedProjects;
  final int downloadedItems;
}

class SyncService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<SyncSummary> syncNow(Isar isar) async {
    await AuthService.ensureAnonymousSignIn();
    final uid = _auth.currentUser!.uid;

    final projectsCol = _firestore.collection('users').doc(uid).collection('projects');
    final itemsCol = _firestore.collection('users').doc(uid).collection('items');

    int downloadedProjects = 0;
    int downloadedItems = 0;
    int uploadedProjects = 0;
    int uploadedItems = 0;

    final projectDocs = await projectsCol.get();
    await isar.writeTxn(() async {
      for (final doc in projectDocs.docs) {
        final data = doc.data();
        final syncId = data['syncId'] as String? ?? doc.id;
        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final deletedAt = (data['deletedAt'] as Timestamp?)?.toDate();

        final local = await isar.projects.filter().syncIdEqualTo(syncId).findFirst();
        if (local == null) {
          final project = Project(
            title: data['title'] as String? ?? 'Untitled',
            budget: (data['budgetCents'] as int?) != null ? (data['budgetCents'] as int) / 100.0 : null,
            initialCreatedDate: (data['createdDate'] as Timestamp?)?.toDate(),
            initialSyncId: syncId,
            initialUpdatedAt: updatedAt,
            deletedAt: deletedAt,
          );
          await isar.projects.put(project);
          downloadedProjects++;
        } else if (updatedAt.isAfter(local.updatedAt)) {
          local.title = data['title'] as String? ?? local.title;
          local.budgetCents = data['budgetCents'] as int?;
          local.createdDate = (data['createdDate'] as Timestamp?)?.toDate() ?? local.createdDate;
          local.updatedAt = updatedAt;
          local.deletedAt = deletedAt;
          await isar.projects.put(local);
          downloadedProjects++;
        }
      }
    });

    final itemDocs = await itemsCol.get();
    await isar.writeTxn(() async {
      for (final doc in itemDocs.docs) {
        final data = doc.data();
        final syncId = data['syncId'] as String? ?? doc.id;
        final projectSyncId = data['projectSyncId'] as String?;
        if (projectSyncId == null) continue;

        final project = await isar.projects.filter().syncIdEqualTo(projectSyncId).findFirst();
        if (project == null) continue;

        final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final deletedAt = (data['deletedAt'] as Timestamp?)?.toDate();

        final local = await isar.items.filter().syncIdEqualTo(syncId).findFirst();
        if (local == null) {
          final item = Item(
            projectId: project.id,
            initialProjectSyncId: projectSyncId,
            name: data['name'] as String? ?? 'Untitled',
            price: ((data['priceCents'] as int?) ?? 0) / 100.0,
            isChecked: data['isChecked'] as bool? ?? false,
            isExcluded: data['isExcluded'] as bool? ?? false,
            targetDate: (data['targetDate'] as Timestamp?)?.toDate(),
            initialCreatedAt: (data['createdAt'] as Timestamp?)?.toDate(),
            initialSyncId: syncId,
            initialUpdatedAt: updatedAt,
            deletedAt: deletedAt,
            category: data['category'] as String?,
          );
          await isar.items.put(item);
          downloadedItems++;
        } else if (updatedAt.isAfter(local.updatedAt)) {
          local.projectId = project.id;
          local.projectSyncId = projectSyncId;
          local.name = data['name'] as String? ?? local.name;
          local.priceCents = (data['priceCents'] as int?) ?? local.priceCents;
          local.isChecked = data['isChecked'] as bool? ?? local.isChecked;
          local.isExcluded = data['isExcluded'] as bool? ?? local.isExcluded;
          local.targetDate = (data['targetDate'] as Timestamp?)?.toDate();
          local.createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? local.createdAt;
          local.updatedAt = updatedAt;
          local.deletedAt = deletedAt;
          local.category = data['category'] as String?;
          await isar.items.put(local);
          downloadedItems++;
        }
      }
    });

    final localProjects = await isar.projects.where().findAll();
    for (final project in localProjects) {
      await projectsCol.doc(project.syncId).set({
        'syncId': project.syncId,
        'title': project.title,
        'budgetCents': project.budgetCents,
        'createdDate': Timestamp.fromDate(project.createdDate),
        'updatedAt': Timestamp.fromDate(project.updatedAt),
        'deletedAt': project.deletedAt == null ? null : Timestamp.fromDate(project.deletedAt!),
      }, SetOptions(merge: true));
      uploadedProjects++;
    }

    final localItems = await isar.items.where().findAll();
    for (final item in localItems) {
      await itemsCol.doc(item.syncId).set({
        'syncId': item.syncId,
        'projectSyncId': item.projectSyncId,
        'name': item.name,
        'priceCents': item.priceCents,
        'isChecked': item.isChecked,
        'isExcluded': item.isExcluded,
        'targetDate': item.targetDate == null ? null : Timestamp.fromDate(item.targetDate!),
        'createdAt': Timestamp.fromDate(item.createdAt),
        'updatedAt': Timestamp.fromDate(item.updatedAt),
        'deletedAt': item.deletedAt == null ? null : Timestamp.fromDate(item.deletedAt!),
        'category': item.category,
      }, SetOptions(merge: true));
      uploadedItems++;
    }

    return SyncSummary(
      uploadedProjects: uploadedProjects,
      uploadedItems: uploadedItems,
      downloadedProjects: downloadedProjects,
      downloadedItems: downloadedItems,
    );
  }
}
