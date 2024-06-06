// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_project_study_o_ver2/data/database.dart';
// import 'package:flutter_project_study_o_ver2/data/structure.dart';
// import 'package:flutter_project_study_o_ver2/utils/change_subject_name.dart';
// import 'package:get/get.dart';
//
// class SubjectPage extends StatefulWidget {
//   final Subject subject;
//
//   SubjectPage({Key? key, required this.subject}) : super(key: key);
//
//   @override
//   _SubjectPageState createState() => _SubjectPageState();
// }
//
// class _SubjectPageState extends State<SubjectPage> {
//   late int widthNum;
//   String changedName = '';
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     widthNum = ManageData().settingMap['widthNum'];
//   }
//
//   quickView(Photo photo) {
//     return showAnimatedDialog(
//         barrierDismissible: true,
//         context: context,
//         animationType: DialogTransitionType.scale,
//         builder: (_) => Dialog(
//             backgroundColor: Colors.transparent,
//             child: Column(children: [
//               Container(
//                 width: 250,
//                 height: 450,
//                 child: Image.memory(
//                   photo.data,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//                 Icon(
//                   Icons.visibility,
//                   color: Colors.white,
//                 ),
//                 Text(
//                   '${photo.viewNum}',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 Icon(Icons.grade, color: Colors.white),
//                 Text(
//                   '${photo.rate}',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ]),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Icon(Icons.date_range, color: Colors.white),
//                   Text(
//                     '${photo.createdDate}',
//                     style: TextStyle(color: Colors.white),
//                   )
//                 ],
//               ),
//             ])));
//   }
//
//   Widget subjectPageAction() {}
//
//   @override
//   Widget build(BuildContext context) {
//     final changeNameController = TextEditingController();
//
//     void changeSubjectName(String changeName) async {
//       print('subject name 변경');
//       Map<String, dynamic> subjectMap =
//           await ManageData().getSubject(widget.subject.id);
//       Map<String, dynamic> newSubjectMap =
//           Map<String, dynamic>.from(subjectMap);
//       newSubjectMap['subjectName'] = changeName;
//       ManageData().updateSubject(newSubjectMap);
//       setState(() {
//         widget.subject.name = changeName;
//       });
//       Navigator.pop(context);
//     }
//
//     return Scaffold(
//         body: Scrollbar(
//           child: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 elevation: 0.0,
//                 floating: false,
//                 pinned: true,
//                 snap: false,
//                 iconTheme: IconThemeData(color: Colors.white),
//                 centerTitle: false,
//                 backgroundColor: Color.fromRGBO(79, 195, 247, 0.7),
//                 expandedHeight: 250,
//                 leadingWidth: 25,
//                 stretch: true,
//                 actions: [
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: PopupMenuButton(
//                       onSelected: (value) async {
//                         if (value == 1) {
//                           /// 과목명 변경 선택
//                           String? changedName = await changeSubjectNameDialog(
//                               context);
//                           ManageData().changeName(widget.subject, changedName);
//                         } else if (value == 2) {
//                           String newThumbnail = await loadSingleImage();
//                           if (newThumbnail != '')
//                             ManageData().updateThumbnail(
//                                 widget.subject,
//                                 base64Encode(
//                                     File(newThumbnail).readAsBytesSync()));
//                           setState(() {});
//                         }
//                       },
//                       child: Icon(
//                         Icons.more_vert,
//                         size: 30,
//                       ),
//                       itemBuilder: (_) {
//                         return [
//                           PopupMenuItem(
//                             padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
//                             child: StatefulBuilder(
//                               builder: (context, StateSetter setsState) {
//                                 return Row(
//                                   children: [
//                                     Text('너비'),
//                                     IconButton(
//                                         disabledColor: Colors.grey,
//                                         onPressed: () {
//                                           if (widthNum != 1) {
//                                             setState(() {
//                                               widthNum -= 1;
//                                             });
//                                             setsState(() {
//                                               widthNum = widthNum;
//                                             });
//                                           }
//                                         },
//                                         icon: Icon(Icons.arrow_left),
//                                         color: widthNum != 1
//                                             ? Colors.black
//                                             : Colors.grey),
//                                     Text('$widthNum'),
//                                     IconButton(
//                                         onPressed: () {
//                                           if (widthNum != 5) {
//                                             setState(() {
//                                               widthNum += 1;
//                                             });
//                                             setsState(() {
//                                               widthNum = widthNum;
//                                             });
//                                           }
//                                         },
//                                         icon: Icon(Icons.arrow_right,
//                                             color: widthNum != 5
//                                                 ? Colors.black
//                                                 : Colors.grey)),
//                                   ],
//                                 );
//                               },
//                             ),
//                           ),
//                           PopupMenuItem(
//                             padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
//                             value: 1,
//                             child: Text('과목명 변경'),
//                           ),
//                           PopupMenuItem(
//                             padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
//                             value: 2,
//                             child: Text('썸네일 변경'),
//                           ),
//                         ];
//                       },
//                     ),
//                   )
//                 ],
//                 flexibleSpace: FlexibleSpaceBar(
//                   centerTitle: true,
//                   background: widget.subject.thumbnail != null
//                       ? Image(
//                           image: widget.subject.thumbnail!.image,
//                           fit: BoxFit.cover)
//                       : Container(),
//                   title: Text(
//                     widget.subject.name,
//                     style: TextStyle(fontSize: 30, color: Colors.white),
//                   ),
//                 ),
//               ),
//               SliverPadding(padding: EdgeInsets.symmetric(vertical: 1)),
//               SliverGrid.count(
//                 crossAxisCount: widthNum,
//                 mainAxisSpacing: 2,
//                 crossAxisSpacing: 2,
//                 children: [
//                   for (Photo photo in widget.subject.photoList)
//                     GestureDetector(
//                       onTap: () async {
//                         await Get.to(() {
//                           return PhotoPageView(
//                               photoIndex:
//                                   widget.subject.photoList.indexOf(photo),
//                               photoList: widget.subject.photoList);
//                         }, transition: Transition.fade);
//                       },
//                       onLongPress: () {
//                         quickView(photo);
//                       },
//                       child: Container(
//                           child: FadeInImage(
//                               fadeInDuration: Duration(milliseconds: 100),
//                               fit: BoxFit.cover,
//                               placeholder: MemoryImage(kTransparentImage),
//                               image: MemoryImage(base64Decode(photo.base64)))),
//                     )
//                 ],
//               )
//             ],
//           ),
//         ),
//         floatingActionButton: SpeedDial(
//           icon: Icons.add,
//           backgroundColor: Colors.lightBlue[300],
//           activeIcon: Icons.close,
//           buttonSize: 60,
//           spacing: 15,
//           animationSpeed: 60,
//           renderOverlay: false,
//           useRotationAnimation: false,
//           children: [
//             SpeedDialChild(
//                 child: Icon(Icons.photo_camera),
//                 onTap: () async {
//                   String imagePath = await loadSingleImage();
//                 }),
//             SpeedDialChild(child: Icon(Icons.photo))
//           ],
//         ));
//   }
// }
