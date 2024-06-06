import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/screens/photo_page.dart';
import 'package:flutter_project_study_o_ver2/utils/load_image.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:transparent_image/transparent_image.dart';

import 'camera_page.dart';

class SubjectPage extends StatefulWidget {
  final Subject subject;

  const SubjectPage({Key? key, required this.subject}) : super(key: key);

  @override
  _SubjectPageState createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  bool onSelect = false;
  List<int> selectedIDList = [];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ManageData>(
      init: ManageData(),
      builder: (md) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              mySliverAppBar(md),
              SliverPadding(padding: EdgeInsets.symmetric(vertical: 1)),
              mySliverGrid(md)
            ],
          ),
          floatingActionButton: FloatingActionButton(
              backgroundColor: Color.fromRGBO(135, 206, 250, 1),
              child: onSelect
                  ? Icon(
                      Icons.delete,
                      size: 28,
                    )
                  : Icon(Icons.camera_alt),
              onPressed: onCameraPressed),
        );
      },
    );
  }

  Future<void> onCameraPressed() async {
    if (!onSelect) {
      print(0);

      try {
        print(1);
        final cameras = await availableCameras();
        print(2);
        print(cameras);

        final firstCamera = cameras.first;
        print(3);

        await Get.to(
            () => CameraPage(
                  camera: firstCamera,
                  subjectID: widget.subject.id,
                ),
            transition: Transition.downToUp);
      } catch (e) {
        print("e");
        Get.back();
      }
    } else {
      int dialog = 0;
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            dialog == 1;
            return AlertDialog(
              title: Text('사진 삭제'),
              content: Text(
                  "${selectedIDList.length}개 사진을 삭제하시겠습니까? \n\n사진은 복구되지 않습니다."),
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
      if (dialog == 1) {
        print("MD.deletePhotos: 사진을 삭제합니다...");
        await ManageData().deletePhotos(selectedIDList);
        Get.back();
        await Get.to(() =>
            SubjectPage(subject: ManageData().subjectMap[widget.subject.id]!));
        print("Get.to 끝");
      }
      setState(() {
        onSelect = false;
      });
    }
  }

  SliverAppBar mySliverAppBar(ManageData md) {
    return SliverAppBar(
      elevation: 0.0,
      floating: false,
      pinned: true,
      snap: false,
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: false,
      backgroundColor: Color.fromRGBO(135, 206, 250, 1),
      expandedHeight: 250,
      leadingWidth: 30,
      stretch: true,
      actions: onSelect
          ? [
              TextButton(
                  onPressed: () {
                    setState(() {
                      onSelect = false;
                    });
                  },
                  child: Text(
                    "취소",
                    style: TextStyle(
                        fontSize: 18, color: Colors.red[900]!.withOpacity(0.8)),
                  ))
            ]
          : [Padding(padding: const EdgeInsets.all(10), child: myPopUp(md))],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Stack(
          children: [
    //         Text(widget.subject.name,
    //             style: TextStyle(
    //                 fontSize: 30,
    //                 // color: Colors.white,
    //                 foreground: Paint()
    //                   ..style = PaintingStyle.stroke
    //                   ..strokeWidth = 1
    //                   // ..color = Color.fromRGBO(135, 206, 250, 1)
    //                   ..color = Colors.black
    // )),
            Text(widget.subject.name,
                style: TextStyle(
                    fontSize: 30,
                    // color: Colors.white,
                    // foreground: Paint()
                    //   ..style = PaintingStyle.stroke
                    //   ..strokeWidth = 1
                    //   ..color = Colors.white
    )
    ),
          ],
        ),
        background: widget.subject.thumbnail != null
            ? Hero(
                tag: widget.subject.id,
                child: Container(
    color: Colors.black,
                  child: Opacity(
    opacity: 0.8,
                    child: Image(
                        image: MemoryImage(widget.subject.thumbnail!),
                        fit: BoxFit.cover),
                  ),
                ))
            : Container(),
      ),
    );
  }

  SliverGrid mySliverGrid(ManageData md) {
    return SliverGrid.count(
        crossAxisCount: md.settingMap['widthNum'],
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        children: List.generate(widget.subject.photoList.length,
            (i) => onSelect ? onSelectPhoto(i) : offSelectPhoto(i)));
  }

  Widget offSelectPhoto(int id) {
    return GestureDetector(
      onTap: () async {
        await Get.to(() {
          return PhotoPage(photoIndex: id, photoList: widget.subject.photoList);
        }, transition: Transition.fade);
      },
      onLongPress: () {
        quickView(widget.subject.photoList[id]);
      },
      child: Container(
          child: Image.memory(widget.subject.photoList[id].data,
              fit: BoxFit.cover)),
    );
  }

  isSelected(int id) {
    if (selectedIDList.contains(id)) return true;
    return false;
  }

  Widget onSelectPhoto(int index) {
    int id = widget.subject.photoList[index].id;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected(id)) {
            selectedIDList.remove(id);
          } else {
            selectedIDList.add(id);
          }
        });
        print(selectedIDList);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
              child: Image.memory(widget.subject.photoList[index].data,
                  fit: BoxFit.cover)),
          isSelected(id)
              ? Container(color: Colors.black.withOpacity(0.5))
              : Container(),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: isSelected(id)
                  ? Icon(Icons.check_circle)
                  : Icon(Icons.circle_outlined),
              color: Colors.white,
              iconSize: 28,
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  List<Widget> photoDisplay() {
    List<Widget> result = [];
    for (Photo photo in widget.subject.photoList) {
      result.add(onSelect
          ? Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Get.to(() {
                      return PhotoPage(
                          photoIndex: widget.subject.photoList.indexOf(photo),
                          photoList: widget.subject.photoList);
                    }, transition: Transition.fade);
                  },
                  onLongPress: () {
                    quickView(photo);
                  },
                  child: Container(
                      child: Image.memory(photo.data, fit: BoxFit.cover)),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.circle_outlined),
                    color: Colors.white,
                    iconSize: 28,
                    onPressed: () {},
                  ),
                )
              ],
            )
          : Container());
    }
    return result;
  }

  quickView(Photo photo) async {
    Map photoMap = await ManageData().getPhoto(photo.id);
    return showAnimatedDialog(
        barrierDismissible: true,
        context: context,
        animationType: DialogTransitionType.scale,
        builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(children: [
              Container(
                width: 250,
                height: 450,
                child: Image.memory(
                  photo.data,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Icon(
                  Icons.visibility,
                  color: Colors.white,
                ),
                Text(
                  '${photoMap['viewNum']}',
                  style: TextStyle(color: Colors.white),
                ),
                Icon(Icons.grade, color: Colors.white),
                Text(
                  '${photo.rate}',
                  style: TextStyle(color: Colors.white),
                ),
              ]),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.date_range, color: Colors.white),
                  Text(
                    '${photoMap['createdDate']}',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ])));
  }

  PopupMenuButton myPopUp(ManageData md) {
    return PopupMenuButton(
      child: Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 1) {
          await changeSubjectNameDialog();
        } else if (value == 2) {
          await changeSubjectThumbnailDialog();
        } else if (value == 3) {
          await addFromGallery();
        } else if (value == 4) {
          selectedIDList = [];
          selectAndDeletePhoto();
        }
      },
      itemBuilder: (_) {
        return [
          PopupMenuItem(
              padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
              child: widthNumSet(md)),
          PopupMenuItem(
            padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
            value: 3,
            child: Text('갤러리에서 추가'),
          ),
          PopupMenuItem(
            padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
            value: 1,
            child: Text('과목명 변경'),
          ),
          PopupMenuItem(
            padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
            value: 2,
            child: Text('썸네일 변경'),
          ),
          PopupMenuItem(
            padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
            value: 4,
            child: Text('선택 삭제'),
          ),
        ];
      },
    );
  }

  Widget widthNumSet(ManageData md) {
    int widthNum = md.settingMap['widthNum'];

    return StatefulBuilder(
      builder: (context, setsState) {
        return Row(
          children: [
            Text('너비'),
            IconButton(
                disabledColor: Colors.grey,
                onPressed: () {
                  if (md.settingMap['widthNum'] != 1)
                    ManageData().widthNumSet(md.settingMap['widthNum'] - 1);
                  setsState(() {
                    widthNum = md.settingMap['widthNum'];
                  });
                },
                icon: Icon(Icons.arrow_left),
                color: md.settingMap['widthNum'] != 1
                    ? Colors.black
                    : Colors.grey),
            Text('$widthNum'),
            IconButton(
                onPressed: () {
                  if (md.settingMap['widthNum'] != 5)
                    ManageData().widthNumSet(md.settingMap['widthNum'] + 1);
                  setsState(() {
                    widthNum = md.settingMap['widthNum'];
                  });
                },
                icon: Icon(Icons.arrow_right,
                    color: md.settingMap['widthNum'] != 5
                        ? Colors.black
                        : Colors.grey)),
          ],
        );
      },
    );
  }

  Future<void> addFromGallery() async {
    List<XFile> xfileList = [];
    List<Photo> photoList = [];
    List<File> fileList = [];

    xfileList = await loadMultiImage();

    fileList = List.generate(xfileList.length, (i) => File(xfileList[i].path));
    fileList
        .sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    for (File file in fileList) {
      // photoList 만드는 for 문!!
      photoList.add(Photo(
        // uint8list 형태 data를 압축해서 저장하자!
        id: -1,
        subjectID: widget.subject.id,
        data: await FlutterImageCompress.compressWithList(
            file.readAsBytesSync(),
            minHeight: 1920,
            minWidth: 1080,
            quality: 60),
        createdDate: await file.lastModified(),
      ));
    }
    print("xfileList의 xfile을 uint8list 형태로 변환하여 photoList에 저장했습니다.");
    ManageData().addPhotos(widget.subject.id, photoList);
    Get.back();
  }

  Future<void> changeSubjectNameDialog() async {
    TextEditingController _textController = TextEditingController();
    Map<int, Subject> subjectMap = ManageData().subjectMap;
    List<String> subjectNameList = [];
    String newSubjectName = "";
    for (Subject s in subjectMap.values) {
      subjectNameList.add(s.name);
    }
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              actionsPadding: EdgeInsets.all(0),
              title: Text(''),
              content: TextField(
                decoration: InputDecoration(
                    hintText: '새 과목명을 입력하세요',
                    hintStyle: TextStyle(fontSize: 18)),
                onChanged: (value) {
                  setState(() {
                    newSubjectName = _textController.text;
                  });
                },
                controller: _textController,
              ),
              actions: [createSubmitButton(newSubjectName, subjectNameList)],
            );
          });
        });
  }

  Widget createSubmitButton(
      String newSubjectName, List<String> subjectNameList) {
    bool change = true;
    if (newSubjectName == "" || subjectNameList.contains(newSubjectName)) {
      change = false;
    }
    return TextButton(
        onPressed: change
            ? () async {
                await ManageData()
                    .changeSubjectName(widget.subject.id, newSubjectName);
                Navigator.of(context).pop();
                Get.back();
                SnackBar changeNameSuccess = SnackBar(
                  content: Text("과목명을 성공적으로 변경했어요"),
                );
                ScaffoldMessenger.of(context).showSnackBar(changeNameSuccess);
              }
            : null,
        child: Text('변경'));
  }

  Future<void> changeSubjectThumbnailDialog() async {
    String path = "";
    String thumbnailBase64 = "";
    late Uint8List bytes;
    path = await loadSingleImage();
    bytes = File(path).readAsBytesSync();
    thumbnailBase64 = base64Encode(bytes);
    await ManageData()
        .changeSubjectThumbnail(widget.subject.id, thumbnailBase64);
    Get.back();
    SnackBar changeThumbnailSuccess = SnackBar(
      content: Text("썸네일을 성공적으로 변경했어요"),
    );
    ScaffoldMessenger.of(context).showSnackBar(changeThumbnailSuccess);
  }

  selectAndDeletePhoto() async {
    setState(() {
      onSelect = true;
    });
  }
}
