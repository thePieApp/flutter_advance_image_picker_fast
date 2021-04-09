import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_advance_image_picker/lib/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:reorderables/reorderables.dart';

// import 'package:image_editor_pro/image_editor_pro.dart';
// import 'package:extended_image/extended_image.dart';

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

  List<AssetEntity> images = <AssetEntity>[];
  List<File> imageFiles = <File>[];
  List<Widget> imageWidgets = <Widget>[];
  int maxImageNumber = 9;
  int gridH = 0;
  int gridV = 0;

  int verticalSpacing = 10;
  int horizontalSpacing = 10;

  List<int> setSelectionWidgetPos(){
    if (imageWidgets.length == 9){
        gridV = -1;
        gridH = -1;
    } else {
        gridV = (imageWidgets.length / 3.0).floor();
        gridH = (imageWidgets.length - gridV*3);
    }
  }

  Widget buildWidget(index, imageFile){
    return Stack(
      children: [
        ClipRRect(
          borderRadius: new BorderRadius.circular(5.0),
          child: Container(
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
            ),
            width: (MediaQuery.of(context).size.width-40)/3,
            height: (MediaQuery.of(context).size.width-40)/3/0.80,
          ),
        ),
        Positioned(
            left: (MediaQuery.of(context).size.width-40)/3 * 0.65,
            top: (MediaQuery.of(context).size.width-40)/3 * 0.65 / 0.72,
            child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.blue,
                    size: 30,
                  ),
                  onPressed: () => setState(() {
                    for (int i=0 ; i<images.length ; i++){
                      if (imageFile.toString() == imageFiles[i].toString()) {
                        images.removeAt(i);
                        imageFiles.removeAt(i);
                        imageWidgets.removeAt(i);
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
    List<AssetEntity> imagesTmp = await PhotoPicker.pickAsset(
      context: context,
      // BuildContext requied

      /// The following are optional parameters.
      themeColor: Colors.orange,
      // the title color and bottom color
      padding: 1.0,
      // item padding
      dividerColor: Colors.grey,
      // divider color
      disableColor: Colors.white,
      // the check box disable color
      itemRadio: 0.88,
      // the content item radio
      maxSelected: maxImageNumber,
      // max picker image count
      provider: I18nProvider.chinese,
      // i18n provider ,default is chinese. , you can custom I18nProvider or use ENProvider()
      rowCount: 4,
      // item row count
      textColor: Colors.black,
      // text color
      thumbSize: (MediaQuery.of(context).size.width/4.0).floor(),
      // preview thumb size , default is 64
      sortDelegate: SortDelegate.common,
      // default is common ,or you make custom delegate to sort your gallery
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
        checkColor: Colors.blue,
      ), // default is DefaultCheckBoxBuilderDelegate ,or you make custom delegate to create checkbox

      // loadingDelegate: this, // if you want to build custom loading widget,extends LoadingDelegate [see example/lib/main.dart]

      badgeDelegate: const DefaultBadgeDelegate(), /// or custom class extends [BadgeDelegate]

      pickType: PickType.onlyImage, // all/image/video

      pickedAssetList: images, /// when [photoPathList] is not null , [pickType] invalid .
    );

    List<File> imageFilesTmp = <File>[];
    List<Widget> imageWidgetsTmp = <Widget>[];
    for ( int i = 0 ; i < imagesTmp.length ; i++ ){
      File original_file = await imagesTmp[i].file;
      imageFilesTmp.add(original_file);
      imageWidgetsTmp.add(buildWidget(i, original_file));
    }

    setState(() {
      images = imagesTmp;
      imageFiles = imageFilesTmp;
      imageWidgets = imageWidgetsTmp;
      setSelectionWidgetPos();
    });
  }

  @override
  Widget build(BuildContext context) {

    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        Widget row = imageWidgets.removeAt(oldIndex);
        imageWidgets.insert(newIndex, row);
        File imageFile = imageFiles.removeAt(oldIndex);
        imageFiles.insert(newIndex, imageFile);
        AssetEntity image = images.removeAt(oldIndex);
        images.insert(newIndex, image);
      });
    }

    var wrap = ReorderableWrap(
        minMainAxisCount: 3,
        maxMainAxisCount: 3,
        spacing: 10.0,
        runSpacing: 10.0,
        padding: const EdgeInsets.all(10),
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
                left: 10 + ( (MediaQuery.of(context).size.width-40)/3 + 10 ) * gridH,
                top: 10 + ( (MediaQuery.of(context).size.width-40)/3/0.80 + 10 ) * gridV,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget selectionCard() => GestureDetector(
    onTap: pickAsset,
    child:   Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.black),
      ),
      width: (MediaQuery.of(context).size.width-40)/3,
      height: (MediaQuery.of(context).size.width-40)/3/0.80,
      child: Icon(
          Icons.add
      ),
    ),
  );

  Widget displayCard(Color color) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5.0),
      border: Border.all(color: Colors.transparent),
    ),
    width: (MediaQuery.of(context).size.width-40)/3,
    height: (MediaQuery.of(context).size.width-40)/3/0.80,
  );

  Widget buildGridView() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: GridView.count(
        controller: ScrollController(),
        shrinkWrap: true,
        crossAxisCount: 3,
        childAspectRatio: 0.80,
        mainAxisSpacing: verticalSpacing.toDouble(),
        crossAxisSpacing: horizontalSpacing.toDouble(),
        children: List.generate(maxImageNumber, (index) {
          if ( index < imageWidgets.length ) {
            return displayCard(Colors.transparent);
          } else {
            return displayCard(Colors.black12);
          }
        }),
      ),
    );
  }

}
