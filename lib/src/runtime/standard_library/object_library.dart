import '../built_in_function.dart';
import '../built_in_library.dart';
import '../function_parameter.dart';
import '../runtime_value.dart';

class ObjectLibrary extends BuiltInLibrary {
  @override
  final String id = 'object';

  @override
  final String defaultImportIdentifier = 'Object';

  ObjectLibrary() {
    // toString
    defineFunction(BuiltInFunction(
      (_, args) {
        return RuntimeValue.fromString(args['object'].toString());
      },
      parameters: [
        FunctionParameter('object')
      ],
      name: 'toString'
    ));

    // typeOf
    defineFunction(BuiltInFunction(
      (_, args) {
        final RuntimeValue arg = args['object']!;

        return RuntimeValue.fromString(arg.toTypeString());
      },
      parameters: [
        FunctionParameter('object')
      ],
      name: 'typeOf'
    ));
  }
}