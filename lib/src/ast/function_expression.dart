import 'expression.dart';
import 'expression_visitor.dart';
import 'function_body.dart';
import 'parameter.dart';

class FunctionExpression implements Expression {
  final List<Parameter> parameters;
  final FunctionBody body;

  FunctionExpression(this.parameters, this.body);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitFunctionExpression(this);
  }
}