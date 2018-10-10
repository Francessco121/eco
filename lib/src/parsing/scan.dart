import 'dart:collection';

import 'package:charcode/charcode.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import 'parse_error.dart';
import 'token.dart';
import 'token_type.dart';

/// A map of literal keywords to their respected [TokenType].
const Map<String, TokenType> _keywords = {
  'as': TokenType.$as,
  'break': TokenType.$break,
  'continue': TokenType.$continue,
  'fn': TokenType.function,
  'return': TokenType.$return,
  'var': TokenType.$var,
  'for': TokenType.$for,
  'foreach': TokenType.foreach,
  'if': TokenType.$if,
  'else': TokenType.$else,
  'while': TokenType.$while,
  'import': TokenType.import,
  'in': TokenType.$in,
  'and': TokenType.and,
  'or': TokenType.or,
  'null': TokenType.$null,
  'true': TokenType.$true,
  'false': TokenType.$false,
  'pub': TokenType.public,
  'html': TokenType.html,
  'tag': TokenType.tag,
  'with': TokenType.$with,
  'write': TokenType.write
};

/// Scans the Eco [source] into a list of [Token]s.
ScanResult scan(SourceSpan source) {
  if (source == null) throw new ArgumentError.notNull('source');

  final scanner = _Scanner(source);
  
  return scanner.scan();
}

class ScanResult {
  final UnmodifiableListView<ParseError> errors;
  final UnmodifiableListView<Token> tokens;

  const ScanResult({
    @required this.tokens,
    @required this.errors
  });
}

class _Scanner {
  /// The offset which [_lexemeBuffer] currently starts at.
  int _startOffset;
  /// The column which [_lexemeBuffer] currently starts at.
  int _startColumn;
  /// The line which [_lexemeBuffer] currently starts at.
  int _startLine;

  int _currentOffset = 0;
  int _currentLine = 0;
  int _currentColumn = 0;

  int _current;

  final List<Token> _tokens = [];
  final List<ParseError> _errors = [];
  final StringBuffer _lexemeBuffer = StringBuffer();

  final StringScanner _scanner;

  _Scanner(SourceSpan source)
    : assert(source != null),
      _scanner = StringScanner(source.text, sourceUrl: source.sourceUrl);

  ScanResult scan() {
    // Prep
    _current = _read();

    // Read until EOF
    while (!_isAtEnd()) {
      _lexemeBuffer.clear();
      _scanToken();
    }

    // Add EOF token
    final location = SourceLocation(
      _currentOffset,
      column: _currentColumn,
      line: _currentLine,
      sourceUrl: _scanner.sourceUrl
    );

    _tokens.add(Token(
      sourceSpan: SourceSpan(location, location, ''),
      type: TokenType.eof
    ));

    // Scan complete!
    return ScanResult(
      tokens: UnmodifiableListView(_tokens),
      errors: UnmodifiableListView(_errors)
    );
  }

  void _scanToken() {
    // Read the next character
    int char = _advance();

    // Reset the starting positions
    _startOffset = _currentOffset;
    _startColumn = _currentColumn;
    _startLine = _currentLine;

    // Determine what to scan based on the first character
    switch (char) {
      case $lparen: _addToken(TokenType.leftParen); break;
      case $rparen: _addToken(TokenType.rightParen); break;
      case $lbracket: _addToken(TokenType.leftBracket); break;
      case $rbracket: _addToken(TokenType.rightBracket); break;
      case $lbrace: _addToken(TokenType.leftBrace); break;
      case $rbrace: _addToken(TokenType.rightBrace); break;
      case $semicolon: _addToken(TokenType.semicolon); break;
      case $colon: _addToken(TokenType.colon); break;
      case $comma: _addToken(TokenType.comma); break;
      case $question: _addToken(TokenType.question); break;
      case $asterisk: _addToken(TokenType.star); break;
      case $hash: _addToken(TokenType.hash); break;
      case $percent: _addToken(TokenType.percent); break;
      case $dot: _addToken(_match($dot) ? TokenType.dotDot : TokenType.dot); break;
      case $equal: _addToken(_match($equal) ? TokenType.equalEqual : TokenType.equal); break;
      case $exclamation: _addToken(_match($equal) ? TokenType.bangEqual : TokenType.bang); break;
      case $greater_than: _addToken(_match($equal) ? TokenType.greaterEqual : TokenType.greater); break;
      case $less_than: _addToken(_match($equal) ? TokenType.lessEqual : TokenType.less); break;
      case $minus: _addToken(_match($minus) ? TokenType.minusMinus : TokenType.minus); break;
      case $plus: _addToken(_match($plus) ? TokenType.plusPlus : TokenType.plus); break;
      case $slash:
        if (_match($slash)) {
          _singleLineComment();
        } else if (_match($asterisk)) {
          _multiLineComment();
        } else {
          _addToken(TokenType.forwardSlash);
        }

        break;
      case $quote:
        _string(doubleQuote: true);
        break;
      case $single_quote:
        _string(doubleQuote: false);
        break;
      case $space:
      case $tab:
        // Visible whitespace
        _currentOffset++;
        _currentColumn++;
        break;
      case $cr:
        // Invisible whitespace
        break;
      case $lf:
        // New line
        _currentOffset++;
        _currentColumn = 0;
        _currentLine++;
        break;
      default:
        if (_isDigit(char)) {
          _number();
        } else if (_isAlpha(char)) {
          _identifierOrKeyword();
        } else {
          _currentOffset++;
          _currentColumn++;
          _addError('Unexpected character.');
        }

        break;
    }
  }

  void _singleLineComment() {
    // A comment goes until the end of the line
    while (_peek() != $lf && !_isAtEnd()) {
      _advance();
    }
  }

  void _multiLineComment() {
    // A multiline comment goes until "*/"
    while (_peek() != $asterisk && _peekNext() != $slash && !_isAtEnd()) {
      final int char = _advance();

      // Update source offsets
      _currentOffset++;

      if (char == $lf) {
        _currentLine++;
        _currentColumn = 0;
      }
      else if (char != $cr) {
        _currentColumn++;
      }
    }

    // Consume "*/"
    if (!_isAtEnd()) {
      _advance();
      _advance();

      _currentOffset += 2;
      _currentColumn += 2;
    } else {
      _addError('Unterminated multi-line comment.');
    }
  }

  void _number() {
    // Read integer part
    while (_isDigit(_peek())) {
      _advance();
    }

    // Look for a fractional part
    if (_peek() == $dot && _isDigit(_peekNext())) {
      // Consume the "."
      _advance();

      // Read the fractional part
      while (_isDigit(_peek())) {
        _advance();
      }
    }

    // Build the literal
    final String lexeme = _lexemeBuffer.toString();
    final double literal = double.tryParse(lexeme);

    // Add the token
    _addToken(TokenType.number, literal: literal ?? 0);

    // Note: Do this after adding the token so the character positions are correct for the source span
    if (literal == null) {
      _addError('Invalid number.', currentLexeme: lexeme);
    }
  }

  void _identifierOrKeyword() {
    // Read all alpha-numeric characters
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final String lexeme = _lexemeBuffer.toString();

    // Check if the text is a keyword, otherwise fallback to an identifier
    TokenType type = _keywords[lexeme] ?? TokenType.identifier;

    // Add the token
    _addToken(type, currentLexeme: lexeme);
  }
  
  void _string({@required bool doubleQuote}) {
    assert(doubleQuote != null);

    final int quoteChar = doubleQuote ? $quote : $single_quote;

    // Note: We manually increment positions here because strings can be multiline,
    // and [_addToken] does not handle newlines.

    // Handle the starting quote
    _currentOffset++;
    _currentColumn++;

    // Read until end of string or EOF
    final literalBuffer = new StringBuffer();
    bool justEscaped = false;
    int lastChar;

    while (!_isAtEnd()) {
      if (!justEscaped && lastChar == $backslash) {
        // Don't let quotes terminate the string for this iteration
        justEscaped = true;
      } else if (_peek() == quoteChar) {
        // String ended with a quote without a backslash prior
        break;
      } else {
        // Allow backslashes to escape quotes next iteration
        justEscaped = false;
      }

      // Update source offsets
      _currentOffset++;

      if (_peek() == $lf) {
        _currentLine++;
        _currentColumn = 0;
      } else {
        _currentColumn++;
      }

      // Read the next char
      final int char = _advance();

      // Handle escape sequences
      if (justEscaped) {
        switch (char) {
          // \\
          case $backslash:
            literalBuffer.writeCharCode($backslash);
            break;
          // \"
          case $quote:
            literalBuffer.writeCharCode($quote);
            break;
          // \"
          case $single_quote:
            literalBuffer.writeCharCode($single_quote);
            break;
          // \n
          case $n:
            literalBuffer.writeCharCode($lf);
            break;
          // \r
          case $r:
            literalBuffer.writeCharCode($cr);
            break;
          // \t
          case $t:
            literalBuffer.writeCharCode($tab);
            break;
          default:
            final int lexemeIndex = _currentOffset - _startOffset;

            _addError('Unexpected escape sequence.', 
              span: SourceSpan(
                SourceLocation(
                  _currentOffset - 2,
                  column: _currentColumn - 2,
                  line: _currentLine,
                  sourceUrl: _scanner.sourceUrl
                ),
                SourceLocation(
                  _currentOffset,
                  column: _currentColumn,
                  line: _currentLine,
                  sourceUrl: _scanner.sourceUrl
                ),
                _lexemeBuffer
                  .toString()
                  .substring(lexemeIndex - 2, lexemeIndex)
              )
            );

            break;
        }
      } else if (char != $backslash) {
        literalBuffer.writeCharCode(char);
      }

      // Save the last char so we can handle escape sequences
      lastChar = char;
    }

    // Check if it's an unterminated string
    if (_isAtEnd()) {
      _addError('Unterminated string.');
      return;
    }

    // Consume the closing quote
    _advance();
    _currentOffset++;
    _currentColumn++;

    // Build the lexeme
    final String lexeme = _lexemeBuffer.toString();

    // Build the literal
    final String literal = literalBuffer.toString();
    
    // Create start and end source locations
    final SourceSpan span = _createSourceSpanForCurrent(lexeme);

    // Manually add the token
    _tokens.add(Token(
      type: TokenType.string,
      literal: literal,
      sourceSpan: span
    ));
  }

  /// Note: Pass the [currentLexeme] if it has already been read to avoid redundency,
  /// otherwise this call will build it from the [_lexemeBuffer].
  void _addError(String message, {SourceSpan span, String currentLexeme}) {
    span ??= _createSourceSpanForCurrent(currentLexeme);

    _errors.add(ParseError(span, message));
  }

  /// Note: Pass the [currentLexeme] if it has already been read to avoid redundency,
  /// otherwise this call will build it from the [_lexemeBuffer].
  void _addToken(TokenType type, {Object literal, String currentLexeme}) {
    // Build the lexeme if not already build
    currentLexeme ??= _lexemeBuffer.toString();

    // Increment the column and offset position
    _currentOffset += currentLexeme.length;
    _currentColumn += currentLexeme.length;

    // Create start and end source locations
    final SourceSpan span = _createSourceSpanForCurrent(currentLexeme);

    // Add the token
    _tokens.add(Token(
      type: type,
      literal: literal,
      sourceSpan: span
    ));
  }

  /// Creates a [SourceSpan] representing the current scanner positions.
  /// 
  /// Pass the [currentLexeme] if it has already been read to avoid redundency,
  /// otherwise this call will build it from the [_lexemeBuffer].
  SourceSpan _createSourceSpanForCurrent([String currentLexeme]) {
    return SourceSpan(
      SourceLocation(_startOffset,
        column: _startColumn,
        line: _startLine,
        sourceUrl: _scanner.sourceUrl
      ),
      SourceLocation(_currentOffset,
        column: _currentColumn,
        line: _currentLine,
        sourceUrl: _scanner.sourceUrl
      ),
      currentLexeme ?? _lexemeBuffer.toString()
    );
  }

  bool _isAlpha(int char) {
    return (char >= $a && char <= $z)
      || (char >= $A && char <= $Z)
      || char == $_;
  }

  bool _isDigit(int char) {
    return char >= $0 && char <= $9;
  }

  bool _isAlphaNumeric(int char) {
    return _isAlpha(char) || _isDigit(char);
  }

  /// Returns whether the next character matches the given character.
  /// 
  /// Note: Consumes the next character if it's a match.
  bool _match(int expected) {
    if (_isAtEnd()) return false;
    if (_current != expected) return false;

    _advance();
    return true;
  }

  int _advance() {
    int char = _current;
    _current = _read();

    _lexemeBuffer.writeCharCode(char);
    return char;
  }

  int _peek() {
    return _current;
  }

  int _peekNext() {
    return _scanner.peekChar();
  }

  int _read() {
    return _scanner.isDone ? -1 : _scanner.readChar();
  }

  bool _isAtEnd() {
    return _current == -1;
  }
}