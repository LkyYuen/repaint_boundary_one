import 'dart:convert';
import 'dart:async';
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

  GlobalKey src = GlobalKey();
  Image _image = Image.network("https://cdn.pixabay.com/photo/2019/05/02/16/58/stone-4173970_960_720.jpg");
  var view = "hsvPicker";

  // TEXT VARIABLE START
  //
  //
  final textController = TextEditingController();
  Offset offset = Offset.zero;
  var textFontSizeUp = 50.0;
    double _scale = 1.0;
  double _previousScale;
  var yOffset = 400.0;
  var xOffset = 50.0;
  var rotation = 0.0;
  var lastRotation = 0.0;
  //
  //
  // TEXT VARIABLE END

  var editMode;
  Matrix4 matrix = Matrix4.identity();

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
  // Color Variable End

  // void hueOnChange(double value) => onChanged(color.withHue(value));

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
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    textController.dispose();
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

    percent = localPosition.dx / 350;

    percent = min(max(0.0, percent), 1.0);
    setState(() {
      percent = percent;
    });

    Color color = HSVColor.fromAHSV(1.0, percent * 360, 1.0, 1.0).toColor();
    print(color);
    setState(() {
      colorSelected = color;
    });
  }
  // void handleTouch(Offset globalPosition, BuildContext context) {
  //   RenderBox box = context.findRenderObject();
  //   Offset localPosition = box.globalToLocal(globalPosition);
  //   double percent;
  //   if (widget.horizontal) {
  //     percent = (localPosition.dx - widget.thumbRadius) / barWidth;
  //   } else {
  //     percent = (localPosition.dy - widget.thumbRadius) / barHeight;
  //   }
  //   percent = min(max(0.0, percent), 1.0);
  //   setState(() {
  //     this.percent = percent;
  //   });
  //   switch (widget.pickMode) {
  //     case PickMode.Color:
  //       Color color = HSVColor.fromAHSV(1.0, percent * 360, 1.0, 1.0).toColor();
  //       widget.colorListener(color.value);
  //       break;
  //     case PickMode.Grey:
  //       final int channel = (0xff * percent).toInt();
  //       widget.colorListener(Color
  //         .fromARGB(0xff, channel, channel, channel)
  //         .value);
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    // SystemChrome.setEnabledSystemUIOverlays([]); // hide status bar

        return Scaffold(
          body: 
          // hsvPicker
          // Center(
          //   child: Column(
          //     children: <Widget>[
          //       Container(
          //         margin: EdgeInsets.only(top: 100.0),
          //         color: colorSelected,
          //         child: Text(colorSelected.toString()),
          //       ),
          //        Container(
          //         // color: Colors.red,
          //         margin: EdgeInsets.only(top: 100.0),
          //         height: 20.0,
          //         width: 350.0,
          //         child: GestureDetector(
          //           // onPanUpdate: (details) {
          //           //   if (details.delta.dx > 0)
          //           //     print("Dragging in +X direction");
          //           //   else
          //           //     print("Dragging in -X direction");
    
          //           //   if (details.delta.dy > 0)
          //           //     print("Dragging in +Y direction");
          //           //   else
          //           //     print("Dragging in -Y direction");
          //           // },
          //           onHorizontalDragUpdate: (DragUpdateDetails details) => handleTouch(details.globalPosition, context),
          //           // onHorizontalDragUpdate: (DragUpdateDetails update) => _onDragUpdate(context, update),
          //           child:
          //             DecoratedBox(
          //               decoration: BoxDecoration(
          //                 gradient: LinearGradient(
          //                   begin: Alignment.centerLeft,
          //                   end: Alignment.centerRight,
          //                   colors: [
          //                     Color(0xfff32121),
          //                     Color(0xfff3f321),
          //                     Color(0xff21f321),
          //                     Color(0xff21f3f3),
          //                     Color(0xff2121f3),
          //                     Color(0xfff321f3),
          //                     Color(0xfff32121),
          //                   ],
          //                   tileMode: TileMode.clamp
          //                 )
          //               ),
          //             ),
          //         ),
          //       )
          //     ],
          //   ),
           
          // )
    
          GestureDetector(
            // onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.blue,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 300,
                  maxWidth: 300,
                  minHeight: 300,
                  maxHeight: 300,
                ),
                child: Stack(
                  overflow: Overflow.visible,
                children: <Widget>[
                  Center(
                    child: Stack(
                      children: <Widget>[
                        _image,
                        Draggable(
                          data: 'Flutter',
                          child: FlutterLogo(
                            size: 100.0,
                          ),
                          feedback: FlutterLogo(
                            size: 100.0,
                          ),
                          childWhenDragging: Container(),
                        ),
                        editMode == "textMode" ? 
                        Container(
                          child: Positioned(
                            left: offset.dx,
                            top: offset.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                if ((offset.dx + details.delta.dx < MediaQuery.of(context).size.width * 0.8) && (offset.dy + details.delta.dy < MediaQuery.of(context).size.height * 0.8)) {
                                  setState(() {
                                    offset = Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                                  });
                                }
                                print(offset.dx.toString() + " | " + offset.dy.toString());
                              },
                              // onScaleStart: (scaleDetails) {
                              //   _previousScale = _scale;
                              //   print(' scaleStarts = ${scaleDetails.focalPoint}');
                              // },
                              // onScaleUpdate: (scaleUpdates) {
                              //   lastRotation += scaleUpdates.rotation;
                              //   var offset = scaleUpdates.focalPoint;
                              //   xOffset = offset.dx;
                              //   yOffset = offset.dy;

                              //   setState(() => _scale = _previousScale * scaleUpdates.scale);
                              // },
                              // onScaleEnd: (scaleEndDetails) {
                              //   _previousScale = null;
                              //   print(' scaleEnds = ${scaleEndDetails.velocity}');
                              // },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 150,
                                child: Center(
                                        child: 
                                        TextField(
                                          maxLines: 10,
                                          controller: textController,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: textFontSizeUp,
                                          ),
                                        ),
                                        // Text("You Think You Are Funny But You Are Not",
                                        //   textAlign: TextAlign.center,
                                        //   style: TextStyle(
                                        //     fontWeight: FontWeight.bold,
                                        //     fontSize: 28.0,
                                        //     color: Colors.red
                                        //   )
                                        // ),.
                                    ),
                              )
                          //   Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Center(
                          //       child: 
                          //       TextField(
                          //         maxLines: 10,
                          //         controller: textController,
                          //         decoration: InputDecoration(
                          //           border: InputBorder.none,
                          //         ),
                          //         style: TextStyle(
                          //           color: Colors.black,
                          //           fontSize: textFontSizeUp,
                          //         ),
                          //       ),
                          //       // Text("You Think You Are Funny But You Are Not",
                          //       //   textAlign: TextAlign.center,
                          //       //   style: TextStyle(
                          //       //     fontWeight: FontWeight.bold,
                          //       //     fontSize: 28.0,
                          //       //     color: Colors.red
                          //       //   )
                          //       // ),
                          //     ),
                          //   ),
                          // )
                        ),
                      ),
                    ) : Container(),
                    // Draggable(
                    //   // alignment: Alignment(0.0, 0.0),
                    //   child: Container(
                    //     color: Colors.white,
                    //     child: TextField(
                    //       controller: textController,
                    //       // maxLines: 3,
                    //       decoration: InputDecoration(
                    //         border: InputBorder.none,
                    //       ),
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //       ),
                    //     ),
                    //   ),
                    //   feedback: TextField(
                    //     // controller: textController,
                    //     // maxLines: 3,
                    //     decoration: InputDecoration(
                    //       border: InputBorder.none,
                    //     ),
                    //     style: TextStyle(
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    //   // childWhenDragging: Container(),
                    // ) : Container(),
                  ],
                ),
              ),
              Row( // TOP RIGHT TOOLBAR
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton( // DELETE
                    color: Colors.white,
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.StrokeWidth)
                          showBottomList = !showBottomList;
                        selectedMode = SelectedMode.StrokeWidth;
                      });
                    }
                  ),
                  IconButton( // CROP
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
                  IconButton( // WRITE
                    color: Colors.white,
                    icon: Icon(Icons.title),
                    onPressed: () {
                      setState(() {
                        editMode = "textMode";
                      });
                    }
                  ),
                  IconButton( // DRAW
                    color: Colors.white,
                    icon: Icon(Icons.create),
                    onPressed: () {
                      setState(() {
                        if (selectedMode == SelectedMode.StrokeWidth)
                          showBottomList = !showBottomList;
                        selectedMode = SelectedMode.StrokeWidth;
                      });
                    }
                  ),
                ],
              ),

            ],
          ),
          ),
        ),
      ),

      //  Container(
      //   height: MediaQuery.of(context).size.height,
      //   child: Column(
      //     children: <Widget> [
      //       Container(
      //         width: MediaQuery.of(context).size.width,
      //         height: 50.0,
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: <Widget>[
      //             IconButton(
      //               icon: Icon(Icons.album),
      //               onPressed: () {
      //                 setState(() {
      //                   if (selectedMode == SelectedMode.StrokeWidth)
      //                     showBottomList = !showBottomList;
      //                   selectedMode = SelectedMode.StrokeWidth;
      //                 });
      //               }
      //             ),
      //             IconButton(
      //               icon: Icon(Icons.opacity),
      //               onPressed: () {
      //                 setState(() {
      //                   if (selectedMode == SelectedMode.Opacity)
      //                     showBottomList = !showBottomList;
      //                   selectedMode = SelectedMode.Opacity;
      //                 });
      //               }
      //             ),
      //             IconButton(
      //               icon: Icon(Icons.color_lens),
      //               onPressed: () {
      //                 setState(() {
      //                   if (selectedMode == SelectedMode.Color)
      //                     showBottomList = !showBottomList;
      //                   selectedMode = SelectedMode.Color;
      //                 });
      //               }
      //             ),
      //             IconButton(
      //               icon: Icon(Icons.clear),
      //               onPressed: () {
      //                 setState(() {
      //                   showBottomList = false;
      //                   points.clear();
      //                 });
      //               }
      //             ),
      //           ],
      //         ),
      //       ),
      //       Expanded(
      //         child: Container(
      //           width: MediaQuery.of(context).size.width,
      //           // height: 500.0,
      //           child: RepaintBoundary(
      //             key: src,
      //             child: Stack(
      //               children: <Widget>[
      //                 _image,
      //                 GestureDetector(
      //                   onPanUpdate: (details) {
      //                     setState(() {
      //                       RenderBox renderBox = context.findRenderObject();
      //                       points.add(DrawingPoints(
      //                           points: renderBox.globalToLocal(details.globalPosition),
      //                           paint: Paint()
      //                             ..strokeCap = strokeCap
      //                             ..isAntiAlias = true
      //                             ..color = selectedColor.withOpacity(opacity)
      //                             ..strokeWidth = strokeWidth));
      //                     });
      //                   },
      //                   onPanStart: (details) {
      //                     setState(() {
      //                       RenderBox renderBox = context.findRenderObject();
      //                       points.add(DrawingPoints(
      //                           points: renderBox.globalToLocal(details.globalPosition),
      //                           paint: Paint()
      //                             ..strokeCap = strokeCap
      //                             ..isAntiAlias = true
      //                             ..color = selectedColor.withOpacity(opacity)
      //                             ..strokeWidth = strokeWidth));
      //                     });
      //                   },
      //                   onPanEnd: (details) {
      //                     setState(() {
      //                       points.add(null);
      //                     });
      //                   },
      //                   child: CustomPaint(
      //                     size: Size.infinite,
      //                     painter: DrawingPainter(
      //                       pointsList: points,
      //                     ),
      //                   ),
      //                 ),
      //                 // Align(
      //                 //   alignment: Alignment.center,
      //                 //   child: TextField(
      //                 //     maxLines: 3,
      //                 //     decoration: InputDecoration(
      //                 //       border: InputBorder.none,
      //                 //       hintText: "Write here..",
      //                 //     ),
      //                 //     style: TextStyle(
      //                 //       color: Colors.black,
      //                 //     ),
      //                 //   ),
      //                 // )
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       RaisedButton(
      //         child: Text('Download'),
      //         onPressed: (){
      //           FocusScope.of(context).requestFocus(FocusNode());
      //           takeScreenShot();
      //         },
      //       )
      //     ]
      //   )
      // )
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