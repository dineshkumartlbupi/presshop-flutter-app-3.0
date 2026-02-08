import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';

// ignore: must_be_immutable
class DocumentView extends StatefulWidget {
  DocumentView({super.key, required this.path});
  String path = '';

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
          AppStrings.docViewer,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * AppDimensions.appBarHeadingFontSizeNew),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          context.pop();
        },
        actionWidget: [
          InkWell(
            onTap: () {
              context.pop();
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              width: size.width * AppDimensions.numD15,
            ),
          ),
          SizedBox(
            width: size.width * AppDimensions.numD02,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD035),
            child: SfPdfViewer.network(
              widget.path,
              key: _pdfViewerKey,
            )),
      ),
    );
  }
}
