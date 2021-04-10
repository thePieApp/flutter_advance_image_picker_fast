import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:reorderables/reorderables.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Asset> images = <Asset>[];
  List<File> imageFiles = <File>[];
  List<Widget> imageWidgets = <Widget>[];
  int maxImageNumber = 9;
  int gridSize = 3;
  int gridH = 0;
  int gridV = 0;

  int verticalSpacing = 10;
  int horizontalSpacing = 10;
  double padding = 10.0;
  double aspectRatio = 0.8;
  double radius = 5.0;

  double cancelButtonOffsetScaleH = 0.7;
  double cancelButtonOffsetScaleW = 0.65;
  double cancelButtonSize = 30;

  double itemWidth;
  double itemHeight;

  List<int> setSelectionWidgetPos(){
    if (imageWidgets.length == maxImageNumber){
        gridV = -1;
        gridH = -1;
    } else {
        gridV = (imageWidgets.length / gridSize).floor();
        gridH = (imageWidgets.length - gridV * gridSize);
    }
  }

  Widget buildWidget(index, File imageFile){
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            child: Image.file(
                imageFile,
                fit: BoxFit.cover
            ),
            width: itemWidth,
            height: itemHeight,
          ),
        ),
        Positioned(
            left: itemWidth * cancelButtonOffsetScaleW,
            top: itemHeight * cancelButtonOffsetScaleH,
            child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.blue,
                    size: cancelButtonSize,
                  ),
                  onPressed: () => setState(() {
                    for (int i=0 ; i<images.length ; i++){
                      if (imageFile.toString() == imageFiles[i].toString()) {
                        images.removeAt(i);
                        imageWidgets.removeAt(i);
                        imageFiles.removeAt(i);
                        setSelectionWidgetPos();
                        break;
                      }
                    }
                  }
                )
            )
        ),
      ],
    );
  }

  void pickAsset() async {

    try {

      List<Asset> imagesTmp = await MultiImagePicker.pickImages(
        maxImages: maxImageNumber,
        enableCamera: false,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "PIE",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );

      List<File> imageFilesTmp = <File>[];
      await Future.forEach(imagesTmp, (asset) async {
        await FlutterAbsolutePath.getAbsolutePath(asset.identifier).then((path) {
          imageFilesTmp.add(File(path));
          print("path---" + path);
        }).catchError((e) {
          print("photoerr" + e.toString());
        });
      });

      List<Widget> imageWidgetsTmp = <Widget>[];
      for ( int i = 0 ; i < imagesTmp.length ; i++ ){
        imageWidgetsTmp.add(buildWidget(i, imageFilesTmp[i]));
      }

      setState(() {
        images = imagesTmp;
        imageWidgets = imageWidgetsTmp;
        imageFiles = imageFilesTmp;
        setSelectionWidgetPos();
      });

    } on Exception catch (e) {
      String error = e.toString();
      return; // the image list remains unchanged
    }
  }

  @override
  Widget build(BuildContext context) {

    itemWidth = ((MediaQuery.of(context).size.width - padding - gridSize * horizontalSpacing ) / gridSize);
    itemHeight = (itemWidth/aspectRatio);

    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = imageWidgets.removeAt(oldIndex);
        imageWidgets.insert(newIndex, row);
        Asset image = images.removeAt(oldIndex);
        images.insert(newIndex, image);
        File imageFile = imageFiles.removeAt(oldIndex);
        imageFiles.insert(newIndex, imageFile);
      });
    }

    Widget wrap = ReorderableWrap(
        minMainAxisCount: gridSize,
        maxMainAxisCount: gridSize,
        spacing: horizontalSpacing.toDouble(),
        runSpacing: verticalSpacing.toDouble(),
        padding: EdgeInsets.all(padding),
        children: imageWidgets,
        onReorder: _onReorder,
        onNoReorder: (int index) {
          debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        },
        onReorderStarted: (int index) {
          debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
        }
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){},
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: Text('PIE Image Selection and Upload')),
          Stack(
            children: [
              buildGridView(),
              wrap,
              gridV == -1 ? Container() : Positioned(
                child: selectionCard(),
                left: padding + ( itemWidth + horizontalSpacing ) * gridH,
                top: padding + ( itemHeight + verticalSpacing ) * gridV,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget selectionCard() => GestureDetector(
    onTap: pickAsset,
    child: Container(
      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.black),
      boxShadow: null,
      ),
      width: itemWidth,
      height: itemHeight,
      child: Icon(
          Icons.add
      ),
    ),
  );

  Widget displayCard(Color color) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.transparent),
    ),
    width: itemWidth,
    height: itemHeight,
  );

  Widget buildGridView() {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.count(
        controller: ScrollController(),
        shrinkWrap: true,
        crossAxisCount: gridSize,
        childAspectRatio: aspectRatio,
        mainAxisSpacing: verticalSpacing.toDouble(),
        crossAxisSpacing: horizontalSpacing.toDouble(),
        children: List.generate(maxImageNumber, (index) {
          if ( index <= imageWidgets.length ) {
            return displayCard(Colors.transparent);
          } else {
            return displayCard(Colors.black12);
          }
        }),
      ),
    );
  }

}
