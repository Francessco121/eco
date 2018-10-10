import 'dart:collection';

import '../parsing/token.dart';
import 'expression.dart';

class Arguments {
  final UnmodifiableListView<Expression> positional;
  final UnmodifiableMapView<Token, Expression> named;

  Arguments(this.positional, this.named);
}