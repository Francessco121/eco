import 'expression.dart';
import 'expression_visitor.dart';
import 'map_pair.dart';

class MapExpression implements Expression {
  final List<MapPair> pairs;

  MapExpression(this.pairs) {
    if (pairs == null) throw ArgumentError.notNull('pairs');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitMap(this);
  }
}