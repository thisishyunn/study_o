import 'package:image_picker/image_picker.dart';

loadSingleImage() async {
  ImagePicker _picker = ImagePicker();
  XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image == null) return '';
  String imagePath = image.path;
  return imagePath;
}

loadMultiImage() async {
  ImagePicker _picker = ImagePicker();
  List<XFile>? xfileList = await _picker.pickMultiImage();
  return xfileList;
}
