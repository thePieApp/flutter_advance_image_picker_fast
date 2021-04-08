import 'dart:io';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter/material.dart';

import 'package:image_editor_pro/image_editor_pro.dart';
// import 'package:extended_image/extended_image.dart';

// import 'package:flutter_advance_image_picker/pieImageEditor.dart';

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

  File _image;

  List<Asset> images = <Asset>[];
  int maxImageNumber = 6;
  String _error = 'No Error Dectected';

  Widget buildGridView() {
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 0.70,
        children: List.generate(images.length+1, (index) {
          print(index);
          if (index == images.length){
            if (images.length < maxImageNumber){
              return selectionCard();
            } else {
              return Container();
            }
          }
          Asset asset = images[index];

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0,  top: 0, right: 10, bottom: 10),
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(8.0),
                  child: AssetThumb(
                    asset: asset,
                    width: (MediaQuery.of(context).size.width/3).toInt(),
                    height: (MediaQuery.of(context).size.width/3/0.70).toInt(),
                  ),
                ),
              ),
              Positioned(
                  left: (MediaQuery.of(context).size.width)/3 * 0.6,
                  top: (MediaQuery.of(context).size.width)/3 * 0.6 / 0.62,
                  child: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.blue,
                        size: 30,
                      ),
                      onPressed: () => setState(() {
                        images.removeAt(index);
                      }
                      )
                  )
              )
            ],
          );
        }),
      ),
    );
  }


  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: maxImageNumber,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
      return; // the image list remains unchanged
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {

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
        children: <Widget>[
          Center(child: Text('Error: $_error')),
          ElevatedButton(
            child: Text("Pick images"),
            onPressed: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ExtendedImageExample()));
              getimageditor();
            }
          ),
          Expanded(
            child: buildGridView(),
          )
        ],
      ),
    );
  }

  Future<void> getimageditor() =>
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ImageEditorPro(
          appBarColor: Colors.blue,
          bottomBarColor: Colors.blue,
        );
      })).then((geteditimage) {
        if (geteditimage != null) {
          setState(() {
            _image = geteditimage;
          });
        }
      }).catchError((er) {
        print(er);
      });

  Widget selectionCard() => GestureDetector(
    onTap: loadAssets,
    child:   Padding(
      padding: EdgeInsets.only(right: 10, bottom: 15),
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(10.0),
        child: Container(
          color: Colors.black12,
          child: Icon(
              Icons.add
          ),
        ),
      ),
    ),
  );

}
