import 'dart:async';

import 'package:eco/runtime.dart';

/// Runs an Eco [script].
/// 
/// The `Assert` library will be implicitly imported when running
/// the [script].
Future<void> runScript(String script) async {
  // Create an Eco program
  final program = new Program();
  
  // Add the Assert library as an implicit import
  program.addLibrary(new AssertLibrary(), importImplicitly: true);

  // Run script
  await program.run(new Source(null, script));
}