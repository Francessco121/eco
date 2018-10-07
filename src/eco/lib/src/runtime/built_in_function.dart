import 'package:meta/meta.dart';

import 'callable.dart';

typedef BuiltInFunctionCallback = Object Function(List<Object> arguments);

/// An Eco function implemented in Dart.
class BuiltInFunction implements Callable {
  @override
  final int arity;

  final String name;

  final BuiltInFunctionCallback _callback;

  BuiltInFunction(this._callback, {
    @required this.arity,
    @required this.name
  })
    : assert(arity != null),
      assert(name != null),
      assert(_callback != null);

  @override
  Object call(_, List<Object> arguments) {
    return _callback(arguments);
  }

  @override
  String toString() {
    return '<built-in fn $name>';
  }
}