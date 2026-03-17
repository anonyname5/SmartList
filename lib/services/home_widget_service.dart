import 'package:home_widget/home_widget.dart';

import '../models/item.dart';
import '../utils/calculation.dart';
import '../utils/currency.dart';

class HomeWidgetService {
  static const _providerNames = <String>[
    'SmartListHomeWidgetProvider',
    'SmartListCompactWidgetProvider',
  ];

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Future<void> updateFromItems(List<Item> items) async {
    final now = DateTime.now();
    final todayTargetCount = items.where((item) => item.targetDate != null && _isSameDay(item.targetDate!, now)).length;
    final planned = totalPlanned(items);
    final bought = totalBought(items);
    final remainingTotal = remaining(items);

    await HomeWidget.saveWidgetData<String>('smartlist_title', 'SmartList');
    await HomeWidget.saveWidgetData<String>('smartlist_today_targets', '$todayTargetCount');
    await HomeWidget.saveWidgetData<String>('smartlist_planned', formatCurrency(planned));
    await HomeWidget.saveWidgetData<String>('smartlist_bought', formatCurrency(bought));
    await HomeWidget.saveWidgetData<String>('smartlist_remaining', formatCurrency(remainingTotal));

    for (final providerName in _providerNames) {
      await HomeWidget.updateWidget(name: providerName);
    }
  }
}
