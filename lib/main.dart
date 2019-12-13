import 'dart:convert';
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repaint_boundary_one/PermissionsService.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; 
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart' as hsvColor;
import 'package:flutter_widgets/flutter_widgets.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  GlobalKey previewContainer = GlobalKey();
  FocusNode editTextFocusNode = FocusNode();
  GlobalKey src = GlobalKey();
  var _image = "https://cdn.pixabay.com/photo/2019/05/02/16/58/stone-4173970_960_720.jpg";
  var view = "hsvPicker";
  bool isSuccessful = false;
  var topRightIconSize = 20.0;

  var selectedImg = "https://cdn.pixabay.com/photo/2019/05/02/16/58/stone-4173970_960_720.jpg";

  List<dynamic> imgArray = [
    {
      "image": "https://cdn.pixabay.com/photo/2019/05/02/16/58/stone-4173970_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/02/20/10/04/penguin-4008872_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/12/02/03/26/snow-4666831_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/12/05/21/07/snowman-4676142_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/12/05/21/07/snowman-4676142_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/10/30/16/19/fox-4589927_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/11/24/14/00/iceland-horses-4649468_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/12/06/12/26/the-height-of-the-4677256_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/12/06/07/58/landscape-4676862_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
    {
      "image": "https://cdn.pixabay.com/photo/2019/12/07/14/03/winter-4679383_960_720.jpg",
      "drawPoint": [],
      "textPoint": [],
    },
  ];

  // TEXT VARIABLE START
  //
  //
  final textController = TextEditingController();
  Offset offset = Offset.zero;
  var textFontSizeUp = 20.0;
  double _scale = 1.0;
  double _previousScale;
  var yOffset = 400.0;
  var xOffset = 50.0;
  var rotation = 0.0;
  var lastRotation = 0.0;
  bool typing = false;
  bool textMode = false;
  bool drawMode = false;
  var textEntered = "";
  var textDisplay = "";
  var textColor;
  //
  //
  // TEXT VARIABLE END

  List newArr = List();

  var editMode;
  Matrix4 matrix = Matrix4.identity();

  // Draw Variable Start
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List();
  TextPoints text = TextPoints();

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

  static var imgIndex = 0;

  // Color Variable Start
  ValueChanged<HSVColor> onChanged;
  List<Color> linearColor = [
    Color(0xfff32121),
    Color(0xfff3f321),
    Color(0xff21f321),
    Color(0xff21f3f3), 
    Color(0xff2121f3),
    Color(0xfff321f3),
    Color(0xfff32121),
  ];
  var colorSelected;
  var pickMode = "color"; // grey
  // Color Variable End

  // void hueOnChange(double value) => onChanged(color.withHue(value));

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  
  takeScreenShot() async {
    _showDialog();
    await Future.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < imgArray.length; i++) {
      setState(() {
        points = imgArray[i]['drawPoint'];
        selectedImg = imgArray[i]['image'];
        text = imgArray[i]['textPoint'];
      });
      // print(selectedImg);
      await Future.delayed(const Duration(milliseconds: 100)); // wait for 0.1 seconds for the changes to reflect
      // if (!showCompletely) {
      //   await Future.delayed(const Duration(milliseconds: 500)); // wait for 0.1 seconds for the changes to reflect
      // }
      FocusScope.of(context).requestFocus(FocusNode());
      print("processing " + i.toString());
      RenderRepaintBoundary boundary = previewContainer.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String bs64 = base64Encode(pngBytes);

      
      final directory = await getExternalStorageDirectory();
      final myImagePath = '${directory.path}/MyImages';
      final myImgDir = await new Directory(myImagePath).create();

      File imgFile = File('$myImagePath/${timestamp()}_$i.png');
      imgFile.writeAsBytes(pngBytes);
      print(imgFile);
      // await GallerySaver.saveImage(imgFile);
      print("done " + i.toString());
    }
    // setState(() {
    //   isSaving = false;
    // });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textController.dispose();
    editTextFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    PermissionsService().requestStoragePermission(
      onPermissionDenied: () {
        print('Permission has been denied');
    });

    //  editTextFocusNode = FocusNode();
    // listen to focus changes
    editTextFocusNode.addListener(() => print('focusNode updated: hasFocus: ${editTextFocusNode.hasFocus}'));
    // calculateImg();
    // calculateImageWidthHeight(_image);

    for (var i = 0; i < imgArray.length; i++) {
      setState(() {
        imgArray[i]['drawPoint'] = List<DrawingPoints>();
        imgArray[i]['textPoint'] = TextPoints();
        // imgArray[i]['textPoint'].points = Offset.zero;
      });
      print(imgArray[i]['textPoint']);
    }

    setState(() {
      imgArray[0]['textPoint'].coloring = Color(0xfff32121);
      imgArray[0]['textPoint'].points = Offset(22.915482954545496, 284.7656250000002);
      imgArray[0]['textPoint'].textStr = "HELLO WORLD";

      text = imgArray[0]['textPoint'];
    });

    
  }

  var hsvPicker = Container(
    child: hsvColor.ColorPicker(
      color: Colors.blue,
      onChanged: (value){ }
    )
  );

  Container linearGradientBox = Container(
    color: Colors.red,
    height: 250.0,
    width: 500.0,
    child: Text("hi"),
    // DecoratedBox(
    //   decoration: BoxDecoration(
    //     gradient: LinearGradient(
    //       begin: Alignment.centerLeft,
    //       end: Alignment.centerRight,
    //       colors: [
    //         Color(0xfff32121),
    //         Color(0xfff3f321),
    //         Color(0xff21f321),
    //         Color(0xff21f3f3),
    //         Color(0xff2121f3),
    //         Color(0xfff321f3),
    //         Color(0xfff32121),
    //       ],
    //       tileMode: TileMode.clamp
    //     )
    //   ),
    // ),
  );

  calculateImg() async {
    var a = await _calculateImageDimension();
    print(a);
  }

  Future<Size> _calculateImageDimension() {
    Completer<Size> completer = Completer();
    Image image = Image.network(_image);
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  calculateImageWidthHeight(image) async {
    File getImage = new File(image); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(getImage.readAsBytesSync());
    print(decodedImage.width);
    print(decodedImage.height);
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    print(update.globalPosition.toString());
    RenderBox getBox = context.findRenderObject();
    var local = getBox.globalToLocal(update.globalPosition);
    print(local.dx.toString() + "|" + local.dy.toString());
  }

  /// calculate colors picked from palette and update our states.
  void handleTouch(Offset globalPosition, BuildContext context) {
    RenderBox box = context.findRenderObject();
    Offset localPosition = box.globalToLocal(globalPosition);
    double percent;
    print(localPosition);

    percent = (localPosition.dy - 75) / 350;
    // percent = localPosition.dx / 360;

    percent = min(max(0.0, percent), 1.0);
    setState(() {
      percent = percent;
    });
    // print(percent);

    Color color;
    if (pickMode == "grey") {
      final int channel = (0xff * percent).toInt();
      color = Color.fromARGB(0xff, channel, channel, channel);
    }
    else {
      color = HSVColor.fromAHSV(1.0, percent * 360, 1.0, 1.0).toColor();
    }

    print(color);
    if (drawMode) {
      setState(() {
        selectedColor = color;
      });
    }
    else if (textMode) {
      setState(() {
        textColor = color;
        imgArray[imgIndex]['textPoint'].coloring = color;
      });
    }
  }

  void _showDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Saving..."),
            ],
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIOverlays([]); // hide status bar

    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: GestureDetector(
        // onTap: () => FocusScope.of(context).unfocus(),
        // onTap: editMode == "drawMode" ? () {
        //   print("yes");
        // } : () {
        //   print("no");
        // },
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            points.add(DrawingPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = strokeCap
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth)
            );
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
                ..strokeWidth = strokeWidth)
            );
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.blue,
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              RepaintBoundary(
                key: previewContainer,
                child: Visibility( // DRAWING WIDGET
                  visible: true,
                  // visible: editMode == "drawMode" ? true : false,
                  child: GestureDetector(
                    onPanStart: drawMode ? (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(DrawingPoints(
                          points: renderBox.globalToLocal(details.globalPosition),
                          paint: Paint()
                            ..strokeCap = strokeCap
                            ..isAntiAlias = true
                            ..color = selectedColor.withOpacity(opacity)
                            ..strokeWidth = strokeWidth
                          )
                        );
                        newArr.add(points);
                      });
                    } : (details) { print("a"); },
                    onPanUpdate: drawMode ? (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(DrawingPoints(
                          points: renderBox.globalToLocal(details.globalPosition),
                          paint: Paint()
                            ..strokeCap = strokeCap
                            ..isAntiAlias = true
                            ..color = selectedColor.withOpacity(opacity)
                            ..strokeWidth = strokeWidth
                          )
                        );
                      });
                    } : (details) { print("b"); },
                    onPanEnd: drawMode ? (details) {
                      setState(() {
                        points.add(null);
                        imgArray[imgIndex]['drawPoint'] = points;
                      });
                      // print(points.length);
                    } : (details) { print("c"); },
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: DrawingPainter(
                        // pointsList: imgArray[imgIndex]['drawPoint'],
                        pointsList: points,
                      ),
                      // child: Text("HELLO WORLD"),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: Image.network(selectedImg),
                            // child: VisibilityDetector(
                            //   key: UniqueKey(),
                            //   onVisibilityChanged: (VisibilityInfo info) {
                            //     debugPrint("${info.visibleFraction} of my widget is visible");
                            //     if (info.visibleFraction == 1.0) {
                            //       setState(() {
                            //         showCompletely = true;
                            //       });
                            //     }
                            //   },
                            //   child: Image.network(selectedImg),
                            // )
                          ),
                          Positioned(
                            left: text.points.dx,
                            top: text.points.dy,
                            child: GestureDetector( 
                              onPanUpdate: (details) { // dx: horizontal, dy: vertical
                                // if ((offset.dx + details.delta.dx > 0 ) && (offset.dy + details.delta.dy > 0 && offset.dy + details.delta.dy <  MediaQuery.of(context).size.height)) {
                                // if ((offset.dx + details.delta.dx > 0 && offset.dx + details.delta.dx < MediaQuery.of(context).size.width) && (offset.dy + details.delta.dy > 0 && offset.dy + details.delta.dy <  MediaQuery.of(context).size.height)) {
                                if ((offset.dx + details.delta.dx < MediaQuery.of(context).size.width * 0.8) && offset.dy + details.delta.dy > 0 && offset.dy + details.delta.dy < MediaQuery.of(context).size.height) {
                                  setState(() {
                                    offset = Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                                    imgArray[imgIndex]['textPoint'].points = offset;
                                  });
                                }
                                print(offset.dx.toString() + " | " + offset.dy.toString());
                              },
                              onTap: () {
                                setState(() {
                                  drawMode = false;
                                  textMode = true;
                                });
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(text.textStr,
                                  maxLines: 100,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28.0,
                                    color: text.coloring
                                    // color: textColor
                                    // color: Colors.red
                                  )
                                )
                              ),
                            ),
                          )
                        ]
                      )
                    ),
                  ),
                ),
              ),
              Visibility( // EDIT TEXT WIDGET
                visible: textMode ? true : false,
                // visible: editTextFocusNode.hasFocus == true ? true : false,
                child: GestureDetector( // OVERLAY EDIT TEXT
                  // onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                  // onTap: () => FocusScope.of(context).unfocus(),
                  onTap: () {
                    print("abc");
                    setState(() {
                      textMode = false;
                      drawMode = false;
                      imgArray[imgIndex]['textPoint'].textStr = textEntered;
                    });
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container( // EDIT TEXT OVERLAY
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        width: 300,
                        height: 250,
                        child: TextField(
                          onChanged: (text) {
                            setState(() {
                              textEntered = text;
                            });
                          },
                          onEditingComplete: () {
                            print("edit complete");
                            FocusScope.of(context).requestFocus(new FocusNode());
                            setState(() {
                              textMode = false;
                              drawMode = false;
                              // textDisplay = textEntered;
                              imgArray[imgIndex]['textPoint'].textStr = textEntered;
                            });
                          },
                          autofocus: true,
                          focusNode: editTextFocusNode,
                          textInputAction: TextInputAction.done,
                          maxLines: 10,
                          controller: textController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            // color: Colors.black,
                            color: textColor,
                            fontSize: textFontSizeUp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility( // COLOR SLIDER WIDGET
                visible: textMode || drawMode ? true : false,
                child: Align( // COLOR PICKER
                  alignment: Alignment(0.95, -0.65),
                  child: Container(
                    // margin: EdgeInsets.only(top: 100.0),
                    height: 350.0,
                    width: 10.0,
                    // height: 20.0,
                    // width: 400.0,
                    child: GestureDetector(
                      onVerticalDragUpdate: (DragUpdateDetails details) => handleTouch(details.globalPosition, context),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            // begin: Alignment.centerLeft,
                            // end: Alignment.centerRight,
                            colors: [
                              Color(0xff000000),
                              Color(0xffffffff),
                              Color(0xfff32121),
                              Color(0xfff3f321),
                              Color(0xff21f321),
                              Color(0xff21f3f3),
                              Color(0xff2121f3),
                              Color(0xfff321f3),
                              Color(0xfff32121),
                            ],
                            tileMode: TileMode.clamp
                          )
                        ),
                      ),
                    ),
                  )
                )
              ),
              
              Row( // TOP RIGHT TOOLBAR
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton( // DELETE
                    iconSize: topRightIconSize,
                    color: Colors.white,
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        imgArray[imgIndex]['drawPoint'].clear();
                      });
                    }
                  ),
                  IconButton( // CROP
                    iconSize: topRightIconSize,
                    color: Colors.white,
                    icon: Icon(Icons.crop),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.StrokeWidth)
                          showBottomList = !showBottomList;
                        selectedMode = SelectedMode.StrokeWidth;
                      });
                    }
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: textMode ? true : false,
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            color: textColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      IconButton( // WRITE
                        iconSize: topRightIconSize,
                        color: Colors.white,
                        icon: Icon(Icons.title),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(editTextFocusNode);
                          setState(() {
                            textMode = !textMode;
                            drawMode = false;
                          });
                        }
                      ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Visibility(
                        visible: drawMode ? true : false,
                        child: Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            color: selectedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      IconButton( // DRAW
                        iconSize: topRightIconSize,
                        color: Colors.white,
                        icon: Icon(Icons.create),
                        onPressed: () {
                          setState(() {
                            drawMode = !drawMode;
                            textMode = false;
                          });
                        }
                      ),
                    ],
                  ),
                  SizedBox(width: 10.0,)
                ],
              ),
              Visibility( // IMAGE HORIZONTAL LIST VIEW WIDGET
                visible: textMode || drawMode ? false : true,
                child: Align(
                  alignment: Alignment(0, 0.8),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    height: 65.0,
                    child: Row(
                      children: <Widget> [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: imgArray.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    imgIndex = index;
                                    points = imgArray[index]['drawPoint'];
                                    selectedImg = imgArray[index]['image'];
                                    text = imgArray[index]['textPoint'];
                                  });
                                  print(text.textStr + ' | ' + text.coloring.toString() + ' | ' + text.points.toString());
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 1.5, right: 1.5),
                                  child: Image.network(imgArray[index]['image'], width: 70.0, fit: BoxFit.cover,),
                                )
                              );
                            }
                          )
                        )
                      ]
                    )
                  )
                ),
              ),
              Align( // SAVE BUTTON
                alignment: Alignment(0, 0.97),
                child: RaisedButton(
                  child: Text('Download'),
                  onPressed: (){
                    // FocusScope.of(context).requestFocus(FocusNode());
                    takeScreenShot();
                  },
                ),
              ),
            ],
          ),
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
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points, pointsList[i].paint);
      } 
      else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
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

class TextPoints {
  Color coloring;
  Offset points;
  String textStr;
  TextPoints({this.points = Offset.zero, this.coloring = const Color(0xfff32121), this.textStr = ""});
}

enum SelectedMode { StrokeWidth, Opacity, Color }