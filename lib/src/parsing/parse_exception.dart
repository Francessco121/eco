import 'dart:collection';

import 'parse_error.dart';

class ParseException implements Exception {
  final UnmodifiableListView<ParseError> parseErrors;

  ParseException(this.parseErrors) {
    if (parseErrors == null) throw new ArgumentError.notNull('parseErrors');
  }
}