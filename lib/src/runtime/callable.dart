import 'dart:collection';

import 'function_parameter.dart';
import 'interpreter.dart';
import 'runtime_value.dart';

abstract class Callable {
  /// Returns all parameters of this callable.
  UnmodifiableListView<FunctionParameter> get parameters;

  /// Runs this callable using the given [interpreter] and with the given [arguments].
  RuntimeValue call(Interpreter interpreter, Map<String, RuntimeValue> arguments);
}
