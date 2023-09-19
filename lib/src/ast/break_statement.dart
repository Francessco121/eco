import '../parsing/token.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class BreakStatement implements Statement {
  final Token keyword;

  BreakStatement(this.keyword);

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitBreak(this);
  }
}