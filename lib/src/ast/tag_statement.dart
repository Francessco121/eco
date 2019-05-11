import '../parsing/token.dart';
import 'attribute.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class TagStatement implements Statement {
  final Token keyword;
  final Token name;
  final List<Attribute> attributes;
  final List<Statement> body;

  TagStatement(this.keyword, this.name, this.attributes, this.body) {
    if (keyword == null) throw ArgumentError.notNull('keyword');
    if (name == null) throw ArgumentError.notNull('name');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitTag(this);
  }
}