import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(title: "Image Picker"),
    );
  }
}

class MainPage extends StatefulWidget {
  final String title;

  MainPage({Key key, this.title}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const platform = MethodChannel("com.lichaojian.image_picker/Media");
  List imageList;

  @override
  void initState() {
    super.initState();
    getImages();
  }

  void getImages() async {
    List result;
    try {
      result = await platform.invokeMethod('getImages');
    } on PlatformException catch (e) {
      log("PlatformException Message ${e.message}");
    }
    setState(() {
      imageList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Image Picker"),
        actions: <Widget>[buildConfirmButton()],
      ),
      body: getMainBody(),
    );
  }

  Widget buildConfirmButton() {
    return new IconButton(icon: new Icon(Icons.check, color: Colors.white), onPressed: null);
  }

  Widget getMainBody() {
    if (imageList == null) {
      return getProgressDialog();
    } else {
      return getGridView();
    }
  }

  getProgressDialog() {
    return Center(child: CircularProgressIndicator());
  }

  Widget getGridView() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: imageList.length,
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          childAspectRatio: 1.0),
      itemBuilder: (context, index) {
        return buildItem(imageList[index]);
      },
    );
  }

  Widget buildItem(String imagePath) {
    return new GestureDetector(
      child: Stack(
        children: <Widget>[
          new ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Image.file(File(imagePath), width: 200,
                height: 200,
                cacheWidth: 200,
                cacheHeight: 200),
          ),
          new Align(
            alignment: Alignment.bottomRight,
            child: Checkbox(
              onChanged: (value) {
              },
            ),
          )
        ],
      ),
      onTap: () {

      },
    );
  }
}
