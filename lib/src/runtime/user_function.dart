import 'dart:collection';

import 'package:meta/meta.dart';

import '../ast/ast.dart';
import 'callable.dart';
import 'function_parameter.dart';
import 'interpreter.dart';
import 'return_exception.dart';
import 'runtime_value.dart';
import 'scope.dart';

/// A user-defined function in Eco code.
class UserFunction implements Callable {
  @override
  UnmodifiableListView<FunctionParameter> get parameters => _parametersView;

  UnmodifiableListView<FunctionParameter> _parametersView;

  final List<Statement> _body;
  final Scope _closure;
  final String _name;
  final Interpreter _interpreter;

  UserFunction({
    @required List<FunctionParameter> parameters,
    @required List<Statement> body,
    @required Scope closure,
    @required String name,
    @required Interpreter interpreter
  })
    : _body = body,
      _closure = closure,
      _name = name,
      _interpreter = interpreter {
    
    _parametersView = UnmodifiableListView(parameters);
  }

  @override
  RuntimeValue call(Map<String, RuntimeValue> arguments) {
    // Create a new scope for the function body
    final scope = new Scope(_closure);

    // Bind each argument to a parameter in the scope
    // ignore: unnecessary_lambdas
    arguments.forEach((paramName, value) {
      scope.define(paramName, value);
    });

    // Execute the function body
    try {
      _interpreter.interpret(_body, scope);
    } on Return catch (ex) {
      // Function ended early with a return statement
      return ex.value;
    }

    // Default to a null return value
    return null;
  }

  @override
  String toString() {
    return _name == null ? '<anonymous fn>' : '<fn $_name>';
  }
}