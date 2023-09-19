import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class IndexExpression implements Expression {
  final Expression indexee;
  final Expression index;

  final Token openBracket;

  IndexExpression(this.indexee, this.index, this.openBracket);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitIndex(this);
  }
}