import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class GetExpression implements Expression {
  final Expression target;
  final Token name;
  final Token dot;

  GetExpression(this.target, this.name, this.dot);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGet(this);
  }
}