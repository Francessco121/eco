import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

@immutable
class ParseError {
  final SourceSpan sourceSpan;
  final String message;

  const ParseError(this.sourceSpan, this.message);

  @override
  String toString() => sourceSpan.message(message);
}