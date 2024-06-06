import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class HighlightManage extends StatefulWidget {
  const HighlightManage({Key? key}) : super(key: key);

  @override
  _HighlightManageState createState() => _HighlightManageState();
}

class _HighlightManageState extends State<HighlightManage> {
  /// 완료를 누르기 전까지는 반영이 되지 않는 것이 목표!
  /// 본 page의 5가지 기능(사진 범위 설정, hl 순서 설정, hl on/off, hl 삭제, hl 추가) 중
  /// hl 추가를 제외한 나머지는 보류되었다가 반영이 되어야 한다.
  /// 이때 처음의 값을 initial, 조작한 값을 current로 묘사한다.
  /// hl의 순서, on/off, 삭제는 모두 긴밀하게 연결되어 있으므로
  /// _initialMap(id - enabled) 형태의 Map으로 한번에 관리한다.
  /// 둘의 변화는 checkChange()로 감지하며, 그 여부는 change~ 변수에 저장한다.
  /// + hl 추가는 newHighlight~ 변수를 이용한다.

  // static late final SfRangeValues _initialRange;
  // static late final List _initialOrder;
  // static late final Map<int, bool> _initialMap;
  static late SfRangeValues _currentRange;
  static late List _currentOrder;
  // static late Map<int, bool> _currentEnable;

  // static late Map<int, bool> _currentMap;

  List<Highlight> _newHighlightList = []; // 새로 생성된 hl만을 모아둔다!!

  // Map<int, Map<String, dynamic>> newHighlightMap = {};

  // late List newHighlightOrder;

  SnackBar alreadyExist = SnackBar(
    content: Text("! 하이라이트가 이미 존재합니다"),
  );

  @override
  void initState() {
    super.initState();
    _currentRange = SfRangeValues(ManageData().settingMap['minHL'] + 0.0,
        ManageData().settingMap['maxHL'] + 0.0);
    _currentOrder =
        jsonDecode(jsonEncode(ManageData().settingMap['highlightOrder']));
    // for (int id in ManageData().highlightMap.keys) {
    //   _currentEnable[id] = ManageData().highlightMap[id]!.enabled;
    // }
    // _initial 변수 초기화

    // _currentRange = _initialRange;
    // _currentOrder = _initialOrder;
    // _currentMap = _initialMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          title: Text(
            '하이라이트 편집',
            style: TextStyle(color: Colors.black54, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color.fromRGBO(135, 206, 250, 1)),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: sb(20) +
                setPhotoNumRange() +
                sb(10) +
                [
                  Divider(
                    thickness: 1.5,
                    indent: 10,
                    endIndent: 10,
                  )
                ] +
                manageHighlight(),
          ),
        ),
      ),
    );
  }

  List<Widget> sb(double height) {
    return [SizedBox(height: height)];
  }

  List<Widget> setPhotoNumRange() {
    return [
      Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(252, 252, 252, 1),
            ),
            height: 120,
            width: 330,
            child: SfRangeSlider(
              max: 40,
              min: 0,
              interval: 10,
              showLabels: true,
              showTicks: true,
              enableIntervalSelection: true,
              values: _currentRange,
              minorTicksPerInterval: 1,
              activeColor: Color.fromRGBO(107, 164, 199, 1),
              onChanged: (values) {
                setState(() {
                  if (values.start == 0) {
                    values = SfRangeValues(1, values.end);
                  }
                  _currentRange = values;
                  ManageData().highlightRangeSet(_currentRange);
                });
              },
            ),
          ),
          Positioned(
            top: 10,
            left: 20,
            child: Text(
              '사진 수 :  ${_currentRange.start.toInt()} - ${_currentRange.end.toInt()}',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      )
    ];
  }

  List<Widget> manageHighlight() {
    return [
      SizedBox(
        height: 10,
      ),
      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Color.fromRGBO(252, 252, 252, 1),
            ),
            height: 330,
            width: 330,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
              child: ReorderableListView(
                children: listTiles(),
                onReorder: reorderListTiles,
              ),
            ),
          ),
          GestureDetector(
            onTap: selectHighlightTypeDialog,
            child: Container(
              height: 40,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                color: Color.fromRGBO(210, 210, 210, 1),
              ),
              child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 32,
              )),
            ),
          ),
        ],
      )
    ];
  }

  List<Widget> listTiles() {
    return <Widget>[
      for (int id in ManageData().settingMap['highlightOrder'])
        Dismissible(
          background: Container(
            color: Colors.red.withOpacity(0.6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                ),
                Text("삭제"),
              ],
            ),
          ),
          onDismissed: (d) {
            ManageData().deleteHighlight(id);
          },
          direction: checkIfAllSubject(id)
              ? DismissDirection.none
              : DismissDirection.startToEnd,
          key: UniqueKey(),
          child: Column(
            key: ValueKey(id),
            children: [
              SwitchListTile(
                  dense: true,
                  tileColor: Colors.transparent,
                  activeColor: Color.fromRGBO(107, 164, 199, 1),
                  title: Text(
                    ManageData().highlightMap[id]!.idList.length == 0?
                        '모든 과목' :
                    '${ManageData().highlightMap[id]!.name}',
                    style: TextStyle(fontSize: 16),
                  ),
                  subtitle: ManageData().highlightMap[id]!.code == 1? Text('빠른 학습')
                  : ManageData().highlightMap[id]!.code == 2? Text('중요도 순') : Text('적게 본 순'),
                  onChanged: (bool value) {
                    setState(() {
                      ManageData().highlightEnableSet(id, value);
                      ManageData().highlightMap[id]!.enabled = value;
                      print('$id, $value');
                      print('${ManageData().highlightMap[id]!.enabled}');
                    });
                  },
                  value: ManageData().highlightMap[id]!.enabled),
              Divider(
                height: 1,
              )
            ],
          ),
        ),
    ];
  }

  bool checkIfAllSubject(int id) {
    return ManageData().highlightMap[id] != null &&
     ManageData().highlightMap[id]!.idList.length == 0 ? true : false;
  }

  void reorderListTiles(int oi, int ni) {
    setState(() {
      if (ni > oi) {
        ni -= 1;
      }
      final index = _currentOrder.removeAt(oi);
      _currentOrder.insert(ni, index);
      ManageData().highlightOrderSet(_currentOrder);
    });
  }

  // newHighlightOrder = jsonDecode(jsonEncode(_initialOrder)); // 순서를 임시 저장할 리스트
  // for (int id in ManageData().highlightMap.keys.toList()) {
  // newHighlightMap[id] = Highlight.toMap(ManageData().highlightMap[id]!);
  // }
  // newHighlightMap = Map.from(ManageData().highlightMap);

  int newHighlightCode = 0;
  List<int> newHighlightSubjectList = [];
  String newHighlightName = '';

  selectHighlightTypeDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          int selectedRadio = 1;
          return AlertDialog(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            titlePadding: EdgeInsets.fromLTRB(25, 20, 20, 15),
            title: Text(
              "사진 선택 기준을 정하세요 (1/3)",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    newHighlightCode = selectedRadio;
                    Navigator.of(context).pop();
                    selectHighlightSubjectDialog();
                  },
                  child: Text('다음'))
            ],
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      contentPadding: EdgeInsets.zero,
                      value: 1,
                      groupValue: selectedRadio,
                      onChanged: (int? s) {
                        setState(() => selectedRadio = 1);
                      },
                      title: Text("빠른 학습"),
                      subtitle: Text("사진을 무작위로 추천합니다"),
                    ),
                    RadioListTile(
                      contentPadding: EdgeInsets.zero,
                      value: 2,
                      groupValue: selectedRadio,
                      onChanged: (int? s) {
                        setState(() => selectedRadio = 2);
                      },
                      title: Text("중요도 순"),
                      subtitle: Text("중요한 사진을 추천합니다"),
                    ),
                    RadioListTile(
                      contentPadding: EdgeInsets.zero,
                      value: 3,
                      groupValue: selectedRadio,
                      onChanged: (int? s) {
                        setState(() => selectedRadio = 3);
                      },
                      title: Text("적게 본 순"),
                      subtitle: Text("적게 본 사진을 추천합니다"),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }

  selectHighlightSubjectDialog() {
    late Map subjectMap;
    late Map<int, String> subjectIdName = {};
    late Map<int, bool> subjectIdSelect = {};
    bool empty = true;
    subjectMap = ManageData().subjectMap;
    for (Subject s in subjectMap.values) {
      subjectIdName[s.id] = s.name;
      subjectIdSelect[s.id] = false;
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(
                  "사진을 고를 과목을 정하세요 (2/3)",
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                      onPressed: empty
                          ? null
                          : () {
                              for (int id in subjectIdSelect.keys) {
                                // 선택 과목 id추출
                                if (subjectIdSelect[id]!) {
                                  newHighlightSubjectList.add(id);
                                }
                              }
                              Navigator.of(context).pop();
                              changeSubjectNameDialog();
                            },
                      child: Text('다음'))
                ],
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int id in subjectIdName.keys)
                      CheckboxListTile(
                        title: Text("${subjectIdName[id]}"),
                        value: subjectIdSelect[id],
                        onChanged: (bool? value) {
                          setState(() {
                            subjectIdSelect[id] = value!;
                            empty = true;
                            for (bool b in subjectIdSelect.values)
                              empty = b ? false : empty;
                          });
                        },
                      )
                  ],
                ),
              );
            },
          );
        });
  }

  changeSubjectNameDialog() async {
    TextEditingController _textController = TextEditingController();
    bool empty = true;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              actionsPadding: EdgeInsets.all(0),
              title: Text(
                "하이라이트 이름을 정하세요 (3/3)",
                style: TextStyle(fontSize: 16),
              ),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                child: TextField(
                  maxLength: 8,
                  onChanged: (value) {
                    setState(() {
                      newHighlightName = _textController.text;
                      empty = newHighlightName == '' ? true : false;
                    });
                  },
                  controller: _textController,
                ),
              ),
              actions: [
                TextButton(
                    onPressed: empty
                        ? null
                        : () async {
                            newHighlightName = _textController.text;
                            // _newHighlightList.add(Highlight(
                            //     code: newHighlightCode,
                            //     idList: newHighlightSubjectList,
                            //     name: newHighlightName,
                            //     enabled: true));
                            ManageData().addHighlight(newHighlightSubjectList,
                                newHighlightCode, newHighlightName);
                            Navigator.of(context).pop();
                            Get.back();
                            Get.back();
                            // Get.to(() => HighlightManage());
                          },
                    child: Text('완료'))
              ],
            );
          });
        });
  }
}
