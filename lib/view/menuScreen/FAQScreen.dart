import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/CommonWigdets.dart';
import '../dashboard/Dashboard.dart';
import '../publishContentScreen/TutorialsScreen.dart';

class FAQScreen extends StatefulWidget {
  bool priceTipsSelected = false;
  String type = "";
  String benefits = "";
   int index=0;

  FAQScreen({super.key, required this.priceTipsSelected, required this.type, this.benefits = "",required this.index});

  @override
  State<StatefulWidget> createState() {
    return FAQScreenState();
  }
}

class FAQScreenState extends State<FAQScreen> implements NetworkResponse {
  ScrollController listController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int selectedCategoryIndex = 0;
  int _offset = 0;

  String selectedSellType = sharedText, selectedCategoryId = "";

  bool isApiSuccess = false;
  bool isSearch = false;

  List<FAQPriceTipsData> questionAnswerList = [];
  List<FAQPriceTipsData> searchResult = [];
  List<CategoryDataModel> categoryList = [];

  @override
  void initState() {
    super.initState();
    debugPrint("widget.index:::::${widget.index}");


    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callFAQCategoryAPI());
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset = 0;
      if (widget.priceTipsSelected) {
        callPriceTipsAPI(categoryList[selectedCategoryIndex].name);
      } else {
        callFAQAPI(categoryList[selectedCategoryIndex].name);
      }
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset += 10;
      if (widget.priceTipsSelected) {
        callPriceTipsAPI(categoryList[selectedCategoryIndex].name);
      } else {
        callFAQAPI(categoryList[selectedCategoryIndex].name);
      }
    });
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          widget.priceTipsSelected ? priceTipsText : faqText,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize),
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
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
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
        child: isApiSuccess
            ? SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                enablePullUp: true,
                enablePullDown: true,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04),
                        child: TextFormField(
                            decoration: InputDecoration(
                                hintText: searchText,
                                filled: true,
                                fillColor: colorLightGrey,
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    )),
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(
                                      right: size.width * numD04),
                                  child: const ImageIcon(
                                    AssetImage("${iconsPath}ic_search.png"),
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIconColor: Colors.black,
                                suffixIconConstraints: BoxConstraints(
                                    maxHeight: size.width * numD07),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04)),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                searchResult = questionAnswerList
                                    .where((element) => element.question.toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();
                                isSearch = true;
                              } else {
                                isSearch = false;
                              }
                              setState(() {});
                            }),
                      ),
                      categoryList.isEmpty
                          ? Center(
                              child: errorMessageWidget("No Category found"))
                          : Container(
                              height: size.width * numD15,
                              margin: EdgeInsets.only(left:size.width * numD035),
                              child: ListView.separated(
                                  controller: listController,

                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        int pos = categoryList.indexWhere(
                                            (element) => element.selected);
                                        if (pos >= 0) {
                                          categoryList[pos].selected = false;
                                        }
                                        categoryList[index].selected =
                                            !categoryList[index].selected;
                                        if (categoryList[index].selected) {
                                          selectedCategoryIndex = index;
                                          if (widget.priceTipsSelected) {
                                            callPriceTipsAPI(categoryList[selectedCategoryIndex].name);
                                          } else {
                                            callFAQAPI(categoryList[selectedCategoryIndex].name);
                                          }
                                        }

                                        listController.animateTo(index * 100,
                                            duration: const Duration(
                                                milliseconds: 200),
                                            curve: Curves.ease);

                                        selectedCategoryId =
                                            categoryList[index].id;
                                        setState(() {});
                                      },
                                      child: Chip(
                                        backgroundColor:
                                            categoryList[index].selected
                                                ? Colors.black
                                                : colorLightGrey,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * numD025,
                                            vertical: size.width * numD02),
                                        label: Text(
                                          categoryList[index]
                                              .name
                                              .toTitleCase(),
                                          style: TextStyle(
                                              color:
                                                  categoryList[index].selected
                                                      ? Colors.white
                                                      : Colors.black,
                                              fontFamily: "AirbnbCereal",
                                              fontSize: size.width * numD036,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return SizedBox(
                                      width: size.width * numD04,
                                    );
                                  },
                                  itemCount: categoryList.length),
                            ),
                      questionAnswerList.isNotEmpty
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * numD035),
                              itemBuilder: (context, index) {
                                var item = isSearch
                                    ? searchResult[index]
                                    : questionAnswerList[index];
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02),
                                      border: Border.all(
                                          color: Colors.grey.shade300)),
                                  child: ExpansionTile(

                                    
                                    title: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top:size.width*numD01),

                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width * numD02,
                                              vertical: size.width * numD01),
                                          decoration: BoxDecoration(
                                              color: colorThemePink,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD01)),
                                          child: Text(
                                            "Q",
                                            style: TextStyle(
                                                fontSize: size.width * numD036,
                                                color: Colors.white,
                                                fontFamily: "AirbnbCereal",
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * numD02,
                                        ),
                                        Expanded(
                                            child: Text(
                                          item.question,
                                          style: TextStyle(
                                              fontSize: size.width * numD035,
                                              color: Colors.black,
                                              fontFamily: "AirbnbCereal",
                                              fontWeight: FontWeight.bold),
                                        ))
                                      ],
                                    ),
                                    iconColor: Colors.black,
                                    onExpansionChanged: (value) {
                                      item.selected = value;
                                      setState(() {});
                                    },
                                    children: [
                                      Container(
                                        height: 1,
                                        margin: EdgeInsets.only(
                                            bottom: size.width * numD04,
                                            left: size.width * numD04,
                                            right: size.width * numD04),
                                        width: size.width,
                                        color: Colors.grey.shade300,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * numD04),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(top:size.width*numD01),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                  size.width * numD02,
                                                  vertical:
                                                      size.width * numD01),
                                              decoration: BoxDecoration(
                                                  color: colorThemePink,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * numD01)),
                                              child: Text(
                                                "A",
                                                style: TextStyle(
                                                    fontSize:
                                                        size.width * numD035,
                                                    color: Colors.white,
                                                    fontFamily: "AirbnbCereal",
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD02,
                                            ),
                                            Expanded(
                                              child: Text(
                                                item.answer,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: "AirbnbCereal",
                                                    fontSize:
                                                        size.width * numD035),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: size.width * numD04,
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: size.width * numD04,
                                );
                              },
                              itemCount: isSearch
                                  ? searchResult.length
                                  : questionAnswerList.length)
                          : errorMessageWidget(widget.priceTipsSelected
                              ? "No Price Tips Found"
                              : "No FAQ found"),
                    ],
                  ),
                ),
              )
            : Container(),
      ),
    );
  }

  void callFAQAPI(String category) {
    Map<String, String> map = {
      'type': widget.type,
      'offset': _offset.toString(),
      'limit': '10',
      'category': category,
    };
    NetworkClass(getAllCmsUrl, this, getAllCmsUrlRequest)
        .callRequestServiceHeader(true, "get", map);
  }

  void callPriceTipsAPI(String category) {
    Map<String, String> map = {
      'offset': _offset.toString(),
      'limit': '10',
      'category': category,
    };
    NetworkClass(priceTipsAPI, this, reqPriceTipsAPI)
        .callRequestServiceHeader(true, "get", map);
  }

  callFAQCategoryAPI() {
    Map<String, String> map = {
      "type": widget.priceTipsSelected ? 'priceTip' : 'FAQ',
    };
    NetworkClass(getHopperCategory, this, reqGetHopperCategory)
        .callRequestServiceHeader(true, "get", map);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case getAllCmsUrlRequest:
          debugPrint(
              "getAllCmsUrlRequest_ErrorResponse ==> ${jsonDecode(response)}");
          break;
        case reqPriceTipsAPI:
          debugPrint(
              "reqPriceTipsAPI_ErrorResponse ==> ${jsonDecode(response)}");
          break;

        case reqGetHopperCategory:
          debugPrint(
              "reqGetHopperCategory_ErrorResponse ==> ${jsonDecode(response)}");
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
        case getAllCmsUrlRequest:
          var map = jsonDecode(response);
          debugPrint("FaqData:$response");
            var list = map["status"] as List;
            if(list.isNotEmpty){
              questionAnswerList =
                  list.map((e) => FAQPriceTipsData.fromJson(e)).toList();
              isApiSuccess = true;
              setState(() {});
            }

          break;

        case reqPriceTipsAPI:
          var map = jsonDecode(response);
          debugPrint("priceTrips=====> :$response");
          if (map["code"] == 200) {
            var list = map["price_tips"] as List;
            questionAnswerList =
                list.map((e) => FAQPriceTipsData.fromJson(e)).toList();
            isApiSuccess = true;
            setState(() {});
          }
          break;

        case reqGetHopperCategory:
          debugPrint(
              "reqGetHopperCategory_SuccessResponse ==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['categories'] as List;

          if(dataList.isNotEmpty){
            categoryList =
                dataList.map((e) => CategoryDataModel.fromJson(e)).toList();
            String categoryName = "";
            if (categoryList.isNotEmpty) {
              if(widget.benefits.isEmpty) {
                categoryName = categoryList.first.name;
                categoryList.indexWhere((element) {
                  if (element.name == categoryName) {
                    element.selected = true;
                  }
                  return true;
                });
              }
              else {
                categoryName = categoryList.last.name;
                debugPrint("categoryName===> ${categoryList.last.name}");
                categoryList.lastIndexWhere((element) {
                  if (element.name.contains(categoryName)) {
                    debugPrint("here===>");
                    element.selected = true;
                  }
                  return true;
                });
              }
            }
            if (widget.index == 1 && categoryList.length > 1) {
              for (var item in categoryList) {
                item.selected = false;
              }
              categoryList[1].selected = true;
              setState(() {});
            }

            if (widget.priceTipsSelected) {
              callPriceTipsAPI(categoryList.first.name);
            } else {
              if(widget.benefits.isNotEmpty){
                for (var item in categoryList) {
                  item.selected = false;
                }
                categoryList[5].selected = true;
                callFAQAPI("PRO benefits");
              }else{
                callFAQAPI(widget.index == 1 && categoryList.length > 1?"Emergency":categoryList.first.name);
              }
            }
          }

          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class FAQPriceTipsData {
  String id = "";
  String question = "";
  String answer = "";
  String category = "";
  bool selected = false;

  FAQPriceTipsData.fromJson(json) {
    id = json["_id"] ?? '';
    question = json["ques"] ?? "";
    answer = json["ans"] ?? "";
    category = json['category'] ?? "";
  }
}
