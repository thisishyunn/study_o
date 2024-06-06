// import 'package:flutter/material.dart';
// import 'package:flutter_project_study_o_ver2/data/database.dart';
// import 'package:flutter_project_study_o_ver2/data/structure.dart';
// import 'package:get/get.dart';
//
// deletePhoto(int id) {
//
// }
//
// deleteSubject(Subject subject) async {
//   await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('앨범 삭제'),
//           content: Text("${listSelection()} 복원하시겠어요?"),
//           actions: [
//             TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('취소')),
//             TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   ManageData().restoreSubject(selectedSubject);
//                   Get.back();
//                   Get.back();
//                 },
//                 child: Text('확인'))
//           ],
//         );
//       });
//   Get.defaultDialog(
//       title: '※ 주의 ※',
//       middleText: '${subject.name}을(를) 정말 삭제하시겠습니까?',
//       actions: [
//         TextButton(
//             onPressed: () {
//               ManageData().deleteSubject(subject);
//               Get.back();
//             },
//             child: Text('확인'))
//       ]);
// }