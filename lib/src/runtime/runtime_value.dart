import 'callable.dart';
import 'library_environment.dart';
import 'runtime_value_type.dart';

/// Represents an Eco value at runtime.
class RuntimeValue {
  final RuntimeValueType type;

  bool get boolean => _boolean;
  double get number => _number;
  String get string => _string;
  List<RuntimeValue> get list => _list;
  Map<RuntimeValue, RuntimeValue> get map => _map;
  Callable get function => _function;
  LibraryEnvironment get library => _library;

  bool _boolean;
  double _number;
  String _string;
  List<RuntimeValue> _list;
  Map<RuntimeValue, RuntimeValue> _map;
  Callable _function;
  LibraryEnvironment _library;

  RuntimeValue.fromNull()
    : type = RuntimeValueType.$null;

  // ignore: avoid_positional_boolean_parameters
  RuntimeValue.fromBoolean(bool value)
    : type = RuntimeValueType.boolean,
      _boolean = value;

  RuntimeValue.fromNumber(double value)
    : type = RuntimeValueType.number,
      _number = value;

  RuntimeValue.fromString(String value)
    : type = RuntimeValueType.string,
      _string = value;

  RuntimeValue.fromList(List<RuntimeValue> value)
    : type = RuntimeValueType.list,
      _list = value;

  RuntimeValue.fromMap(Map<RuntimeValue, RuntimeValue> value)
    : type = RuntimeValueType.map,
      _map = value;

  RuntimeValue.fromFunction(Callable value)
    : type = RuntimeValueType.function,
      _function = value;

  RuntimeValue.fromLibrary(LibraryEnvironment value)
    : type = RuntimeValueType.library,
      _library = value;

  @override
  bool operator ==(other) {
    if (other is RuntimeValue) {
      switch (type) {
        case RuntimeValueType.$null: return other.type == RuntimeValueType.$null;
        case RuntimeValueType.boolean: return _boolean == other._boolean;
        case RuntimeValueType.function: return _function == other._function;
        case RuntimeValueType.library: return _library == other._library;
        case RuntimeValueType.list: return _list == other._list;
        case RuntimeValueType.map: return _map == other._map;
        case RuntimeValueType.number: return _number == other._number;
        case RuntimeValueType.string: return _string == other._string;
      }
    }

    return false;
  }

  @override
  int get hashCode {
    switch (type) {
      case RuntimeValueType.$null: return 0;
      case RuntimeValueType.boolean: return _boolean.hashCode;
      case RuntimeValueType.function: return _function.hashCode;
      case RuntimeValueType.library: return _library.hashCode;
      case RuntimeValueType.list: return _list.hashCode;
      case RuntimeValueType.map: return _map.hashCode;
      case RuntimeValueType.number: return _number.hashCode;
      case RuntimeValueType.string: return _string.hashCode;
    }

    throw UnimplementedError();
  }

  @override
  String toString() {
    switch (type) {
      case RuntimeValueType.$null: return 'null';
      case RuntimeValueType.boolean: return _boolean.toString();
      case RuntimeValueType.function: return _function.toString();
      case RuntimeValueType.library: return _library.toString();
      case RuntimeValueType.list: return 'list';
      case RuntimeValueType.map: return 'map';
      case RuntimeValueType.number: return _numberToString(_number);
      case RuntimeValueType.string: return _string;
      default: throw UnimplementedError();
    }
  }

  String _numberToString(double number) {
    if (number.truncate() == number) {
      return number.toInt().toString();
    } else {
      return number.toString();
    }
  }
}