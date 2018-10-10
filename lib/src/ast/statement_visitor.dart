import 'block_statement.dart';
import 'break_statement.dart';
import 'continue_statement.dart';
import 'expression_statement.dart';
import 'foreach_statement.dart';
import 'for_statement.dart';
import 'function_statement.dart';
import 'if_statement.dart';
import 'import_statement.dart';
import 'return_statement.dart';
import 'tag_statement.dart';
import 'variable_statement.dart';
import 'while_statement.dart';
import 'write_statement.dart';

abstract class StatementVisitor {
  void visitBlock(BlockStatement block);
  void visitBreak(BreakStatement $break);
  void visitContinue(ContinueStatement $continue);
  void visitExpressionStatement(ExpressionStatement expressionStatement);
  void visitForeach(ForeachStatement foreach);
  void visitFor(ForStatement $for);
  void visitFunctionStatement(FunctionStatement functionStatement);
  void visitIf(IfStatement $if);
  void visitImport(ImportStatement $import);
  void visitReturn(ReturnStatement $return);
  void visitTag(TagStatement tag);
  void visitVariableStatement(VariableStatement variableStatement);
  void visitWhile(WhileStatement $while);
  void visitWrite(WriteStatement write);
}