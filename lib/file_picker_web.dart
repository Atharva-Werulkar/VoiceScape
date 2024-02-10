import 'dart:async';
import 'dart:html';

Future<Blob?> pickAudioFile() {
  final completer = Completer<Blob?>();
  final input = FileUploadInputElement()..accept = 'audio/*';
  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.length > 0) {
      final file = files[0];
      completer.complete(file);
    } else {
      completer.complete(null);
    }
  });
  input.click();
  return completer.future;
}
