// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter_project_study_o_ver2/data/database.dart';
// import 'package:flutter_project_study_o_ver2/data/structure.dart';
// import 'package:flutter_project_study_o_ver2/screens/addsubject_page.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:get/get.dart';
//
// addSubject() async {
//   List value = await Get.to(() => AddSubjectPage(),
//       transition: Transition.fadeIn); // value에 이름, 썸네일, xfile 리스트 순서대로 가져옴
//   // [subjectNameController.text, thumbnailPath, photoList]
//   print(value);
//
//
//   List<Photo> photoList = [];
//   String? thumbnailBase64;
//
//   if (value[2] != null) {
//     /// 사진을 선택한 경우 xfile을 photo로 바꾸고 날짜순으로 정렬
//     photoList = await toPhoto(value[2]);
//     photoList.sort((a, b) => a.createdDate.compareTo(b.createdDate));
//     print('photoList 완성');
//   }
//
//   if (value[1] != null) {
//     thumbnailBase64 = base64Encode(File(value[1]).readAsBytesSync());
//   } else if (photoList != []) {
//     thumbnailBase64 = base64Encode(photoList[0].data);
//   } else {
//     print('과목명만 있는 경우');
//   }
//
//   ManageData().addSubject(value[0], thumbnailBase64, photoList);
//
// }
//
// Future<List<Photo>> toPhoto(List<XFile> xl) async {
//   // Future<List<Photo>> result;
//   List<Photo> result = [];
//   List<DateTime> dateList = [];
//   late DateTime date;
//   for (XFile xfile in xl) {
//     date = await xfile.lastModified();
//     dateList.add(date);
//   }
//
//   for (int i = 0; i < xl.length; i++) {
//     Uint8List data = await FlutterImageCompress.compressWithList(
//         File(xl[i].path).readAsBytesSync(),
//         minHeight: 1920,
//         minWidth: 1080,
//         quality: 60);
//     result.add(Photo(data: data, createdDate: dateList[i]));
//   }
//
//   return result;
// }
