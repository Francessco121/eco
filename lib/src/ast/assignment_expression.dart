import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class AssignmentExpression implements Expression {
  final Expression target;
  final Expression value;

  final Token equalSign;

  AssignmentExpression(this.target, this.value, this.equalSign);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitAssignment(this);
  }
}