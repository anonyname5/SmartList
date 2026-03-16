import '../models/item.dart';

enum ItemSortOption {
  newest,
  name,
  priceLowToHigh,
  priceHighToLow,
  purchasedFirst,
}

List<Item> applyItemSearchAndSort({
  required List<Item> items,
  required String query,
  required ItemSortOption sortOption,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final filtered = items.where((item) {
    if (normalizedQuery.isEmpty) return true;
    return item.name.toLowerCase().contains(normalizedQuery) ||
        (item.category?.toLowerCase().contains(normalizedQuery) ?? false);
  }).toList();

  switch (sortOption) {
    case ItemSortOption.newest:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case ItemSortOption.name:
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case ItemSortOption.priceLowToHigh:
      filtered.sort((a, b) => a.priceCents.compareTo(b.priceCents));
      break;
    case ItemSortOption.priceHighToLow:
      filtered.sort((a, b) => b.priceCents.compareTo(a.priceCents));
      break;
    case ItemSortOption.purchasedFirst:
      filtered.sort((a, b) {
        if (a.isChecked == b.isChecked) {
          return b.createdAt.compareTo(a.createdAt);
        }
        return a.isChecked ? -1 : 1;
      });
      break;
  }

  return filtered;
}
