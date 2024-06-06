import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/screens/photo_page.dart';
import 'package:get/get.dart';

class HighlightPage extends StatefulWidget {
  const HighlightPage({Key? key, required this.id}) : super(key: key);
  final int id;

  @override
  _HighlightPageState createState() => _HighlightPageState();
}

class _HighlightPageState extends State<HighlightPage> {
  int index = 0;
  int l = 0;
  bool storyBarVisible = true;
  late Highlight hl;

  @override
  void initState() {
    // TODO: implement initState
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
    hl = ManageData().highlightMap[widget.id]!;
    int id = hl.photoList[index].id;
    hl.photoList[index].viewNum += 1;
    int v = hl.photoList[index].viewNum;
    ManageData().savePhoto(id: id, key: 'viewNum', value: v);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // SystemChrome.setEnabledSystemUIMode(
    //     SystemUiMode.leanBack);
    super.dispose();
  }

  Widget storyBar(int index) {
    Uint8List? thumbnail =
        ManageData().subjectMap[hl.photoList[index].subjectID]!.thumbnail;
    int l = hl.photoList.length;
    return Container(
      height: 95,
      decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.65)])),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(3, 30, 3, 0),
            child: Row(
              children: [
                for (int i = 0; i < l; i++)
                  Padding(
                    padding: const EdgeInsets.all(0.9),
                    child: Container(
                      height: 2,
                      width: (Get.width - 7.8 - 1.8 * (l - 1)) / l,
                      color: i <= index
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  )
              ],
            ),
          ),
          Container(
            width: Get.width,
            height: 50,
            child: Stack(children: [
              GestureDetector(
                child: Container(
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                            image: thumbnail != null
                                ? DecorationImage(
                                fit: BoxFit.fill, image: MemoryImage(thumbnail))
                                : null),
                      ),
                      Text(
                        "${ManageData().subjectMap[hl.photoList[index]
                            .subjectID]!.name}",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Get.to(() =>
                      PhotoPage(photoList: [Photo(
                          id: hl.photoList[index].id,
                          subjectID: hl.photoList[index].subjectID,
                          data: hl.photoList[index].data,
                          createdDate: hl.photoList[index].createdDate,
                        rate: hl.photoList[index].rate,
                        viewNum: hl.photoList[index].viewNum,
                        name: hl.photoList[index].name,
                        answer: hl.photoList[index].answer,
                        explanation: hl.photoList[index].explanation
                      )
                      ], photoIndex: 0, mode: 1,),
                      transition: Transition.downToUp,
                      duration: Duration(milliseconds: 500));
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Transform.rotate(
                  angle: 3.14 / 4,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.add, color: Colors.white, size: 35),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
              )
            ]),
          )
        ],
      ),
    );
  }

  bool visible(int photoIndex) {
    return index > photoIndex ? false : true;
  }

  updateSubjectPhoto() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          for (Photo photo in hl.photoList.reversed)
            Visibility(
              visible: visible(hl.photoList.indexOf(photo)),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(color: Colors.black),
                    Container(child: Image.memory(photo.data)),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onLongPressStart: (_) {
              setState(() {
                storyBarVisible = false;
              });
            },
            onLongPressEnd: (_) {
              setState(() {
                storyBarVisible = true;
              });
            },
            onVerticalDragUpdate: (dragUpdateDetails) {
              if (dragUpdateDetails.delta.dy > 3) {
                Get.back();
              }
            },
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      color: Colors.green.withOpacity(0),
                    ),
                    onTap: () {
                      index != 0
                          ? setState(() {
                        index -= 1;
                        int id = hl.photoList[index].id;
                        hl.photoList[index].viewNum += 1;
                        int v = hl.photoList[index].viewNum;
                        ManageData()
                            .savePhoto(id: id, key: 'viewNum', value: v);
                      })
                          : Get.back();
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    child: Container(
                      color: Colors.blue.withOpacity(0),
                    ),
                    onTap: () {
                      index != hl.photoList.length - 1
                          ? setState(() {
                        index += 1;
                        int id = hl.photoList[index].id;
                        hl.photoList[index].viewNum += 1;
                        int v = hl.photoList[index].viewNum;
                        ManageData()
                            .savePhoto(id: id, key: 'viewNum', value: v);
                      })
                          : Get.back();
                    },
                  ),

                ),
              ],
            ),
          ),
          storyBarVisible ? storyBar(index) : Container(),
        ],
      ),
    );
  }
}
