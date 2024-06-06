import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/screens/camera_page.dart';
import 'package:flutter_project_study_o_ver2/screens/new_subject_page.dart';
import 'package:flutter_project_study_o_ver2/screens/photo_rotate_edit.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_project_study_o_ver2/utils/edit_photo.dart';

class PhotoConfirm extends StatefulWidget {
  final List<Uint8List> photoIntList;
  final int subjectID;

  const PhotoConfirm(
      {Key? key, required this.photoIntList, required this.subjectID})
      : super(key: key);

  @override
  _PhotoConfirmState createState() => _PhotoConfirmState();
}

class _PhotoConfirmState extends State<PhotoConfirm> {
  List<Uint8List> _photoIntList = [];
  FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 0);
  CarouselController _carouselController = CarouselController();
  int selectedPhoto = 0;

  f1_Edit() async {
    // Uint8List photoInt = await Get.to(() => PhotoRotateEdit(
    //     id: selectedPhoto,
    //     length: _photoIntList.length,
    //     photoInt: _photoIntList[selectedPhoto]),
    // transition: Transition.fadeIn,
    // duration: Duration(milliseconds: 300));

    File? editedPhoto = await editPhoto(_photoIntList[selectedPhoto],
        [selectedPhoto + 1, _photoIntList.length]);

    setState(() {
      _photoIntList[selectedPhoto] = editedPhoto!.readAsBytesSync();
    });
  }

  f2_Reload() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Uint8List photoInt = await Get.to(() => CameraPage(
          camera: firstCamera,
          mode: 1,
        ));
    setState(() {
      _photoIntList[selectedPhoto] = photoInt;
    });
  }

  f3_Delete() async {
    int dialog = 0;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text('과목 추가'),
            content: Text("사진을 삭제하시겠습니까?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소')),
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
      setState(() {
        _photoIntList.removeAt(selectedPhoto);
      });
      _carouselController.previousPage();
      setState(() {
        if (selectedPhoto != 0) selectedPhoto -= 1;
      });
    }
    if (_photoIntList.length == 0) Get.back();
  }

  f4_Add() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Uint8List photoInt = await Get.to(() => CameraPage(
          camera: firstCamera,
          mode: 1,
        ));
    setState(() {
      _photoIntList.add(photoInt);
    });
    _carouselController.jumpToPage(_photoIntList.length - 1);
    setState(() {
      selectedPhoto = _photoIntList.length - 1;
    });
  }

  Future<void> saveAll() async {
    List<Photo> photoList = List.generate(
        _photoIntList.length,
        (id) => Photo(
            id: -1,
            subjectID: widget.subjectID,
            data: _photoIntList[id],
            createdDate: DateTime.now()));
    await ManageData().addPhotos(widget.subjectID, photoList);
    if (ManageData().subjectMap[widget.subjectID]!.thumbnail == null) {
      ManageData().changeSubjectThumbnail(
          widget.subjectID, base64.encode(_photoIntList[0]));
    }
    SnackBar savePhotoSucess = SnackBar(
      content: Text("${_photoIntList.length} 장의 사진을 성공적으로 저장했어요"),
    );
    ScaffoldMessenger.of(context).showSnackBar(savePhotoSucess);
    Get.back();
    Get.back();
    await Get.to(
        () => SubjectPage(subject: ManageData().subjectMap[widget.subjectID]!));
  }

  PreferredSizeWidget myAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(Get.height / 16),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.add_circle_outline,
                color: Color.fromRGBO(135, 206, 250, 1)),
            onPressed: f4_Add),
        title: Text(
          "${selectedPhoto + 1} / ${_photoIntList.length}",
          style: TextStyle(color: Colors.black.withOpacity(0.7)),
        ),
        centerTitle: true,
        bottom: PreferredSize(
            child: Container(
              color: Colors.grey[400]!.withOpacity(0.8),
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(4.0)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [TextButton(onPressed: saveAll, child: Text("모두 저장"))],
      ),
    );
  }

  Widget myCarousel() {
    return Container(
      height: Get.height * 0.7,
      child: CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
            enlargeCenterPage: true,
            height: Get.height * 0.6,
            enableInfiniteScroll: false,
            onPageChanged: (id, b) {
              setState(() {
                selectedPhoto = id;
              });
            }),
        items: [
          for (Uint8List photoInt in _photoIntList)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              // width: Get.width * 0.65,
              height: Get.height * 0.65,
              child: Hero(
                tag: _photoIntList.indexOf(photoInt),
                child: Image.memory(
                  photoInt,
                  fit: BoxFit.cover,
                ),
              ),
              decoration: BoxDecoration(
                  border: _photoIntList.indexOf(photoInt) == selectedPhoto
                      ? Border.all(
                          color: Colors.grey.withOpacity(0.8), width: 4)
                      : null),
            )
        ],
      ),
    );
  }

  Widget myButtons() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: f1_Edit,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(135, 206, 250, 1)),
                  width: 50,
                  height: 50,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              GestureDetector(
                onTap: f2_Reload,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(135, 206, 250, 1)),
                    width: 60,
                    height: 60,
                    child:
                        Icon(Icons.camera_alt, color: Colors.white, size: 30)),
              ),
              GestureDetector(
                onTap: f3_Delete,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(135, 206, 250, 1)),
                  width: 50,
                  height: 50,
                  child: Icon(Icons.delete, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("편집",
                  style: TextStyle(color: Colors.black.withOpacity(0.6))),
              Text("   재촬영   ",
                  style: TextStyle(color: Colors.black.withOpacity(0.6))),
              Text("삭제", style: TextStyle(color: Colors.black.withOpacity(0.6)))
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _photoIntList = List.generate(
        widget.photoIntList.length, (index) => widget.photoIntList[index]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(252, 252, 252, 1),
        appBar: myAppBar(),
        body: Column(children: [
          myCarousel(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: Get.width,
              height: 1,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          myButtons(),
        ]),
      ),
    );
  }
}
