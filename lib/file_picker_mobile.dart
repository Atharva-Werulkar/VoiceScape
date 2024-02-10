import 'dart:io';
import 'package:file_picker/file_picker.dart';

Future<File?> pickAudioFile() async {
  FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.audio);
  if (result != null) {
    return File(result.files.single.path!);
  } else {
    return null;
  }
}
