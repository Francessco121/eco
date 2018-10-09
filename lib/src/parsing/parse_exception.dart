import 'dart:collection';

import 'parse_error.dart';

class ParseException implements Exception {
  final UnmodifiableListView<ParseError> parseErrors;

  ParseException(this.parseErrors) {
    if (parseErrors == null) throw new ArgumentError.notNull('parseErrors');
  }

  @override
  String toString() {
    final buffer = new StringBuffer();
    buffer.writeln('ParseException:');

    for (final error in parseErrors) {
      buffer.writeln(error);
    }

    return buffer.toString();
  }
}