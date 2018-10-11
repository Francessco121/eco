import 'expression.dart';
import 'statement.dart';

/// Represents the body of a function.
/// 
/// Only one of the fields will not be `null`, this class
/// works kind of like a union type.
class FunctionBody {
  final List<Statement> block;
  final Expression expression;

  FunctionBody.fromBlock(this.block)
    : expression = null {
    
    if (block == null) throw ArgumentError.notNull('block');
  }

  FunctionBody.fromExpression(this.expression)
    : block = null {
    
    if (expression == null) throw ArgumentError.notNull('expression');
  }
}