import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

editPhoto(Uint8List photoInt, List<int>? index) async {
  Directory directory = await getApplicationDocumentsDirectory();
  String path = directory.path;

  final buffer = photoInt.buffer;
  await File('$path/edit_image.png').writeAsBytes(
      buffer.asUint8List(photoInt.offsetInBytes, photoInt.lengthInBytes));

  File? editComplete = await ImageCropper.cropImage(
      sourcePath: "$path/edit_image.png",
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: index == null? '사진 편집' : '사진 편집 (${index[0]} / ${index[1]})',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Cropper',
      ));

  return editComplete;
}
