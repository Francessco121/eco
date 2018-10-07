import 'interpreter.dart';

abstract class Callable {
  /// Returns the number of arguments this callable accepts.
  int get arity;

  /// Runs this callable using the given [interpreter] and with the given [arguments].
  Object call(Interpreter interpreter, List<Object> arguments);
}
