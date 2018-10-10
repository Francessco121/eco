import '../built_in_function.dart';
import '../built_in_library.dart';
import '../function_parameter.dart';
import '../runtime_value.dart';
import '../runtime_value_type.dart';

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
        final RuntimeValue arg = args['object'];

        return RuntimeValue.fromString(_typeOfValue(arg));
      },
      parameters: [
        FunctionParameter('object')
      ],
      name: 'typeOf'
    ));
  }

  String _typeOfValue(RuntimeValue value) {
    switch (value.type) {
      case RuntimeValueType.$null: return 'null';
      case RuntimeValueType.boolean: return 'boolean';
      case RuntimeValueType.function: return 'function';
      case RuntimeValueType.library: return 'library';
      case RuntimeValueType.list: return 'list';
      case RuntimeValueType.map: return 'map';
      case RuntimeValueType.number: return 'number';
      case RuntimeValueType.string: return 'string';
      default: throw UnimplementedError();
    }
  }
}