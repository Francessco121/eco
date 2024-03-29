import 'expression.dart';
import 'expression_visitor.dart';

class GroupingExpression implements Expression {
  final Expression expression;

  GroupingExpression(this.expression);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGrouping(this);
  }
}