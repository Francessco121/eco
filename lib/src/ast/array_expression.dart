import 'expression.dart';
import 'expression_visitor.dart';

class ArrayExpression implements Expression {
  final List<Expression> values;

  ArrayExpression(this.values) {
    if (values == null) throw ArgumentError.notNull('values');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitArray(this);
  }
}