import 'statement_visitor.dart';

abstract class Statement {
  void accept(StatementVisitor visitor);
}