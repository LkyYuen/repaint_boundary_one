import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  
  takeScreenShot() async {
    print("processing");
    RenderRepaintBoundary boundary = src.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    String bs64 = base64Encode(pngBytes);

    final directory = (await getExternalStorageDirectory()).path;
    File imgFile = File('$directory/screenshot.png');
    imgFile.writeAsBytes(pngBytes);
    print(directory);

    // Directory extDir = await getApplicationDocumentsDirectory();
    // if (Platform.isAndroid) {
    //   extDir = await getExternalStorageDirectory();
    // }
    // else {
    //   extDir = await getApplicationDocumentsDirectory();
    // }

    // final String dirPath = '${extDir.path}/Pictures';
    // await Directory(dirPath).create(recursive: true);
    // // final String filePath = '${timestamp()}.jpg';
    // final String filePath = '$dirPath/${timestamp()}.jpg';

    // final result = await GallerySaver.saveImage(filePath);
    // print(result);
    print("done");

  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    PermissionsService().requestCameraPermission(
      onPermissionDenied: () {
        print('Permission has been denied');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget> [
          Container(
            width: 500.0,
            height: 500.0,
            child: RepaintBoundary(
              key: src,
              child: Stack(
                children: <Widget>[
                  _image,
                  Align(
                    alignment: Alignment.center,
                    child: TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Write here..",
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
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
    );
  }
}
