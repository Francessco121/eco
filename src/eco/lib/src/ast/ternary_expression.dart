import 'package:meta/meta.dart';

import '../token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class TernaryExpression implements Expression {
  final Expression condition;
  final Expression thenExpression;
  final Expression elseExpression;

  final Token questionMark;
  final Token colon;

  TernaryExpression({
    @required this.condition, 
    @required this.thenExpression, 
    @required this.elseExpression,
    @required this.questionMark,
    @required this.colon
  }) {
    if (condition == null) throw ArgumentError.notNull('condition');
    if (thenExpression == null) throw ArgumentError.notNull('thenExpression');
    if (elseExpression == null) throw ArgumentError.notNull('elseExpression');
    if (questionMark == null) throw ArgumentError.notNull('questionMark');
    if (colon == null) throw ArgumentError.notNull('colon');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitTernary(this);
  }
}