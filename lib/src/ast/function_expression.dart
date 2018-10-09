import '../parsing/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';
import 'statement.dart';

class FunctionExpression implements Expression {
  final List<Token> parameters;
  final List<Statement> body;

  FunctionExpression(this.parameters, this.body) {
    if (parameters == null) throw ArgumentError.notNull('parameters');
    if (body == null) throw ArgumentError.notNull('body');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitFunctionExpression(this);
  }
}