import 'statement.dart';
import 'statement_visitor.dart';

class BlockStatement implements Statement {
  final List<Statement> statements;

  BlockStatement(this.statements);

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitBlock(this);
  }
}