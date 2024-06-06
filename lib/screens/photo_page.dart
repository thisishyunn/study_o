import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_study_o_ver2/data/database.dart';
import 'package:flutter_project_study_o_ver2/data/structure.dart';
import 'package:flutter_project_study_o_ver2/utils/edit_photo.dart';
import 'package:get/get.dart';
import 'package:transparent_image/transparent_image.dart';

class PhotoPage extends StatefulWidget {
  final List<Photo> photoList;
  final int photoIndex;
  final int mode;

  const PhotoPage(
      {Key? key,
      required this.photoList,
      required this.photoIndex,
      this.mode = 0})
      : super(key: key);

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage>
    with SingleTickerProviderStateMixin {
  late PageController pageController;
  TransformationController _transformationController =
      TransformationController();
  late TapDownDetails _doubleTapDetails;
  late AnimationController _animationController;
  late Animation<Matrix4> _animation;
  bool appBarSwitch = false;
  bool onZoom = false;
  double scale = 1.0;
  late int currentPhoto;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController =
        PageController(initialPage: widget.photoIndex, viewportFraction: 1.1);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addListener(() {
        _transformationController.value = _animation.value;
      });

    currentPhoto = widget.photoIndex;
    widget.photoList[currentPhoto].viewNum += 1;
    int id = widget.photoList[currentPhoto].id;
    int v = widget.photoList[currentPhoto].viewNum;
    ManageData().savePhoto(id: id, key: 'viewNum', value: v);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // scaffold 의 body 를 담당!!
  Widget photoView() {
    return PageView.builder(
      itemCount: widget.photoList.length,
      physics: onZoom ? NeverScrollableScrollPhysics() : null,
      onPageChanged: (index) async {
        setState(() {
          currentPhoto = index;
          widget.photoList[currentPhoto].viewNum += 1;
        });
        await Future.delayed(Duration(seconds: 1));
        int id = widget.photoList[currentPhoto].id;
        int v = widget.photoList[currentPhoto].viewNum;
        ManageData().savePhoto(id: id, key: 'viewNum', value: v);
      },
      allowImplicitScrolling: true,
      controller: pageController,
      itemBuilder: (BuildContext context, int index) {
        return Center(
          child: GestureDetector(
            child: Container(
              width: Get.width + 500,
              color: Colors.black,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: Get.width,
                  child: InteractiveViewer(
                    // boundaryMargin: EdgeInsets.all(20.0),
                    // constrained: false,
                    transformationController: _transformationController,
                    minScale: 1.0,
                    child: Image.memory(widget.photoList[index].data, fit: BoxFit.cover,),
                    onInteractionEnd: (details) {
                      scale =
                          _transformationController.value.getMaxScaleOnAxis();
                      if (scale != 1) {
                        setState(() {
                          onZoom = true;
                        });
                      } else {
                        setState(() {
                          onZoom = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            onVerticalDragUpdate: onZoom
                ? null
                : (dragUpdateDetails) {
                    if (dragUpdateDetails.delta.dy > 3) {
                      Get.back();
                    }
                  },
            onTap: () {
              setState(() {});
              appBarSwitch = !appBarSwitch;
            },
            onDoubleTapDown: (TapDownDetails details) {
              _doubleTapDetails = details;
            },
            onDoubleTap: () {
              late Matrix4 _endMatrix;
              if (onZoom) {
                _endMatrix = Matrix4.identity();
                print("zooming out");
                setState(() {
                  onZoom = false;
                });
              } else {
                final position = _doubleTapDetails.localPosition;
                _endMatrix = Matrix4.identity()
                  ..translate(-position.dx * 2, -position.dy * 2)
                  ..scale(3.0);
                print("zooming in");
                setState(() {
                  onZoom = true;
                });
              }

              _animation = Matrix4Tween(
                begin: _transformationController.value,
                end: _endMatrix,
              ).animate(CurveTween(curve: Curves.easeOut)
                  .animate(_animationController));
              _animationController.forward(from: 0);
            },
            onTapDown: (_) {
              print(onZoom ? "true" : "false");
            },
          ),
        );
      },
    );
  }

  BottomAppBar bottomAppBar() {
    Color iconColor = Colors.white.withOpacity(0.65);
    return BottomAppBar(
        // color: Color.fromRGBO(100, 100, 100, 1),
        color: Colors.transparent,
        elevation: 1,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: iconColor,
                  ),
                  onPressed: () async {
                    File? editedPhoto = await editPhoto(
                        widget.photoList[currentPhoto].data, null);
                    setState(() {
                      widget.photoList[currentPhoto].data =
                          editedPhoto!.readAsBytesSync();
                    });

                    Map<String, dynamic> photoMap =
                    await ManageData().getPhoto(widget.photoList[currentPhoto].id);
                    Map<String, dynamic> newPhotoMap = Map<String, dynamic>.from(photoMap);
                    newPhotoMap['thumbnailBase64'] = base64.encode(editedPhoto!.readAsBytesSync());
                    ManageData().updatePhoto(newPhotoMap);
                  }),
            ),
            Spacer(),
            importanceIcon(currentPhoto),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: Icon(
                    Icons.comment_outlined,
                    color: iconColor,
                    size: 30,
                  ),
                  onPressed: () {
                    explanationDialog(currentPhoto);
                  }),
            ),
          ],
        ));
  }

  // 사진 탭하면 밑에 뜨는 별표시 색깔 정하기!!
  importanceIcon(int currentPhoto) {
    print(currentPhoto);
    switch (widget.photoList[currentPhoto].rate) {
      case 0:
        return IconButton(
            icon: Icon(
              Icons.star_outline_sharp,
              color: Colors.white.withOpacity(0.65),
              size: 35,
            ),
            onPressed: () {
              setState(() {
                widget.photoList[currentPhoto].rate += 1;
              });
              ManageData().savePhoto(
                  id: widget.photoList[currentPhoto].id, key: 'rate', value: 1);
            });
      case 1:
        return IconButton(
            icon: Icon(
              // Icons.star_outline_sharp,
              Icons.star,
              color: Colors.white.withOpacity(0.9),
              size: 35,
            ),
            onPressed: () {
              setState(() {
                widget.photoList[currentPhoto].rate += 1;
              });
              ManageData().savePhoto(
                  id: widget.photoList[currentPhoto].id, key: 'rate', value: 2);
            });
      case 2:
        return IconButton(
            icon: Icon(
              Icons.star,
              color: Colors.yellowAccent.withOpacity(0.9),
              // color: Colors.blue.withOpacity(0.9),
              size: 35,
            ),
            onPressed: () {
              setState(() {
                widget.photoList[currentPhoto].rate -= 2;
              });
              ManageData().savePhoto(
                  id: widget.photoList[currentPhoto].id, key: 'rate', value: 0);
            });
    }
  }

  // 사진 탭하면 밑에 뜨는 말풍선!!
  explanationDialog(int currentPhoto) {
    TextEditingController nameController =
        TextEditingController(text: widget.photoList[currentPhoto].name);
    TextEditingController answerController =
        TextEditingController(text: widget.photoList[currentPhoto].answer);
    TextEditingController explanationController =
        TextEditingController(text: widget.photoList[currentPhoto].explanation);
    return showDialog(

        // barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 0),
            insetPadding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            scrollable: true,
            content: Column(
              children: [
                Container(
                  width: 300,
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '이름을 추가하세요',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Divider(),
                TextField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  maxLines: null,
                  controller: answerController,
                  decoration: InputDecoration(
                      hintText: '답을 추가하세요', border: InputBorder.none),
                ),
                Divider(),
                TextField(
                  style: TextStyle(height: 1.7),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  maxLines: 6,
                  controller: explanationController,
                  decoration: InputDecoration(
                      hintText: '해설을 추가하세요', border: InputBorder.none),
                ),
              ],
            ),
          );
        }).then((val) async {
      widget.photoList[currentPhoto].name = nameController.value.text;
      widget.photoList[currentPhoto].answer = answerController.value.text;
      widget.photoList[currentPhoto].explanation =
          explanationController.value.text;
      Map<String, dynamic> photoMap =
          await ManageData().getPhoto(widget.photoList[currentPhoto].id);
      Map<String, dynamic> newPhotoMap = Map<String, dynamic>.from(photoMap);
      newPhotoMap['name'] = nameController.value.text;
      newPhotoMap['answer'] = answerController.value.text;
      newPhotoMap['explanation'] = explanationController.value.text;
      ManageData().updatePhoto(newPhotoMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: appBarSwitch
          ? PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: AppBar(
                // actions: [Icon(Icons.settings)],
                automaticallyImplyLeading: false,
                elevation: 0,
                // backgroundColor: Color.fromRGBO(80, 80, 80, 0.5),
                backgroundColor: Colors.transparent,
              ),
            )
          : null,
      body: photoView(),
      extendBody: true,
      bottomNavigationBar: appBarSwitch ? bottomAppBar() : null,
    );
  }
}
