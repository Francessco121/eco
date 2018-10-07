import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class IfStatement implements Statement {
  final Token ifKeyword;
  final Expression condition;
  final Statement thenStatement;
  final Statement elseStatement;

  IfStatement(this.ifKeyword, this.condition, this.thenStatement, [this.elseStatement]) {
    if (condition == null) throw ArgumentError.notNull('condition');
    if (thenStatement == null) throw ArgumentError.notNull('thenStatement');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitIf(this);
  }
}