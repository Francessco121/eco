import 'package:meta/meta.dart';

import '../ast/ast.dart';
import '../parsing/token.dart';
import '../parsing/token_type.dart';
import '../library.dart';
import '../library_identifier.dart';
import '../program.dart';
import '../user_library.dart';
import 'runtime_exception.dart';
import 'built_in_function_exception.dart';
import 'callable.dart';
import 'library_environment.dart';
import 'return_exception.dart';
import 'scope.dart';
import 'user_function.dart';

// Special exceptions for unwinding the stack in the interpreter
class _Break implements Exception { }

class _Continue implements Exception { }

/// A class capable of interpreting a user-defined Eco library.
abstract class Interpreter {
  /// The environment being used.
  LibraryEnvironment get environment;

  /// The user library being interpreted.
  UserLibrary get library;

  /// Interprets the block of [statements] using the given [scope].
  void interpret(List<Statement> statements, Scope scope);

  factory Interpreter(Program program, UserLibrary library, LibraryEnvironment environment) {
    return _InterpreterBase(program, library, environment);
  }
}

class _InterpreterBase implements Interpreter, ExpressionVisitor<Object>, StatementVisitor {
  @override
  final LibraryEnvironment environment;

  @override
  final UserLibrary library;

  Scope _currentScope;

  final Program _program;

  _InterpreterBase(this._program, this.library, this.environment);

  @override
  void interpret(List<Statement> statements, Scope scope) {
    // Save the current scope so we can restore it after
    final Scope previousScope = _currentScope;

    try {
      // Update the current scope
      _currentScope = scope;

      // Run each statement
      for (Statement statement in statements) {
        _execute(statement);
      }
    } finally {
      // Revert scope
      _currentScope = previousScope;
    }
  }

  @override
  Object visitArray(ArrayExpression array) {
    // Evaluate each array item and store them in a list
    final List<Object> list = [];

    for (final Expression value in array.values) {
      list.add(_evaluate(value));
    }

    return list;
  }

  @override
  Object visitAssignment(AssignmentExpression assignment) {
    final Expression target = assignment.target;

    if (target is VariableExpression) {
      // variable = value
      final Object value = _evaluate(assignment.value);

      _assignVariable(target.name, target, value);

      return value;
    } else if (target is GetExpression) {
      // map.key = value
      final Object targetValue = _evaluate(target.target);

      if (targetValue is Map<Object, Object>) {
        final Object value = _evaluate(assignment.value);
        targetValue[target.name.lexeme] = value;

        return value;
      } else {
        _error(target.dot, 'Setter target must be a map.');
      }
    } else if (target is IndexExpression) {
      // indexee[key] = value

      final Object targetValue = _evaluate(target.indexee);
      final Object indexValue = _evaluate(target.index);

      if (targetValue is List<Object>) {
        // list[key] = value

        final int intIndex = _checkIntegerOperand(indexValue, target.openBracket);

        if (intIndex < 0) {
          _error(target.openBracket, 'List index must not be negative.');
        }

        // Expand the list if necessary
        if (intIndex >= targetValue.length) {
          int spaceNeeded = intIndex - targetValue.length + 1;

          for (int i = 0; i < spaceNeeded; i++) {
            targetValue.add(null);
          }
        }

        // Set the value
        final Object value = _evaluate(assignment.value);
        targetValue[intIndex] = value;

        return value;
      } else if (targetValue is Map<Object, Object>) {
        // map[key] = value

        if (indexValue == null) {
          _error(target.openBracket, 'Map index must not be null.');
        }

        final Object value = _evaluate(assignment.value);
        targetValue[indexValue] = value;

        return value;
      } else {
        _error(assignment.equalSign, 'Only lists and maps can be indexed.');
      }
    } else {
      _error(assignment.equalSign, 'Assignment target must be a variable, setter, or indexer.');
    }
  }

  @override
  Object visitBinary(BinaryExpression binary) {
    final Object left = _evaluate(binary.left);
    final Object right = _evaluate(binary.right);

    switch (binary.$operator.type) {
      case TokenType.greater:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) > (right as double);
      case TokenType.greaterEqual:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) >= (right as double);
      case TokenType.less:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) < (right as double);
      case TokenType.lessEqual:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) <= (right as double);
      case TokenType.minus:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) - (right as double);
      case TokenType.plus:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) + (right as double);
      case TokenType.forwardSlash:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) / (right as double);
      case TokenType.star:
        _checkNumberOperands(binary.$operator, left, right);
        return (left as double) * (right as double);
      case TokenType.bangEqual:
        _checkNumberOperands(binary.$operator, left, right);
        return !_isEqual(left, right);
      case TokenType.equalEqual:
        _checkNumberOperands(binary.$operator, left, right);
        return _isEqual(left, right);
      case TokenType.dotDot:
        if (left is String && right is String) {
          return left + right;
        } else if (left is List<Object> && right is List<Object>) {
          return <Object>[]
            ..addAll(left)
            ..addAll(right);
        }

        _error(binary.$operator, 'Concatenation operands must both be strings or lists.');
        break; // Just to make the analyzer happy... _error always throws
      default:
        _error(binary.$operator, 'Unknown binary operator.');
    }
  }

  @override
  void visitBlock(BlockStatement block) {
    final Scope previousScope = _currentScope;

    try {
      // Make a new scope for the block
      _currentScope = new Scope(_currentScope);

      // Run each statement
      for (Statement statement in block.statements) {
        _execute(statement);
      }
    } finally {
      // Revert scope
      _currentScope = previousScope;
    }
  }

  @override
  void visitBreak(BreakStatement $break) {
    // Throw a special exception to unwind the stack back to a loop.
    throw _Break();
  }

  @override
  Object visitCall(CallExpression call) {
    // Evaluate the target
    final Object callee = _evaluate(call.callee);

    // Evaluate each argument
    final List<Object> arguments = [];
    for (Expression argument in call.arguments) {
      arguments.add(_evaluate(argument));
    }

    if (callee is Callable) {
      // Check the arity
      if (arguments.length == callee.arity) {
        // Run the callable
        try {
          return callee.call(this, arguments);
        } on BuiltInFunctionException catch (ex) {
          // Convert built-in function exceptions
          _error(call.openParen, ex.message);
        }
      } else {
        _error(call.openParen, 
          'Expected ${callee.arity} arguments but got ${arguments.length}.'
        );
      }
    } else {
      _error(call.openParen, 'Only functions are callable.');
    }
  }

  @override
  void visitContinue(ContinueStatement $continue) {
    // Throw a special exception to unwind the stack back to a loop.
    throw _Continue();
  }

  @override
  void visitExpressionStatement(ExpressionStatement expressionStatement) {
    _evaluate(expressionStatement.expression);
  }

  @override
  void visitFor(ForStatement $for) {
    // Capture the current scope so we can reset it after
    final Scope outerScope = _currentScope;

    try {
      // Create a scope for the for-loop clauses
      _currentScope = new Scope(outerScope);

      // Run the initialization statement if present
      if ($for.initializer != null) {
        _execute($for.initializer);
      }

      // Loop until the condition is false
      while (true) {
        // Check condition
        if ($for.condition != null) {
          final Object value = _evaluate($for.condition);

          if (value is bool) {
            if (!value) {
              break;
            }
          } else {
            _error($for.keyword, 'For-loop condition must evaluate to a boolean.');
          }
        }

        // Execute the statement body
        try {
          _execute($for.body);
        } on _Continue { 
          // Loop body was stopped early by a continue statement.
        }

        // Evaluate the afterthought if present
        if ($for.afterthought != null) {
          _evaluate($for.afterthought);
        }
      }
    } on _Break {
      // Loop was cancelled with a break statement.
    } finally {
      _currentScope = outerScope;
    }
  }

  @override
  void visitForeach(ForeachStatement foreach) {
    // Capture the current scope so we can reset it after
    final Scope outerScope = _currentScope;

    try {
      // Evaluate the iterable
      final Object iterable = _evaluate(foreach.inExpression);

      // Create a scope for the key/value variables
      _currentScope = new Scope(outerScope);

      // Define key and values variables
      _currentScope.define(foreach.keyName.lexeme, null);
      
      if (foreach.valueName != null) {
        _currentScope.define(foreach.valueName.lexeme, null);
      }

      // Iterate
      if (iterable is List<Object>) {
        for (int i = 0; i < iterable.length; i++) {
          // Update key and value variables
          _currentScope.assign(foreach.keyName, i.toDouble());

          if (foreach.valueName != null) {
            _currentScope.assign(foreach.valueName, iterable[i]);
          }

          // Execute the loop body
          try {
            _execute(foreach.body);
          } on _Continue {
            // Loop body was stopped early by a continue statement
          }
        }
      } else if (iterable is Map<Object, Object>) {
        iterable.forEach((key, value) {
          // Update key and value variables
          _currentScope.assign(foreach.keyName, key);

          if (foreach.valueName != null) {
            _currentScope.assign(foreach.valueName, value);
          }

          // Execute the loop body
          try {
            _execute(foreach.body);
          } on _Continue {
            // Loop body was stopped early by a continue statement
          }
        });
      } else {
        _error(foreach.inKeyword, 
          'Foreach in expression must evaluate to a list or map.'
        );
      }
    } on _Break {
      // Loop was cancelled with a break statement.
    } finally {
      _currentScope = outerScope;
    }
  }

  @override
  Object visitFunctionExpression(FunctionExpression functionExpression) {
    return UserFunction(
      parameters: functionExpression.parameters,
      body: functionExpression.body,
      closure: _currentScope,
      name: null // Anonymous functions don't have names
    );
  }

  @override
  void visitFunctionStatement(FunctionStatement functionStatement) {
    final function = new UserFunction(
      parameters: functionStatement.parameters,
      body: functionStatement.body,
      closure: _currentScope,
      name: functionStatement.name.lexeme
    );

    final Scope scope = functionStatement.publicKeyword != null
      ? environment.publicScope
      : _currentScope;

    scope.define(functionStatement.name.lexeme, function);
  }

  @override
  Object visitGet(GetExpression $get) {
    // Evaluate the target
    final Object target = _evaluate($get.target);

    // Evaluate the get
    if (target is Map<Object, Object>) {
      // map.key
      return target[$get.name.lexeme];
    } else if (target is LibraryEnvironment) {
      // library.variable
      return target.publicScope.get($get.name);
    }

    _error($get.dot, 'Get target must be a map or a library.');
  }

  @override
  Object visitGrouping(GroupingExpression grouping) {
    return _evaluate(grouping.expression);
  }

  @override
  void visitIf(IfStatement $if) {
    final Object conditionValue = _evaluate($if.condition);

    if (conditionValue is bool) {
      if (conditionValue) {
        _execute($if.thenStatement);
      } else {
        _execute($if.elseStatement);
      }
    } else {
      _error($if.ifKeyword, 'If condition must evaluate to a boolean.');
    }
  }

  @override
  void visitImport(ImportStatement $import) {
    // Get the imported library
    final LibraryIdentifier importedLibraryId = library.imports[$import];
    final Library importedLibrary = _program.libraries[importedLibraryId];
  
    // Load the library's environment for the program
    final LibraryEnvironment importedEnvironment = 
      _program.loadEnvironment(importedLibrary);

    // Define the import under the specified 'as' identifier
    _currentScope.define($import.asIdentifier.lexeme, importedEnvironment);
  }

  @override
  Object visitIndex(IndexExpression indexExpression) {
    final Object indexee = _evaluate(indexExpression.indexee);
    final Object index = _evaluate(indexExpression.index);

    if (indexee is List<Object>) {
      // Indexing a list
      if (index is double) {
        final int intIndex = index.truncate();
        
        if (intIndex == index) {
          if (intIndex >= 0 && intIndex < indexee.length) {
            return indexee[intIndex];
          } else {
            _error(indexExpression.openBracket, 'List index is out of range.');
          }
        }
      }

      _error(indexExpression.openBracket, 'List index must be an integer.');
    } else if (indexee is Map<Object, Object>) {
      // Indexing a map
      if (index != null) {
        return indexee[index];
      } else {
        _error(indexExpression.openBracket, 'Map index must not be null.');
      }
    }

    _error(indexExpression.openBracket, 'Only lists and maps can be indexed.');
  }

  @override
  Object visitLiteral(LiteralExpression literal) {
    return literal.value;
  }

  @override
  Object visitLogical(LogicalExpression logical) {
    final Object left = _evaluate(logical.left);

    if (left is bool) {
      // Short-circuit if possible
      if (logical.$operator.type == TokenType.or) {
        if (left) {
          return true;
        }
      } else {
        if (!left) {
          return false;
        }
      }

      final Object right = _evaluate(logical.right);

      if (right is bool) {
        return right;
      } else {
        _error(logical.$operator, 'Right logical operand must be a boolean.');
      }
    } else {
      _error(logical.$operator, 'Left logical operand must be a boolean.');
    }
  }

  @override
  Object visitMap(MapExpression mapExpression) {
    final Map<Object, Object> map = {};

    // Evaluate each pair and store the results in a map
    for (final MapPair pair in mapExpression.pairs) {
      // Evaluate key
      final Expression keyExpression = pair.key;

      Object key;
      if (keyExpression is VariableExpression) {
        // Keys can be identifiers as a shortcut for string keys
        key = keyExpression.name.lexeme;
      } else {
        key = _evaluate(keyExpression);
      }

      // Ensure the evaluated key is not null
      if (key == null) {
        _error(pair.colon, 'Map keys must not be null.');
      }

      // Evaluate value
      Object value = _evaluate(pair.value);

      map[key] = value;
    }

    return map;
  }

  @override
  void visitReturn(ReturnStatement $return) {
    // Evaluate return value if present
    Object value = null;

    if ($return.expression != null) {
      value = _evaluate($return.expression);
    }

    // Throw a special exception to unwind the stack back to a function call.
    throw Return(value);
  }

  @override
  Object visitTernary(TernaryExpression ternary) {
    final Object value = _evaluate(ternary.condition);

    if (value is bool) {
      if (value) {
        return _evaluate(ternary.thenExpression);
      } else {
        return _evaluate(ternary.elseExpression);
      }
    }

    _error(ternary.questionMark, 'Ternary condition must be a boolean.');
  }

  @override
  Object visitUnary(UnaryExpression unary) {
    // Post-fix operators
    if (unary.$operator.type == TokenType.plusPlus
      || unary.$operator.type == TokenType.minusMinus
    ) {
      final expression = unary.expression;

      if (expression is VariableExpression) {
        final Object value = _lookUpVariable(expression.name, expression);

        if (value is double) {
          if (unary.$operator.type == TokenType.plusPlus) {
            // value++
            _currentScope.assign(expression.name, value + 1);
          } else {
            // value--
            _currentScope.assign(expression.name, value - 1);
          }
        }

        // Return old value since this is a post-fix increment/decrement
        return value;
      } else {
        _error(unary.$operator, 'Post-fix unary operand must be a variable.');
      }
    }

    // Pre-fix unary operators
    final Object value = _evaluate(unary.expression);

    switch (unary.$operator.type) {
      case TokenType.bang:
        // !value
        _checkBooleanOperand(unary.$operator, value);

        final bool boolean = value;

        return !boolean;
      case TokenType.minus:
        // -value
        _checkNumberOperand(unary.$operator, value);

        final double number = value;

        return -number;
      case TokenType.hash:
        // #value
        if (value is List<Object>) {
          return value.length.toDouble();
        } else if (value is Map<Object, Object>) {
          return value.length.toDouble();
        } else if (value is String) {
          return value.length.toDouble();
        }

        _error(unary.$operator, 'Unary length operand must be a list, map, or string.');
        break; // Just to make the analyzer happy... _error always throws.
      default:
        _error(unary.$operator, 'Unknown unary operator.');
    }
  }

  @override
  Object visitVariable(VariableExpression variable) {
    return _lookUpVariable(variable.name, variable);
  }

  @override
  void visitVariableStatement(VariableStatement variableStatement) {
    // Evaluate initializer if present
    Object value = null;
    if (variableStatement.initializer != null) {
      value = _evaluate(variableStatement.initializer);
    }

    // Define variable
    final Scope scope = variableStatement.publicKeyword != null
      ? environment.publicScope
      : _currentScope;

    scope.define(variableStatement.name.lexeme, value);
  }

  @override
  void visitWhile(WhileStatement $while) {
    try {
      // Loop until condition is false
      while (true) {
        // Check condition
        final Object conditionValue = _evaluate($while.condition);

        if (conditionValue is bool) {
          if (!conditionValue) {
            break;
          }
        } else {
          _error($while.keyword, 'While condition must evaluate to a boolean.');
        }

        // Execute loop body
        try {
          _execute($while.body);
        } on _Continue {
          // Loop body ended early by a continue statement
        }
      }
    } on _Break {
      // Loop ended early by a break statement
    }
  }

  Object _evaluate(Expression expression) {
    return expression.accept(this);
  }

  void _execute(Statement statement) {
    statement.accept(this);
  }

  bool _isEqual(Object a, Object b) {
    if (a == null && b == null) return true;
    if (a == null) return false;

    return a == b;
  }

  Object _lookUpVariable(Token name, Expression expression) {
    final int distance = library.locals[expression];

    if (distance != null) {
      return _currentScope.getAt(distance, name.lexeme);
    } else {
      return environment.libraryScope.get(name);
    }
  }

  void _assignVariable(Token name, Expression expression, Object value) {
    final int distance = library.locals[expression];

    if (distance != null) {
      _currentScope.assignAt(distance, name, value);
    } else {
      environment.libraryScope.assign(name, value);
    }
  }

  @alwaysThrows
  void _error(Token token, String message) {
    throw RuntimeException(token.sourceSpan, message);
  }

  /// Returns [value] as an `int`.
  /// 
  /// Throws a [RuntimeException] if [value] is not a `double` integer.
  int _checkIntegerOperand(Object value, Token token) {
    if (value is double) {
      final int intValue = value.truncate();

      if (intValue == value) {
        return intValue;
      }
    }

    _error(token, 'Value must be an integer.');
  }

  /// Throws a [RuntimeException] if [operand] is not a `bool`.
  void _checkBooleanOperand(Token $operator, Object operand) {
    if (operand is bool) {
      return;
    }

    _error($operator, 'Operand must be a number.');
  }

  /// Throws a [RuntimeException] if [operand] is not a `double`.
  void _checkNumberOperand(Token $operator, Object operand) {
    if (operand is double) {
      return;
    }

    _error($operator, 'Operand must be a number.');
  }

  /// Throws a [RuntimeException] if [left] or [right] is not a `double`.
  void _checkNumberOperands(Token $operator, Object left, Object right) {
    if (left is double && right is double) {
      return;
    }

    _error($operator, 'Operands must be a numbers.');
  }
}