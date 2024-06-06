import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/screens/addsubject_page.dart';
import 'package:flutter_project_study_o_ver2/screens/highlight_page.dart';
import 'package:flutter_project_study_o_ver2/screens/new_subject_page.dart';
import 'package:flutter_project_study_o_ver2/screens/subject_page.dart';
import 'package:flutter_project_study_o_ver2/utils/addsubject.dart';
import 'package:flutter_project_study_o_ver2/utils/deletePhoto.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class HomePageBody extends StatefulWidget {
  final Map<int, Subject> subjectMap;
  final Map<int, Highlight> highlightMap;
  final Map<String, dynamic> settingMap;

  const HomePageBody(
      {Key? key,
      required this.subjectMap,
      required this.highlightMap,
      required this.settingMap})
      : super(key: key);

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  Container drawThumbnail(Uint8List? data) {
    if (data != null)
      return Container(
        width: 150,
        height: 150,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(data, fit: BoxFit.cover)),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent)),
      );
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: Colors.transparent),
      ),
    );
  }

  Widget subjectAddTile(bool onDelete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bounce(
          duration: Duration(milliseconds: 120),
          onPressed: onDelete
              ? () {}
              : () async {
                  List newSubject = await Get.to(() => AddSubjectPage());
                  print("addsubject_page에서 새로운 과목의 정보를 변수 newSubject에 받아왔습니다."
                      "ManageData().addSubject 메소드에 정보를 반환합니다.");

                  /// value = [subjectNameController.text, thumbnailPath, photoList] 꼴
                  Future<int> add = ManageData().addSubject(newSubject);
                  FutureBuilder(
                      future: add,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();
                        return Container();
                      });
                },
          child: Container(
            width: 150,
            height: 150,
            child: Icon(
              Icons.add,
              size: 60,
              color: Color.fromRGBO(135, 206, 250, 1),
              // color: Colors.red
            ),
            decoration: BoxDecoration(
                color: Color.fromRGBO(252, 252, 252, 1),
                border: Border.all(width: 1, color: Colors.black26),
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 3, 0, 3),
          child: Text(''),
        )
      ],
    );
  }

  Widget subjectTile(Subject subject, bool onDelete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Bounce(
          duration: Duration(milliseconds: 100),
          child: Stack(children: [
            Hero(tag: subject.id, child: drawThumbnail(subject.thumbnail)),
            onDelete
                ? Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.remove_circle),
                      color: Colors.red[900]!.withOpacity(0.8),
                      iconSize: 28,
                      onPressed: () async {
                        await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('앨범 삭제'),
                                content: Text(
                                    "'${subject.name}'${checkBottomConsonant(subject.name)} 삭제하시겠어요?"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('취소')),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        ManageData().deleteSubject(subject);
                                      },
                                      child: Text('확인'))
                                ],
                              );
                            });
                      },
                    ),
                  )
                : SizedBox()
          ]),
          onPressed: onDelete
              ? () {}
              : () async {
                  await Get.to(() => SubjectPage(subject: subject),
                      transition: Transition.fade);
                },
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            subject.name,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  String checkBottomConsonant(String input) {
    input = input[input.length - 1];
    if (!isKorean(input)) {
      return "을(를)";
    }
    if (!((input.runes.first - 0xAC00) / (28 * 21) < 0)) {
      if ((input.runes.first - 0xAC00) % 28 != 0) {
        return "을";
      } else {
        return "를";
      }
    } else {
      return "을(를)";
    }
  }

  bool isKorean(String input) {
    int inputToUniCode = input.codeUnits[0];

    return (inputToUniCode >= 12593 && inputToUniCode <= 12643)
        ? true
        : (inputToUniCode >= 44032 && inputToUniCode <= 55203)
            ? true
            : false;
  }

  void onReorder(int oldIndex, int newIndex) {
    ManageData().reorderSubject(oldIndex, newIndex);
  }

  Widget sb(double h) {
    return SizedBox(height: h);
  }

  List<Widget> highlights(bool onDelete) {
    bool empty = true;

    for (int id in widget.settingMap['highlightOrder']) {
      if (widget.highlightMap[id] != null) {
        if (widget.highlightMap[id]!.photoList.length >=
                widget.settingMap['minHL'] &&
            widget.highlightMap[id]!.photoList.length <=
                widget.settingMap['maxHL']) {
          empty = false;
        }
      }
    }

    List<Widget> highlightView = [
      SizedBox(width: 10),
      for (int id in widget.settingMap['highlightOrder'])
        widget.highlightMap[id] != null &&
                widget.highlightMap[id]!.photoList.length >=
                    widget.settingMap['minHL']
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9.0),
                child: GestureDetector(
                    onTap: () {
                      Get.to(() => HighlightPage(id: id),
                          transition: Transition.downToUp);
                    },
                    child: drawHighlight(widget.highlightMap[id]!)))
            : Container(),
      SizedBox(width: 10),
    ];

    return empty
        ? [
            Container(
                width: 330,
                child: Image.asset(
                  'images/no_highlight.png',
                  fit: BoxFit.contain,
                ))
          ]
        : [
            Container(
                width: 360,
                height: 180,
                child: ListView(
                    scrollDirection: Axis.horizontal, children: highlightView))
          ];

    // return [Container(width: 330, child: Image.asset('images/no_highlight.png', fit: BoxFit.contain,))];
  }

  Widget drawHighlight(Highlight hl) {
    return Stack(
      children: [
        Container(
          width: 125,
          height: 190,
          color: Colors.black38,
          child: Opacity(
              opacity: 0.8,
              child: Image.memory(hl.photoList[0].data, fit: BoxFit.cover)),
        ),
        Positioned(
            child: Text(
              '${hl.name}',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            left: 7,
            bottom: 10)
      ],
    );
  }

  List<Widget> subjects(bool onDelete) {
    if (ManageData().settingMap['subjectOrder'].length == 0)
      return [
        Container(width: 330, child: Row(children: [subjectAddTile(onDelete)]))
      ];
    return [
      Container(
          width: 350,
          alignment: Alignment.center,
          child: ReorderableWrap(
              spacing: 21,
              runSpacing: 12,
              padding: EdgeInsets.symmetric(horizontal: 12),
              direction: Axis.horizontal,
              header: [subjectAddTile(onDelete)],
              children: [
                for (int id in widget.settingMap['subjectOrder'])
                  subjectTile(widget.subjectMap[id]!, onDelete)
              ],
              onReorder: onReorder)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 600));
        await ManageData().reloadHighlight();
      },
      child: ListView(
        children: [
          Column(
              children: [sb(24)] +
                  highlights(widget.settingMap['onDelete']) +
                  [
                    Divider(
                        height: 39,
                        thickness: 1.5,
                        indent: 7,
                        endIndent: 7,
                        color: Colors.black12)
                  ] +
                  subjects(widget.settingMap['onDelete']) +
                  [sb(20)],
              mainAxisAlignment: MainAxisAlignment.center),
        ],
      ),
    );
  }
}
