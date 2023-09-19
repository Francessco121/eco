import '../parsing/token.dart';
import 'function_body.dart';
import 'parameter.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class FunctionStatement implements Statement {
  final Token name;
  final List<Parameter> parameters;
  final FunctionBody body;
  final Token? publicKeyword;

  FunctionStatement(this.name, this.parameters, this.body, {this.publicKeyword});

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitFunctionStatement(this);
  }
}