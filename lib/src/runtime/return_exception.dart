import 'runtime_value.dart';

// Special exception for unwinding the stack in the 
// interpreter with a return value.
class Return implements Exception {
  final RuntimeValue value;

  Return(this.value);
}