import 'package:intl/intl.dart';

const defaultCurrencySymbol = 'RM';

final _currencyFormatter = NumberFormat.currency(symbol: defaultCurrencySymbol, decimalDigits: 2);

String formatCurrency(double value) => _currencyFormatter.format(value);
