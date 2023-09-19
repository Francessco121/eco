import 'package:meta/meta.dart';

import '../library.dart';
import '../program.dart';
import 'built_in_function.dart';
import 'built_in_function_exception.dart';
import 'callable.dart';
import 'library_environment.dart';
import 'runtime_value.dart';
import 'runtime_value_type.dart';

// ignore_for_file: avoid_returning_null

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

  @override
  Uri get uri => Uri(scheme: 'eco', path: id);

  final Map<String, RuntimeValue> _variables = {};

  @override
  @mustCallSuper
  void run(Program program, LibraryEnvironment environment) {
    // Populate environment public scope
    _variables.forEach((name, value) {
      environment.publicScope.define(name, value);
    });
  }

  /// Defines a library-scoped variable with the given [name] and [value].
  void defineVariable(String name, RuntimeValue value) {
    _variables[name] = value;
  }

  /// Defines a library-scoped [function].
  void defineFunction(BuiltInFunction function) {
    _variables[function.name] = RuntimeValue.fromFunction(function);
  }

  /// Utility function to parse a boolean from function [args].
  @protected
  bool? parseBoolean(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.boolean) {
      return value.boolean;
    }

    throw BuiltInFunctionException("Argument '$paramName' must be a boolean.");
  }

  /// Utility function to parse a double from function [args].
  @protected
  double? parseDouble(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.number) {
      return value.number;
    }

    throw BuiltInFunctionException("Argument '$paramName' must be a number.");
  }

  /// Utility function to parse an integer from function [args].
  @protected
  int? parseInteger(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.number) {
      int intValue = value.number.truncate();

      if (intValue == value.number) {
        return intValue;
      }
    }

    throw BuiltInFunctionException("Argument '$paramName' must be an integer.");
  }

  /// Utility function to parse a string from function [args].
  @protected
  String? parseString(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.string) {
      return value.string;
    }

    throw BuiltInFunctionException("Argument '$paramName' must be a string.");
  }

  /// Utility function to parse a list from function [args].
  @protected
  List<RuntimeValue>? parseList(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.list) {
      return value.list;
    }

    throw BuiltInFunctionException("Argument '$paramName' must be a list.");
  }

  /// Utility function to parse a map from function [args].
  @protected
  Map<RuntimeValue, RuntimeValue>? parseMap(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.map) {
      return value.map;
    }

    throw BuiltInFunctionException("Argument '$paramName' must be a map.");
  }

  /// Utility function to parse a function from function [args].
  @protected
  Callable? parseFunction(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.function) {
      return value.function;
    }

    throw BuiltInFunctionException("Argument '$paramName' must be a function.");
  }

  /// Utility function to parse a library from function [args].
  @protected
  LibraryEnvironment? parseLibrary(Map<String, RuntimeValue?> args, String paramName, {
    bool allowNull = false
  }) {
    final RuntimeValue value = args[paramName]!;

    if (allowNull && value.type == RuntimeValueType.$null) {
      return null;
    }

    if (value.type == RuntimeValueType.library) {
      return value.library;
    }

    throw BuiltInFunctionException("Argument '$paramName' must be a library.");
  }
}