import 'expression.dart';
import 'expression_visitor.dart';

class ArrayExpression implements Expression {
  final List<Expression> values;

  ArrayExpression(this.values);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitArray(this);
  }
}