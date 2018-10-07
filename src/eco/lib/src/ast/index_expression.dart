import '../token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class IndexExpression implements Expression {
  final Expression indexee;
  final Expression index;

  final Token openBracket;

  IndexExpression(this.indexee, this.index, this.openBracket) {
    if (indexee == null) throw ArgumentError.notNull('indexee');
    if (index == null) throw ArgumentError.notNull('index');
    if (openBracket == null) throw ArgumentError.notNull('openBracket');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitIndex(this);
  }
}