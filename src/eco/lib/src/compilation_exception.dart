import 'dart:collection';

import 'parse_error.dart';

class CompilationException implements Exception {
  final UnmodifiableListView<ParseError> parseErrors;

  CompilationException(this.parseErrors) {
    if (parseErrors == null) throw new ArgumentError.notNull('parseErrors');
  }
}