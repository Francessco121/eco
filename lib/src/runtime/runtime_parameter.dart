import 'runtime_value.dart';

class RuntimeParameter {
  final String name;
  final RuntimeValue defaultValue;

  RuntimeParameter(this.name, {this.defaultValue});
}