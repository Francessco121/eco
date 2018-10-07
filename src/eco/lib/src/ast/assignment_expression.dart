import '../token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class AssignmentExpression implements Expression {
  final Expression target;
  final Expression value;

  final Token equalSign;

  AssignmentExpression(this.target, this.value, this.equalSign) {
    if (target == null) throw ArgumentError.notNull('target');
    if (value == null) throw ArgumentError.notNull('value');
    if (equalSign == null) throw ArgumentError.notNull('equalSign');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitAssignment(this);
  }
}