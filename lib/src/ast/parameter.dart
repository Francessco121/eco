import '../parsing/token.dart';
import 'expression.dart';

class Parameter {
  final Token identifier;
  final Expression? defaultValue;

  Parameter(this.identifier, this.defaultValue);
}