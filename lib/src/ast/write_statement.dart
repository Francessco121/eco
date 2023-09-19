import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class WriteStatement implements Statement {
  final Token keyword;
  final Expression expression;

  WriteStatement(this.keyword, this.expression);

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitWrite(this);
  }
}