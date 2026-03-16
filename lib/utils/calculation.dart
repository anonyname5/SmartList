import '../models/item.dart';

double totalPlanned(List<Item> items) {
  return items.where((item) => !item.isExcluded).fold(0, (sum, item) => sum + item.price);
}

double totalBought(List<Item> items) {
  return items.where((item) => !item.isExcluded && item.isChecked).fold(0, (sum, item) => sum + item.price);
}

double remaining(List<Item> items) {
  return totalPlanned(items) - totalBought(items);
}
