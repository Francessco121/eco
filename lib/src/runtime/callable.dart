import 'dart:collection';

import 'call_context.dart';
import 'function_parameter.dart';
import 'runtime_value.dart';

abstract class Callable {
  /// Returns all parameters of this callable.
  UnmodifiableListView<FunctionParameter> get parameters;

  /// Runs this callable with the given [arguments] and [context].
  RuntimeValue? call(CallContext context, Map<String, RuntimeValue?> arguments);
}
