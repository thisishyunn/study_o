import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_project_study_o_ver2/screens/photo_confirm.dart';
import 'package:flutter_project_study_o_ver2/screens/photo_rotate_edit.dart';
import 'package:flutter_project_study_o_ver2/screens/photo_rotate_edit.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  final int subjectID;
  final int mode;
  final int length;

  const CameraPage({Key? key, required this.camera, this.subjectID = 0, this.mode = 0, this.length = 0}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<Uint8List> photoByteList = [];
  Image? prevImage;
  double x = 0;
  double y = 0;
  bool showGrid = false;
  bool onTakePhoto = false;
  bool showFocusCircle = false;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _controller = CameraController(widget.camera, ResolutionPreset.max);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Widget cameraTopBar() {
    return Container(
      // color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      showGrid = !showGrid;
                    });
                  },
                  icon: Icon(
                    Icons.grid_on_outlined,
                    color: Colors.white,
                    size: 33,
                  )),
            ),
            // TextButton(onPressed: (){}, child: Text("x"))
            Transform.rotate(
              angle: 3.1415 / 4,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    if (await onWillPop()) {
                      Get.back();
                    }
                  },
                  icon: Icon(
                    Icons.add_outlined,
                    color: Colors.white.withOpacity(0.8),
                    size: 50,
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget grid() {
    double thickness = 0.6;
    return Stack(
      children: [
        Column(
          children: [
            Spacer(),
            Container(
                width: Get.width,
                height: thickness,
                color: Colors.white.withOpacity(0.8)),
            Spacer(),
            Container(
                width: Get.width,
                height: thickness,
                color: Colors.white.withOpacity(0.8)),
            Spacer(),
          ],
        ),
        Row(
          children: [
            Spacer(),
            Container(
                height: Get.height,
                width: thickness,
                color: Colors.white.withOpacity(0.8)),
            Spacer(),
            Container(
                height: Get.height,
                width: thickness,
                color: Colors.white.withOpacity(0.8)),
            Spacer(),
          ],
        )
      ],
    );
  }

  Widget cameraBottomBar() {
    return Container(
      width: Get.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Container(
          //   color: Color.fromRGBO(0, 0, 0, 1),
          //   width: Get.width,
          //   // height: 60,
          // ),
          photoByteList.length == 0? Container() : Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: 15),
              height: 45,
              width: 45,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(3)),
                        height: 45,
                        width: 45,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: prevImage ?? Container(),
                          clipBehavior: Clip.hardEdge,
                        )),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                          child: Text(
                        "${photoByteList.length}",
                        style: TextStyle(
                            color: photoByteList.length == 0
                                ? Colors.black
                                : Colors.white,
                            fontSize: 20),
                      )))
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle_outlined,
                  size: 70,
                  color: Colors.white,
                ),
                Bounce(
                    onPressed: takePicture,
                    duration: Duration(milliseconds: 100),
                    child: Icon(
                      Icons.circle,
                      size: 50,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
          photoByteList.length == 0
              ? Container()
              : Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text(
                      "다음",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: editAndSave,
                  )),
        ],
      ),
    );
  }

  Widget focusCircle() {
    return Positioned(
        top: y-30,
        left: x-30,
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              // shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 2),
          ),
        ));
  }

  Future<void> onTapFocus(TapUpDetails details) async {
    if(_controller.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = Get.width;
      double cameraHeight = fullWidth * _controller.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp,yp);
      print("point : $point");

      // Manually focus
      await _controller.setFocusPoint(point);

      // Manually set light exposure
      _controller.setExposurePoint(point);

      setState(() {
        Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    }
  }

  Future<void> editAndSave() async {
    // for (int id = 0; id < photoByteList.length; id++) {
    //   // Uint8List editedPhotoInt = await
    //   Get.to(() => PhotoRotateEdit(id: id, length: photoByteList.length, photoInt: photoByteList[id]),
    //       transition: Transition.fadeIn, duration: Duration(milliseconds: 800));
    // }
    Get.off(PhotoConfirm(photoIntList: photoByteList, subjectID: widget.subjectID,));
  }

  void takePicture() async {
    await _initializeControllerFuture;
    XFile xImage = await _controller.takePicture();
    await blink();
    File fImage = File(xImage.path);
    if(widget.mode == 1) Get.back(result: fImage.readAsBytesSync());
    setState(() {
      prevImage = Image.file(fImage);
    });
    photoByteList.add(fImage.readAsBytesSync());
  }

  Future<void> blink() async {
    setState(() {
      onTakePhoto = true;
    });
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      onTakePhoto = false;
    });
  }

  Future<bool> onWillPop() async {
    late bool goBack;
    if (photoByteList.length == 0) return true;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('나가시겠습니까?'),
            content: Text("사진 촬영 내역이 저장되지 않습니다"),
            actions: [
              TextButton(
                  onPressed: () {
                    goBack = true;
                    Navigator.of(context).pop();
                  },
                  child: Text('확인')),
              TextButton(
                  onPressed: () {
                    goBack = false;
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'))
            ],
          );
        });
    return goBack;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          child: Container(
                            width: Get.width,
                            height: Get.height,
                            child: AspectRatio(
                              aspectRatio: 1 / _controller.value.aspectRatio,
                              child: CameraPreview(_controller,
                                  child: Container(
                                      color: onTakePhoto
                                          ? Colors.black.withOpacity(0.9)
                                          : null,
                                      child: showGrid ? grid() : null)),
                            ),
                          ),
                          onTapUp: (details) {
                            onTapFocus(details);
                          },
                        ),
                        cameraTopBar(),
                        Positioned(
                          bottom: 0,
                          child: cameraBottomBar(),
                        ),
                        showFocusCircle? focusCircle() : Container()
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
