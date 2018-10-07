import 'package:source_span/source_span.dart';

class Source {
  final SourceSpan sourceSpan;
  
  String get text => sourceSpan.text;
  Uri get uri => sourceSpan.sourceUrl;

  Source._(this.sourceSpan) {
    if (sourceSpan == null) throw ArgumentError.notNull('sourceSpan');
  }

  factory Source(Uri uri, String content) {
    return Source._(SourceSpan(
      SourceLocation(0, sourceUrl: uri),
      SourceLocation(content.length, sourceUrl: uri),
      content
    ));
  }

  factory Source.fromSourceSpan(SourceSpan sourceSpan) {
    return Source._(sourceSpan);
  }
}