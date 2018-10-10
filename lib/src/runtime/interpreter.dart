import 'package:meta/meta.dart';

import '../ast/ast.dart';
import '../parsing/token.dart';
import '../parsing/token_type.dart';
import '../library.dart';
import '../library_identifier.dart';
import '../program.dart';
import '../user_library.dart';
import 'built_in_function_exception.dart';
import 'callable.dart';
import 'library_environment.dart';
import 'return_exception.dart';
import 'runtime_exception.dart';
import 'runtime_parameter.dart';
import 'runtime_value.dart';
import 'runtime_value_type.dart';
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

class _InterpreterBase implements Interpreter, ExpressionVisitor<RuntimeValue>, StatementVisitor {
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
  RuntimeValue visitArray(ArrayExpression array) {
    // Evaluate each array item and store them in a list
    final List<RuntimeValue> list = [];

    for (final Expression value in array.values) {
      list.add(_evaluate(value));
    }

    return RuntimeValue.fromList(list);
  }

  @override
  RuntimeValue visitAssignment(AssignmentExpression assignment) {
    final Expression target = assignment.target;

    if (target is VariableExpression) {
      // variable = value
      final RuntimeValue value = _evaluate(assignment.value);

      _assignVariable(target.name, target, value);

      return value;
    } else if (target is GetExpression) {
      // map.key = value
      final RuntimeValue targetValue = _evaluate(target.target);

      if (targetValue.type == RuntimeValueType.map) {
        final RuntimeValue value = _evaluate(assignment.value);
        targetValue.map[RuntimeValue.fromString(target.name.lexeme)] = value;

        return value;
      } else {
        _error(target.dot, 'Setter target must be a map.');
      }
    } else if (target is IndexExpression) {
      // indexee[key] = value

      final RuntimeValue targetValue = _evaluate(target.indexee);
      final RuntimeValue indexValue = _evaluate(target.index);

      if (targetValue.type == RuntimeValueType.list) {
        // list[key] = value

        final int intIndex = _checkIntegerOperand(indexValue, target.openBracket);

        if (intIndex < 0) {
          _error(target.openBracket, 'List index must not be negative.');
        }

        // Expand the list if necessary
        if (intIndex >= targetValue.list.length) {
          int spaceNeeded = intIndex - targetValue.list.length + 1;

          for (int i = 0; i < spaceNeeded; i++) {
            targetValue.list.add(RuntimeValue.fromNull());
          }
        }

        // Set the value
        final RuntimeValue value = _evaluate(assignment.value);
        targetValue.list[intIndex] = value;

        return value;
      } else if (targetValue.type == RuntimeValueType.map) {
        // map[key] = value

        if (indexValue.type == RuntimeValueType.$null) {
          _error(target.openBracket, 'Map index must not be null.');
        }

        final RuntimeValue value = _evaluate(assignment.value);
        targetValue.map[indexValue] = value;

        return value;
      } else {
        _error(assignment.equalSign, 'Only lists and maps can be indexed.');
      }
    } else {
      _error(assignment.equalSign, 'Assignment target must be a variable, setter, or indexer.');
    }
  }

  @override
  RuntimeValue visitBinary(BinaryExpression binary) {
    final RuntimeValue left = _evaluate(binary.left);
    final RuntimeValue right = _evaluate(binary.right);

    switch (binary.$operator.type) {
      case TokenType.greater:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromBoolean(left.number > right.number);
      case TokenType.greaterEqual:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromBoolean(left.number >= right.number);
      case TokenType.less:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromBoolean(left.number < right.number);
      case TokenType.lessEqual:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromBoolean(left.number <= right.number);
      case TokenType.minus:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromNumber(left.number - right.number);
      case TokenType.plus:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromNumber(left.number + right.number);
      case TokenType.forwardSlash:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromNumber(left.number / right.number);
      case TokenType.star:
        _checkNumberOperands(binary.$operator, left, right);
        return RuntimeValue.fromNumber(left.number * right.number);
      case TokenType.bangEqual:
        return RuntimeValue.fromBoolean(left != right);
      case TokenType.equalEqual:
        return RuntimeValue.fromBoolean(left == right);
      case TokenType.dotDot:
        if (left.type == RuntimeValueType.string && right.type == RuntimeValueType.string) {
          // String concatenation
          return RuntimeValue.fromString(left.string + right.string);
        } else if (left.type == RuntimeValueType.list && right.type == RuntimeValueType.list) {
          // List concatenation
          return RuntimeValue.fromList(
            <RuntimeValue>[]
              ..addAll(left.list)
              ..addAll(right.list)
          );
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
  RuntimeValue visitCall(CallExpression call) {
    // Evaluate the target
    final RuntimeValue callee = _evaluate(call.callee);

    if (callee.type == RuntimeValueType.function) {
      final Callable callable = callee.function;

      if (call.arguments.length > callable.parameters.length) {
        _error(call.openParen, 
          'Function only has ${callable.parameters.length} parameters '
          'but was given ${call.arguments.length} arguments.'
        );
      }

      final Map<String, RuntimeValue> mappedArguments = {};

      // Evaluate each argument and map them
      for (int i = 0; i < callable.parameters.length; i++) {
        final RuntimeParameter parameter = callable.parameters[i];

        RuntimeValue argValue;

        if (call.arguments.length > i) {
          final Expression argument = call.arguments[i];
          argValue = _evaluate(argument);
        } else {
          // Default missing arguments to their default value or null
          argValue = parameter.defaultValue ?? RuntimeValue.fromNull();
        }
        
        mappedArguments[parameter.name] = argValue;
      }

      // Run the callable
      try {
        return callable.call(this, mappedArguments);
      } on BuiltInFunctionException catch (ex) {
        // Convert built-in function exceptions
        _error(call.openParen, ex.message);
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
          final RuntimeValue value = _evaluate($for.condition);

          if (value.type == RuntimeValueType.boolean) {
            if (!value.boolean) {
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
      final RuntimeValue iterable = _evaluate(foreach.inExpression);

      // Create a scope for the key/value variables
      _currentScope = new Scope(outerScope);

      // Define key and values variables
      _currentScope.define(foreach.keyName.lexeme, RuntimeValue.fromNull());
      
      if (foreach.valueName != null) {
        _currentScope.define(foreach.valueName.lexeme, RuntimeValue.fromNull());
      }

      // Iterate
      if (iterable.type == RuntimeValueType.list) {
        for (int i = 0; i < iterable.list.length; i++) {
          // Update key and value variables
          _currentScope.assign(foreach.keyName, RuntimeValue.fromNumber(i.toDouble()));

          if (foreach.valueName != null) {
            _currentScope.assign(foreach.valueName, iterable.list[i]);
          }

          // Execute the loop body
          try {
            _execute(foreach.body);
          } on _Continue {
            // Loop body was stopped early by a continue statement
          }
        }
      } else if (iterable.type == RuntimeValueType.map) {
        iterable.map.forEach((key, value) {
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
  RuntimeValue visitFunctionExpression(FunctionExpression functionExpression) {
    return RuntimeValue.fromFunction(
      UserFunction(
        parameters: functionExpression.parameters
          .map(_convertToRuntimeParameter)
          .toList(),
        body: functionExpression.body,
        closure: _currentScope,
        name: null // Anonymous functions don't have names
      )
    );
  }

  @override
  void visitFunctionStatement(FunctionStatement functionStatement) {
    final function = new UserFunction(
      parameters: functionStatement.parameters
        .map(_convertToRuntimeParameter)
        .toList(),
      body: functionStatement.body,
      closure: _currentScope,
      name: functionStatement.name.lexeme
    );

    final Scope scope = functionStatement.publicKeyword != null
      ? environment.publicScope
      : _currentScope;

    scope.define(functionStatement.name.lexeme, RuntimeValue.fromFunction(function));
  }

  @override
  RuntimeValue visitGet(GetExpression $get) {
    // Evaluate the target
    final RuntimeValue target = _evaluate($get.target);

    // Evaluate the get
    if (target.type == RuntimeValueType.map) {
      // map.key
      return target.map[RuntimeValue.fromString($get.name.lexeme)];
    } else if (target.type == RuntimeValueType.library) {
      // library.variable
      return target.library.publicScope.get($get.name);
    }

    _error($get.dot, 'Get target must be a map or a library.');
  }

  @override
  RuntimeValue visitGrouping(GroupingExpression grouping) {
    return _evaluate(grouping.expression);
  }

  @override
  void visitIf(IfStatement $if) {
    final RuntimeValue conditionValue = _evaluate($if.condition);

    if (conditionValue.type == RuntimeValueType.boolean) {
      if (conditionValue.boolean) {
        _execute($if.thenStatement);
      } else if ($if.elseStatement != null) {
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
    _currentScope.define(
      $import.asIdentifier.lexeme, 
      RuntimeValue.fromLibrary(importedEnvironment)
    );
  }

  @override
  RuntimeValue visitIndex(IndexExpression indexExpression) {
    final RuntimeValue indexee = _evaluate(indexExpression.indexee);
    final RuntimeValue index = _evaluate(indexExpression.index);

    if (indexee.type == RuntimeValueType.list) {
      // Indexing a list
      if (index.type == RuntimeValueType.number) {
        final int intIndex = index.number.truncate();
        
        if (intIndex == index.number) {
          if (intIndex >= 0 && intIndex < indexee.list.length) {
            return indexee.list[intIndex];
          } else {
            _error(indexExpression.openBracket, 'List index is out of range.');
          }
        }
      }

      _error(indexExpression.openBracket, 'List index must be an integer.');
    } else if (indexee.type == RuntimeValueType.map) {
      // Indexing a map
      if (index.type != RuntimeValueType.$null) {
        return indexee.map[index];
      } else {
        _error(indexExpression.openBracket, 'Map index must not be null.');
      }
    }

    _error(indexExpression.openBracket, 'Only lists and maps can be indexed.');
  }

  @override
  RuntimeValue visitLiteral(LiteralExpression literal) {
    return literal.value;
  }

  @override
  RuntimeValue visitLogical(LogicalExpression logical) {
    final RuntimeValue left = _evaluate(logical.left);

    if (left.type == RuntimeValueType.boolean) {
      // Short-circuit if possible
      if (logical.$operator.type == TokenType.or) {
        if (left.boolean) {
          return RuntimeValue.fromBoolean(true);
        }
      } else {
        if (!left.boolean) {
          return RuntimeValue.fromBoolean(false);
        }
      }

      final RuntimeValue right = _evaluate(logical.right);

      if (right.type == RuntimeValueType.boolean) {
        return right;
      } else {
        _error(logical.$operator, 'Right logical operand must be a boolean.');
      }
    } else {
      _error(logical.$operator, 'Left logical operand must be a boolean.');
    }
  }

  @override
  RuntimeValue visitMap(MapExpression mapExpression) {
    final Map<RuntimeValue, RuntimeValue> map = {};

    // Evaluate each pair and store the results in a map
    for (final MapPair pair in mapExpression.pairs) {
      // Evaluate key
      final Expression keyExpression = pair.key;

      RuntimeValue key;
      if (keyExpression is VariableExpression) {
        // Keys can be identifiers as a shortcut for string keys
        key = RuntimeValue.fromString(keyExpression.name.lexeme);
      } else {
        key = _evaluate(keyExpression);
      }

      // Ensure the evaluated key is not null
      if (key.type == RuntimeValueType.$null) {
        _error(pair.colon, 'Map keys must not be null.');
      }

      // Evaluate value
      RuntimeValue value = _evaluate(pair.value);

      map[key] = value;
    }

    return RuntimeValue.fromMap(map);
  }

  @override
  void visitReturn(ReturnStatement $return) {
    // Evaluate return value if present
    RuntimeValue value;

    if ($return.expression != null) {
      value = _evaluate($return.expression);
    } else {
      value = RuntimeValue.fromNull();
    }

    // Throw a special exception to unwind the stack back to a function call.
    throw Return(value);
  }

  @override
  RuntimeValue visitTernary(TernaryExpression ternary) {
    final RuntimeValue value = _evaluate(ternary.condition);

    if (value.type == RuntimeValueType.boolean) {
      if (value.boolean) {
        return _evaluate(ternary.thenExpression);
      } else {
        return _evaluate(ternary.elseExpression);
      }
    }

    _error(ternary.questionMark, 'Ternary condition must be a boolean.');
  }

  @override
  RuntimeValue visitUnary(UnaryExpression unary) {
    // Post-fix operators
    if (unary.$operator.type == TokenType.plusPlus
      || unary.$operator.type == TokenType.minusMinus
    ) {
      final expression = unary.expression;

      if (expression is VariableExpression) {
        final RuntimeValue value = _lookUpVariable(expression.name, expression);

        if (value.type == RuntimeValueType.number) {
          if (unary.$operator.type == TokenType.plusPlus) {
            // value++
            _currentScope.assign(expression.name, RuntimeValue.fromNumber(value.number + 1));
          } else {
            // value--
            _currentScope.assign(expression.name, RuntimeValue.fromNumber(value.number - 1));
          }
        }

        // Return old value since this is a post-fix increment/decrement
        return value;
      } else {
        _error(unary.$operator, 'Post-fix unary operand must be a variable.');
      }
    }

    // Pre-fix unary operators
    final RuntimeValue value = _evaluate(unary.expression);

    switch (unary.$operator.type) {
      case TokenType.bang:
        // !value
        _checkBooleanOperand(unary.$operator, value);

        return RuntimeValue.fromBoolean(!value.boolean);
      case TokenType.minus:
        // -value
        _checkNumberOperand(unary.$operator, value);

        return RuntimeValue.fromNumber(-value.number);
      case TokenType.hash:
        // #value
        if (value.type == RuntimeValueType.list) {
          return RuntimeValue.fromNumber(value.list.length.toDouble());
        } else if (value.type == RuntimeValueType.map) {
          return RuntimeValue.fromNumber(value.map.length.toDouble());
        } else if (value.type == RuntimeValueType.string) {
          return RuntimeValue.fromNumber(value.string.length.toDouble());
        }

        _error(unary.$operator, 'Unary length operand must be a list, map, or string.');
        break; // Just to make the analyzer happy... _error always throws.
      default:
        _error(unary.$operator, 'Unknown unary operator.');
    }
  }

  @override
  RuntimeValue visitVariable(VariableExpression variable) {
    return _lookUpVariable(variable.name, variable);
  }

  @override
  void visitVariableStatement(VariableStatement variableStatement) {
    // Evaluate initializer if present
    RuntimeValue value;

    if (variableStatement.initializer != null) {
      value = _evaluate(variableStatement.initializer);
    } else {
      value = new RuntimeValue.fromNull();
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
        final RuntimeValue conditionValue = _evaluate($while.condition);

        if (conditionValue.type == RuntimeValueType.boolean) {
          if (!conditionValue.boolean) {
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

  RuntimeParameter _convertToRuntimeParameter(Parameter parameter) {
    return RuntimeParameter(
      parameter.identifier.lexeme,
      defaultValue: parameter.defaultValue == null
        ? null
        : _evaluate(parameter.defaultValue)
    );
  }

  RuntimeValue _evaluate(Expression expression) {
    return expression.accept(this);
  }

  void _execute(Statement statement) {
    statement.accept(this);
  }

  RuntimeValue _lookUpVariable(Token name, Expression expression) {
    final int distance = library.locals[expression];

    if (distance != null) {
      return _currentScope.getAt(distance, name.lexeme);
    } else {
      return environment.libraryScope.get(name);
    }
  }

  void _assignVariable(Token name, Expression expression, RuntimeValue value) {
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
  /// Throws a [RuntimeException] if [value] is not an integer expressed as a number.
  int _checkIntegerOperand(RuntimeValue value, Token token) {
    if (value.type == RuntimeValueType.number) {
      final int intValue = value.number.truncate();

      if (intValue == value.number) {
        return intValue;
      }
    }

    _error(token, 'Value must be an integer.');
  }

  /// Throws a [RuntimeException] if [operand] is not a boolean.
  void _checkBooleanOperand(Token $operator, RuntimeValue operand) {
    if (operand.type == RuntimeValueType.boolean) {
      return;
    }

    _error($operator, 'Operand must be a number.');
  }

  /// Throws a [RuntimeException] if [operand] is not a number.
  void _checkNumberOperand(Token $operator, RuntimeValue operand) {
    if (operand.type == RuntimeValueType.number) {
      return;
    }

    _error($operator, 'Operand must be a number.');
  }

  /// Throws a [RuntimeException] if [left] or [right] is not a number.
  void _checkNumberOperands(Token $operator, RuntimeValue left, RuntimeValue right) {
    if (left.type == RuntimeValueType.number 
      && right.type == RuntimeValueType.number
    ) {
      return;
    }

    _error($operator, 'Operands must be numbers.');
  }
}