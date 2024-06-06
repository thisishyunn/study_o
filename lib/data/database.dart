import 'dart:convert';
import 'dart:io'; // initDB에서 path를 구할 때 Directory 타입을 지정!

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/utils/idList.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart'; // initDB에서 path를 join할 때(합칠 때!) 사용
import 'package:path_provider/path_provider.dart'; // 데이터베이스가 저장공간에 저장되는 위치를 얻을 때 사용
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart'; // 데이터베이스를 사용하려면 기본으로 import! Database 타입을 지정
import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class ManageData extends GetxController {
  static Database? _database;

  ManageData._(); // 실제 인스턴스를 만들어내는 생성자 ManageData._()

  static final ManageData _md =
      ManageData._(); // 한번 만들면 계속 쓰일(final) 인스턴스 _MD 선언
  factory ManageData() {
    return _md; // 외부에서 ManageData()아면 언제나 동일한 인스턴스 _MD 리턴
  }

  Future<Database> get database async {
    // 데이터베이스에 접근할 때 항상 이 getter 로 접근하게 된다.
    // 데이터베이스 _database 가 있으면 바로 리턴하고, 없으면 초기화(initDB)해서 리턴한다
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    // database가 없으면 새로 만든다!
    // 앱이 처음 설치되어 처음 실행될 때 딱 한 번만 실행되는 함수
    print('initDB: 데이터베이스를 새롭게 만드는 중입니다...');
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = join(appDir.path, 'DATA.db');
    // await deleteDatabase(path);
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      print('데이터베이스를 create합니다...');
      await db.execute('''
        CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        thumbnailBase64 BLOB
        )
        ''');
      await db.execute('''
        CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectID INTEGER,
        thumbnailBase64 BLOB,
        createdDate TEXT,
        lastViewDate TEXT,
        viewNum INTEGER,
        rate INTEGER,
        name TEXT,
        answer TEXT,
        explanation TEXT,
        deleted INTEGER
        )
        ''');
      await db.execute('''
        CREATE TABLE highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idList TEXT,
        code INTEGER,
        name TEXT,
        enabled INTEGER
        )
        ''');

      await db.insert('highlights',
          {'idList': '[]', 'code': 1, 'name': '빠른 학습', 'enabled': 1});
      await db.insert('highlights',
          {'idList': '[]', 'code': 2, 'name': '중요도 순', 'enabled': 1});
      await db.insert('highlights',
          {'idList': '[]', 'code': 3, 'name': '적게 본 순', 'enabled': 1});
    });
  }

  ///////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////

  /// 앱 실행 시 데이터를 불러오는 부분을 주석으로 묶었다.
  /// loadData => loadSubjectMap, loadHighlightMap
  /// loadSubjectMap => loadPhotoList
  /// 데이터가 모두 정상적으로 로딩되면 0을 리턴한다

  Map<int, Subject> _subjectMap = {};
  Map<int, Highlight> _highlightMap = {};
  Map<String, dynamic> _settingMap = {};

  Future<int> loadData() async {
    // 앱이 restart 될 때마다 main의 initState에서 호출되어 실행된다
    await loadSetting();
    _subjectMap = await loadSubjectMap();
    _highlightMap = await loadHighlightMap();

    await reloadHighlight();
    print("loadData: setting, subject, highlight 모두 load했습니다.");
    return 0;
  }

  Future<Map<int, Subject>> loadSubjectMap() async {
    print('loadSubjectMap: DB로부터 subjectMap을 불러오고 있습니다...');
    final db = await database;
    List<Map<String, dynamic>> subjectTable = await db.query('subjects');
    for (Map<String, dynamic> subjectMap in subjectTable) {
      _subjectMap[subjectMap['id']] = Subject(
          id: subjectMap['id'],
          name: subjectMap['name'],
          thumbnail: subjectMap['thumbnailBase64'] != null
              ? base64Decode(subjectMap['thumbnailBase64'])
              : null,
          photoList: await loadPhotoList(subjectMap['id']));
    }

    return _subjectMap;
  }

  Future<List<Photo>> loadPhotoList(int id) async {
    print('loadPhotoList: 특정 과목 id의 사진을 불러오고 있습니다...');
    final db = await database;
    List<Map<String, dynamic>> photoTable =
        await db.query('photos', where: 'subjectID = ?', whereArgs: [id]);
    List<Photo> _photoList = List.generate(
        photoTable.length,
        (i) => Photo(
            id: photoTable[i]['id'],
            subjectID: id,
            data: base64Decode(photoTable[i]['thumbnailBase64']),
            createdDate: DateTime.parse(photoTable[i]['createdDate']),
            lastViewDate: null,
            // photoTable[i]['lastViewDate'] == null
            //     ? null
            //     : DateTime.parse(photoTable[i]['lastViewDate']),
            viewNum: photoTable[i]['viewNum'],
            rate: photoTable[i]['rate'],
            name: photoTable[i]['name'],
            answer: photoTable[i]['answer'],
            explanation: photoTable[i]['explanation'],
            deleted: photoTable[i]['deleted'] == 1 ? true : false));

    return _photoList;
  }

  Future<Map<int, Highlight>> loadHighlightMap() async {
    final db = await database;
    List<Map<String, dynamic>> highlightTable = await db.query('highlights');
    for (Map<String, dynamic> highlightMap in highlightTable) {
      // List<int> idList = jsonDecode(highlightMap['idList']);
      _highlightMap[highlightMap['id']] = Highlight(
          code: highlightMap['code'],
          idList: jsonDecode(highlightMap['idList']),
          name: highlightMap['name'],
          enabled: highlightMap['enabled'] == 1 ? true : false);
    }
    return _highlightMap;
  }

  Future<void> loadSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('subjectOrder') == null) initSetting(prefs);

    _settingMap['subjectOrder'] = jsonDecode(prefs.getString('subjectOrder')!);
    _settingMap['highlightOrder'] =
        jsonDecode(prefs.getString('highlightOrder')!);
    _settingMap['widthNum'] = prefs.getInt('widthNum');
    _settingMap['minHL'] = prefs.getInt('minHL');
    _settingMap['maxHL'] = prefs.getInt('maxHL');
    _settingMap['onDelete'] = prefs.getBool('onDelete');
  }

  initSetting(SharedPreferences prefs) {
    print('initSetting: shared preference 설정 초기화...');

    prefs.setString('subjectOrder', '[]');
    prefs.setString('highlightOrder', '[1, 2, 3]');
    prefs.setInt('widthNum', 3);
    prefs.setInt('minHL', 5);
    prefs.setInt('maxHL', 20);
    prefs.setBool('onDelete', false);
  }

  reloadHighlight() async {
    /// _highlightMap 속 Highlight 인스턴스 각각에서 코드에 맞는 사진을 db로부터 불러와 Highlight.photoList에 저장
    print('reloadHighlight: 하이라이트를 새롭게 불러옵니다...');

    final db = await database;
    for (Highlight hl in _highlightMap.values.toList()) {
      List<Map> pmList = []; // pm은 photoMap의 약자
      if (hl.enabled) {
        switch (hl.code) {
          case 1:
            {
              pmList = await db.rawQuery(
                  ''' SELECT * FROM photos ${idList(hl, 1)} ORDER BY RANDOM() LIMIT '${settingMap['maxHL']}'; ''');
            }
            break;
          case 2:
            {
              pmList = await db.rawQuery(
                  ''' SELECT * FROM photos ${idList(hl, 2)} ORDER BY rate DESC LIMIT '${settingMap['maxHL']}'; ''');
            }
            break;
          case 3:
            {
              pmList = await db.rawQuery(
                  ''' SELECT * FROM photos ${idList(hl, 3)} ORDER BY viewNum LIMIT '${settingMap['maxHL']}'; ''');
            }
        }
      }
      hl.photoList = [];
      for (Map photoMap in pmList) {
        hl.photoList.add(Photo(
            id: photoMap['id'],
            subjectID: photoMap['subjectID'],
            data: base64Decode(photoMap['thumbnailBase64']),
            createdDate: DateTime.parse(photoMap['createdDate']),
            lastViewDate: null,
            viewNum: photoMap['viewNum'],
            rate: photoMap['rate'],
            name: photoMap['name'],
            answer: photoMap['answer'],
            explanation: photoMap['explanation'],
            deleted: false));
      }
      update();
    }
  }

  ///////////////////////////////////////////////////////////////

  Map<int, Subject> get subjectMap {
    return _subjectMap;
  }

  Map<int, Highlight> get highlightMap {
    return _highlightMap;
  }

  Map<String, dynamic> get settingMap {
    return _settingMap;
  }

  Future<Map<String, dynamic>> getPhoto(int id) async {
    final db = await database;
    List<Map<String, dynamic>> photoMapList =
        await db.query('photos', where: 'id = ?', whereArgs: [id]);
    return photoMapList[0];
  }

  /////////////////////////////////////////////////////////////////

  saveSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('subjectOrder', jsonEncode(_settingMap['subjectOrder']));
    prefs.setString(
        'highlightOrder', jsonEncode(_settingMap['highlightOrder']));
    prefs.setInt('widthNum', _settingMap['widthNum']);
    prefs.setInt('minHL', _settingMap['minHL']);
    prefs.setInt('maxHL', _settingMap['maxHL']);
    prefs.setBool('onDelete', _settingMap['onDelete']);
  }

// 사진의 세부 정보(본 횟수, rate 등) 바꿀 때 사용
  savePhoto(
      {required int id, required String key, required dynamic value}) async {
    final DB = await database;
    DB.rawQuery(''' UPDATE photos SET $key = $value WHERE id = $id ''');
    update();
  }

  saveHighlight() async {
    final DB = await database;
    late Highlight hl;
    for (int key in _highlightMap.keys.toList()) {
      hl = _highlightMap[key]!;
      DB.update(
          'highlights',
          {
            'idList': jsonEncode(hl.idList),
            'code': hl.code,
            'name': hl.name,
            'enabled': hl.enabled ? 1 : 0
          },
          where: 'id = ?',
          whereArgs: [key]);
    }
  }

  Future<int> addSubject(List value) async {
    /// addsubjectpage에서 불러온 newSubject를 한번에 관리하는 함수!!
    /// 날것의 정보를 정리해서 subject 인스턴스로 만들고,
    /// 데이터베이스에 저장하고, _subjectMap에 저장하고, subjectOrder 관리해야한다
    /// 데이터베이스에 먼저 저장해서 id를 먼저 얻어와야한다!!

    String name = value[0];
    String? thumbnailPath = value[1];
    List<XFile> xfileList = value[2];
    List<File> fileList = [];
    List<Photo> photoList = [];

    fileList = List.generate(xfileList.length, (i) => File(xfileList[i].path));
    fileList.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    String? thumbnailBase64;
    if (thumbnailPath == null) {
      if (fileList.length != 0)
        thumbnailBase64 = base64Encode(await FlutterImageCompress.compressWithList(
            fileList[0].readAsBytesSync(),
            minHeight: 1920,
            minWidth: 1080,
            quality: 60),);
    } else {
      thumbnailBase64 = base64Encode(File(thumbnailPath).readAsBytesSync());
    }

    final db = await database;
    int subjectID = await db
        .insert('subjects', {'name': name, 'thumbnailBase64': thumbnailBase64});

    for (File file in fileList) {
      // photoList 만드는 for 문!!
      photoList.add(Photo(
        // uint8list 형태 data를 압축해서 저장하자!
        id: -1,
        subjectID: subjectID,
        data: await FlutterImageCompress.compressWithList(
            file.readAsBytesSync(),
            minHeight: 1920,
            minWidth: 1080,
            quality: 60),
        createdDate: await file.lastModified(),
      ));
    }
    print("xfileList의 xfile을 uint8list 형태로 변환하여 photoList에 저장했습니다.");
    // photoList 완성~!~!
    print("photoList의 photo들을 만들어진 날짜를 기준으로 정렬하여 photoList를 완성했습니다.");



    // String? thumbnailBase64에 값 저장 완료!!


    for (Photo photo in photoList)
      await db.insert('photos', Photo.toMap(photo));
    print('새 과목 정보가 DB의 subjects와 photos 테이블에 저장되었습니다');
    // DB에 저장했으니 이제 subject 인스턴스를 만들어서 _subjectMap과 subjectOrder에 추가할 차례!

    // Uint8List? thumbnail =
    //     thumbnailBase64 != null ? base64Decode(thumbnailBase64) : null;
    // 이제 준비는 끝났다. subject 인스턴스를 만들고 추가만 하자.

    // _subjectMap[subjectID] = Subject(
    //     id: subjectID,
    //     name: name,
    //     thumbnail: thumbnail,
    //     photoList: photoList); // subjectMap에 추가 완료
    _settingMap['subjectOrder'].add(subjectID); // subjectOrder에 추가 완료
    await subjectOrderSet(); // subjectOrder는 따로 sharedPreferences에 저장
    _subjectMap = await loadSubjectMap();
    reloadHighlight();
    print('addSubject 메소드가 완료되었습니다. subjectMap과 Highlight를 새롭게 불러옵니다');
    update();

    return 0;
  }



  deletePhotos(List<int> idList) async {
    final DB = await database;
    for(int id in idList) {
      await DB.delete('photos', where: 'id = ?', whereArgs: [id]);
    }
    _subjectMap = await loadSubjectMap();
    update();
  }

  void deleteSubject(Subject subject) async {
    _settingMap['subjectOrder'].remove(subject.id);

    /// 만약 삭제하는 과목을 포함하는 하이라이트가 있으면 함께 삭제!
    List highlightOrder = jsonDecode(jsonEncode(_settingMap['highlightOrder']));
    for(int highlightID in highlightOrder) {
      if(_highlightMap[highlightID]!.idList.contains(subject.id)) {
        deleteHighlight(highlightID);
      }
    }

    saveSetting();
    update();
  }

  Future<void> permanentlyDeleteSubject(List<int> subjectIDList) async {
    final DB = await database;

    // for(int id in subjectIDList) {
    //   await DB.delete('photos', where: 'subjectID = ?', whereArgs: [id]);
    // }
    for(int id in subjectIDList) {
      print(id);
      await DB.delete('subjects', where: 'id = ?', whereArgs: [id]);
    }
    _subjectMap = await loadSubjectMap();
    update();
    List allSubject = List.generate(
        _subjectMap.keys.length, (i) => _subjectMap.values.toList()[i].id);
    print("allSubject: $allSubject");
  }


  void restoreSubject(List<int> idList) {
    for(int id in idList) {
      _settingMap['subjectOrder'].add(id);
    }
    saveSetting();
    update();
  }

  Future<void> addPhotos(int subjectID, List<Photo> photoList) async {
    /// 0106 기준, 내가 만들었지만 어디에 쓰이는지 모르겠다?? 애초에 db에 저장을 해야 id를 알 수 있고,
    /// Photo를 만들 수가 있는데... 일단 내비두고, addPhotoList를 새롭게 만든다.
    /// 아아, 다시 보아하니 Photo의 id를 -1로 두고 저장하는 것 같은데, 의미가 뭐지..? 아무리 나라지만
    /// 이해할 수 없다..
    final DB = await database;
    for (Photo photo in photoList) {
      await DB.insert('photos', Photo.toMap(photo));
    }
    _subjectMap = await loadSubjectMap();
    update();
  }

  void addPhotoList(int subjectID, List) {

  }

  void updatePhoto(Map<String, dynamic> photoMap) async {
    final DB = await database;
    DB.update('photos', photoMap, where: 'id = ?', whereArgs: [photoMap['id']]);
  }

  void reorderSubject(int oldIndex, int newIndex) async {
    /// oldOrder에서 object와 target의 위치를 바꾼다.
    List subjectOrder = settingMap['subjectOrder'];
    int object = subjectOrder[oldIndex];
    int target = subjectOrder[newIndex];
    subjectOrder.removeAt(newIndex);
    subjectOrder.insert(newIndex, object);
    subjectOrder.removeAt(oldIndex);
    subjectOrder.insert(oldIndex, target);

    _settingMap['subjectOrder'] = subjectOrder;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('subjectOrder', jsonEncode(_settingMap['subjectOrder']));
    update();
    print("reorderSubject: subjectOrder를 업데이트했습니다.");
  }

  Future<void> changeSubjectName(int id, String name) async {
    final DB = await database;
    await DB
        .rawQuery(''' UPDATE subjects SET name = ? WHERE id = $id ''', [name]);
    print("changeSubjectName: DB에 subject의 name을 업데이트했습니다.");
    _subjectMap = await loadSubjectMap();
    update();
  }

  Future<void> changeSubjectThumbnail(int id, String thumbnailBase64) async {
    final DB = await database;
    await DB.rawQuery(
        ''' UPDATE subjects SET thumbnailBase64 = ? WHERE id = $id ''',
        [thumbnailBase64]);
    print("changeSubjectThumbnail: DB에 subject의 thumbnail을 업데이트했습니다.");
    _subjectMap = await loadSubjectMap();
    update();
  }

  Future<void> subjectOrderSet() async {
    /// subject의 배열 순서를 주관하는 subjectOrder 리스트를 점검하고, SharedPreferences에 저장한다.
    // if (_settingMap['subjectOrder'].length != _subjectMap.length)
    //   print('!!에러: _settingMap의 subjectOrder의 원소 개수와 subjectMap의 원소 개수가 다릅니다');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('subjectOrder', jsonEncode(_settingMap['subjectOrder']));
  }

  // Future<void> highlightOrderSet() async {
  //   /// highlight 배열 순서를 주관하는 highlightOrder 리스트를 점검하고, SharedPreferences에 저장한다.
  //   if (_settingMap['highlightOrder'].length != _highlightMap.length)
  //     print('!!에러: _settingMap의 highlightOrder 원소 개수와 _highlightMap 원소 개수가 다릅니다');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('highlightOrder', jsonEncode(_settingMap['highlightOrder']));
  // }

  onSubjectDeleteStart() {
    _settingMap['onDelete'] = true;
    update();
  }

  onSubjectDeleteEnd() {
    _settingMap['onDelete'] = false;
    saveSetting();
    update();
  }

  widthNumSet(int num) {
    _settingMap['widthNum'] = num;
    update();
  }

  Future<void> addHighlight(
      List<int> subjectList, int code, String name) async {
    final db = await database;
    int id = await db.insert('highlights', {
      'idList': jsonEncode(subjectList),
      'code': code,
      'name': name,
      'enabled': 1
    });
    _highlightMap = await loadHighlightMap();
    _settingMap['highlightOrder'].add(id);
    saveSetting();
    reloadHighlight();
    update();
  }

  deleteHighlight(int id) async {
    final DB = await database;
    await DB.delete('highlights', where: 'id = ?', whereArgs: [id]);
    _highlightMap = await loadHighlightMap();
    _settingMap['highlightOrder'].remove(id);
    saveSetting();
    reloadHighlight();
    update();
  }

  Future<void> highlightRangeSet(SfRangeValues values) async {
    _settingMap['minHL'] = values.start.toInt() == 0 ? 1 : values.start.toInt();
    _settingMap['maxHL'] = values.end.toInt();
    update();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('minHL', _settingMap['minHL']);
    prefs.setInt('maxHL', _settingMap['maxHL']);
  }

  highlightEnableSet(int id, bool enabled) async {
    final DB = await database;
    await DB.rawUpdate(
        'UPDATE highlights SET enabled = ? WHERE id = $id ', [enabled ? 1 : 0]);
    _highlightMap = await loadHighlightMap();
    update();
  }

  highlightOrderSet(List newHighlightOrder) {
    _settingMap['highlightOrder'] = newHighlightOrder;
    update();
    saveSetting();
  }

  highlightSet(Map<int, Map> newHighlightMap) {
    _highlightMap = {};
    for (int id in newHighlightMap.keys.toList()) {
      _highlightMap[id] = Highlight(
        code: newHighlightMap[id]!['code'],
        idList: newHighlightMap[id]!['idList'],
        name: newHighlightMap[id]!['name'],
        enabled: newHighlightMap[id]!['enabled'],
      );
    }
    saveHighlight();
  }
}
