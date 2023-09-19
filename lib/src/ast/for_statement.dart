import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class ForStatement implements Statement {
  final Token keyword;
  final Statement? initializer;
  final Expression? condition;
  final Expression? afterthought;
  final Statement body;

  ForStatement({
    required this.keyword,
    required this.initializer,
    required this.condition,
    required this.afterthought,
    required this.body
  });

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitFor(this);
  }
}