import 'package:build/build.dart';

import 'src/builders/clean_up_builder.dart';
import 'src/builders/view_builder.dart';

Builder viewBuilder(BuilderOptions options) => ViewBuilder();

PostProcessBuilder cleanUpBuilder(BuilderOptions options) => CleanUpBuilder();
