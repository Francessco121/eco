import 'dart:collection';

import 'function_parameter.dart';
import 'runtime_value.dart';

abstract class Callable {
  /// Returns all parameters of this callable.
  UnmodifiableListView<FunctionParameter> get parameters;

  /// Runs this callable with the given [arguments].
  RuntimeValue call(Map<String, RuntimeValue> arguments);
}
