import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class WhenExpression implements Expression {
  final Expression expression;
  final Expression condition;
  final Token keyword;

  WhenExpression(this.expression, this.condition, this.keyword) {
    if (expression == null) throw ArgumentError.notNull('expression');
    if (condition == null) throw ArgumentError.notNull('condition');
    if (keyword == null) throw ArgumentError.notNull('keyword');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitWhen(this);
  }
}