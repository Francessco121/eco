import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class UnaryExpression implements Expression {
  final Expression expression;
  final Token $operator;

  UnaryExpression(this.expression, this.$operator) {
    if (expression == null) throw ArgumentError.notNull('expression');
    if ($operator == null) throw ArgumentError.notNull('\$operator');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitUnary(this);
  }
}