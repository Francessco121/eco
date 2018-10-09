import 'package:source_span/source_span.dart';

class RuntimeException implements Exception {
  final SourceSpan sourceSpan;

  final String message;

  RuntimeException(this.sourceSpan, this.message);

  @override
  String toString() => 
    'RuntimeException: ' + sourceSpan.message(message);
}