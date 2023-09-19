import '../runtime/runtime_value.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class LiteralExpression implements Expression {
  final RuntimeValue value;

  LiteralExpression(this.value);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLiteral(this);
  }
}