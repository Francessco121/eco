import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class VariableStatement implements Statement {
  final Token name;
  final Expression? initializer;
  final Token? publicKeyword;

  VariableStatement(this.name, {this.initializer, this.publicKeyword});

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitVariableStatement(this);
  }
}