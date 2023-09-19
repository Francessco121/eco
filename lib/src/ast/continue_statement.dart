import '../parsing/token.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class ContinueStatement implements Statement {
  final Token keyword;

  ContinueStatement(this.keyword);

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitContinue(this);
  }
}