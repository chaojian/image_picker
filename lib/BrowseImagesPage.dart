import 'dart:io';

import 'package:flutter/material.dart';

class BrowseImagesPage extends StatefulWidget {
  int mCurrentImageIndex;
  List mImageList;

  BrowseImagesPage(this.mCurrentImageIndex, this.mImageList);

  @override
  BrowseImagesState createState() =>
      BrowseImagesState(this.mCurrentImageIndex, this.mImageList);
}

class BrowseImagesState extends State<BrowseImagesPage> {
  int mCurrentImageIndex;
  List mImageList;

  BrowseImagesState(this.mCurrentImageIndex, this.mImageList);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: getPageView(mCurrentImageIndex),
    );
  }

  Widget getPageView(index) {
    PageController _transController = new PageController(initialPage: index);
    return PageView.builder(
        controller: _transController,
        itemCount: mImageList.length,
        itemBuilder: (context, index) {
          return Image.file(File(mImageList[index]));
        });
  }
}
