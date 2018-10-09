import '../built_in_function.dart';
import '../built_in_function_exception.dart';
import '../built_in_library.dart';

class AssertLibrary extends BuiltInLibrary {
  @override
  final String id = 'assert';

  @override
  final String defaultImportIdentifier = 'Assert';

  AssertLibrary() {
    // isTrue
    defineFunction(BuiltInFunction(
      (args) {
        final bool condition = parseBoolean(args, 0);
        final String errorMessage = parseString(args, 1, allowNull: true);

        if (!condition) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      arity: 2,
      name: 'isTrue'
    ));

    // isFalse
    defineFunction(BuiltInFunction(
      (args) {
        final bool condition = parseBoolean(args, 0);
        final String errorMessage = parseString(args, 1, allowNull: true);

        if (condition) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      arity: 2,
      name: 'isFalse'
    ));

    // isNull
    defineFunction(BuiltInFunction(
      (args) {
        final Object obj = args[0];
        final String errorMessage = parseString(args, 1, allowNull: true);

        if (obj != null) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      arity: 2,
      name: 'isNull'
    ));

    // isNotNull
    defineFunction(BuiltInFunction(
      (args) {
        final Object obj = args[0];
        final String errorMessage = parseString(args, 1, allowNull: true);

        if (obj == null) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      arity: 2,
      name: 'isNotNull'
    ));
  }
}