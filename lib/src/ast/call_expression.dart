import '../parsing/token.dart';
import 'arguments.dart';
import 'expression.dart';
import 'expression_visitor.dart';

class CallExpression implements Expression {
  final Expression callee;
  final Arguments arguments;

  final Token openParen;

  CallExpression(this.callee, this.arguments, this.openParen) {
    if (callee == null) throw ArgumentError.notNull('callee');
    if (arguments == null) throw ArgumentError.notNull('arguments');
    if (openParen == null) throw ArgumentError.notNull('openParen');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitCall(this);
  }
}