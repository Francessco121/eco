import '../built_in_function.dart';
import '../built_in_function_exception.dart';
import '../built_in_library.dart';
import '../function_parameter.dart';
import '../runtime_value.dart';
import '../runtime_value_type.dart';

class AssertLibrary extends BuiltInLibrary {
  @override
  final String id = 'assert';

  @override
  final String defaultImportIdentifier = 'Assert';

  AssertLibrary() {
    // isTrue
    defineFunction(BuiltInFunction(
      (args) {
        final bool condition = parseBoolean(args, 'condition');
        final String errorMessage = parseString(args, 'errorMessage', allowNull: true);

        if (!condition) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      parameters: [
        FunctionParameter('condition'),
        FunctionParameter('errorMessage', defaultValue: RuntimeValue.fromNull())
      ],
      name: 'isTrue'
    ));

    // isFalse
    defineFunction(BuiltInFunction(
      (args) {
        final bool condition = parseBoolean(args, 'condition');
        final String errorMessage = parseString(args, 'errorMessage', allowNull: true);

        if (condition) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      parameters: [
        FunctionParameter('condition'),
        FunctionParameter('errorMessage', defaultValue: RuntimeValue.fromNull())
      ],
      name: 'isFalse'
    ));

    // areEqual
    defineFunction(BuiltInFunction(
      (args) {
        final RuntimeValue expected = args['expected'];
        final RuntimeValue actual = args['actual'];
        final String errorMessage = parseString(args, 'errorMessage', allowNull: true);

        if (expected != actual) {
          throw BuiltInFunctionException(errorMessage ?? 
            "Assert failed. Expected '$expected' but got '$actual'."
          );
        }
      },
      parameters: [
        FunctionParameter('expected'),
        FunctionParameter('actual'),
        FunctionParameter('errorMessage', defaultValue: RuntimeValue.fromNull())
      ],
      name: 'areEqual'
    ));

    // isNull
    defineFunction(BuiltInFunction(
      (args) {
        final RuntimeValue obj = args['object'];
        final String errorMessage = parseString(args, 'errorMessage', allowNull: true);

        if (obj.type != RuntimeValueType.$null) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      parameters: [
        FunctionParameter('object'),
        FunctionParameter('errorMessage', defaultValue: RuntimeValue.fromNull())
      ],
      name: 'isNull'
    ));

    // isNotNull
    defineFunction(BuiltInFunction(
      (args) {
        final RuntimeValue obj = args['object'];
        final String errorMessage = parseString(args, 'errorMessage', allowNull: true);

        if (obj.type == RuntimeValueType.$null) {
          throw BuiltInFunctionException(errorMessage ?? 'Assert failed.');
        }
      },
      parameters: [
        FunctionParameter('object'),
        FunctionParameter('errorMessage', defaultValue: RuntimeValue.fromNull())
      ],
      name: 'isNotNull'
    ));
  }
}