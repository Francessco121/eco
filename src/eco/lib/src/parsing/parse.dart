import 'dart:collection';

import 'package:meta/meta.dart';

import '../ast/ast.dart';
import 'parse_error.dart';
import 'token.dart';
import 'token_type.dart';

/// Parses a list of Eco [tokens] into a list of [Statement]s.
ParseResult parse(List<Token> tokens) {
  if (tokens == null) throw ArgumentError.notNull('tokens');

  final parser = _Parser(tokens);
  
  return parser.parse();
}

class ParseResult {
  final UnmodifiableListView<ParseError> errors;
  final UnmodifiableListView<Statement> statements;

  ParseResult({
    @required this.statements,
    @required this.errors
  })
    : assert(statements != null),
      assert(errors != null);
}

class _ParseException implements Exception { }

class _Parser {
  int _current = 0;

  final List<ParseError> _errors = [];

  final List<Token> _tokens;

  _Parser(this._tokens);
  
  ParseResult parse() {
    final List<Statement> statements = [];

    // Parse until EOF
    while (!_isAtEnd()) {
      try {
        statements.add(_declaration());
      } on _ParseException {
        // Skip until beginning of new statement
        _synchronize();
      }
    }

    // Parse complete!
    return ParseResult(
      statements: UnmodifiableListView(statements),
      errors: UnmodifiableListView(_errors)
    );
  }

  Statement _declaration() {
    if (_check(TokenType.import)) {
      // Import
      return _import();
    } else if (_check(TokenType.function)) {
      // Function
      return _function();
    } else if (_check(TokenType.$var)) {
      // Variable
      return _variableDeclaration();
    } else if (_check(TokenType.public)) {
      final Token publicKeyword = _advance();

      if (_check(TokenType.function)) {
        // Public function
        return _function(publicKeyword);
      } else if (_check(TokenType.$var)) {
        // Public variable
        return _variableDeclaration(publicKeyword);
      } else {
        throw _error(_advance(), "Expected function or variable declaration after 'pub'.");
      }
    } else {
      // Fallback to statement
      return _statement();
    }
  }

  ImportStatement _import() {
    final Token keyword = _advance();

    final Token path = _consume(TokenType.string,
      'Expected import path string.'
    );

    Token asKeyword;
    Token asIdentifier;

    if (_check(TokenType.$as)) {
      asKeyword = _advance();

      asIdentifier = _consume(TokenType.identifier, 
        "Expected 'as' identifier."
      );
    }

    _consume(TokenType.semicolon, "Expected ';' to end import statement.");

    return ImportStatement(keyword, path, asKeyword, asIdentifier);
  }

  FunctionStatement _function([Token publicKeyword]) {
    // Consume 'fn'
    _advance();

    final Token identifier = _consume(TokenType.identifier, 
      "Expected function identifier after 'fn'."
    );

    _consume(TokenType.leftParen, "Expected '(' to begin function parameter list.");

    final List<Token> parameters = _parameters();

    _consume(TokenType.rightParen, "Expected ')' to end function parameter list.");
    _consume(TokenType.leftBrace, "Expected '{' to begin function body.");

    final List<Statement> body = [];

    while (!_match(TokenType.rightBrace)) {
      body.add(_declaration());
    }

    return FunctionStatement(identifier, parameters, body, publicKeyword: publicKeyword);
  }

  VariableStatement _variableDeclaration([Token publicKeyword]) {
    // Consume 'var'
    _advance();

    final Token identifier = _consume(TokenType.identifier, 
      "Expected variable identifier after 'var'."
    );

    Expression initializer;
    if (_match(TokenType.equal)) {
      initializer = _expression();
    }

    _consume(TokenType.semicolon, "Expected ';' after variable declaration.");

    return VariableStatement(identifier,
      initializer: initializer,
      publicKeyword: publicKeyword
    );
  }

  Statement _statement() {
    final TokenType type = _peek().type;

    switch (type) {
      case TokenType.leftBrace: return _block();
      case TokenType.$break: return _break();
      case TokenType.$continue: return _continue();
      case TokenType.$for: return _for();
      case TokenType.foreach: return _foreach();
      case TokenType.$if: return _if();
      case TokenType.$return: return _return();
      case TokenType.$while: return _while();
      default:
        return _expressionStatement();
    }
  }

  BlockStatement _block() {
    // Consume '{'
    _advance();

    final List<Statement> body = [];

    while (!_match(TokenType.rightBrace)) {
      body.add(_declaration());
    }

    return BlockStatement(body);
  }

  BreakStatement _break() {
    // Consume 'break'
    final Token keyword = _advance();

    _consume(TokenType.semicolon, "Expected ';' after 'break'.");

    return BreakStatement(keyword);
  }

  ContinueStatement _continue() {
    // Consume 'continue'
    final Token keyword = _advance();

    _consume(TokenType.semicolon, "Expected ';' after 'continue'.");

    return ContinueStatement(keyword);
  }

  ForStatement _for() {
    // Consume 'for'
    final Token keyword = _advance();

    // Parse initializer
    Statement initializer;
    if (_check(TokenType.$var)) {
      initializer = _variableDeclaration();
    } else if (!_match(TokenType.semicolon)) {
      initializer = _expressionStatement();
    }

    // Parse condition
    Expression condition;
    if (!_match(TokenType.semicolon)) {
      condition = _expression();
      _consume(TokenType.semicolon, "Expected ';' after for condition.");
    }

    // Parse afterthought
    Expression afterthought;
    if (!_check(TokenType.leftBrace)) {
      afterthought = _expression();
    }

    // Parse body
    if (!_check(TokenType.leftBrace)) {
      throw _error(_advance(), "Expected '{' to begin for loop body.");
    }

    BlockStatement body = _block();

    // Done
    return ForStatement(
      keyword: keyword,
      initializer: initializer,
      condition: condition,
      afterthought: afterthought,
      body: body
    );
  }

  ForeachStatement _foreach() {
    // Consume 'foreach'
    _advance();

    // Parse key/value identifiers
    final Token keyIdentifier = _consume(TokenType.identifier, 
      'Expected foreach key identifier.'
    );

    Token valueIdentifier;
    if (_match(TokenType.comma)) {
      valueIdentifier = _consume(TokenType.identifier,
        "Expected foreach value identifier after ','."
      );
    }

    // Parse in expression
    final Token inKeyword = _consume(TokenType.$in,
      "Expected 'in' after foreach identifiers."
    );

    final Expression inExpression = _expression();

    // Parse body
    if (!_check(TokenType.leftBrace)) {
      throw _error(_advance(), "Expected '{' to begin foreach loop body.");
    }

    BlockStatement body = _block();

    // Done
    return ForeachStatement(
      keyName: keyIdentifier,
      valueName: valueIdentifier,
      inKeyword: inKeyword,
      inExpression: inExpression,
      body: body
    );
  }

  IfStatement _if() {
    // Consume 'if'
    final Token keyword = _advance();

    // Parse condition
    final Expression condition = _expression();

    // Parse then statement
    if (!_check(TokenType.leftBrace)) {
      throw _error(_advance(), "Expected '{' to begin if then statement.");
    }

    BlockStatement thenStatement = _block();

    // Parse else statement
    Statement elseStatement;
    if (_match(TokenType.$else)) {
      if (_check(TokenType.$if)) {
        // Else if
        elseStatement = _if();
      } else {
        if (!_check(TokenType.leftBrace)) {
          throw _error(_advance(), "Expected '{' to begin if else statement.");
        }

        elseStatement = _block();
      }
    }

    // Done
    return IfStatement(keyword, condition, thenStatement, elseStatement);
  }

  ReturnStatement _return() {
    // Consume 'return'
    final Token keyword = _advance();

    // Parse expression
    Expression expression;
    if (!_match(TokenType.semicolon)) {
      expression = _expression();

      // Consume ';'
      _consume(TokenType.semicolon, "Expected ';' after return expression.");
    }

    return ReturnStatement(keyword, expression);
  }

  WhileStatement _while() {
    // Consume 'while'
    final Token keyword = _advance();

    // Parse condition
    final Expression condition = _expression();

    // Parse body
    if (!_check(TokenType.leftBrace)) {
      throw _error(_advance(), "Expected '{' to begin while body.");
    }

    BlockStatement body = _block();

    return WhileStatement(keyword, condition, body);
  }

  ExpressionStatement _expressionStatement() {
    // Parse expression
    final Expression expression = _expression();

    // Consume ';'
    _consume(TokenType.semicolon, "Expected ';' after expression.");

    return ExpressionStatement(expression);
  }

  Expression _expression() {
    return _assignment();
  }

  Expression _assignment() {
    final Expression expression = _ternary();

    if (_check(TokenType.equal)) {
      final Token equal = _advance();

      final Expression value = _expression();

      if (expression is VariableExpression 
        || expression is GetExpression 
        || expression is IndexExpression
      ) {
        return AssignmentExpression(expression, value, equal);
      }

      throw _error(equal, 
        'The left-hand of an assignment must be a variable, setter, or indexer.'
      );
    }

    return expression;
  }

  Expression _ternary() {
    final Expression expression = _concatenation();

    if (_check(TokenType.question)) {
      final Token questionMark = _advance();

      final Expression thenExpression = _expression();

      final Token colon = _consume(TokenType.colon,
        "Expected ':' to begin ternary else expression."
      );

      final Expression elseExpression = _expression();

      return TernaryExpression(
        condition: expression, 
        thenExpression: thenExpression, 
        elseExpression: elseExpression, 
        questionMark: questionMark, 
        colon: colon
      );
    }

    return expression;
  }

  Expression _concatenation() {
    Expression expression = _or();

    while (_check(TokenType.dotDot)) {
      final Token $operator = _advance();
      final Expression right = _or();

      expression = BinaryExpression(expression, right, $operator);
    }

    return expression;
  }

  Expression _or() {
    Expression expression = _and();

    while (_check(TokenType.or)) {
      final Token $operator = _advance();
      final Expression right = _and();

      expression = LogicalExpression(expression, right, $operator);
    }

    return expression;
  }

  Expression _and() {
    Expression expression = _equality();

    while (_check(TokenType.and)) {
      final Token $operator = _advance();
      final Expression right = _equality();

      expression = LogicalExpression(expression, right, $operator);
    }

    return expression;
  }

  Expression _equality() {
    Expression expression = _comparison();

    while (_checkAny(const [TokenType.equalEqual, TokenType.bangEqual])) {
      final Token $operator = _advance();
      final Expression right = _comparison();

      expression = BinaryExpression(expression, right, $operator);
    }

    return expression;
  }

  Expression _comparison() {
    Expression expression = _addition();

    while (_checkAny(const [
      TokenType.greater, 
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual
    ])) {
      final Token $operator = _advance();
      final Expression right = _addition();

      expression = BinaryExpression(expression, right, $operator);
    }

    return expression;
  }

  Expression _addition() {
    Expression expression = _multiplication();

    while (_checkAny(const [TokenType.plus, TokenType.minus])) {
      final Token $operator = _advance();
      final Expression right = _multiplication();

      expression = BinaryExpression(expression, right, $operator);
    }

    return expression;
  }

  Expression _multiplication() {
    Expression expression = _unary();

    while (_checkAny(const [TokenType.star, TokenType.forwardSlash])) {
      final Token $operator = _advance();
      final Expression right = _unary();

      expression = BinaryExpression(expression, right, $operator);
    }

    return expression;
  }

  Expression _unary() {
    if (_checkAny(const [TokenType.bang, TokenType.minus, TokenType.hash])) {
      // Left-unary
      final Token $operator = _advance();
      final Expression expression = _unary();

      return UnaryExpression(expression, $operator);
    } else {
      // Right-unary or no unary
      Expression expression = _value();

      while (_checkAny(const [TokenType.plusPlus, TokenType.minusMinus])) {
        final Token $operator = _advance();

        expression = UnaryExpression(expression, $operator);
      }

      return expression;
    }
  }

  Expression _value() {
    return _functionExpression();
  }

  Expression _functionExpression() {
    if (_match(TokenType.function)) {
      // Consume '('
      _consume(TokenType.leftParen,
        "Expected '(' to begin function parameter list."
      );

      // Parse parameter list
      final List<Token> parameters = _parameters();

      // Consume ')'
      _consume(TokenType.rightParen,
        "Expected ')' to end function parameter list."
      );

      // Parse body
      _consume(TokenType.leftBrace,
        "Expected '{' to begin function body."
      );

      final List<Statement> body = [];

      while (!_match(TokenType.rightBrace)) {
        body.add(_declaration());
      }

      return FunctionExpression(parameters, body);
    }

    return _map();
  }

  List<Token> _parameters() {
    final List<Token> identifiers = [];

    while (_check(TokenType.identifier)) {
      identifiers.add(_advance());

      if (!_match(TokenType.comma)) {
        break;
      }
    }

    return identifiers;
  }

  Expression _map() {
    if (_match(TokenType.leftBrace)) {
      // Parse key-value-pairs
      final List<MapPair> pairs = [];

      while (!_check(TokenType.rightBrace) && !_isAtEnd()) {
        do {
          pairs.add(_mapPair());
        } while (_match(TokenType.comma));
      }

      // Consume '}'
      _consume(TokenType.rightBrace,
        "Expected '}' to end map expression."
      );

      return MapExpression(pairs);
    }
    
    return _array();
  }

  MapPair _mapPair() {
    final Expression keyExpression = _expression();

    final Token colon = _consume(TokenType.colon,
      "Expected ':' to begin pair value expression."
    );

    final Expression valueExpression = _expression();

    return MapPair(keyExpression, valueExpression, colon);
  }

  Expression _array() {
    if (_match(TokenType.leftBracket)) {
      // Parse array values
      final List<Expression> values = [];

      while (!_match(TokenType.rightBracket)) {
        do {
          values.add(_expression());
        } while (_match(TokenType.comma));
      }

      return ArrayExpression(values);
    }
    
    return _access();
  }

  Expression _access() {
    Expression expression = _primary();

    access_while: while (true) {
      final TokenType type = _peek().type;

      switch (type) {
        case TokenType.dot:
          expression = _get(expression);
          break;
        case TokenType.leftBracket:
          expression = _index(expression);
          break;
        case TokenType.leftParen:
          expression = _call(expression);
          break;
        default:
          break access_while;
      }
    }

    return expression;
  }

  GetExpression _get(Expression target) {
    final Token dot = _advance();

    // Parse getter name
    final Token identifier = _consume(TokenType.identifier,
      "Expected identifier after '.'."
    );

    return GetExpression(target, identifier, dot);
  }

  IndexExpression _index(Expression target) {
    final Token leftBracket = _advance();

    // Parse index
    final Expression index = _expression();

    _consume(TokenType.rightBracket,
      "Expected ']' after index expression."
    );

    return IndexExpression(target, index, leftBracket);
  }

  CallExpression _call(Expression target) {
    final Token leftParen = _advance();

    // Parse arguments
    final List<Expression> arguments = _arguments();

    _consume(TokenType.rightParen,
      "Expected ')' after call arguments."
    );

    return CallExpression(target, arguments, leftParen);
  }

  List<Expression> _arguments() {
    final List<Expression> args = [];

    while (!_check(TokenType.rightParen)) {
      args.add(_expression());

      if (!_match(TokenType.comma)) {
        break;
      }
    }

    return args;
  }

  Expression _primary() {
    if (_check(TokenType.identifier)) {
      return VariableExpression(_advance());
    }

    if (_checkAny(const [TokenType.number, TokenType.string])) {
      return LiteralExpression(_advance().literal);
    }

    if (_match(TokenType.$false)) return LiteralExpression(false);
    if (_match(TokenType.$true)) return LiteralExpression(true);
    if (_match(TokenType.$null)) return LiteralExpression(null);

    if (_match(TokenType.leftParen)) {
      final Expression expression = _expression();

      _consume(TokenType.rightParen, "Expected ')' to end grouping expression.");

      return GroupingExpression(expression);
    }

    throw _error(_advance(), 'Expected expression.');
  }

  void _synchronize() {
    // Skip until semicolon or EOF
    if (_current > 0 && _previous().type == TokenType.semicolon) {
      return;
    }

    while (true) {
      final Token token = _advance();

      if (token.type == TokenType.semicolon || token.type == TokenType.eof) {
        break;
      }
    }
  }

  _ParseException _error(Token token, String message) {
    _errors.add(ParseError(token.sourceSpan, message));

    return _ParseException();
  }

  /// Checks if the current token is of the given [type].
  /// 
  /// If it does match, this method consumes it and returns `true`, otherwise it does
  /// not advance and returns `false`.
  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }

    return false;
  }

  /// Consumes the current token if it is of the given [type]
  /// and returns the next token.
  /// 
  /// Otherwise, throws a [_ParseException] and adds an error
  /// with the given [errorMessage].
  Token _consume(TokenType type, String errorMessage) {
    if (_check(type)) {
      return _advance();
    }

    throw _error(_peek(), errorMessage);
  }

  /// Returns whether the current token is of the given [type].
  bool _check(TokenType type) {
    return _peek().type == type;
  }

  /// Returns whether the current token is of any of the given [types].
  bool _checkAny(List<TokenType> types) {
    final TokenType currentType = _peek().type;

    for (TokenType type in types) {
      if (type == currentType) {
        return true;
      }
    }

    return false;
  }

  /// Consumes the current token and returns it.
  Token _advance() {
    if (_isAtEnd()) {
      return _peek();
    } else {
      _current++;
      return _previous();
    }
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.eof;
  }

  /// Returns the current token.
  Token _peek() {
    return _tokens[_current];
  }

  Token _previous() {
    return _tokens[_current - 1];
  }
}