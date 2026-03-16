int toCents(double amount) => (amount * 100).round();

double fromCents(int cents) => cents / 100.0;

int? parseToCents(String? input) {
  if (input == null) return null;
  final normalized = input.trim();
  if (normalized.isEmpty) return null;
  final parsed = double.tryParse(normalized);
  if (parsed == null) return null;
  if (parsed < 0) return null;
  return toCents(parsed);
}
