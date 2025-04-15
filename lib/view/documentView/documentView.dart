import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';

class DocumentView extends StatefulWidget {
  String path= '';

   DocumentView({Key? key,required this.path}) : super(key: key);

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  bool isDocumentType = false;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          docViewer,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSizeNew),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: [

          InkWell(
            onTap: (){
             /* Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          Dashboard(initialPosition: 2)),
                      (route) => false);*/
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              width: size.width * numD15,
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
        ],
      ),
      body:
      SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: size.width*numD035),
          child: SfPdfViewer.network(widget.path,
            key: _pdfViewerKey,
          )
        ),
      ),
    );
  }
}
