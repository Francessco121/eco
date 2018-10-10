import '../parsing/token.dart';
import 'expression.dart';

class Parameter {
  final Token identifier;
  final Token equalSign;
  final Expression defaultValue;

  Parameter(this.identifier, this.equalSign, this.defaultValue) {
    if (identifier == null) throw new ArgumentError.notNull('identifier');
  }
}