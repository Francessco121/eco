import '../built_in_function.dart';
import '../built_in_function_exception.dart';
import '../built_in_library.dart';

class StringLibrary extends BuiltInLibrary {
  @override
  final String id = 'string';

  @override
  final String defaultImportIdentifier = 'String';

  StringLibrary() {
    // byte
    defineFunction(BuiltInFunction(
      (args) {
        final String str = parseString(args, 0);
        final int index = parseInteger(args, 1);

        if (index < 0 || index >= str.length) {
          throw BuiltInFunctionException(
            'String index is out of range. '
            'index = $index, string length = ${str.length}'
          );
        }

        return str.codeUnitAt(index).toDouble();
      },
      arity: 2,
      name: 'byte'
    ));

    // sub
    defineFunction(BuiltInFunction(
      (args) {
        final String str = parseString(args, 0);
        final int startIndex = parseInteger(args, 1);
        final int length = parseInteger(args, 2);

        if (startIndex < 0 || startIndex > str.length) {
          throw BuiltInFunctionException(
            'Start index is out of range. '
            'start index = $startIndex, string length = ${str.length}'
          );
        }

        final int endIndex = startIndex + length;

        if (endIndex < 0 || endIndex > str.length) {
          throw BuiltInFunctionException(
            'Start index plus length must not be larger than the string length. '
            'start index = $startIndex, length = $length, string length = ${str.length}'
          );
        }

        return str.substring(startIndex, endIndex);
      },
      arity: 3,
      name: 'sub'
    ));
  }
}