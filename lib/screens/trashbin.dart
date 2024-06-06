import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/main.dart';
import 'package:flutter_project_study_o_ver2/utils/idList.dart';
import 'package:get/get.dart';
import 'dart:convert';

class TrashBin extends StatefulWidget {
  const TrashBin({Key? key}) : super(key: key);

  @override
  State<TrashBin> createState() => _TrashBinState();
}

class _TrashBinState extends State<TrashBin> {
  late List<int> allSubject;
  late List subjectOrder;
  List<int> deletedSubject = [];
  List<bool> selectedBoolList = [];
  List<int> selectedSubject = [];
  List<CheckboxListTile> listItem = [];

  @override
  void initState() {
    super.initState();
    print('휴지통 trashbin initState...');
    Map<int, Subject> subjectMap = ManageData().subjectMap;
    allSubject = List.generate(
        subjectMap.keys.length, (i) => subjectMap.values.toList()[i].id);
    print("allSubject: $allSubject");
    subjectOrder = ManageData().settingMap['subjectOrder'];
    for (int id in allSubject) {
      if (!subjectOrder.contains(id)) {
        deletedSubject.add(id);
      }
    }
    print("deletedSubject: $deletedSubject");
    // for (int id in deletedSubject) {
    //   listItem.add(CheckboxListTile(
    //     title: Text(ManageData().subjectMap[id]!.name),
    //     value: false,
    //     onChanged: (a) {},
    //   ));
    // }
    // selectedBoolList = List.generate(deletedSubject.length, (i) => false);
  }

  Widget deletedSubjects() {
    return Center(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 30),
            width: Get.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
            ),
            child: ListView(
                shrinkWrap: true,
                children: ListTile.divideTiles(context: context, tiles: [
                  for (int id in deletedSubject)
                    CheckboxListTile(
                      title: Text(ManageData().subjectMap[id]!.name),
                      value: selectedSubject.contains(id),
                      activeColor: Color.fromRGBO(135, 206, 250, 1),
                      checkColor: Colors.white,
                      onChanged: (b) {
                        setState(() {
                          if (b!) {
                            selectedSubject.add(id);
                          } else {
                            selectedSubject.remove(id);
                          }
                        });
                      },
                    ),
                ]).toList()),
          )
        ],
      ),
    );
  }

  String listSelection() {
    String s = "";
    for (int subjectID in selectedSubject) {
      s = s + ManageData().subjectMap[subjectID]!.name + ", ";
    }
    s = s.substring(0, s.length - 2);

    if (!isKorean(s[s.length - 1])) {
      return s + "을(를)";
    } else if (checkBottomConsonant(s[s.length - 1])) {
      return s + "을";
    } else {
      return s + "를";
    }
  }

  bool checkBottomConsonant(String input) {
    return (input.runes.first - 0xAC00) / (28 * 21) < 0
        ? false
        : ((input.runes.first - 0xAC00) % 28 != 0)
            ? true
            : false;
  }

  bool isKorean(String input) {
    int inputToUniCode = input.codeUnits[0];

    return (inputToUniCode >= 12593 && inputToUniCode <= 12643)
        ? true
        : (inputToUniCode >= 44032 && inputToUniCode <= 55203)
            ? true
            : false;
  }

  onRestore() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('앨범 복원'),
            content: Text("${listSelection()} 복원하시겠어요?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ManageData().restoreSubject(selectedSubject);
                    Get.back();
                    Get.back();
                  },
                  child: Text('확인'))
            ],
          );
        });
  }

  onDelete() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('※ 영구 삭제'),
            content: Text("${listSelection()} 정말 삭제하시겠어요??"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소')),
              TextButton(
                  onPressed: () async {
                    // Navigator.of(context).pop();
                    await ManageData().permanentlyDeleteSubject(selectedSubject);
                    await Phoenix.rebirth(context);
                    Get.back();
                    print('restart');
                  },
                  child: Text('확인'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            title: Text(
              '휴지통',
              style: TextStyle(color: Colors.black54, fontSize: 20),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: PopupMenuButton(
                  child: Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 1) {
                      if (selectedSubject.length != 0) {
                        onRestore();
                      }
                    } else if (value == 2) {
                      if (selectedSubject.length != 0) {
                        onDelete();
                      }
                    }
                  },
                  itemBuilder: (_) {
                    return [
                      PopupMenuItem(
                          enabled: selectedSubject.length != 0,
                          padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.refresh),
                              SizedBox(width: 15,),
                              Text("복원"),
                            ],
                          )),
                      PopupMenuItem(
                          enabled: selectedSubject.length != 0,
                          padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 15,),
                              Text("삭제"),
                            ],
                          )),
                    ];
                  },
                ),
              ),
            ],
            iconTheme: IconThemeData(color: Color.fromRGBO(135, 206, 250, 1)),
          ),
        ),
        body: deletedSubject.length == 0
            ? Center(
                child: Text(
                  "삭제된 과목 없음",
                  style: TextStyle(
                      fontSize: 16, color: Colors.black.withOpacity(0.6)),
                ),
              )
            : deletedSubjects());
  }
}
