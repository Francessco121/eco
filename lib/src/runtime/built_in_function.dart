import 'dart:collection';

import 'package:meta/meta.dart';

import 'callable.dart';
import 'runtime_value.dart';
import 'runtime_parameter.dart';

typedef BuiltInFunctionCallback = RuntimeValue Function(Map<String, RuntimeValue> arguments);

/// An Eco function implemented in Dart.
class BuiltInFunction implements Callable {
  @override
  UnmodifiableListView<RuntimeParameter> get parameters => _parametersView;

  final String name;

  UnmodifiableListView<RuntimeParameter> _parametersView;

  final BuiltInFunctionCallback _callback;

  BuiltInFunction(this._callback, {
    @required List<RuntimeParameter> parameters,
    @required this.name
  })
    : assert(parameters != null),
      assert(name != null),
      assert(_callback != null) {
    
    _parametersView = new UnmodifiableListView(parameters);
  }

  @override
  RuntimeValue call(_, Map<String, RuntimeValue> arguments) {
    return _callback(arguments);
  }

  @override
  String toString() {
    return '<built-in fn $name>';
  }
}