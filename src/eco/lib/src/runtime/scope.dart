import '../parsing/token.dart';
import 'runtime_exception.dart';

class Scope {
  final Scope parent;

  final Map<String, Object> _values = {};

  Scope([this.parent]);

  void define(String name, Object value) {
    _values[name] = value;
  }

  /// Throws a [RuntimeException] if there is no variable with the given
  /// [name] in this scope or any parent scope.
  Object get(Token name) {
    // Try our scope first
    final Object value = _values[name.lexeme];

    if (value != null) {
      return value;
    }

    // Fallback to parent scope
    if (parent != null) {
      return parent.get(name);
    }

    throw RuntimeException(name.sourceSpan, 
      "Undefined variable '${name.lexeme}."
    );
  }

  Object getAt(int distance, String name) {
    return _ancestor(distance)._values[name];
  }

  /// Throws a [RuntimeException] if there is no variable with the given
  /// [name] in this scope or any parent scope.
  void assign(Token name, Object value) {
    // Try our scope first
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    // Fallback to parent scope
    if (parent != null) {
      parent.assign(name, value);
      return;
    }

    throw RuntimeException(name.sourceSpan, 
      "Undefined variable '${name.lexeme}."
    );
  }

  void assignAt(int distance, Token name, Object value) {
    _ancestor(distance)._values[name.lexeme] = value;
  }

  Scope _ancestor(int distance) {
    Scope scope = this;

    for (int i = 0; i < distance; i++) {
      scope = scope.parent;
    }
    
    return scope;
  }
}