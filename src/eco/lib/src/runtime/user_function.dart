import 'package:meta/meta.dart';

import '../ast/ast.dart';
import '../token.dart';
import 'callable.dart';
import 'interpreter.dart';
import 'return_exception.dart';
import 'scope.dart';

/// A user-defined function in Eco code.
class UserFunction implements Callable {
  @override
  int get arity => _parameters.length;

  final List<Token> _parameters;
  final List<Statement> _body;
  final Scope _closure;
  final String _name;

  UserFunction({
    @required List<Token> parameters,
    @required List<Statement> body,
    @required Scope closure,
    @required String name
  })
    : _parameters = parameters,
      _body = body,
      _closure = closure,
      _name = name;

  @override
  Object call(Interpreter interpreter, List<Object> arguments) {
    // Create a new scope for the function body
    final scope = new Scope(_closure);

    // Bind each argument to a parameter in the scope
    for (int i = 0; i < _parameters.length; i++) {
      scope.define(_parameters[i].lexeme, arguments[i]);
    }

    // Execute the function body
    try {
      interpreter.interpret(_body, scope);
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