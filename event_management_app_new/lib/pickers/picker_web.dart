import 'dart:typed_data';
import 'package:image_picker_web/image_picker_web.dart';
import 'picker_stub.dart';

class WebPicker implements PlatformPicker {
  @override
  Future<Uint8List?> pickImage() async {
    return await ImagePickerWeb.getImageAsBytes();
  }
}
