import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class WhenExpression implements Expression {
  final Expression expression;
  final Expression condition;
  final Token keyword;

  WhenExpression(this.expression, this.condition, this.keyword);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitWhen(this);
  }
}