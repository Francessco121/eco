import 'dart:async';
import 'dart:collection';

import 'package:source_span/source_span.dart';

import 'ast/ast.dart';
import 'parsing/parse_error.dart';
import 'parsing/parse.dart';
import 'parsing/resolve.dart';
import 'parsing/scan.dart';
import 'runtime/interpreter.dart';
import 'runtime/library_environment.dart';
import 'library.dart';
import 'program.dart';
import 'source_tree.dart';

class UserLibrary implements Library {
  @override
  final Uri? uri;

  final UnmodifiableListView<Statement> statements;

  final UnmodifiableMapView<Expression, int> locals;
  final UnmodifiableListView<String> publicVariables;
  final UnmodifiableMapView<ImportStatement, Uri> imports;

  final UnmodifiableListView<ParseError> parseErrors;

  UserLibrary._({
    required this.uri,
    required this.statements,
    required this.locals,
    required this.publicVariables,
    required this.parseErrors,
    required this.imports
  });

  @override
  void run(Program program, LibraryEnvironment environment) {
    final interpreter = new Interpreter(program, this, environment);

    interpreter.interpret(statements, environment.libraryScope);
  }

  static Future<UserLibrary> create(
    Program program, 
    SourceTreeNode sourceTreeNode, 
    SourceSpan sourceSpan
  ) async {
    final ScanResult scanResult = scan(sourceSpan);
    final ParseResult parseResult = parse(scanResult.tokens);
    
    final ResolveResult resolveResult = await resolve(
      program, 
      sourceTreeNode,
      parseResult.statements
    );

    final List<ParseError> errors = [];

    errors
      ..addAll(scanResult.errors)
      ..addAll(parseResult.errors)
      ..addAll(resolveResult.errors);

    return UserLibrary._(
      uri: sourceSpan.sourceUrl,
      statements: parseResult.statements,
      locals: resolveResult.locals,
      publicVariables: resolveResult.publicVariables,
      parseErrors: UnmodifiableListView(errors),
      imports: resolveResult.imports
    );
  }
}