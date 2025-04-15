import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/publishContentScreen/PublishContentScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import '../../utils/networkOperations/NetworkClass.dart';
import '../myEarning/MyEarningScreen.dart';
import '../publishContentScreen/HashTagSearchScreen.dart';
import '../publishContentScreen/TutorialsScreen.dart';
import 'MyContentScreen.dart';

class MyDraftScreen extends StatefulWidget {
  bool publishedContent = false;
  String screenType = "";

  MyDraftScreen({super.key, required this.publishedContent, required this.screenType});

  @override
  State<StatefulWidget> createState() {
    return MyDraftScreenState();
  }
}

class MyDraftScreenState extends State<MyDraftScreen> implements NetworkResponse {
  late Size size;
  List<MyContentData> myDraftList = [];
  String selectedSellType = sharedText;
  ScrollController listController = ScrollController();
  List<FilterModel> sortList = [];
  List<FilterModel> filterList = [];
  bool showData = false;
  int limit = 10, offset = 0;
  int draftIndex = 0;
  int selectedIndex = 0;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    debugPrint("screenType::::::${runtimeType}");
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      myDraftApi();
      initializeFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (widget.publishedContent || widget.screenType == "welcome") {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
        } else {
          Navigator.pop(context);
        }

        return false;
      },
      child: Scaffold(
        appBar: CommonAppBar(
          elevation: 0,
          title: Text(
            myDraftText,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: size.width * appBarHeadingFontSize),
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
                  showBottomSheet(size);
                },
                child: commonFilterIcon(size)),
            SizedBox(
              width: size.width * numD02,
            ),
            Container(
              margin: EdgeInsets.only(bottom: size.width * numD02),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
                },
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.width * numD07,
                  width: size.width * numD07,
                ),
              ),
            ),
            SizedBox(
              width: size.width * numD04,
            )
          ],
          hideLeading: false,
        ),
        body: SafeArea(
          child: myDraftList.isNotEmpty
              ? SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: true,
                  onLoading: _onLoading,
                  onRefresh: _onRefresh,
                  controller: _refreshController,
                  child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD04),
                      itemBuilder: (context, index) {
                        var item = myDraftList[index];
                        return InkWell(
                          onTap: () {
                            selectedIndex = index;
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PublishContentScreen(
                                      publishData: null,
                                      myContentData: myDraftList[selectedIndex],
                                      hideDraft: true,
                                      docType: '',
                                    )));
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: size.width * numD03, right: size.width * numD03, top: size.width * numD03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                item.contentMediaList.isNotEmpty ? mediaWidget(item) : Text("No media found."),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(myDraftList[index].textValue.toCapitalized(), maxLines: 2, overflow: TextOverflow.ellipsis, style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, lineHeight: 1.5, fontWeight: FontWeight.w600)),
                                    ),
                                    SizedBox(height: size.width * numD02),
                                    Image.asset(
                                      myDraftList[index].exclusive ? "${iconsPath}ic_exclusive.png" : "${iconsPath}ic_share.png",
                                      height: size.width * numD035,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Text(
                                      myDraftList[index].exclusive ? exclusiveText : sharedText,
                                      style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_clock.png",
                                      height: size.width * numD04,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      dateTimeFormatter(dateTime: item.time.toString(), format: "hh:mm a, dd MMM yyyy", utc: true),
                                      style: commonTextStyle(size: size, fontSize: size.width * numD028, color: colorHint, fontWeight: FontWeight.normal),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_location.png",
                                      height: size.width * numD045,
                                      color: colorTextFieldIcon,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.location,
                                        overflow: TextOverflow.ellipsis,
                                        style: commonTextStyle(size: size, fontSize: size.width * numD028, color: colorHint, fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Text(
                                  "${myDraftList[index].leftPercent}% left to complete",
                                  style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, lineHeight: 1.5, fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    overlayShape: SliderComponentShape.noThumb,
                                    thumbColor: Colors.transparent,
                                    trackHeight: size.width * numD025,
                                  ),
                                  child: Slider(
                                    value: 100.0 - double.parse(myDraftList[index].leftPercent.toString()),
                                    min: 0.0,
                                    max: 100.0,
                                    inactiveColor: colorLightGrey,
                                    activeColor: colorThemePink,
                                    onChanged: (double newValue) {},
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          thickness: 1,
                          color: colorLightGrey,
                        );
                      },
                      itemCount: myDraftList.length),
                )
              : showData
                  ? errorMessageWidget("No Saved Content")
                  : Container(),
        ),
      ),
    );
  }

  /// Load Filter And Sort
  void initializeFilter() {
    sortList.addAll([
      FilterModel(name: viewMonthlyText, icon: "ic_monthly_calendar.png", isSelected: false),
      FilterModel(name: viewYearlyText, icon: "ic_yearly_calendar.png", isSelected: false),
      FilterModel(name: filterDateText, icon: "ic_eye_outlined.png", isSelected: false),
    ]);
    filterList.addAll([
      FilterModel(name: allExclusiveContentText, icon: "ic_exclusive.png", isSelected: false),
      FilterModel(name: allSharedContentText, icon: "ic_share.png", isSelected: false),
    ]);
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      showData = false;
      offset = 0;
      myDraftList.clear();
      myDraftApi();
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      offset += 10;
      myDraftApi();
    });
    _refreshController.loadComplete();
  }

  Widget mediaWidget(item) {
    debugPrint("MediaWidget: ${item.contentMediaList.toString()}");
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.width * numD04),
      child: Stack(
        children: [
          showImage(
            item.contentMediaList.first.mediaType,
            item.contentMediaList.first.mediaType == "video" ? item.contentMediaList.first.thumbNail : item.contentMediaList.first.media,
          ), // item.contentMediaList
          Positioned(
              right: size.width * numD02,
              top: size.width * numD02,
              child: Column(
                children: getMediaCount(item.contentMediaList, size),
              )),
          Visibility(
            visible: false,
            child: Positioned(
              right: size.width * numD02,
              bottom: size.width * numD02,
              child: Text(
                "+${item.contentMediaList.length - 1}",
                style: commonTextStyle(size: size, fontSize: size.width * numD04, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Visibility(
            visible:true,
            child: Image.asset(
              "${commonImagePath}watermark1.png",
              height: size.width * numD50,
              width: size.width,
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }

  Widget showImage(String type, String url) {
    debugPrint("url::::${contentImageUrl + url}");
    return type == "audio"
        ? Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * numD50,
            color: colorThemePink,
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * numD15,
            ),
          )
        : type == "pdf"
            ? Image.asset(
                "${dummyImagePath}pngImage.png",
                fit: BoxFit.contain,
                height: size.width * numD50,
                width: size.width,
              )
            : type == "doc"
                ? Image.asset(
                    "${dummyImagePath}doc_black_icon.png",
                    height: size.width * numD50,
                    fit: BoxFit.contain,
                    width: size.width,
                  )
                : Image.network(
                    //  "$contentImageUrl$url",
                    "$imageUrlBefore$url",
                    height: size.width * numD50,
                    width: size.width,
                    fit: BoxFit.cover,
                    errorBuilder: (c, s, o) {
                      return Container(
                        color: colorLightGrey,
                        height: size.width * numD50,
                        width: size.width,
                      );
                    },
                  );
  }

  Future<void> showBottomSheet(Size size) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD085),
          topRight: Radius.circular(size.width * numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter stateSetter) {
            return Padding(
              padding: EdgeInsets.only(
                top: size.width * numD06,
                left: size.width * numD05,
                right: size.width * numD05,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          splashRadius: size.width * numD07,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: size.width * numD07,
                          ),
                        ),
                        Text(
                          "Sort and Filter",
                          style: commonTextStyle(size: size, fontSize: size.width * appBarHeadingFontSizeNew, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            filterList.clear();
                            sortList.clear();
                            initializeFilter();
                            stateSetter(() {});
                          },
                          child: Text(
                            "Clear all",
                            style: TextStyle(color: colorThemePink, fontWeight: FontWeight.w400, fontSize: size.width * numD035),
                          ),
                        ),
                      ],
                    ),

                    /// Sort
                    SizedBox(
                      height: size.width * numD085,
                    ),

                    /// Sort Heading
                    Text(
                      sortText,
                      style: commonTextStyle(size: size, fontSize: size.width * numD05, color: Colors.black, fontWeight: FontWeight.w500),
                    ),

                    filterListWidget(sortList, stateSetter, size, true),

                    /// Filter
                    SizedBox(
                      height: size.width * numD05,
                    ),

                    /// Filter Heading
                    Text(
                      filterText,
                      style: commonTextStyle(size: size, fontSize: size.width * numD05, color: Colors.black, fontWeight: FontWeight.w500),
                    ),

                    filterListWidget(filterList, stateSetter, size, false),
                    SizedBox(
                      height: size.width * numD06,
                    ),

                    /// Button
                    Container(
                      width: size.width,
                      height: size.width * numD13,
                      margin: EdgeInsets.symmetric(horizontal: size.width * numD04),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: commonElevatedButton(applyText, size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () {
                        Navigator.pop(context);
                        myDraftApi();
                      }),
                    ),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget filterListWidget(List<FilterModel> list, StateSetter stateSetter, Size size, bool isSort) {
    return ListView.separated(
      padding: EdgeInsets.only(top: size.width * numD03),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var item = list[index];
        return InkWell(
          onTap: () {
            if (isSort) {
              int pos = list.indexWhere((element) => element.isSelected);
              if (pos != -1) {
                list[pos].isSelected = false;
                list[pos].fromDate = null;
                list[pos].toDate = null;
              }
            }
            item.isSelected = !item.isSelected;
            stateSetter(() {});
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.only(
              top: list[index].name == filterDateText ? size.width * 0 : size.width * numD025,
              bottom: list[index].name == filterDateText ? size.width * 0 : size.width * numD025,
              left: size.width * numD02,
              right: size.width * numD02,
            ),
            color: item.isSelected ? Colors.grey.shade400 : null,
            child: Row(
              children: [
                Image.asset(
                  "$iconsPath${list[index].icon}",
                  color: Colors.black,
                  height: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                  width: list[index].name == soldContentText ? size.width * numD06 : size.width * numD05,
                ),
                SizedBox(
                  width: size.width * numD03,
                ),
                item.name == filterDateText
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              item.fromDate = await commonDatePicker();
                              item.toDate = null;
                              int pos = list.indexWhere((element) => element.isSelected);
                              if (pos != -1) {
                                list[pos].isSelected = false;
                              }
                              item.isSelected = !item.isSelected;
                              stateSetter(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size.width * numD04),
                                border: Border.all(width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.fromDate != null ? dateTimeFormatter(dateTime: item.fromDate.toString()) : fromText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD015,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD03,
                          ),
                          InkWell(
                            onTap: () async {
                              if (item.fromDate != null) {
                                String? pickedDate = await commonDatePicker();

                                if (pickedDate != null) {
                                  DateTime parseFromDate = DateTime.parse(item.fromDate!);
                                  DateTime parseToDate = DateTime.parse(pickedDate);

                                  debugPrint("parseFromDate : $parseFromDate");
                                  debugPrint("parseToDate : $parseToDate");

                                  if (parseToDate.isAfter(parseFromDate) || parseToDate.isAtSameMomentAs(parseFromDate)) {
                                    item.toDate = pickedDate;
                                  } else {
                                    showSnackBar("Date Error", "Please select to date above from date", Colors.red);
                                  }
                                }
                              }
                              stateSetter(() {});
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: size.width * numD01,
                                bottom: size.width * numD01,
                                left: size.width * numD03,
                                right: size.width * numD01,
                              ),
                              width: size.width * numD32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size.width * numD04),
                                border: Border.all(width: 1, color: const Color(0xFFDEE7E6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.toDate != null ? dateTimeFormatter(dateTime: item.toDate.toString()) : toText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(
                                    width: size.width * numD02,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(list[index].name, style: TextStyle(fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w400, fontFamily: "AirbnbCereal_W_Bk"))
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(
          height: size.width * numD01,
        );
      },
    );
  }

  ///--------Apis Section------------

  void myDraftApi() {
    Map<String, String> params = {"is_draft": 'true'};

    int pos = sortList.indexWhere((element) => element.isSelected);

    if (pos != -1) {
      myDraftList.clear();
      if (sortList[pos].name == filterDateText) {
        params["startdate"] = sortList[pos].fromDate!;
        params["endDate"] = sortList[pos].toDate!;
      } else if (sortList[pos].name == viewMonthlyText) {
        params["posted_date"] = "31";
      } else if (sortList[pos].name == viewYearlyText) {
        params["posted_date"] = "365";
      }
    } else {
      params["limit"] = limit.toString();
      params["offset"] = offset.toString();
    }

    for (var element in filterList) {
      if (element.isSelected) {
        switch (element.name) {
          case allSharedContentText:
            params["sharedtype"] = "shared";
            break;

          case allExclusiveContentText:
            params["type"] = "exclusive";
            break;
        }
      }
    }

    NetworkClass(myDraftUrl, this, myDraftUrlRequest).callRequestServiceHeader(true, "get", params);
  }

  updateDraftListAPI(String contentId) {
    Map<String, String> map = {
      'content_id': contentId,
    };

    NetworkClass.fromNetworkClass(removeFromDraftContentAPI, this, reqRemoveFromDraftContentAPI, map).callRequestServiceHeader(true, "patch", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myContentUrlRequest:
          debugPrint("myContentError: $response");
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
        case myDraftUrlRequest:
          try {
            var data = jsonDecode(response);
            log("myDraftUrlRequest success: $data");
            if (data != null) {
              var listModel = data["contentList"] as List;
              var list = listModel.map((e) => MyContentData.fromJson(e)).toList();
              if (list.isNotEmpty) {
                _refreshController.loadComplete();
              } else if (list.isEmpty) {
                _refreshController.loadNoData();
              } else {
                _refreshController.loadFailed();
              }

              if (offset == 0) {
                myDraftList.clear();
              }

              myDraftList.addAll(list);
            }
            showData = true;
            setState(() {});
          } catch (e) {
            debugPrint("Exception::::::::$e");
          }

          break;

        case reqRemoveFromDraftContentAPI:
          log("reqRemoveFromDraftContentAPI===> ${jsonDecode(response)}");
      }
    } on Exception catch (e) {
      debugPrint("ApiError::::$e");
    }
  }
}

class MyDraftData {
  String textValue = "";
  String time = "";
  String location = "";
  String latitude = "";
  String longitude = "";
  String amount = "";
  bool exclusive = false;
  bool showVideo = false;
  List<ContentMediaData> contentMediaList = [];
  List<HashTagData> hashTagList = [];
  CategoryDataModel? categoryData;
  String completionPercent = "";
  int leftPercent = 0;

  MyDraftData.fromJson(json) {
    exclusive = json["type"] == "shared" ? false : true;
    time = changeDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", json["timestamp"], "HH:mm, dd MMM, yyyy");
    textValue = json["description"];
    location = json["location"];
    latitude = json["latitude"].toString();
    longitude = json["longitude"].toString();
    amount = json["original_ask_price"].toString();

    if (json["content"] != null) {
      var contentList = json["content"] as List;
      contentMediaList = contentList.map((e) => ContentMediaData.fromJson(e)).toList();
    }

    if (json["tagData"] != null) {
      var tagList = json["tagData"] as List;
      hashTagList = tagList.map((e) => HashTagData.fromJson(e)).toList();
    }
    if (json["categoryData"] != null) {
      categoryData = CategoryDataModel.fromJson(json["categoryData"]);
    }

    int count = 0;

    if (textValue.trim().isNotEmpty) {
      count += 1;
    }
    if (time.trim().isNotEmpty) {
      count += 1;
    }

    if (location.trim().isNotEmpty) {
      count += 1;
    }

    if (amount.trim().isNotEmpty) {
      count += 1;
    }

    if (contentMediaList.isNotEmpty) {
      count += 1;
    }

    if (hashTagList.isNotEmpty) {
      count += 1;
    }

    if (categoryData != null) {
      count += 1;
    }
    debugPrint("Count: $count");
    completionPercent = ((count * 14.286) / 100).round().toString();
    leftPercent = ((7 - count) * 14.286).round();
  }
}

class ContentMediaData {
  String id = "";
  String media = "";
  String mediaType = "";
  String thumbNail = "";
  String waterMark = "";

  ContentMediaData(this.id, this.media, this.mediaType, this.thumbNail, this.waterMark);

  ContentMediaData.fromJson(json) {
    id = json["_id"].toString();
    media = json["media"];
    mediaType = json["media_type"] ?? "";
    thumbNail = (json["thumbnail"] ?? "").toString();
    waterMark = (json["watermark"] ?? "").toString();
    if (mediaType == "video") {
      getVideoThumbNail("$media").then((value) {
        debugPrint("TValue: $value");

        thumbNail = value;
      });
    }
  }

  Future<String> getVideoThumbNail(String path) async {
    debugPrint("MediaIs:::::: $path");
    final thumbnail = await vt.VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vt.ImageFormat.PNG,
      maxHeight: 500,
      quality: 100,
    );
    return thumbnail ?? "";
  }
}
