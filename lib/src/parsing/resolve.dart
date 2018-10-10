import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import '../ast/ast.dart';
import '../library_identifier.dart';
import '../program.dart';
import '../source.dart';
import '../source_tree.dart';
import '../user_library.dart';
import 'parse_error.dart';
import 'token.dart';

Future<ResolveResult> resolve(
  Program program, 
  SourceTreeNode sourceTreeNode,
  List<Statement> statements
) async {
  final resolver = new _Resolver();
  resolver._resolveStatements(statements);

  final _ImportResolveResult importResolveResult = 
    await _resolveImports(
      program, 
      sourceTreeNode, 
      resolver.imports
    );

  return ResolveResult(
    errors: UnmodifiableListView(
      <ParseError>[]
        ..addAll(resolver.errors)
        ..addAll(importResolveResult.parseErrors)
    ),
    locals: UnmodifiableMapView(resolver.locals),
    publicVariables: UnmodifiableListView(resolver.publicVariables),
    imports: UnmodifiableMapView(importResolveResult.imports)
  );
}

class _ImportResolveResult {
  final List<ParseError> parseErrors;
  final Map<ImportStatement, LibraryIdentifier> imports;

  _ImportResolveResult(this.parseErrors, this.imports);
}

Future<_ImportResolveResult> _resolveImports(
  Program program, 
  SourceTreeNode sourceTreeNode,
  List<ImportStatement> imports
) async {
  final List<ParseError> errors = [];
  final Map<ImportStatement, LibraryIdentifier> resolvedImports = {};

  for (final ImportStatement $import in imports) {
    final String importPath = $import.path.literal;

    if (importPath.startsWith('eco:')) {
      // Get the ID of the built-in library
      final String id = importPath.substring(4);

      // Ensure the built-in library is defined
      if (!program.builtInLibraries.containsKey(id)) {
        errors.add(ParseError($import.path.sourceSpan, "The built-in library '$id' is not available."));
        continue;
      }

      // Mark this import as resolved
      resolvedImports[$import] = new LibraryIdentifier.forBuiltInLibrary(id);
    } else {
      // Load the import source
      final Uri importUri = program.sourceResolver.resolvePath(importPath, sourceTreeNode.uri);

      if (importUri == sourceTreeNode.uri) {
        errors.add(ParseError($import.path.sourceSpan, 'Source file cannot import itself.'));
        continue;
      }

      final Source importedSource = await program.loadSource(importUri);

      if (importedSource == null) {
        errors.add(ParseError($import.path.sourceSpan, 'Could not find source from import path.'));
        continue;
      }

      // Check for a cyclic import
      final cyclicParent = sourceTreeNode.getAncestor(importUri);
      if (cyclicParent != null) {
        errors.add(_createCyclicImportError(
          sourceTreeNode,
          $import,
          importUri,
          cyclicParent
        ));

        continue;
      }

      // Create a child node for the imported source
      final SourceTreeNode importedNode = sourceTreeNode.addChild(importUri);

      // Create a library from the imported source
      final UserLibrary library = await program.loadUserLibrary(importedSource, importedNode);
      
      if (library.parseErrors != null) {
        errors.addAll(library.parseErrors);
      }

      // Mark this import as resolved
      resolvedImports[$import] = new LibraryIdentifier.forUserLibrary(importUri);
    }
  }

  return _ImportResolveResult(errors, resolvedImports);
}

ParseError _createCyclicImportError(
  SourceTreeNode sourceTreeNode,
  ImportStatement importStatement,
  Uri importedUri, 
  SourceTreeNode cyclicParent
) {
  final buffer = StringBuffer();
  buffer.writeln('Import would result in cyclic dependencies because');
  buffer.writeln('it imports $importedUri,');

  final Iterable<SourceTreeNode> ancestors = sourceTreeNode
    .getAncestors(untilSourceUri: cyclicParent.uri)
    .reversed;

  for (final SourceTreeNode ancestor in ancestors) {
    buffer.writeln('which imports ${ancestor.uri},');
  }

  buffer.write('which imports ${sourceTreeNode.uri}.');

  return ParseError(importStatement.path.sourceSpan, buffer.toString());
}

class ResolveResult {
  final UnmodifiableListView<ParseError> errors;
  final UnmodifiableMapView<Expression, int> locals;
  final UnmodifiableListView<String> publicVariables;
  final UnmodifiableMapView<ImportStatement, LibraryIdentifier> imports;

  ResolveResult({
    @required this.errors,
    @required this.locals,
    @required this.publicVariables,
    @required this.imports
  });
}

class _Resolver implements ExpressionVisitor<void>, StatementVisitor {
  final List<ParseError> errors = [];
  final Map<Expression, int> locals = {};
  final Set<String> publicVariables = new Set<String>();
  final List<ImportStatement> imports = [];

  bool _inFunction = false;
  bool _inLoop = false;
  bool _inTagContext = false;

  final List<Map<String, bool>> _scopes = [];

  @override
  void visitArray(ArrayExpression array) {
    _resolveExpressions(array.values);
  }

  @override
  void visitAssignment(AssignmentExpression assignment) {
    _resolveExpression(assignment.target);
    _resolveExpression(assignment.value);
  }

  @override
  void visitBinary(BinaryExpression binary) {
    _resolveExpression(binary.left);
    _resolveExpression(binary.right);
  }

  @override
  void visitBlock(BlockStatement block) {
    _blockScope(() {
      _resolveStatements(block.statements);
    });
  }

  @override
  void visitBreak(BreakStatement $break) {
    if (!_inLoop) {
      _addError($break.keyword, 'Cannot break outside of a loop.');
    }
  }

  @override
  void visitCall(CallExpression call) {
    _resolveExpression(call.callee);
    
    _resolveExpressions(call.arguments.positional);
    _resolveExpressions(call.arguments.named.values);
  }

  @override
  void visitContinue(ContinueStatement $continue) {
    if (!_inLoop) {
      _addError($continue.keyword, 'Cannot continue outside of a loop.');
    }
  }

  @override
  void visitExpressionStatement(ExpressionStatement expressionStatement) {
    _resolveExpression(expressionStatement.expression);
  }

  @override
  void visitFor(ForStatement $for) {
    _loopScope(() {
      if ($for.initializer != null) {
        _resolveStatement($for.initializer);
      }

      if ($for.condition != null) {
        _resolveExpression($for.condition);
      }

      if ($for.afterthought != null) {
        _resolveExpression($for.afterthought);
      }

      _resolveStatement($for.body);
    });
  }

  @override
  void visitForeach(ForeachStatement foreach) {
    // Resolve the 'in expression' before we enter the loop's scope
    _resolveExpression(foreach.inExpression);

    _loopScope(() {
      _declare(foreach.keyName);
      _define(foreach.keyName);

      if (foreach.valueName != null) {
        _declare(foreach.valueName);
        _define(foreach.valueName);
      }

      _resolveStatement(foreach.body);
    });
  }

  @override
  void visitFunctionExpression(FunctionExpression functionExpression) {
    _functionScope(() {
      for (final Parameter parameter in functionExpression.parameters) {
        _declare(parameter.identifier);
        _define(parameter.identifier);
      }

      _resolveStatements(functionExpression.body);
    });
  }

  @override
  void visitFunctionStatement(FunctionStatement functionStatement) {
    if (functionStatement.publicKeyword != null) {
      if (_scopes.isEmpty) {
        publicVariables.add(functionStatement.name.lexeme);
      } else {
        _addError(functionStatement.publicKeyword, 
          'Only top-level functions can be public.'
        );
      }
    }

    _declare(functionStatement.name);
    _define(functionStatement.name);

    _functionScope(() {
      for (final Parameter parameter in functionStatement.parameters) {
        _declare(parameter.identifier);
        _define(parameter.identifier);
      }

      _resolveStatements(functionStatement.body);
    });
  }

  @override
  void visitGet(GetExpression $get) {
    _resolveExpression($get.target);
  }

  @override
  void visitGrouping(GroupingExpression grouping) {
    _resolveExpression(grouping.expression);
  }

  @override
  void visitHtml(HtmlExpression html) {
    _tagContext(() {
      _resolveStatements(html.body);
    });
  }

  @override
  void visitIf(IfStatement $if) {
    _resolveExpression($if.condition);
    _resolveStatement($if.thenStatement);

    if ($if.elseStatement != null) {
      _resolveStatement($if.elseStatement);
    }
  }

  @override
  void visitImport(ImportStatement $import) {
    if (_scopes.isNotEmpty) {
      _addError($import.keyword, 'Imports can only be specified at the top-level scope.');
    }

    imports.add($import);

    _declare($import.asIdentifier);
    _define($import.asIdentifier);
  }

  @override
  void visitIndex(IndexExpression index) {
    _resolveExpression(index.indexee);
    _resolveExpression(index.index);
  }

  @override
  void visitLiteral(_) { }

  @override
  void visitLogical(LogicalExpression logical) {
    _resolveExpression(logical.left);
    _resolveExpression(logical.right);
  }

  @override
  void visitMap(MapExpression map) {
    for (final MapPair pair in map.pairs) {
      _resolveExpression(pair.key);
      _resolveExpression(pair.value);
    }
  }

  @override
  void visitReturn(ReturnStatement $return) {
    if (!_inFunction) {
      _addError($return.keyword, 'Cannot return outside of a function.');
    }

    if ($return.expression != null) {
      _resolveExpression($return.expression);
    }
  }

  @override
  void visitTag(TagStatement tag) {
    if (!_inTagContext) {
      _addError(tag.keyword, 'Cannot use tags outside of tag context.');
    }

    if (tag.body != null) {
      _resolveStatements(tag.body);
    }
  }

  @override
  void visitTernary(TernaryExpression ternary) {
    _resolveExpression(ternary.condition);
    _resolveExpression(ternary.thenExpression);
    _resolveExpression(ternary.elseExpression);
  }

  @override
  void visitUnary(UnaryExpression unary) {
    _resolveExpression(unary.expression);
  }

  @override
  void visitVariable(VariableExpression variable) {
    _resolveLocal(variable, variable.name);
  }

  @override
  void visitVariableStatement(VariableStatement variableStatement) {
    if (variableStatement.publicKeyword != null) {
      if (_scopes.isEmpty) {
        publicVariables.add(variableStatement.name.lexeme);
      } else {
        _addError(variableStatement.publicKeyword, 
          'Only top-level variables can be public.'
        );
      }
    }

    if (variableStatement.initializer != null) {
      _resolveExpression(variableStatement.initializer);
    }

    _declare(variableStatement.name);
    _define(variableStatement.name);
  }

  @override
  void visitWhile(WhileStatement $while) {
    _loopScope(() {
      _resolveExpression($while.condition);
      _resolveStatement($while.body);
    });
  }

  @override
  void visitWrite(WriteStatement write) {
    if (!_inTagContext) {
      _addError(write.keyword, 'Cannot use write outside of tag context.');
    }

    _resolveExpression(write.expression);
  }

  void _blockScope(Function callback) {
    _beginScope();

    callback();

    _endScope();
  }

  void _loopScope(Function callback) {
    bool prevInLoop = _inLoop;
    _inLoop = true;

    _beginScope();

    callback();

    _endScope();

    _inLoop = prevInLoop;
  }

  void _functionScope(Function callback) {
    bool prevInFunction = _inFunction;
    bool prevInTagContext = _inTagContext;

    _inFunction = true;
    _inTagContext = false;

    _beginScope();

    callback();

    _endScope();

    _inFunction = prevInFunction;
    _inTagContext = prevInTagContext;
  }

  void _tagContext(Function callback) {
    bool prevInLoop = _inLoop;
    bool prevInFunction = _inFunction;
    bool prevInTagContext = _inTagContext;

    _inLoop = false;
    _inFunction = false;
    _inTagContext = true;

    callback();

    _inLoop = prevInLoop;
    _inFunction = prevInFunction;
    _inTagContext = prevInTagContext;
  }

  void _resolveExpression(Expression expression) {
    expression.accept(this);
  }

  void _resolveExpressions(Iterable<Expression> expressions) {
    for (final Expression expression in expressions) {
      expression.accept(this);
    }
  }

  void _resolveStatement(Statement statement) {
    statement.accept(this);
  }

  void _resolveStatements(List<Statement> statements) async {
    for (final Statement statement in statements) {
      statement.accept(this);
    }
  }

  void _resolveLocal(Expression expression, Token name) {
    for (int i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(name.lexeme)) {
        locals[expression] = _scopes.length - 1 - i;
        return;
      }
    }

    // Not found, assume it is global
  }

  void _beginScope() {
    _scopes.add({});
  }

  void _endScope() {
    _scopes.removeLast();
  }

  void _declare(Token name) {
    if (_scopes.isEmpty) {
      return;
    }

    Map<String, bool> scope = _scopes.last;

    if (scope.containsKey(name.lexeme)) {
      _addError(name, 'Cannot redefine a variable in the same scope.');
    }

    scope[name.lexeme] = false;
  }

  void _define(Token name) {
    if (_scopes.isEmpty) {
      return;
    }

    _scopes.last[name.lexeme] = true;
  }

  void _addError(Token token, String message) {
    errors.add(ParseError(token.sourceSpan, message));
  }
}