// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:get/get.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:path_provider/path_provider.dart';
//
// double ratio = 9 / 16;
// double h = Get.height * 0.6;
// double w = Get.height * 0.6 * ratio;
//
// class PhotoCropEdit extends StatefulWidget {
//   final Uint8List? photoInt;
//
//   // final Image photo;
//   const PhotoCropEdit({Key? key, required this.photoInt}) : super(key: key);
//
//   @override
//   _PhotoCropEditState createState() => _PhotoCropEditState();
// }
//
// class _PhotoCropEditState extends State<PhotoCropEdit> {
//   late final Future<File> newImage;
//   late final String path;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     saveImage();
//   }
//
//   saveImage() async {
//     Directory dir = await getApplicationDocumentsDirectory();
//     path = dir.path;
//     final buffer = widget.photoInt!.buffer;
//     File imageFile =  await File(path).writeAsBytes(
//         buffer.asUint8List(widget.photoInt!.offsetInBytes, widget.photoInt!.lengthInBytes));
//     imageFile.copy('$path/image111.png');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(40),
//         child: AppBar(
//           title: Text(
//             "1 / 4 장의 사진",
//             style: TextStyle(fontSize: 17),
//           ),
//           centerTitle: true,
//           elevation: 0,
//           leadingWidth: 0,
//           backgroundColor: Colors.transparent,
//           actions: [TextButton(onPressed: () {}, child: Text("저장"))],
//         ),
//       ),
//       body: Center(
//         child: Container(
//
//           child: Image.file(await ImageCropper.cropImage(
//             sourcePath: path
//           )),
//         ),
//       ),
//       // body: Center(
//       //   child: FutureBuilder(
//       //     builder: (BuildContext context, newImage) {
//       //       return File.fromRawPath(widget.photoInt!);
//       //     },
//       //   ),
//       // ),
//       // body: Center(
//       //   child: Image.file(
//       //       File.fromRawPath(widget.photoInt!)
//       //   ),
//       // ),
//     );
//   }
// }
