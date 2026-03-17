import 'dart:math';

final _random = Random();

String newSyncId() {
  final ts = DateTime.now().microsecondsSinceEpoch;
  final rand = _random.nextInt(1 << 32);
  return '$ts-$rand';
}
