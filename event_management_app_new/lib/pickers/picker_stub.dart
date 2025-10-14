import 'dart:typed_data';

abstract class PlatformPicker {
  Future<Uint8List?> pickImage();
}
