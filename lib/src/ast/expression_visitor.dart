import 'array_expression.dart';
import 'assignment_expression.dart';
import 'binary_expression.dart';
import 'call_expression.dart';
import 'function_expression.dart';
import 'get_expression.dart';
import 'grouping_expression.dart';
import 'index_expression.dart';
import 'literal_expression.dart';
import 'logical_expression.dart';
import 'map_expression.dart';
import 'ternary_expression.dart';
import 'unary_expression.dart';
import 'variable_expression.dart';

abstract class ExpressionVisitor<T> {
  T visitArray(ArrayExpression array);
  T visitAssignment(AssignmentExpression assignment);
  T visitBinary(BinaryExpression binary);
  T visitCall(CallExpression call);
  T visitFunctionExpression(FunctionExpression functionExpression);
  T visitGet(GetExpression $get);
  T visitGrouping(GroupingExpression grouping);
  T visitIndex(IndexExpression index);
  T visitLiteral(LiteralExpression literal);
  T visitLogical(LogicalExpression logical);
  T visitMap(MapExpression map);
  T visitTernary(TernaryExpression ternary);
  T visitUnary(UnaryExpression unary);
  T visitVariable(VariableExpression variable);
}