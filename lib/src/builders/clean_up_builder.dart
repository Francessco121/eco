import 'dart:async';

import 'package:build/build.dart';

class CleanUpBuilder implements PostProcessBuilder {
  @override
  final inputExtensions = const ['.eco'];

  @override
  Future build(PostProcessBuildStep buildStep) async {
    buildStep.deletePrimaryInput();
  }
}