import '../built_in_function.dart';
import '../built_in_function_exception.dart';
import '../built_in_library.dart';
import '../function_parameter.dart';
import '../runtime_value.dart';

class StringLibrary extends BuiltInLibrary {
  @override
  final String id = 'string';

  @override
  final String defaultImportIdentifier = 'String';

  StringLibrary() {
    // byte
    defineFunction(BuiltInFunction(
      (_, args) {
        final String str = parseString(args, 'str')!;
        final int index = parseInteger(args, 'index')!;

        if (index < 0 || index >= str.length) {
          throw BuiltInFunctionException(
            'String index is out of range. '
            'index = $index, string length = ${str.length}'
          );
        }

        return RuntimeValue.fromNumber(str.codeUnitAt(index).toDouble());
      },
      parameters: [
        FunctionParameter('str'),
        FunctionParameter('index')
      ],
      name: 'byte'
    ));

    // sub
    defineFunction(BuiltInFunction(
      (_, args) {
        final String str = parseString(args, 'str')!;
        final int startIndex = parseInteger(args, 'startIndex')!;
        final int length = parseInteger(args, 'length')!;

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

        return RuntimeValue.fromString(str.substring(startIndex, endIndex));
      },
      parameters: [
        FunctionParameter('str'),
        FunctionParameter('startIndex'),
        FunctionParameter('length')
      ],
      name: 'sub'
    ));
  }
}