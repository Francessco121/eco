import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart' as $path;

import 'source.dart';

abstract class SourceResolver {
  Uri resolvePath(String path, [Uri relativeTo]);
  Future<Source> load(Uri uri);
}

class FileSourceResolver implements SourceResolver {
  @override
  Future<Source> load(Uri uri) async {
    final file = new io.File.fromUri(uri);

    if (file.existsSync()) {
      final String content = await file.readAsString();

      return Source(file.uri, content);
    }

    return null;
  }

  @override
  Uri resolvePath(String path, [Uri relativeTo]) {
    final String fullPath = relativeTo == null
      ? path
      : $path.join($path.dirname($path.fromUri(relativeTo)), path);

    return Uri.file(fullPath, windows: io.Platform.isWindows);
  }
}