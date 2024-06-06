import 'dart:math';
import 'package:flutter/material.dart';

enum InitialPosition { start, center, end }

class HorizantalPicker extends StatefulWidget {
  final double minValue, maxValue;
  final int divisions;
  final Function(double) onChanged;
  final InitialPosition initialPosition;
  final Color backgroundColor;
  final bool showCursor;
  final Color cursorColor;
  final Color activeItemTextColor;
  final Color passiveItemsTextColor;
  final String? suffix;
  HorizantalPicker(
      {required this.minValue,
        required this.maxValue,
        required this.divisions,
        required this.onChanged,
        this.initialPosition = InitialPosition.center,
        this.backgroundColor = Colors.transparent,
        this.showCursor = true,
        this.cursorColor = Colors.red,
        this.activeItemTextColor = Colors.blue,
        this.passiveItemsTextColor = Colors.red,
        this.suffix = ''})
      : assert(minValue < maxValue),
        assert(onChanged != null);
  @override
  _HorizantalPickerState createState() => _HorizantalPickerState();
}

class _HorizantalPickerState extends State<HorizantalPicker> {
  List<double> valueList = [];
  late FixedExtentScrollController _scrollController;

  int selectedFontSize = 14;
  List<Map> valueMap = [];

  @override
  void initState() {
    super.initState();

    for (var i = 0; i <= widget.divisions; i++) {
      Color barColor = Colors.grey;
      int _height = 24;
      if(i % 10 == 0) {
        barColor = Colors.red;
      }
      valueMap.add({
        "value": widget.minValue +
            ((widget.maxValue - widget.minValue) / widget.divisions) * i,
        "fontSize": 14.0,
        "color": barColor,
        "height" : 24,
      });
    }
    setScrollController();
  }

  setScrollController() {
    int initialItem;
    switch (widget.initialPosition) {
      case InitialPosition.start:
        initialItem = 0;
        break;
      case InitialPosition.center:
        initialItem = (valueMap.length ~/ 2);
        break;
      case InitialPosition.end:
        initialItem = valueMap.length - 1;
        break;
    }

    _scrollController = FixedExtentScrollController(initialItem: initialItem);
  }

  @override
  Widget build(BuildContext context) {
    // _scrollController.jumpToItem(curItem);
    return Container(
      padding: EdgeInsets.all(3),
      margin: EdgeInsets.all(20),
      height: 150,
      alignment: Alignment.center,
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        body: Stack(
          children: <Widget>[
            RotatedBox(
              quarterTurns: 3,
              child: ListWheelScrollView(
                  controller: _scrollController,
                  itemExtent: 10,
                  onSelectedItemChanged: (item) {
                    setState(() {
                      int decimalCount = 1;
                      num fac = pow(10, decimalCount);
                      valueMap[item]["value"] =
                          (valueMap[item]["value"] * fac).round() / fac;
                      widget.onChanged(valueMap[item]["value"]);
                      for (var i = 0; i < valueMap.length; i++) {
                        Color barColor = Colors.grey;
                        int _height = 24;
                        if(i % 10 == 0) {
                          barColor = Colors.white;
                          _height = 24;
                        }

                        if (i == item) {
                          valueMap[item]["color"] = widget.activeItemTextColor;
                          valueMap[item]["fontSize"] = 15.0;
                          valueMap[item]["hasBorders"] = true;
                          valueMap[item]["height"] = _height;
                        } else {
                          valueMap[i]["color"] = barColor;
                          valueMap[i]["fontSize"] = 14.0;
                          valueMap[i]["hasBorders"] = false;
                          valueMap[i]["height"] = _height;
                        }
                      }
                    });
                    setState(() {});
                  },
                  children: valueMap.map((Map curValue) {
                    //print("q");
                    //print(widget.backgroundColor.toString());
                    return ItemWidget(curValue,
                        backgroundColor: widget.backgroundColor,
                        suffix: widget.suffix!);
                  }).toList()),
            ),
            Visibility(
              visible: widget.showCursor,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: widget.cursorColor.withOpacity(0.3)),
                  width: 3,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ItemWidget extends StatefulWidget {
  final Map curItem;
  final Color backgroundColor;
  final String? suffix;
  ItemWidget(this.curItem, {required this.backgroundColor, this.suffix});

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  void initState() {
    super.initState();
    int decimalCount = 1;
    num fac = pow(10, decimalCount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RotatedBox(
        quarterTurns: 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                height: widget.curItem["height"] + 0.0,
                width: 1.2,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_app/utils/horizontal_picker.dart';

// void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horizontal Picker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _maxValue = 250;
  int _divisions = 250;
  double? newValue;


  @override
  void initState() {
    newValue = (_maxValue ~/ 2) as double;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(newValue.toString()),
          Container(
            margin: EdgeInsets.all(10),
            height: 120,
            child: HorizantalPicker(
              minValue: 0,
              maxValue: _maxValue,
              divisions: _divisions,
              onChanged: (value) {
                setState(() {
                  newValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}