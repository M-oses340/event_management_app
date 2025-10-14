import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'picker_stub.dart';

class MobilePicker implements PlatformPicker {
  @override
  Future<Uint8List?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      return File(result.files.first.path!).readAsBytes();
    }
    return null;
  }
}
