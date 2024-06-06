import 'dart:convert';
import 'dart:typed_data'; // Uint8List 타입 가져올 때 사용

class Subject {
  int id;
  String name;
  Uint8List? thumbnail;
  List<Photo> photoList;

  Subject(
      {required this.id,
      required this.name,
      this.thumbnail,
      required this.photoList});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'thumbnailBase64': thumbnail == null ? null : base64Encode(thumbnail!)
    };
  }
}

class Photo {
  int id;
  int subjectID;
  Uint8List data;
  DateTime createdDate;
  DateTime? lastViewDate;
  late int viewNum;
  late int rate;
  String? name;
  String? answer;
  String? explanation;
  bool deleted;

  Photo(
      {required this.id,
      required this.subjectID,
      required this.data,
      required this.createdDate,
      this.lastViewDate,
      this.viewNum = 0,
      this.rate = 0,
      this.name,
      this.answer,
      this.explanation,
      this.deleted = false});

  static Map<String, dynamic> toMap(Photo photo) {
    /// 데이터베이스에 저장 (insert, update) 하려고 map 자료형이 필요할 때 사용하는 함수!!
    return {
      'subjectID': photo.subjectID,
      'thumbnailBase64': base64Encode(photo.data),
      'createdDate': photo.createdDate.toString(),
      'lastViewDate': photo.lastViewDate.toString(),
      'viewNum': photo.viewNum,
      'rate': photo.rate,
      'name': photo.name,
      'answer': photo.answer,
      'explanation': photo.explanation,
      'deleted': photo.deleted? 1 : 0
    };
  }
}

class Highlight {
  int code;
  List idList;
  String? name;
  bool enabled = true;

  List<Photo> photoList = [];

  Highlight(
      {required this.code,
      required this.idList,
      this.name,
      this.enabled = true});

  static Map<String, dynamic> toMap(Highlight hl) {
    /// 데이터베이스에 저장 (insert, update) 하려고 map 자료형이 필요할 때 사용하는 함수!!
    return {
      'code': hl.code,
      'idList': hl.idList,
      'name': hl.name,
      'enabled': hl.enabled
    };
  }
}
