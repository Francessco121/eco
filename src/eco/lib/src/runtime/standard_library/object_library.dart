import '../built_in_function.dart';
import '../built_in_library.dart';

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
  }
}