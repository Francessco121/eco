import 'runtime_value.dart';

class FunctionParameter {
  final String name;
  final RuntimeValue? defaultValue;

  FunctionParameter(this.name, {this.defaultValue});
}