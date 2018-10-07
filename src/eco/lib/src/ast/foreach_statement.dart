import 'package:meta/meta.dart';

import '../parsing/token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class ForeachStatement implements Statement {
  final Token keyName;
  final Token valueName;
  final Expression inExpression;
  final Token inKeyword;
  final Statement body;

  ForeachStatement({
    @required this.keyName,
    @required this.valueName,
    @required this.inExpression,
    @required this.inKeyword,
    @required this.body
  }) {
    if (keyName == null) throw ArgumentError.notNull('keyName');
    if (valueName == null) throw ArgumentError.notNull('valueName');
    if (inExpression == null) throw ArgumentError.notNull('inExpression');
    if (inKeyword == null) throw ArgumentError.notNull('inKeyword');
    if (body == null) throw ArgumentError.notNull('body');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitForeach(this);
  }
}