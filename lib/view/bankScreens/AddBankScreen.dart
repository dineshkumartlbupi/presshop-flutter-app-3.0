import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/view/authentication/UploadDocumnetsScreen.dart';
import 'package:presshop/view/authentication/WelcomeScreen.dart';

import '../../utils/CommonTextField.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../dashboard/Dashboard.dart';
import 'MyBanksScreen.dart';

class AddBankScreen extends StatefulWidget {
  bool editBank = false;
  final String screenType;
  MyBankData? myBankData;
  List<MyBankData> myBankList = [];

  AddBankScreen({super.key, required this.editBank, this.myBankData, required this.screenType, required this.myBankList});

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> implements NetworkResponse {
  var formKey = GlobalKey<FormState>();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController bankController = TextEditingController();
  TextEditingController sortCodeController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController confirmAccountNumberController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String stripOnBoardURL = '';
  bool defaultValue = false;
  bool isSelectDoc = false;
  List<DocumentDataModel> docList = [];
  List<MyBankData> bankUkList = [];
  List<DocInstructionModel> docInstructionList = [
    DocInstructionModel(title: "Government ID (Passport/Drivers license/Biometric\nresidence permit)", isSelected: false),
    DocInstructionModel(title: "Utility Bill (Electricity/Water/Gas/Council)", isSelected: false),
    DocInstructionModel(title: "Bank/Credit card/Mortgage statement", isSelected: false),
  ];

  File? file;

  @override
  void initState() {
    super.initState();
    debugPrint("screenType::::${widget.screenType}");
    callGetUkBankList();
    //  WidgetsBinding.instance.addPostFrameCallback((timeStamp) => crateStripAccount());
    if (widget.editBank) {
      // setBankData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: widget.screenType == "publish" || widget.screenType == "myBank" ? false : true,
        title: Padding(
          padding: EdgeInsets.only(left: widget.screenType == "publish" || widget.screenType == "myBank" ? 0 : size.width * numD058, right: size.width * numD1),
          child: FittedBox(
            child: Text(
              "Add & Verify Bank",
              style: TextStyle(fontFamily: "AirbnbCereal", color: Colors.black, fontSize: size.width * numD06, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: false,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: null,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.width * numD058, right: size.width * numD1),
                child: Text(
                  addBankDetailsSubHeadingText,
                  style: TextStyle(fontFamily: "AirbnbCereal", color: Colors.black, fontSize: size.width * numD035),
                ),
              ),
              SizedBox(
                height: size.width * numD03,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: size.width * numD06, vertical: size.width * numD04),
                  children: [
                    Text(
                      accountHolderNameText,
                      style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      controller: accountHolderNameController,
                      hintText: enterAccountHolderNameText,
                      textInputFormatters: null,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_user.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: TextInputType.text,
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    Text(
                      bankText,
                      style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      controller: bankController,
                      hintText: enterBankText,
                      textInputFormatters: null,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_bank.png",
                        ),
                      ),
                      callback: () {
                        chooseBankUKListBottomSheet(context, size);
                      },
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: TextInputType.text,
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      filled: false,
                      readOnly: true,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    Text(
                      sortCodeText,
                      style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      controller: sortCodeController,
                      hintText: enterSortCodeText,
                      maxLength: 8,
                      textInputFormatters: null,
                      onChanged: (value) {
                        /*  if (value!.trim().isEmpty) {
                          return requiredText;
                        } else if (value.length < 9) {
                          return sortCodeErrorText;
                        }
                        return null;*/
                        if (value!.endsWith("-") && value.isNotEmpty) {
                          sortCodeController.text = value.substring(0, value.length - 2);
                        } else if ([2, 5].contains(value.length)) {
                          sortCodeController.text += "-";
                        }
                        sortCodeController.selection = TextSelection.collapsed(offset: sortCodeController.text.length);
                        setState(() {});
                      },
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_locker.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: TextInputType.number,
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    Row(
                      children: [
                        Text(
                          accountNumberText,
                          style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            defaultValue = !defaultValue;
                            setState(() {});
                          },
                          child: defaultValue
                              ? Image.asset(
                                  "${iconsPath}ic_checkbox_filled.png",
                                  height: size.width * numD05,
                                )
                              : Image.asset("${iconsPath}ic_checkbox_empty.png", height: size.width * numD05),
                        ),
                        SizedBox(
                          width: size.width * numD013,
                        ),
                        Text(
                          setAsDefaultText,
                          style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      controller: accountNumberController,
                      hintText: enterAccountNumberText,
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_piggy.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                      textInputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return requiredText;
                        } else if (value.length < 8) {
                          return bankErrorText;
                        }
                        return null;
                      },
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    Text(
                      "Upload your documents for verification (any 2)",
                      style: TextStyle(fontFamily: "AirbnbCereal", color: Colors.black, fontSize: size.width * numD036),
                    ),
                    SizedBox(
                      height: size.width * numD025,
                    ),
                    Container(
                      padding: EdgeInsets.all(size.width * numD04),
                      decoration: BoxDecoration(color: colorLightGrey, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(size.width * numD03)),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docInstructionList.length,
                        itemBuilder: (context, index) {
                          return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                            Container(
                              margin: EdgeInsets.only(
                                top: size.width * numD004,
                              ),
                              child: Icon(
                                Icons.circle,
                                color: colorThemePink,
                                size: size.width * numD035,
                              ),
                            ),
                            SizedBox(
                              width: size.width * numD02,
                            ),
                            Expanded(
                              child: Text(
                                docInstructionList[index].title,
                                style: TextStyle(fontFamily: "AirbnbCereal", color: Colors.black, fontSize: size.width * numD035),
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
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    ),

                    /* SizedBox(
                      height: size.width * numD06,
                    ),
                    Text(
                      "Confirm $accountNumberText",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      borderColor: colorTextFieldBorder,
                      controller: confirmAccountNumberController,
                      hintText: "Confirm account number",
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_piggy.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD06,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: false),
                      textInputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return requiredText;
                        }
                        else if (accountNumberController.text != value) {
                          return "Account number doesn't match";
                        }
                        return null;
                      },
                      enableValidations: true,
                      filled: false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),*/

/*
                    !widget.showPageNumber && widget.myBankList.isNotEmpty
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  defaultValue = !defaultValue;
                                  setState(() {});
                                },
                                child: defaultValue
                                    ? Image.asset(
                                        "${iconsPath}ic_checkbox_filled.png",
                                        height: size.width * numD05,
                                      )
                                    : Image.asset(
                                        "${iconsPath}ic_checkbox_empty.png",
                                        height: size.width * numD05),
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Text(
                                  setAsDefaultText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          )
                        : Container(),*/
                    SizedBox(
                      height: size.width * numD15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: size.width * numD13,
                            child: commonElevatedButton("Later", size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, Colors.black), () {
                              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
                            }),
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD04,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: size.width * numD13,
                            child: commonElevatedButton("Upload", size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () {
                              showUploadBottomSheet();
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    widget.screenType == "addBank" ? Container() : Align(alignment: Alignment.center, child: Text("3 of 3", style: TextStyle(color: Colors.black, fontSize: size.width * numD035, fontWeight: FontWeight.w500)))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /* void setBankData() {
    if (widget.myBankData != null) {
      accountHolderNameController.text = widget.myBankData!.accountHolderName;
      bankController.text = widget.myBankData!.bankName;
      sortCodeController.text = widget.myBankData!.sortCode;
      accountNumberController.text = widget.myBankData!.accountNumber;
      defaultValue = widget.myBankData!.isDefault;
    }
    setState(() {});
  }*/

  void getFromGallery(bool isFile1, StateSetter mainStateSetter, int idx) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      var pickFile = File(pickedFile.path);
      file = File(pickFile.path);
      docList.add(DocumentDataModel(id: "", documentName: pickFile.path, isSelected: false));
      docInstructionList[idx].isSelected = true;
      setState(() {});
      mainStateSetter(() {});
    }
  }

  void pickFile(String fileName, StateSetter mainStateSetter, int idx) async {
    debugPrint("inside in this if ::::::");
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], allowMultiple: false);
    if (result != null) {
      debugPrint("docFile=====> $fileName");
      file = File(result.files.single.path.toString());
      docList.add(DocumentDataModel(id: "", documentName: result.files.single.path.toString(), isSelected: false));

      docInstructionList[idx].isSelected = true;
      setState(() {});
      mainStateSetter(() {});
    }
  }

  void showUploadImageOptionBottomSheet(bool selectFirst, StateSetter mainStateSetter, int index) {
    var size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(size.width * numD04), topRight: Radius.circular(size.width * numD04))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(left: size.width * numD06, right: size.width * numD03, top: size.width * numD018),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Option",
                        style: TextStyle(color: Colors.black, fontSize: size.width * numD048, fontFamily: "AirbnbCereal", fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close_rounded, color: Colors.black, size: size.width * numD08)),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Container(
                  margin: EdgeInsets.only(left: size.width * numD06, right: size.width * numD06),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            getFromGallery(selectFirst, mainStateSetter, index);
                            // getImages();
                          },
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(size.width * numD02),
                              ),
                              height: size.width * numD25,
                              padding: EdgeInsets.all(size.width * numD02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload, size: size.width * numD08),
                                  SizedBox(
                                    height: size.width * numD03,
                                  ),
                                  Text(
                                    "My Gallery",
                                    style: TextStyle(color: Colors.black, fontSize: size.width * numD035, fontFamily: "AirbnbCereal", fontWeight: FontWeight.bold),
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
                            pickFile("", mainStateSetter, index);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(size.width * numD02),
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
                                    style: TextStyle(color: Colors.black, fontSize: size.width * numD035, fontFamily: "AirbnbCereal", fontWeight: FontWeight.bold),
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
          );
        });
  }

  void showUploadBottomSheet() {
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: size.width * numD04),
                    Row(
                      children: [
                        ...[
                          Text(
                            "Upload docs for verification",
                            style: commonTextStyle(size: size, fontSize: size.width * numD045, color: Colors.black, fontWeight: FontWeight.w700),
                          ),
                        ],
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1.3,
                    ),
                    SizedBox(height: size.width * numD04),
                    Text(
                      "Kindly upload clear copies of your original documents to complete bank verification.",
                      style: TextStyle(color: Colors.black, fontSize: size.width * numD035),
                    ),
                    SizedBox(height: size.width * numD05),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docInstructionList.length,
                      itemBuilder: (context, index) {
                        return Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                          docInstructionList[index].isSelected
                              ? Container(
                                  margin: EdgeInsets.only(top: size.width * numD005),
                                  child: Image.asset("${iconsPath}ic_checkbox_filled.png", height: size.width * numD05),
                                )
                              : Container(
                                  margin: EdgeInsets.only(top: size.width * numD005),
                                  child: Icon(
                                    Icons.circle,
                                    color: colorThemePink,
                                    size: size.width * numD035,
                                  ),
                                ),
                          SizedBox(
                            width: docInstructionList[index].isSelected ? size.width * numD028 : size.width * numD04,
                          ),
                          Expanded(
                            child: index == 0 ? RichText(text: TextSpan(children: [TextSpan(text: docInstructionList[index].title, style: TextStyle(fontSize: size.width * numD035, color: Colors.black, fontFamily: "AirbnbCereal", fontWeight: FontWeight.w400)), TextSpan(text: "* Front and back side images are needed", style: TextStyle(fontSize: size.width * numD028, color: Colors.black, fontFamily: "AirbnbCereal", fontWeight: FontWeight.w400))])) : Text(docInstructionList[index].title, style: TextStyle(fontSize: size.width * numD035, color: Colors.black, fontFamily: "AirbnbCereal", fontWeight: FontWeight.w400)),
                          ),
                        ]);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: size.width * numD025,
                        );
                      },
                    ),
                    SizedBox(height: size.width * numD06),
                    InkWell(
                      onTap: () {
                        if (docList.length == docInstructionList.length) {
                          showSnackBar("Error", "You can upload all the document. ", Colors.red);
                        } else {
                          showDocListBottomSheet(stateSetter);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: size.width * numD035, vertical: size.width * numD028),
                        decoration: BoxDecoration(border: Border.all(color: colorTextFieldBorder), borderRadius: BorderRadius.circular(size.width * numD03)),
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
                    SizedBox(height: size.width * numD04),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        //mainAxisExtent: 175,
                      ),
                      itemCount: docList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.all(size.width * numD025),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(size.width * numD04),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(size.width * numD03),
                                    child: docList[index].documentName.endsWith(".pdf")
                                        ? Image.asset(
                                            "${iconsPath}pdfIcon.png",
                                            height: size.width * numD28,
                                            width: size.width * numD38,
                                          )
                                        : docList[index].id.isNotEmpty
                                            ? Image.network(
                                                docImageUrl + docList[index].documentName,
                                                height: size.width * numD28,
                                                width: size.width * numD38,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(
                                                  docList[index].documentName,
                                                ),
                                                height: size.width * numD28,
                                                width: size.width * numD38,
                                                fit: BoxFit.cover,
                                              ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      debugPrint("index:::::$index");
                                      if (docInstructionList[0].isSelected) {
                                        docInstructionList[0].isSelected = false;
                                      } else if (docInstructionList[1].isSelected) {
                                        docInstructionList[1].isSelected = false;
                                      } else if (docInstructionList[2].isSelected) {
                                        docInstructionList[2].isSelected = false;
                                      }
                                      docList.removeAt(index);
                                      setState(() {});
                                      stateSetter(() {});
                                    },
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding: EdgeInsets.all(size.width * numD018),
                                        child: Image.asset("${iconsPath}ic_deleteIcon.png", height: size.width * numD05),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              Text(
                                docList[index].id.isEmpty ? docList[index].documentName.split("/").last : docList[index].documentName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: size.width * numD05),
                    SizedBox(
                      width: size.width,
                      height: size.width * numD13,
                      child: commonElevatedButton(submitText, size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () {
                        if (formKey.currentState!.validate()) {
                          if (widget.editBank) {
                            //  editBankApi();
                          } else {
                            if (docList.length < 2) {
                              showSnackBar("Error", "Please upload your documents to proceed", Colors.red);
                            } else {
                              Navigator.pop(context);
                              callAddBankToStripeApi();
                            }
                          }
                        }
                      }),
                    ),
                    SizedBox(height: size.width * numD03),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void showDocListBottomSheet(StateSetter mainStateSetter) {
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
                  SizedBox(height: size.width * numD04),
                  Row(
                    children: [
                      ...[
                        Text(
                          "Select Document",
                          style: commonTextStyle(size: size, fontSize: size.width * numD045, color: Colors.black, fontWeight: FontWeight.w700),
                        ),
                      ],
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.close),
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
                          Navigator.pop(context);
                          if (docInstructionList[index].isSelected) {
                            showSnackBar("Error", "You have already uploaded ${docInstructionList[index].title}.", Colors.red);
                          } else {
                            showUploadImageOptionBottomSheet(true, mainStateSetter, index);
                          }
                        },
                        child: Text(
                          docInstructionList[index].title,
                          style: commonTextStyle(size: size, fontSize: size.width * numD036, color: Colors.black, fontWeight: FontWeight.w400),
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
  }

  void chooseBankUKListBottomSheet(BuildContext context, Size size) {
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
          return Stack(alignment: Alignment.center, children: [
            Container(
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: size.width * numD035),
                        Row(
                          children: [
                            ...[
                              Text(
                                "Select bank",
                                style: commonTextStyle(size: size, fontSize: size.width * numD045, color: Colors.black, fontWeight: FontWeight.w700),
                              ),
                            ],
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                setState(() {});
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

                        /*     CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: searchController,
                          hintText: "Search...",
                          textInputFormatters: null,
                          onChanged: (value){
                            callGetUkBankList();

                          },
                          prefixIcon:null,
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: null,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(height: size.width * numD035),*/
                        /*     CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: searchController,
                          hintText: "Search...",
                          textInputFormatters: null,
                          onChanged: (value){
                            callGetUkBankList();

                          },
                          prefixIcon:null,
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: null,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(height: size.width * numD035),*/

                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ListView.separated(
                                itemCount: bankUkList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      for (var item in bankUkList) {
                                        item.isSelected = false;
                                      }
                                      bankUkList[index].isSelected = true;
                                      bankController.text = bankUkList[index].bankName;
                                      debugPrint("bankUkList-> ${bankUkList[index].bankImage}");
                                      setState(() {});
                                      stateSetter(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(color: bankUkList[index].isSelected ? colorGreyChat : Colors.white, borderRadius: BorderRadius.circular(size.width * numD03), border: Border.all(color: Colors.grey.shade300)),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: size.width * numD02,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(size.width * numD02),
                                              child: Image.network(
                                                bankUkList[index].bankImage,
                                                height: size.width * numD11,
                                                width: size.width * numD11,
                                                fit: BoxFit.contain,
                                                errorBuilder: (c, s, o) {
                                                  return Container(
                                                    height: size.width * numD11,
                                                    width: size.width * numD11,
                                                    decoration: BoxDecoration(
                                                      color: colorLightGrey,
                                                      borderRadius: BorderRadius.circular(size.width * numD02),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * numD02,
                                          ),
                                          Expanded(
                                              child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: size.width * numD01,
                                            ),
                                            child: Text(
                                              bankUkList[index].bankName,
                                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: size.width * numD034),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height: size.width * numD02,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.width * numD02),
                        SizedBox(
                          width: size.width,
                          height: size.width * numD13,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorThemePink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(size.width * numD03),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Submit',
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]);
        });
      },
    );
  }

  /* ///-------ApisSection-----------
  void addBankApi() {
    Map<String, String> params = {
      "acc_holder_name": accountHolderNameController.text.trim(),
      "bank_name": bankController.text.trim(),
      "sort_code": sortCodeController.text.toString(),
      "acc_number": accountNumberController.text.trim(),
      "is_default": widget.showPageNumber
          ? true.toString()
          : widget.myBankList.isNotEmpty
              ? defaultValue.toString()
              : true.toString(),
    };
    debugPrint("AddBankParams:$params");
    NetworkClass.fromNetworkClass(addBankUrl, this, addBankUrlRequest, params)
        .callRequestServiceHeader(true, "patch", null);
  }

  void editBankApi() {
    Map<String, String> bankDetails = {
      "acc_holder_name": accountHolderNameController.text.trim(),
      "bank_name": bankController.text.trim(),
      "sort_code": sortCodeController.text.trim(),
      "acc_number": accountNumberController.text.trim(),
      "is_default":
          widget.showPageNumber ? true.toString() : defaultValue.toString(),
    };
    Map<String, String> params = {
      "bank_detail_id": widget.myBankData!.id,
      "bank_detail": jsonEncode(bankDetails),
    };
    debugPrint("EditBankParams: $params");
    NetworkClass.fromNetworkClass(editBankUrl, this, editBankUrlRequest, params)
        .callRequestServiceHeader(true, "patch", null);
  }

  /// Add Stripe Account
  void crateStripAccount() {
    NetworkClass.fromNetworkClass(
            createStripeAccount, this, reqCreateStipeAccount, {})
        .callRequestServiceHeader(false, "post", null);
  }
*/

  void callAddBankToStripeApi() {
    List<File> filesPath = [];
    Map<String, String> params = {
      "account_holder_name": accountHolderNameController.text.trim(),
      "sort_code": sortCodeController.text.trim(),
      "account_number": accountNumberController.text.trim(),
      "is_default": defaultValue.toString(),
    };

    debugPrint("AddBankParams: $params");
    Map<String, String> fileParams = {};
    if (docList.isNotEmpty) {
      for (int i = 0; i < docList.length; i++) {
        if (i == 0) {
          fileParams.addAll({"front": docList.first.documentName});
        } else {
          fileParams.addAll({"images": docList[i].documentName});
        }
      }

      filesPath.addAll(docList.map((path) => File(path.documentName)).toList());
    }
    NetworkClass.multipartNetworkClassFiles(createStripeAccount, this, reqCreateStipeAccount, params, filesPath).callMultipartServiceNew(true, "post", fileParams);
  }

  callUpdateStripeAccountApi(String accountId) {
    NetworkClass("${updateStripeBankUrl}id=$accountId&is_stripe_registered=true", this, updateStripeBankReq).callRequestServiceHeader(true, "get", null);
  }

  void callGetUkBankList() {
    NetworkClass.fromNetworkClass("$getUkBankListUrl?bankName=${searchController.text}", this, getUkBankListUrlReq, {}).callRequestServiceHeader(false, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqCreateStipeAccount:
          var map = jsonDecode(response);
          showSnackBar("PressHop", map['errors']['msg'].toString(), Colors.red);

          debugPrint("reqCreateStipeAccount error:::::::::$map");

          break;
        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("EditBankError:$map");

          break;
        case updateStripeBankReq:
          debugPrint("updateStripeBankReq:::::: error:::::::::$response");
          break;

        case getUkBankListUrlReq:
          debugPrint("getUkBankListUrlReq error :::::::$response ");
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqCreateStipeAccount:
          var map = jsonDecode(response);
          debugPrint("reqCreateStipeAccount success::::::::$map");
          callUpdateStripeAccountApi(map['account_id']['id'].toString());
          /* if (map["code"] == 200) {
            if (widget.showPageNumber) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UploadDocumentsScreen(
                        menuScreen: false,
                        hideLeading: false,
                      )));
            } else {
              Navigator.pop(context);
            }
          }*/

          break;
        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("editBankUrlRequest success:::::::$map");

          if (map["code"] == 200) {
            Navigator.pop(context);
          }
          break;

        case updateStripeBankReq:
          debugPrint("updateStripeBankReq success:::::$response");
          debugPrint("screenType :::::${widget.screenType}");
          if (widget.screenType == "publish") {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => WelcomeScreen(hideLeading: false, screenType: "publish")), (route) => false);
          } else if (widget.screenType == "myBank") {
            Navigator.pop(context);
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => WelcomeScreen(
                          hideLeading: false,
                          screenType: '',
                        )),
                (route) => false);
          }

          break;
        case getUkBankListUrlReq:
          debugPrint("getUkBankListUrlReq success::::::: $response");
          var data = jsonDecode(response);
          var dataModel = data['data'] as List;
          bankUkList = dataModel.map((e) => MyBankData.fromJson(e)).toList();
          debugPrint("bankUkList length:::: ${bankUkList.length}");
          setState(() {});

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
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
