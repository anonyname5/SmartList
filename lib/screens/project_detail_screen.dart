import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/item.dart';
import '../models/project.dart';
import '../providers/item_provider.dart';
import '../utils/currency.dart';
import '../utils/item_filter_sort.dart';
import '../widgets/add_item_dialog.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({
    required this.project,
    super.key,
  });

  final Project project;

  @override
  ConsumerState<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ItemSortOption _sortOption = ItemSortOption.newest;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _sortLabel(ItemSortOption option) {
    switch (option) {
      case ItemSortOption.newest:
        return 'Newest';
      case ItemSortOption.name:
        return 'Name';
      case ItemSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case ItemSortOption.priceHighToLow:
        return 'Price: High to Low';
      case ItemSortOption.purchasedFirst:
        return 'Purchased First';
    }
  }

  List<String> _extractCategories(List<Item> items) {
    final categories = items
        .map((item) => item.category?.trim() ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final project = widget.project;
    final itemsAsync = ref.watch(projectItemsProvider(project.id));
    final planned = ref.watch(totalPlannedProvider(project.id));
    final bought = ref.watch(totalBoughtProvider(project.id));
    final remaining = ref.watch(remainingProvider(project.id));
    final budgetExceeded = project.budget != null && planned > project.budget!;

    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: budgetExceeded ? Colors.red.shade50 : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Total Planned', value: formatCurrency(planned)),
                    _SummaryRow(label: 'Total Bought', value: formatCurrency(bought)),
                    _SummaryRow(label: 'Remaining', value: formatCurrency(remaining)),
                    if (project.budget != null) ...[
                      const Divider(height: 24),
                      _SummaryRow(
                        label: 'Budget',
                        value: formatCurrency(project.budget!),
                      ),
                      _SummaryRow(
                        label: 'Remaining Budget',
                        value: formatCurrency(project.budget! - planned),
                      ),
                      if (budgetExceeded)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Warning: Total exceeds budget',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 260.ms).slideY(begin: -0.05, end: 0, duration: 260.ms),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      labelText: 'Search items',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<ItemSortOption>(
                  value: _sortOption,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sortOption = value);
                  },
                  items: ItemSortOption.values
                      .map(
                        (option) => DropdownMenuItem<ItemSortOption>(
                          value: option,
                          child: Text(_sortLabel(option)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 80.ms, duration: 240.ms),
          const SizedBox(height: 8),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final categories = _extractCategories(items);
                if (_selectedCategory != null && !categories.contains(_selectedCategory)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _selectedCategory = null);
                    }
                  });
                }

                final visibleItems = applyItemSearchAndSort(
                  items: items,
                  query: _searchQuery,
                  sortOption: _sortOption,
                  selectedCategory: _selectedCategory,
                );

                if (items.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No items yet.\nTap "Add Item" to create your checklist.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (visibleItems.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No items match your search.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (categories.isNotEmpty)
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: const Text('All'),
                                selected: _selectedCategory == null,
                                onSelected: (_) => setState(() => _selectedCategory = null),
                              ),
                            ),
                            ...categories.map(
                              (category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (_) => setState(() => _selectedCategory = category),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: visibleItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _ItemTile(
                          item: visibleItems[index],
                          index: index,
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Failed to load items: $error'),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => AddItemDialog(projectId: widget.project.id),
        ),
        label: const Text('Add Item'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            key: ValueKey('summary-${label.toLowerCase().replaceAll(' ', '-')}'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({
    required this.item,
    required this.index,
  });

  final Item item;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> showItemActions() async {
      final shouldToggleExclude = await showModalBottomSheet<bool>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(item.isExcluded ? Icons.undo : Icons.remove_circle_outline),
                title: Text(item.isExcluded ? 'Include item' : 'Exclude item'),
                subtitle: Text(
                  item.isExcluded
                      ? 'Include this item back into totals'
                      : 'Exclude this item from totals',
                ),
                onTap: () => Navigator.of(sheetContext).pop(true),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      );

      if (shouldToggleExclude == true) {
        await ref.read(itemActionsProvider).toggleExcluded(item);
      }
    }

    final subtitleParts = <String>[
      if (item.category != null && item.category!.isNotEmpty) item.category!,
      if (item.isExcluded) 'Excluded',
    ];

    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => showDialog<void>(
              context: context,
              builder: (_) => AddItemDialog(projectId: item.projectId, item: item),
            ),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) async {
              await ref.read(itemActionsProvider).delete(item.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: showItemActions,
        child: Opacity(
          opacity: item.isExcluded ? 0.55 : 1,
          child: Card(
            child: CheckboxListTile(
              value: item.isChecked,
              onChanged: item.isExcluded
                  ? null
                  : (_) async {
                      await ref.read(itemActionsProvider).toggleChecked(item);
                    },
              title: Text(
                item.name,
                style: TextStyle(
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
              secondary: Text(
                formatCurrency(item.price),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 35 * index))
        .fadeIn(duration: 220.ms)
        .slideX(begin: 0.04, end: 0, duration: 220.ms, curve: Curves.easeOutCubic);
  }
}
