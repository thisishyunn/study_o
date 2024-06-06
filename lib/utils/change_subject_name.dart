//
// import 'package:flutter/material.dart';
//
// Future<String> changeSubjectNameDialog(BuildContext context) async {
//   TextEditingController changeNameController = TextEditingController();
//   String? changedName;
//   showDialog(
//       context: context,
//       builder: (context) {
//     return StatefulBuilder(
//         builder: (context, setsState) {
//           return AlertDialog(
//               scrollable: true,
//               title: Text('과목명 변경'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SizedBox(height: 30),
//                   Container(
//                     height: 100,
//                     child: TextField(
//                       controller: changeNameController,
//                       onChanged: (text) {
//                         setsState(() {
//                           changedName =
//                               changeNameController
//                                   .text;
//                         });
//                       },
//                       maxLength: 10,
//                       decoration: InputDecoration(
//                           hintText: '바꿀 이름을 입력하세요'),
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 changedName == null
//                     ? TextButton(
//                     onPressed: null,
//                     child: Text('확인'))
//                     : TextButton(
//                     onPressed: () async {
//
//                       return setState(() {
//                         return changeSubjectName(
//                             changedName);
//                       });
//                     },
//                     child: Text('확인'))
//               ]);
//         });
// }