import '../parsing/token.dart';
import 'runtime_exception.dart';
import 'runtime_value.dart';

class Scope {
  final Scope parent;

  final Map<String, RuntimeValue> _values = {};

  Scope([this.parent]);

  void define(String name, RuntimeValue value) {
    if (name == null) throw ArgumentError.notNull('name');
    if (value == null) throw ArgumentError.notNull('value');
    
    _values[name] = value;
  }

  /// Throws a [RuntimeException] if there is no variable with the given
  /// [name] in this scope or any parent scope.
  RuntimeValue get(Token name) {
    if (name == null) throw ArgumentError.notNull('name');

    // Try our scope first
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    // Fallback to parent scope
    if (parent != null) {
      return parent.get(name);
    }

    throw RuntimeException(name.sourceSpan, 
      "Undefined variable '${name.lexeme}."
    );
  }

  RuntimeValue getAt(int distance, String name) {
    if (distance == null) throw ArgumentError.notNull('distance');
    if (name == null) throw ArgumentError.notNull('name');

    return _ancestor(distance)._values[name];
  }

  /// Throws a [RuntimeException] if there is no variable with the given
  /// [name] in this scope or any parent scope.
  void assign(Token name, RuntimeValue value) {
    if (name == null) throw ArgumentError.notNull('name');
    if (value == null) throw ArgumentError.notNull('value');

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

  void assignAt(int distance, Token name, RuntimeValue value) {
    if (distance == null) throw ArgumentError.notNull('distance');
    if (name == null) throw ArgumentError.notNull('name');
    if (value == null) throw ArgumentError.notNull('value');

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