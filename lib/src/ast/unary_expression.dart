import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class UnaryExpression implements Expression {
  final Expression expression;
  final Token $operator;

  UnaryExpression(this.expression, this.$operator);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitUnary(this);
  }
}