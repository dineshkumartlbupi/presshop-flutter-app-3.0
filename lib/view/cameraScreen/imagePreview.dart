import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../utils/Common.dart';

class ImagePreview extends StatefulWidget {
  String imageURL = "";
   ImagePreview({Key? key,required this.imageURL}) : super(key: key);

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
    return  Scaffold(
   backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:   Text(
          'Image Preview',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize)
        ),
        leading: IconButton(
          icon:  Icon(
            Icons.arrow_back_ios,
            size: size.width*numD05,
            color: Colors.white ,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: PhotoView(
          imageProvider:  NetworkImage(
            widget.imageURL
          ), // Replace with your image source
        ),
      ),
    );
  }
}

