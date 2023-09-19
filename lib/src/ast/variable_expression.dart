import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class VariableExpression implements Expression {
  final Token name;

  VariableExpression(this.name);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitVariable(this);
  }
}