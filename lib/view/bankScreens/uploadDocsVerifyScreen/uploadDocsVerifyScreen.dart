/*
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../utils/Common.dart';
import '../../../utils/CommonWigdets.dart';

class UploadDocsVerifyScreen extends StatefulWidget {
  const UploadDocsVerifyScreen({super.key});

  @override
  State<UploadDocsVerifyScreen> createState() => _UploadDocsVerifyScreenState();
}

class _UploadDocsVerifyScreenState extends State<UploadDocsVerifyScreen> {
  File? file1;
  List<DocInstructionModel> docInstructionList = [
    DocInstructionModel(title:"Government ID (Passport/Drivers license)/Biometric residence permit", isSelected: false),
    DocInstructionModel(title: "Utility Bill (Electricity/Water/Gas/Council)",isSelected: false),
    DocInstructionModel(title:"Bank/Creadit card/Mortgage statement", isSelected: false),

  ];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
body: Container(
  width: double.infinity,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(size.width * numD07),
      topRight: Radius.circular(size.width * numD07),
    ), // Optional: for rounded border
  ),
  child: Padding(
    padding: EdgeInsets.symmetric(
      horizontal: size.width * numD045,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: size.width * numD035),
        Row(
          children: [
            ...[
              Text(
                "Upload docs for verification",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * numD045,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ],
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const Divider(
          color: Colors.black,
          thickness: 1.3,
        ),
        SizedBox(height: size.width * numD035),
        Text(
          addBankDetailsSubHeadingText,
          style: TextStyle(
              color: Colors.black, fontSize: size.width * numD035),
        ),
        SizedBox(height: size.width * numD05),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docInstructionList.length,
          itemBuilder: (context, index) {
            return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  docInstructionList[index].isSelected
                      ?  Image.asset(
                      "${iconsPath}ic_checkbox_empty.png",
                      height: size.width * numD05):
                  Image.asset(
                    "${iconsPath}ic_checkbox_filled.png",
                    height: size.width * numD05,
                  )
                  ,
                  SizedBox(
                    width: size.width * numD02,
                  ),
                  Expanded(
                    child: Text(
                      docInstructionList[index].title,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD038,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: size.width * numD025,
            );
          },
        ),
        SizedBox(height: size.width * numD05),
        InkWell(
          onTap: () {
            showDocListBottomSheet();
          },
          child: Container(
            padding: EdgeInsets.all(size.width * numD035),
            decoration: BoxDecoration(
                border: Border.all(color: colorTextFieldBorder),
                borderRadius:
                BorderRadius.circular(size.width * numD03)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: size.width * numD05),
        InkWell(
          onTap: () {
            showUploadImageOptionBottomSheet(true);
          },
          child: file1 == null
              ? Container(
              padding: EdgeInsets.all(size.width * numD11),
              decoration: BoxDecoration(
                  color: lightGrey.withOpacity(.3),
                  borderRadius: BorderRadius.circular(
                      size.width * numD03)),
              child: Column(
                children: [
                  Icon(
                    Icons.add,
                    size: size.width * numD05,
                  ),
                  Text(
                    "Upload",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ))
              : Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: size.width * numD012),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      size.width * numD03),
                  child: Image.file(
                    File(
                      file1!.path,
                    ),
                    height: size.width * numD30,
                    width: size.width * numD30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  file1 = null;
                  setState(() {});
                },
                child: CircleAvatar(
                  backgroundColor: colorThemePink,
                  radius: size.width * numD024,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: size.width * numD038,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size.width * numD05),
        SizedBox(
          width: size.width,
          height: size.width * numD13,
          child: commonElevatedButton(
              submitText,
              size,
              commonTextStyle(
                  size: size,
                  fontSize: size.width * numD035,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
              commonButtonStyle(size, colorThemePink), () {
            if (formKey.currentState!.validate()) {
                if (file1 == null) {
                  showSnackBar(
                      "", "Please upload your document", Colors.red);
                } else {
                  callAddBankToStripeApi();
                }

            }
          }),
        ),
        SizedBox(height: size.width * numD05),
      ],
    ),
  ),
),
    );
  }

  void showUploadImageOptionBottomSheet(bool selectFirst) {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size.width * numD04),
                      topRight: Radius.circular(size.width * numD04))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        left: size.width * numD06,
                        right: size.width * numD03,
                        top: size.width * numD018),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Option",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD048,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close_rounded,
                                color: Colors.black,
                                size: size.width * numD08)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: size.width * numD06, right: size.width * numD06),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              getFromGallery(selectFirst);
                              // getImages();
                            },
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD02),
                                ),
                                height: size.width * numD25,
                                padding: EdgeInsets.all(size.width * numD02),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload,
                                        size: size.width * numD08),
                                    SizedBox(
                                      height: size.width * numD03,
                                    ),
                                    Text(
                                      "My Gallery",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD035,
                                          fontFamily: "AirbnbCereal",
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )),
                          ),
                        ),
                        SizedBox(
                          width: size.width * 0.05,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              pickFile("");
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD02),
                                ),
                                height: size.width * numD25,
                                padding: EdgeInsets.all(size.width * numD04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.file_copy_outlined,
                                      size: size.width * numD08,
                                    ),
                                    SizedBox(
                                      height: size.width * numD03,
                                    ),
                                    Text(
                                      "My Files",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD035,
                                          fontFamily: "AirbnbCereal",
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD06,
                  ),
                ],
              ),
            ),
          );
        });
  }


  void showDocListBottomSheet() {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD07),
          topRight: Radius.circular(size.width * numD07),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter stateSetter) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * numD07),
                topRight: Radius.circular(size.width * numD07),
              ), // Optional: for rounded border
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * numD045,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: size.width * numD035),
                  Row(
                    children: [
                      ...[
                        Text(
                          "Select Document",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD045,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 1.3,
                  ),
                  SizedBox(height: size.width * numD03),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docInstructionList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          for (var element in docInstructionList) {
                            element.isSelected =false;
                          }
                          docInstructionList[index].isSelected =true;
                          setState(() {});
                          stateSetter(() {});
                          Navigator.pop(context);
                          showUploadImageOptionBottomSheet(true);
                        },
                        child: Text(
                          docInstructionList[index].title,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD038,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: size.width * numD04,
                      );
                    },
                  ),
                  SizedBox(height: size.width * numD05),
                ],
              ),
            ),
          );
        });
      },
    );
    ;
  }
}


class DocInstructionModel {
  String title = "";
  bool isSelected = false;

  DocInstructionModel({
    required this.title,
    required this.isSelected,
  });
}

*/
