import 'package:meta/meta.dart';

import '../library.dart';
import '../program.dart';
import 'built_in_function.dart';
import 'built_in_function_exception.dart';
import 'library_environment.dart';

/// An Eco library implemented in Dart.
abstract class BuiltInLibrary implements Library {
  /// The ID of the library. This is used for imports,
  /// IDs should be in lower_snake_case.
  /// 
  /// For example, an [id] of 'math' is imported with
  /// `import 'eco:math' as Math;`
  String get id;

  /// The default import identifier to use when this library
  /// is implicitly imported into an Eco program. Import
  /// identifiers should be in PascalCase.
  /// 
  /// For example, a [defaultImportIdentifier] of 'Math' is
  /// implicitly imported as `import 'eco:math' as Math;`.
  String get defaultImportIdentifier;

  final Map<String, Object> _variables = {};

  @override
  @mustCallSuper
  void run(Program program, LibraryEnvironment environment) {
    // Populate environment public scope
    _variables.forEach((name, value) {
      environment.publicScope.define(name, value);
    });
  }

  /// Defines a library-scoped variable with the given [name] and [value].
  /// 
  /// [value] must be `null`, a numeric, `String`, `List<Object>`, or `Map<Object, Object>`.
  void defineVariable(String name, Object value) {
    // Convert numerics to doubles
    if (value is num) {
      value = value as double;
    }

    // Ensure value is valid for Eco
    if (value != null
      && value is! double
      && value is! String
      && value is! List<Object>
      && value is! Map<Object, Object>
    ) {
      throw ArgumentError.value(
        value, 
        'value',
        'Value must be a numeric, String, List<Object>, or Map<Object, Object>.'
      );
    }

    _variables[name] = value;
  }

  /// Defines a library-scoped [function].
  void defineFunction(BuiltInFunction function) {
    _variables[function.name] = function;
  }

  /// Utility function to parse a boolean from function [args].
  @protected
  bool parseBoolean(List<Object> args, int index, {
    bool allowNull = false
  }) {
    final Object value = args[index];

    if (allowNull && value == null) {
      // ignore: avoid_returning_null
      return null;
    }

    if (value is bool) {
      return value;
    }

    throw BuiltInFunctionException('Argument ${index + 1} must be a boolean.');
  }

  /// Utility function to parse a double from function [args].
  @protected
  double parseDouble(List<Object> args, int index, {
    bool allowNull = false
  }) {
    final Object value = args[index];

    if (allowNull && value == null) {
      // ignore: avoid_returning_null
      return null;
    }

    if (value is double) {
      return value;
    }

    throw BuiltInFunctionException('Argument ${index + 1} must be a number.');
  }

  /// Utility function to parse an integer from function [args].
  @protected
  int parseInteger(List<Object> args, int index, {
    bool allowNull = false
  }) {
    final Object value = args[index];

    if (allowNull && value == null) {
      // ignore: avoid_returning_null
      return null;
    }

    if (value is double) {
      int intValue = value.truncate();

      if (intValue == value) {
        return intValue;
      }
    }

    throw BuiltInFunctionException('Argument ${index + 1} must be an integer.');
  }

  /// Utility function to parse a string from function [args].
  @protected
  String parseString(List<Object> args, int index, {
    bool allowNull = false
  }) {
    final Object value = args[index];

    if (allowNull && value == null) {
      return null;
    }

    if (value is String) {
      return value;
    }

    throw BuiltInFunctionException('Argument ${index + 1} must be a string.');
  }

  /// Utility function to parse a list from function [args].
  @protected
  List<Object> parseList(List<Object> args, int index, {
    bool allowNull = false
  }) {
    final Object value = args[index];

    if (allowNull && value == null) {
      return null;
    }

    if (value is List<Object>) {
      return value;
    }

    throw BuiltInFunctionException('Argument ${index + 1} must be a list.');
  }

  /// Utility function to parse a map from function [args].
  @protected
  Map<Object, Object> parseMap(List<Object> args, int index, {
    bool allowNull = false
  }) {
    final Object value = args[index];

    if (allowNull && value == null) {
      return null;
    }

    if (value is Map<Object, Object>) {
      return value;
    }

    throw BuiltInFunctionException('Argument ${index + 1} must be a map.');
  }
}