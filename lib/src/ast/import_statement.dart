import '../parsing/token.dart';
import 'statement.dart';
import 'statement_visitor.dart';

class ImportStatement implements Statement {
  final Token keyword;
  final Token path;
  final Token asKeyword;
  final Token asIdentifier;

  ImportStatement(this.keyword, this.path, this.asKeyword, this.asIdentifier) {
    // if ((asKeyword != null) != (asIdentifier != null)) {
    //   throw ArgumentError(
    //     "If either the 'asKeyword' or 'asIdentifier' parameters are not null, then both must not be null."
    //   );
    // }
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitImport(this);
  }
}