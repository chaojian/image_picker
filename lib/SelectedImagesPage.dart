import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/BrowseImagesPage.dart';

class SelectedImagesPage extends StatefulWidget {
  Set<String> mSelectedImages;

  SelectedImagesPage(this.mSelectedImages);

  @override
  SelectedImagesPageState createState() =>
      SelectedImagesPageState(this.mSelectedImages.toList());
}

class SelectedImagesPageState extends State<SelectedImagesPage> {
  List mSelectedImageList;

  SelectedImagesPageState(this.mSelectedImageList);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Selected Images'),
      ),
      body: getGridView()
    );
  }

  Widget getGridView() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: mSelectedImageList.length,
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          childAspectRatio: 1.0),
      itemBuilder: (context, index) {
        return buildItem(index);
      },
    );
  }

  Widget buildItem(int index) {
    String imagePath = mSelectedImageList[index];
    return new GestureDetector(
      child: new ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.file(File(imagePath),
            width: 200, height: 200, cacheWidth: 200, cacheHeight: 200),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return BrowseImagesPage(index, mSelectedImageList);
        }));
      },
    );
  }

}

