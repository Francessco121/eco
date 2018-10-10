import '../parsing/token.dart';
import 'statement.dart';
import 'statement_visitor.dart';
import 'with_clause.dart';

class TagStatement implements Statement {
  final Token keyword;
  final Token name;
  final WithClause withClause;
  final List<Statement> body;

  TagStatement(this.keyword, this.name, this.withClause, this.body) {
    if (keyword == null) throw ArgumentError.notNull('keyword');
    if (name == null) throw ArgumentError.notNull('name');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitTag(this);
  }
}