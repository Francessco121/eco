import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class WhileStatement implements Statement {
  final Token keyword;
  final Expression condition;
  final Statement body;

  WhileStatement(this.keyword, this.condition, this.body);

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitWhile(this);
  }
}