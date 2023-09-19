import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class ExpressionStatement implements Statement {
  final Expression expression;

  ExpressionStatement(this.expression);

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitExpressionStatement(this);
  }
}