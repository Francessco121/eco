import '../parsing/token.dart';
import 'expression.dart';

class Attribute {
  final Token name;
  final Expression expression;

  Attribute(this.name, this.expression);
}