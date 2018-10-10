import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';
import 'statement.dart';

class HtmlExpression implements Expression {
  final Token keyword;
  final List<Statement> body;

  HtmlExpression(this.keyword, this.body) {
    if (keyword == null) throw ArgumentError.notNull('keyword');
    if (body == null) throw ArgumentError.notNull('body');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitHtml(this);
  }
}