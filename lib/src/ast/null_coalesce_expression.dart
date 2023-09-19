import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class NullCoalesceExpression implements Expression {
  final Expression left;
  final Expression right;

  final Token symbol;

  NullCoalesceExpression(this.left, this.right, this.symbol);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitNullCoalesce(this);
  }
}