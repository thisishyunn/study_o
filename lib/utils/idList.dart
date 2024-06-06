import 'dart:convert';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';

String? idList(Highlight hl, int code) {  // highlightReload에서 사진 불러올 때 과목 고려
  List subjectIDList = jsonDecode(jsonEncode(hl.idList));

  if (subjectIDList.length == 0) {
    List<int> allSubject = [];
    late List subjectOrder;
    Map<int, Subject> subjectMap = ManageData().subjectMap;

    allSubject = List.generate(
        subjectMap.keys.length, (i) => subjectMap.values.toList()[i].id);
    subjectOrder = ManageData().settingMap['subjectOrder'];
    for (int id in allSubject) {
      if (subjectOrder.contains(id)) {
        subjectIDList.add(id);
      }
    }
  }

  String id = jsonEncode(subjectIDList);
  int l = id.length;



  if (subjectIDList.length == 0) {  // 전체 앨범에서 사진을 골라올 때! 고민이 필요없다 --> 이젠 필요하다;; 삭제된 과목은 제외!
    if (code != 2) return 'WHERE deleted != 1';
    return 'WHERE deleted != 1 AND rate != 0';
  }
  if (code == 2) {
  return 'WHERE deleted != 1 AND rate != 0 AND subjectID in (${jsonEncode(subjectIDList).substring(1, l-1)})';
  }
  return 'WHERE deleted != 1 AND subjectID in (${jsonEncode(subjectIDList).substring(1, l-1)})';
}