import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/view/authentication/UploadDocumnetsScreen.dart';

import '../../utils/CommonTextField.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../dashboard/Dashboard.dart';
import 'MyBanksScreen.dart';

class EditBankScreen extends StatefulWidget {
  bool showPageNumber = false;
  bool hideLeading = false;
  bool editBank = false;
  MyBankData? myBankData;
  List<MyBankListData> myBankList = [];

  EditBankScreen({super.key, required this.showPageNumber, required this.hideLeading, required this.editBank, this.myBankData, required this.myBankList});

  @override
  State<EditBankScreen> createState() => _EditBankScreenState();
}

class _EditBankScreenState extends State<EditBankScreen> implements NetworkResponse {
  var formKey = GlobalKey<FormState>();
  TextEditingController accountHolderNameController = TextEditingController();
  TextEditingController bankController = TextEditingController();
  TextEditingController sortCodeController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String stripOnBoardURL = '';
  String bankLogoUrl = '';
  bool defaultValue = false;
  List<MyBankData> bankUkList = [];

  @override
  void initState() {
    super.initState();
    callGetUkBankList();
    //  WidgetsBinding.instance.addPostFrameCallback((timeStamp) => crateStripAccount());
    if (widget.editBank) {
      //  setBankData();
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: widget.hideLeading,
        title: Padding(
          padding: EdgeInsets.only(left: !widget.hideLeading ? 0 : size.width * numD058, right: size.width * numD1),
          child: Text(
            "Add & Verify Bank",
            style: commonBigTitleTextStyle(size, Colors.black),
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: false,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)));
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD07,
              width: size.width * numD07,
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          )
        ],
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
                  style: TextStyle(color: Colors.black, fontSize: size.width * numD035),
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
                      callback: () {
                        chooseBankUKListBottomSheet(context, size);
                      },
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_bank.png",
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
                      readOnly: true,
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
                      readOnly: widget.editBank ? true : false,
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
                        //<-- add String? as a return type
                        if (value!.trim().isEmpty) {
                          return requiredText;
                        } else if (value.length < 7) {
                          return bankErrorText;
                        }
                        return null;
                      },
                      enableValidations: true,
                      filled: false,
                      readOnly: widget.editBank ? true : false,
                      filledColor: Colors.transparent,
                      autofocus: false,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),

                    /*     Container(
                      margin: EdgeInsets.symmetric(horizontal: size.width*numD04),
                      width: size.width,
                      height: size.width * numD13,

                      child: commonElevatedButton(
                          widget.showPageNumber
                              ? nextText
                              : widget.editBank
                              ? updateText
                              : submitText,
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        if (formKey.currentState!.validate()) {
                          if (widget.editBank) {
                            editBankApi();
                          } else {
                            addBankApi();

                            */ /*  if(stripOnBoardURL.isNotEmpty){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CommonWebView(
                                          webUrl: stripOnBoardURL,
                                          title: ""))).then((value) {
                                debugPrint('value data===> $value');
                                if (value) {
                                 addBankApi();
                                }
                              });
                            }else{
                              addBankApi();
                            }*/ /*

                          }
                        }
                      }),
                    ),*/
                    SizedBox(
                      width: size.width,
                      height: size.width * numD13,
                      child: commonElevatedButton(submitText, size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () {
                        if (formKey.currentState!.validate()) {
                          addBankApi();
                        }
                      }),
                    ),
                    SizedBox(
                      height: widget.showPageNumber ? size.width * numD04 : 0,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
                                      bankLogoUrl = bankUkList[index].bankImage;
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
                        SizedBox(height: size.width * numD02),
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

  ///-------ApisSection-----------
  void addBankApi() {
    Map<String, String> params = {
      "acc_holder_name": accountHolderNameController.text.trim(),
      "bank_name": bankController.text.trim(),
      "sort_code": sortCodeController.text.toString(),
      "account_number": accountNumberController.text.trim(),
      "bank_logo": bankLogoUrl,
      "is_default": widget.showPageNumber
          ? true.toString()
          : widget.myBankList.isNotEmpty
              ? defaultValue.toString()
              : true.toString(),
    };
    debugPrint("AddBankParams:$params");
    NetworkClass.fromNetworkClass(addBankUrl, this, addBankUrlRequest, params).callRequestServiceHeader(true, "patch", null);
  }

/*
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
      "stripe_bank_id": widget.myBankData!.stripeBankId,
      "is_default":
          widget.showPageNumber ? true.toString() : defaultValue.toString(),
      "bank_detail": jsonEncode(bankDetails),
    };
    debugPrint("EditBankParams: $params");
    NetworkClass.fromNetworkClass(editBankUrl, this, editBankUrlRequest, params)
        .callRequestServiceHeader(true, "patch", null);
  }
*/

  /// Add Stripe Account
  void crateStripAccount() {
    NetworkClass.fromNetworkClass(createStripeAccount, this, reqCreateStipeAccount, {}).callRequestServiceHeader(false, "post", null);
  }

  void callGetUkBankList() {
    NetworkClass.fromNetworkClass("$getUkBankListUrl?bankName=${searchController.text}", this, getUkBankListUrlReq, {}).callRequestServiceHeader(false, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case addBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("addBankUrlRequest:$map");
          showSnackBar("PressHop", map['message'].toString(), Colors.red);

          break;
        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("EditBankError:$map");

          break;
        case reqCreateStipeAccount:
          debugPrint("reqCreateStipeAccountErrorResponse===>${jsonDecode(response)} ");
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
        case addBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");
          if (map["code"] == 200) {
            if (widget.showPageNumber) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const UploadDocumentsScreen(
                        menuScreen: false,
                        hideLeading: false,
                      )));
            } else {
              Navigator.pop(context);
            }
          }

          break;
        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("EditBankresponse:$map");

          if (map["code"] == 200) {
            Navigator.pop(context);
          }
          break;
        case reqCreateStipeAccount:
          debugPrint("reqCreateStipeAccountSuccessResponse===>${jsonDecode(response)} ");
          var data = jsonDecode(response);
          stripOnBoardURL = data['message']['url'];
          debugPrint("stripBoardURK ====> $stripOnBoardURL");
          setState(() {});
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
