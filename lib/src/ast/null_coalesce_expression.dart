import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class NullCoalesceExpression implements Expression {
  final Expression left;
  final Expression right;

  final Token symbol;

  NullCoalesceExpression(this.left, this.right, this.symbol) {
    if (left == null) throw ArgumentError.notNull('left');
    if (right == null) throw ArgumentError.notNull('right');
    if (symbol == null) throw ArgumentError.notNull('symbol');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitNullCoalesce(this);
  }
}