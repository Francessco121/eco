import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class ForeachStatement implements Statement {
  final Token keyName;
  final Token? valueName;
  final Expression inExpression;
  final Token inKeyword;
  final Statement body;

  ForeachStatement({
    required this.keyName,
    required this.valueName,
    required this.inExpression,
    required this.inKeyword,
    required this.body
  });

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitForeach(this);
  }
}