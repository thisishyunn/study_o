import 'package:flutter/material.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/utils/load_image.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';

double w = Get.width;
double h = Get.height;

class AddSubjectPage extends StatefulWidget {
  const AddSubjectPage({Key? key}) : super(key: key);

  @override
  _AddSubjectPageState createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  /// [createButton],[subjectNameCheck],[subjectImageCheck],[subjectThumbnailCheck]
  ///

  final subjectNameController = TextEditingController();
  String? thumbnailPath;
  List<XFile> photoList = [];

  //사실 무쓸모, 보류했다가 지울 것
  YYDialog confirm() {
    //과목명, 사진을 선택하고 과목을 추가할 때 "과목을 추가하시겠습니까?" 알림 창
    return YYDialog().build()
      ..width = 260
      ..height = 142
      ..widget(Container(
        // color: Colors.blue,
        // height: 150,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "과목 추가",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 20, 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "과목을 추가하시겠습니까?",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text("확인"),
                    onPressed: () {
                      // Get.back(
                      //     result: [subjectNameController.text, thumbnailPath, photoList]);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ))
      ..borderRadius = 4
      ..show();
  }

  TextButton createButton() {
    /// 이름, 사진, 썸네일을 지정하고 마지막으로 과목을 추가할 떄 누르는 '확인' 버튼 표시!
    /// 과목명이 있을 경우에만 활성화되고, 중복되는 과목명이 있는지, 실수가 아닌지 확인하는
    /// 알림창을 띄우는 기능까지 담당한다.
    if (subjectNameController.text == '')
      return TextButton(onPressed: null, child: Text('만들기'));
    return TextButton(
        onPressed: () async {
          if (subjectNameRepeat(subjectNameController.text)) {
            Get.defaultDialog(middleText: '같은 이름의 앨범이 이미 존재합니다');
            return; // 다음 코드가 실행되지 않도록 아예 나가버린다
          }
          int dialog = 0;
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('과목 추가'),
                  content: Text("과목을 추가하시겠습니까?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          dialog = 1;
                          Navigator.of(context).pop();
                        },
                        child: Text('확인'))
                  ],
                );
              });
          if (dialog == 1)
            Get.back(
                result: [subjectNameController.text, thumbnailPath, photoList]);
        },
        child: Text('만들기'));
  }

  Icon subjectNameCheck() {
    /// 과목명 텍스트필드에 입력이 들어왔는지 확인해서 체크를 표시하는 함수
    return Icon(
      Icons.check,
      size: 30,
      color: subjectNameController.text == ''
          ? Colors.transparent
          : Colors.greenAccent[700],
    );
  }

  Icon subjectImageCheck() {
    /// 사진 선택 버튼에 선택을 완료했다는 뜻의 체크 표시를 옆에 띄울지 말지 알려주는 함수
    return Icon(
      Icons.check,
      color:
          photoList.length == 0 ? Colors.transparent : Colors.greenAccent[700],
      size: 25,
    );
  }

  Icon subjectThumbnailCheck() {
    /// 썸네일 선택 버튼에 선택을 완료했다는 뜻의 체크 표시를 옆에 띄울지 말지 알려주는 함수
    if (thumbnailPath == null) {
      return Icon(Icons.add, color: Colors.transparent);
    } else {
      return Icon(
        Icons.check,
        size: 25,
        color: thumbnailPath == null
            ? Colors.transparent
            : Colors.greenAccent[700],
      );
    }
  }

  bool subjectNameRepeat(String name) {
    /// 과목명이 중복되는지 검토하는 함수
    List<Subject> sl = ManageData().subjectMap.values.toList();
    for (Subject subject in sl) {
      if (subject.name == name) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.lightBlue),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: h * 0.15,),
            Container(
              // '과목명 추가' 텍스트필드! 체크표시를 스택으로 구성한다
              width: w * 0.85,
              child: Stack(children: [
                TextField(
                  controller: subjectNameController,
                  maxLength: 10,
                  style: TextStyle(fontSize: 23),
                  decoration: InputDecoration(
                      hintText: '과목명을 입력하세요',
                      hintStyle: TextStyle(fontSize: 23)),
                  onEditingComplete: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    currentFocus.unfocus();
                    setState(() {
                      createButton();
                      subjectNameCheck();
                    });
                  },
                ),
                Positioned(
                  child: subjectNameCheck(),
                  top: 10,
                  right: 5,
                )
              ]),
            ),
            SizedBox(height: h * 21 / 64,),
            Container(
              width: w * 0.85,
              alignment: Alignment.centerLeft,
              child: Text(
                '사진 추가',
                style: TextStyle(
                    fontSize: 12, color: Colors.black.withOpacity(0.5)),
              ),
            ),
            SizedBox(height: 14),
            ElevatedButton(
                /// 사진 추가 버튼!!
                onPressed: () async {
                  photoList = await loadMultiImage();
                  setState(subjectImageCheck);
                },
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0.0),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        side: BorderSide(
                            color: Colors.black.withOpacity(0.4))))),
                child: Container(
                    width: w * 0.8,
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: Stack(children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 20),
                          Text(
                            '사진 선택',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.9)),
                          ),
                        ],
                      ),
                      Positioned(
                        child: subjectImageCheck(),
                        right: 0,
                      )
                    ]))),
            SizedBox(height: 8),
            ElevatedButton(

                /// 썸네일 추가 버튼!!
                onPressed: () async {
                  thumbnailPath = await loadSingleImage();
                  setState(subjectThumbnailCheck);
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                        side: BorderSide(
                            color: Colors.black.withOpacity(0.4)))),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    elevation: MaterialStateProperty.all(0.0)),
                child: Container(
                    width: w * 0.8,
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 20),
                            Text(
                              '썸네일 선택',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.9)),
                            ),
                          ],
                        ),
                        Positioned(
                          child: subjectThumbnailCheck(),
                          right: 0,
                        )
                      ],
                    ))),
            SizedBox(height: 25),
            Expanded(child: createButton()) // 마지막 확인 버튼!!
          ],
        ),
      ),
    );
  }
}
