import '../parsing/token.dart';
import 'attribute.dart';

class WithClause {
  final Token keyword;
  final List<Attribute> attributes;

  WithClause(this.keyword, this.attributes) {
    if (keyword == null) throw ArgumentError.notNull('keyword');
    if (attributes == null) throw ArgumentError.notNull('attributes');
  }
}