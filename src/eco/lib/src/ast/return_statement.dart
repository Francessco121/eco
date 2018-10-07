import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class ReturnStatement implements Statement {
  final Token keyword;
  final Expression expression;

  ReturnStatement(this.keyword, [this.expression]) {
    if (keyword == null) throw ArgumentError.notNull('keyword');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitReturn(this);
  }
}