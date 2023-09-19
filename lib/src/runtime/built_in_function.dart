import 'dart:collection';

import 'call_context.dart';
import 'callable.dart';
import 'function_parameter.dart';
import 'runtime_value.dart';

typedef BuiltInFunctionCallback = RuntimeValue? Function(CallContext context, Map<String, RuntimeValue?> arguments);

/// An Eco function implemented in Dart.
class BuiltInFunction implements Callable {
  @override
  UnmodifiableListView<FunctionParameter> get parameters => _parametersView;

  final String name;

  late final UnmodifiableListView<FunctionParameter> _parametersView;

  final BuiltInFunctionCallback _callback;

  BuiltInFunction(this._callback, {
    required List<FunctionParameter> parameters,
    required this.name
  }) {
    _parametersView = new UnmodifiableListView(parameters);
  }

  @override
  RuntimeValue? call(CallContext context, Map<String, RuntimeValue?> arguments) {
    return _callback(context, arguments);
  }

  @override
  String toString() {
    return '<built-in fn $name>';
  }
}