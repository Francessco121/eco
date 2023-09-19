typedef SystemPrintCallback = void Function(String message);

class StandardLibraryOptions {
  final SystemPrintCallback? systemPrintCallback;

  StandardLibraryOptions({
    this.systemPrintCallback
  });
}