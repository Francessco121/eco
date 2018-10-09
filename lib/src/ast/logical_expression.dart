import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class LogicalExpression implements Expression {
  final Expression left;
  final Expression right;
  final Token $operator;

  LogicalExpression(this.left, this.right, this.$operator) {
    if (left == null) throw ArgumentError.notNull('left');
    if (right == null) throw ArgumentError.notNull('right');
    if ($operator == null) throw ArgumentError.notNull('\$operator');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLogical(this);
  }
}