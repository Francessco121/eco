import '../parsing/token.dart';
import 'expression.dart';

class MapPair {
  final Expression key;
  final Expression value;
  final Token colon;

  MapPair(this.key, this.value, this.colon);
}