import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repaint_boundary_one/PermissionsService.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  GlobalKey src = GlobalKey();
  Image _image = Image.network("https://cdn.pixabay.com/photo/2019/05/02/16/58/stone-4173970_960_720.jpg");

  // Draw Variable Start
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];
  // Draw Variable End

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  
  takeScreenShot() async {
    print("processing");
    RenderRepaintBoundary boundary = src.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    String bs64 = base64Encode(pngBytes);

    
    final directory = await getExternalStorageDirectory();
    final myImagePath = '${directory.path}/MyImages';
    final myImgDir = await new Directory(myImagePath).create();

    File imgFile = File('$myImagePath/abc.png');
    imgFile.writeAsBytes(pngBytes);
    print(imgFile);
    // await GallerySaver.saveImage(imgFile);
    print("done");
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    PermissionsService().requestStoragePermission(
      onPermissionDenied: () {
        print('Permission has been denied');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget> [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.album),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.StrokeWidth)
                          showBottomList = !showBottomList;
                        selectedMode = SelectedMode.StrokeWidth;
                      });
                    }
                  ),
                  IconButton(
                    icon: Icon(Icons.opacity),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.Opacity)
                          showBottomList = !showBottomList;
                        selectedMode = SelectedMode.Opacity;
                      });
                    }
                  ),
                  IconButton(
                    icon: Icon(Icons.color_lens),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.Color)
                          showBottomList = !showBottomList;
                        selectedMode = SelectedMode.Color;
                      });
                    }
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        showBottomList = false;
                        points.clear();
                      });
                    }
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                // height: 500.0,
                child: RepaintBoundary(
                  key: src,
                  child: Stack(
                    children: <Widget>[
                      _image,
                      GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            RenderBox renderBox = context.findRenderObject();
                            points.add(DrawingPoints(
                                points: renderBox.globalToLocal(details.globalPosition),
                                paint: Paint()
                                  ..strokeCap = strokeCap
                                  ..isAntiAlias = true
                                  ..color = selectedColor.withOpacity(opacity)
                                  ..strokeWidth = strokeWidth));
                          });
                        },
                        onPanStart: (details) {
                          setState(() {
                            RenderBox renderBox = context.findRenderObject();
                            points.add(DrawingPoints(
                                points: renderBox.globalToLocal(details.globalPosition),
                                paint: Paint()
                                  ..strokeCap = strokeCap
                                  ..isAntiAlias = true
                                  ..color = selectedColor.withOpacity(opacity)
                                  ..strokeWidth = strokeWidth));
                          });
                        },
                        onPanEnd: (details) {
                          setState(() {
                            points.add(null);
                          });
                        },
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: DrawingPainter(
                            pointsList: points,
                          ),
                        ),
                      ),
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: TextField(
                      //     maxLines: 3,
                      //     decoration: InputDecoration(
                      //       border: InputBorder.none,
                      //       hintText: "Write here..",
                      //     ),
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            ),
            RaisedButton(
              child: Text('Download'),
              onPressed: (){
                FocusScope.of(context).requestFocus(FocusNode());
                takeScreenShot();
              },
            )
          ]
        )
      )
    );
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (color) {
                    pickerColor = color;
                  },
                  enableLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Save'),
                  onPressed: () {
                    setState(() => selectedColor = pickerColor);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }
        );
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.red, Colors.green, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }