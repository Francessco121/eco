import 'statement.dart';
import 'statement_visitor.dart';

class BlockStatement implements Statement {
  final List<Statement> statements;

  BlockStatement(this.statements) {
    if (statements == null) throw ArgumentError.notNull('statements');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitBlock(this);
  }
}