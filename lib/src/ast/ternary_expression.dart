import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class TernaryExpression implements Expression {
  final Expression condition;
  final Expression thenExpression;
  final Expression elseExpression;

  final Token questionMark;
  final Token colon;

  TernaryExpression({
    required this.condition, 
    required this.thenExpression, 
    required this.elseExpression,
    required this.questionMark,
    required this.colon
  });

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitTernary(this);
  }
}