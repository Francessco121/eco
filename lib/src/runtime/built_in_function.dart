import 'dart:collection';

import 'package:meta/meta.dart';

import 'callable.dart';
import 'function_parameter.dart';
import 'runtime_value.dart';

typedef BuiltInFunctionCallback = RuntimeValue Function(Map<String, RuntimeValue> arguments);

/// An Eco function implemented in Dart.
class BuiltInFunction implements Callable {
  @override
  UnmodifiableListView<FunctionParameter> get parameters => _parametersView;

  final String name;

  UnmodifiableListView<FunctionParameter> _parametersView;

  final BuiltInFunctionCallback _callback;

  BuiltInFunction(this._callback, {
    @required List<FunctionParameter> parameters,
    @required this.name
  })
    : assert(parameters != null),
      assert(name != null),
      assert(_callback != null) {
    
    _parametersView = new UnmodifiableListView(parameters);
  }

  @override
  RuntimeValue call(Map<String, RuntimeValue> arguments) {
    return _callback(arguments);
  }

  @override
  String toString() {
    return '<built-in fn $name>';
  }
}