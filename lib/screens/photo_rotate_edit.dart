import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_project_study_o_ver2/screens/photo_crop_edit.dart';
import 'package:flutter_project_study_o_ver2/screens/temp.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:screenshot/screenshot.dart';
import 'package:crop/crop.dart';
import 'dart:ui' as ui;

double ratio = 9 / 16;
double h = Get.height * 0.6;
double w = Get.height * 0.6 * ratio;

class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double sh = w; // for convenient shortage
    double sw = h; // for convenient shortage
    // double sh = 210; // for convenient shortage
    // double sw = 140;
    double cornerSide = sh * 0.08; // desirable value for corners side

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    Path path = Path()
      ..moveTo(cornerSide, 0)
      ..lineTo(0, 0)
      ..lineTo(0, cornerSide)
      ..moveTo(0, sw - cornerSide)
      ..lineTo(0, sw)
      ..lineTo(cornerSide, sw)
      ..moveTo(sh - cornerSide, sw)
      ..lineTo(sh, sw)
      ..lineTo(sh, sw - cornerSide)
      ..moveTo(sh, cornerSide)
      ..lineTo(sh, 0)
      ..lineTo(sh - cornerSide, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;
//
// @override
// bool shouldRebuildSemantics(BorderPainter oldDelegate) => false;
}

class PhotoRotateEdit extends StatefulWidget {
  final int id;
  final int length;
  final Uint8List photoInt;

  const PhotoRotateEdit(
      {Key? key,
      required this.id,
      required this.length,
      required this.photoInt})
      : super(key: key);

  @override
  State<PhotoRotateEdit> createState() => _PhotoRotateEditState();
}

class _PhotoRotateEditState extends State<PhotoRotateEdit> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  double angle = 0;
  FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 45);
  final cropController = CropController(aspectRatio: ratio);
  final _cropController =
      CropController(aspectRatio: ratio); //숨겨진 전체화면 크기 사진

  int _currentAngle = 0;
  int delayedTime = 0;
  double _theta = 0;
  bool changed = false;

  _cropImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cropped = await cropController.crop(pixelRatio: pixelRatio);
    return cropped;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            // width: 30,
            // height: 45,
            child: Crop(
              controller: _cropController,
              child: Image.memory(
                widget.photoInt,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(40),
                child: AppBar(
                  title: Text(
                    "${widget.id + 1} / ${widget.length} 장의 사진",
                    style: TextStyle(fontSize: 17),
                  ),
                  leading: IconButton(
                    onPressed: () {
                      print("뒤로");
                      Get.back(result: widget.photoInt);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  elevation: 0,
                  leadingWidth: 0,
                  backgroundColor: Colors.transparent,
                  actions: [
                    TextButton(
                        onPressed: () {
                          print("뒤로");
                          Get.back(result: widget.photoInt);
                        },
                        child: Text("완료"))
                  ],
                ),
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: Column(
                  children: [
                    Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(30),
                      child: IgnorePointer(
                        child: Stack(
                          children: [
                            Container(
                              width: w,
                              height: h,
                              child: Crop(
                                controller: cropController,
                                child: Image.memory(
                                  widget.photoInt,
                                  fit: BoxFit.contain,
                                ),
                                helper: CustomPaint(
                                  foregroundPainter: BorderPainter(),
                                  child: Container(
                                    height: h,
                                    width: w,
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                            // Container(color: Colors.black.withOpacity(0.5),width:  Get.width, height: Get.height,),
                            changed
                                ? grid()
                                : Container(
                                    height: h,
                                    width: w,
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: anglePicker()),
                  ],
                ),
              ),
              bottomNavigationBar: bottomAppBar()),
        ],
      ),
    );
  }

  Widget anglePicker() {
    return Container(
      width: Get.width * 0.8,
      height: Get.height * 0.14,
      child: Stack(
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: ListWheelScrollView(
                controller: _scrollController,
                diameterRatio: 2.3,
                itemExtent: 10,
                squeeze: 1,
                onSelectedItemChanged: (item) async {
                  //////////////////////////////////////
                  print(item);
                  delayedTime = 0;
                  setState(() {
                    /////////////////////////////////////////////////////////////////
                    // changed = item == 45 ? false : true;
                    changed = true;
                    _currentAngle = item - 45;
                    _theta = (item - 45) * 3.14 / 180;
                    cropController.rotation = item - 45;
                    cropController.scale = _theta < 0
                        ? max(sin(atan(ratio) + _theta) / sin(atan(ratio)),
                            cos(atan(ratio) + _theta) / cos(atan(ratio)))
                        : max(sin(atan(1 / ratio) + _theta) / sin(1 / ratio),
                            cos(1 / ratio + _theta) / cos(1 / ratio));
                  });
                  delayedTime = item;
                  await Future.delayed(Duration(milliseconds: 1000));
                  if (delayedTime == item) {
                    setState(() {
                      changed = false;
                    });
                  }
                },
                children: [
                  for (int i = -45; i < 0; i++)
                    Container(
                      margin: EdgeInsets.all(4.2),
                      width: 15,
                      height: 1,
                      color: i % 10 == 0 ? Colors.white : Colors.grey,
                    ),
                  Container(
                    margin: EdgeInsets.all(4.2),
                    width: 15,
                    height: 1,
                    color: Colors.blue,
                  ),
                  for (int i = 1; i < 46; i++)
                    Container(
                      margin: EdgeInsets.all(4.2),
                      width: 15,
                      height: 1,
                      color: i % 10 == 0 ? Colors.white : Colors.grey,
                    ),
                ]),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 30,
              width: 2,
              color: Colors.blue,
            ),
          ),
          Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Text(
                "$_currentAngle˚",
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
    );
  }

  Widget grid() {
    double thickness = 0.6;
    double opacity = 0.6;
    return Container(
      width: w,
      height: h,
      child: Stack(
        children: [
          Column(
            children: [
              Spacer(),
              Container(
                  width: w,
                  height: thickness,
                  color: Colors.white.withOpacity(opacity)),
              Spacer(),
              Container(
                  width: w,
                  height: thickness,
                  color: Colors.white.withOpacity(opacity)),
              Spacer(),
            ],
          ),
          Row(
            children: [
              Spacer(),
              Container(
                  height: h,
                  width: thickness,
                  color: Colors.white.withOpacity(opacity)),
              Spacer(),
              Container(
                  height: h,
                  width: thickness,
                  color: Colors.white.withOpacity(opacity)),
              Spacer(),
            ],
          )
        ],
      ),
    );
  }

  Widget bottomAppBar() {
    return BottomAppBar(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: Text("재설정"),
            onPressed: () {
              setState(() {
                _theta = 0;
                changed = false;
              });
              _scrollController.animateTo(45 * 10,
                  duration: Duration(milliseconds: 1), curve: Curves.ease);
            },
            style: TextButton.styleFrom(
                primary: Colors.red[900]!.withOpacity(0.8)),
          ),
          // Text("제목", style: TextStyle(color: Colors.white, fontSize: 16),),
          IconButton(
              onPressed: () async {
                _cropController.rotation = _theta * 180 / 3.14;
                _cropController.scale = _theta < 0
                    ? max(sin(0.982793 + _theta) / sin(0.982793),
                        cos(0.982793 + _theta) / cos(0.982793))
                    : max(sin(0.588 + _theta) / sin(0.588),
                        cos(0.588 + _theta) / cos(0.588));
                ui.Image rotatedImage = await _cropController.crop();
                final pngBytes = await rotatedImage.toByteData(
                    format: ui.ImageByteFormat.png);



                Directory dir = await getApplicationDocumentsDirectory();
                String path = dir.path;
                final buffer = pngBytes!.buffer;
                print("buffer 완료");

                File imageFile = await File('$path/image.PNG').writeAsBytes(
                    buffer.asUint8List(pngBytes.offsetInBytes, pngBytes.lengthInBytes));
                imageFile.copy('$path/image111.png');
                imageFile.printInfo();
                print("변환 완료");
                // Get.to(() => PhotoCropEdit(photoInt: Uint8List.view(pngBytes!.buffer)));
                // Get.to(() => PhotoCropEdit(photoInt: widget.photoInt));
                Get.to(() => MyHomePage(title: "제목", imageFilePath: '$path/image.PNG',));
              },
              icon: Icon(
                Icons.crop,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
