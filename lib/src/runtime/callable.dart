import 'dart:collection';

import 'interpreter.dart';
import 'runtime_parameter.dart';
import 'runtime_value.dart';

abstract class Callable {
  /// Returns all parameters of this callable.
  UnmodifiableListView<RuntimeParameter> get parameters;

  /// Runs this callable using the given [interpreter] and with the given [arguments].
  RuntimeValue call(Interpreter interpreter, Map<String, RuntimeValue> arguments);
}
