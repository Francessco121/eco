import '../built_in_function.dart';
import '../built_in_library.dart';
import '../callable.dart';
import '../library_environment.dart';

class ObjectLibrary extends BuiltInLibrary {
  @override
  final String id = 'object';

  @override
  final String defaultImportIdentifier = 'Object';

  ObjectLibrary() {
    // toString
    defineFunction(BuiltInFunction(
      (args) {
        final Object arg = args[0];

        if (arg == null) {
          return 'null';
        } else {
          return arg.toString();
        }
      },
      arity: 1,
      name: 'toString'
    ));

    // typeOf
    defineFunction(BuiltInFunction(
      (args) {
        final Object arg = args[0];

        if (arg == null) return 'null';
        else if (arg is String) return 'string';
        else if (arg is double) return 'number';
        else if (arg is bool) return 'boolean';
        else if (arg is List<Object>) return 'list';
        else if (arg is Map<Object, Object>) return 'map';
        else if (arg is Callable) return 'function';
        else if (arg is LibraryEnvironment) return 'library';
        else throw UnimplementedError();
      },
      arity: 1,
      name: 'typeOf'
    ));
  }
}