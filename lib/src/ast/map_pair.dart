import '../parsing/token.dart';
import 'expression.dart';

class MapPair {
  final Expression key;
  final Expression value;
  final Token colon;

  MapPair(this.key, this.value, this.colon) {
    if (key == null) throw ArgumentError.notNull('key');
    if (value == null) throw ArgumentError.notNull('value');
    if (colon == null) throw ArgumentError.notNull('colon');
  }
}