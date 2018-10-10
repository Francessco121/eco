import 'expression.dart';
import 'expression_visitor.dart';
import 'parameter.dart';
import 'statement.dart';

class FunctionExpression implements Expression {
  final List<Parameter> parameters;
  final List<Statement> body;
  final Expression expression;

  FunctionExpression(this.parameters, {this.body, this.expression}) {
    if (parameters == null) throw ArgumentError.notNull('parameters');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitFunctionExpression(this);
  }
}