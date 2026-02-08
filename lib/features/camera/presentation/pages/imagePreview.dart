import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:presshop/core/core_export.dart';

// ignore: must_be_immutable
class ImagePreview extends StatefulWidget {
  ImagePreview({super.key, required this.imageURL});
  String imageURL = "";

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  void initState() {
    debugPrint("imageUrL ======> ${widget.imageURL}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Image Preview',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size.width * AppDimensions.appBarHeadingFontSize)),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: size.width * AppDimensions.numD05,
            color: Colors.white,
          ),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider:
              NetworkImage(widget.imageURL), // Replace with your image source
        ),
      ),
    );
  }
}
