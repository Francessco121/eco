import 'expression_visitor.dart';

abstract class Expression {
  T accept<T>(ExpressionVisitor<T> visitor);
}