import '../token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class VariableExpression implements Expression {
  final Token name;

  VariableExpression(this.name) {
    if (name == null) throw ArgumentError.notNull('name');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitVariable(this);
  }
}