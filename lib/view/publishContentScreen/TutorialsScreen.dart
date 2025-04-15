import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/chatScreens/FullVideoView.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../main.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';

class TutorialsScreen extends StatefulWidget {
  const TutorialsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return TutorialsScreenState();
  }
}

class TutorialsScreenState extends State<TutorialsScreen>
    implements NetworkResponse {
  ScrollController listController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int _offset = 0;
  int selectedCategoryIndex = 0;
  int selectedVideoIndex = 0;

  String selectedSellType = sharedText;
  bool isAPISuccess = false;
  bool isSearch = false;

  List<CategoryDataModel> categoryList = [];
  List<TutorialsModel> tutorialsList = [];
  List<TutorialsModel> searchResult = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callVideoCategoryAPI());

    setState(() {});
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      isAPISuccess = false;
      _offset = 0;
      tutorialsList.clear();
      callVideoTutorialAPI(categoryList[selectedCategoryIndex].name);
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _offset += 10;
      callVideoTutorialAPI(categoryList[selectedCategoryIndex].name);
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
          tutorialsText,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)));
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
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          enablePullUp: true,
          enablePullDown: true,
          footer: const CustomFooter(builder: commonRefresherFooter),
          child: ListView(
            children: [
              Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * numD04),
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: searchText,
                          filled: true,
                          fillColor: colorLightGrey,
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD035),
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              )),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              )),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              )),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              )),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              )),
                          suffixIcon: Padding(
                            padding:
                                EdgeInsets.only(right: size.width * numD04),
                            child: const ImageIcon(
                              AssetImage("${iconsPath}ic_search.png"),
                              color: Colors.black,
                            ),
                          ),
                          suffixIconColor: Colors.black,
                          suffixIconConstraints:
                              BoxConstraints(maxHeight: size.width * numD07),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04)),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          searchResult = tutorialsList
                              .where((element) => element.description
                                  .trim()
                                  .contains(value.toLowerCase()))
                              .toList();
                          isSearch = true;
                        } else {
                          isSearch = false;
                        }
                        setState(() {});
                      },
                    ),
                  ),

                  /// Category
                  SizedBox(
                    height: size.width * numD15,
                    child: ListView.separated(
                        controller: listController,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              int pos = categoryList
                                  .indexWhere((element) => element.selected);
                              if (pos >= 0) {
                                categoryList[pos].selected = false;
                              }
                              categoryList[index].selected =
                                  !categoryList[index].selected;
                              if (categoryList[index].selected) {
                                selectedCategoryIndex = index;
                                callVideoTutorialAPI(categoryList[index].name);
                              }

                              listController.animateTo(index * 100,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.ease);

                              setState(() {});
                            },
                            child: Chip(
                              backgroundColor: categoryList[index].selected
                                  ? Colors.black
                                  : colorLightGrey,
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * numD04,
                                  vertical: size.width * numD02),
                              label: Text(
                                categoryList[index].name,
                                style: TextStyle(
                                    color: categoryList[index].selected
                                        ? Colors.white
                                        : Colors.black,
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
                ],
              ),
              isAPISuccess
                  ? Center(child: showLoader())
                  :   tutorialsList.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04,
                          vertical: size.width * numD04),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        mainAxisSpacing: size.width * numD04,
                        crossAxisSpacing: size.width * numD04,
                      ),
                      itemBuilder: (context, index) {
                        var item = isSearch
                            ? searchResult[index]
                            : tutorialsList[index];
                        return InkWell(
                          onTap: () {
                            selectedVideoIndex = index;
                            setState(() {});
                            callAddFeedContentCount(item.id);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD04,
                                vertical: size.width * numD04),
                            decoration: BoxDecoration(
                                border: Border.all(color: colorTextFieldIcon),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04)),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  child: Stack(
                                    children: [
                                      item.thumbnail.isNotEmpty
                                          ? Image.network(
                                       item.thumbnail,
                                              height: size.width * numD30,
                                              width: size.width,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return Image.asset(
                                                  "${dummyImagePath}placeholderImage.png",
                                                  width: size.width,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : Image.asset(
                                              "${dummyImagePath}placeholderImage.png",
                                              height: size.width * numD30,
                                              width: size.width,
                                              fit: BoxFit.cover,
                                            ),
                                      Positioned(
                                        right: size.width * numD02,
                                        top: size.width * numD02,
                                        child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width * numD01,
                                                vertical: size.width * 0.002),
                                            decoration: BoxDecoration(
                                                color: colorLightGreen
                                                    .withOpacity(0.8),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD015)),
                                            child: Icon(
                                              Icons.videocam_outlined,
                                              size: size.width * numD045,
                                              color: Colors.white,
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * numD01,
                                ),
                                Text(item.description,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const Spacer(),
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_clock.png",
                                      height: size.width * numD03,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                        item.duration,
                                        /*Duration(seconds: int.parse(item.duration))
                                            .toString(),*/
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD025,
                                          color: colorHint,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    Image.asset(
                                      "${iconsPath}ic_view.png",
                                      height: size.width * numD03,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      item.view.toString(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD025,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD01,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount:
                          isSearch ? searchResult.length : tutorialsList.length)
                  :Container()
            ],
          ),
        ),
      ),
    );
  }

  callVideoTutorialAPI(String categoryName) {
    isAPISuccess = true;
    setState(() {

    });
    Map<String, String> map = {
      "type": 'videos',
      "offset": _offset.toString(),
      "limit": '10',
      "category": categoryName,
    };
    NetworkClass(getAllCmsUrl, this, getAllCmsUrlRequest)
        .callRequestServiceHeader(false, "get", map);
  }

  callVideoCategoryAPI() {
    Map<String, String> map = {
      "type": 'tutorial',
    };
    NetworkClass(getHopperCategory, this, reqGetHopperCategory)
        .callRequestServiceHeader(false, "get", map);
  }

  /// Add count
  callAddFeedContentCount(String tutorialID) {
    Map<String, String> map = {
      "type": "tutorial",
      'tutorial_id': tutorialID,
      "user_id": sharedPreferences!.getString(hopperIdKey).toString() ?? ''
    };
    debugPrint("map value====> $map");

    NetworkClass.fromNetworkClass(
            addViewCountAPI, this, reqAddViewCountAPI, map)
        .callRequestServiceHeader(false, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case getAllCmsUrlRequest:
          debugPrint(
              "getAllCmsUrlRequest_ErrorResponse ==> ${jsonDecode(response)}");
          break;
        case reqGetHopperCategory:
          debugPrint(
              "reqGetHopperCategory_ErrorResponse ==> ${jsonDecode(response)}");
          break;

        case reqAddViewCountAPI:
          debugPrint(
              "reqAddViewCountAPI_ErrorResponse ==> ${jsonDecode(response)}");
          break;
      }
    } on Exception catch (e) {
      debugPrint('exception catch==> $e');
    }
  }

  @override
  Future<void> onResponse(
      {required int requestCode, required String response}) async {
    try {
      switch (requestCode) {
        case getAllCmsUrlRequest:
          debugPrint(
              "getAllCmsUrlRequest_SuccessResponse ==> ${jsonDecode(response)}");
          var data = jsonDecode(response);

          var dataModel = data["status"] as List;
          tutorialsList = dataModel.map((e) => TutorialsModel.fromJson(e)).toList();
          //tutorialsList.clear();
          /* tutorialData.forEach((element) async {
            var fileName = await VideoThumbnail.thumbnailFile(
              video: element.video,
              thumbnailPath: (await getTemporaryDirectory()).path,
              imageFormat: ImageFormat.PNG,
              quality: 75,
            );*/

          //  debugPrint("=======>$fileName");
          /*  tutorialsList.add(TutorialsData(
                id: element.id,
                video: element.video,
                description: element.description,
                category: element.category,
                duration: element.duration,
                view: element.view,
                thumbnail: fileName ?? '',
                showVideo: false));
             });*/
          isAPISuccess = false;
          setState(() {});
           Future.delayed(const Duration(milliseconds: 5000),(){

           });

           debugPrint("tutorialData::::${tutorialsList.length}");

          break;

        case reqGetHopperCategory:
          debugPrint(
              "reqGetHopperCategory_SuccessResponse ==> ${jsonDecode(response)}");
          var data = jsonDecode(response);
          var dataList = data['categories'] as List;
          categoryList =
              dataList.map((e) => CategoryDataModel.fromJson(e)).toList();

          if (categoryList.isNotEmpty) {
            selectedCategoryIndex = 0;
            String categoryName = categoryList.first.name;
            categoryList.indexWhere((element) {
              if (element.name == categoryName) {
                element.selected = true;
              }
              return true;
            });
            callVideoTutorialAPI(categoryList.first.name);
          } else {
            showSnackBar(
                "Tutorial", "Tutorial category not available", colorThemePink);
          }

          setState(() {});
          break;

        case reqAddViewCountAPI:
          debugPrint(
              "reqAddViewCountAPI_SuccessResponse ==> ${jsonDecode(response)}");
          if (tutorialsList.isNotEmpty || searchResult.isNotEmpty) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MediaViewScreen(
                          mediaFile: isSearch
                              ? searchResult[selectedVideoIndex].video
                              : tutorialsList[selectedVideoIndex].video,
                          type: MediaTypeEnum.video,
                        )));
          }
      }
    } on Exception catch (e) {
      debugPrint('exception catch==> $e');
    }
  }
}

/// Tutorial
class TutorialsModel{
  String id = "";
  String video = "";
  String thumbnail = "";
  String description = "";
  String category = "";
  String duration = "";
  int view = 0;
  bool showVideo = false;

  TutorialsModel(
      {required this.id,
      required this.video,
      required this.description,
      required this.category,
      required this.duration,
      required this.view,
      required this.thumbnail,
      required this.showVideo});

  factory TutorialsModel.fromJson(Map<String, dynamic> json) {
    return TutorialsModel(
        id: json['_id'] ?? "",
        video: json['video'] ?? "",
        description: json['description'] ?? "",
        category: json['category'] ?? "",
        duration: json['duration'] ?? "",
        view: json['count_for_hopper'] ?? 0,
        thumbnail: json['thumbnail'] ?? "",
        showVideo: false);
  }
}

/// Hopper Category
class CategoryDataModel {
  String id = "";
  String name = "";
  String type = "";
  String percentage = "";
  bool selected = false;

  CategoryDataModel(
      {required this.id,
      required this.name,
      required this.type,
      required this.percentage,
      required this.selected});

  factory CategoryDataModel.fromJson(Map<String, dynamic> json) {
    return CategoryDataModel(
        id: json['_id'] ?? "",
        name: json['name'] ?? "",
        type: json['type'] ?? "",
        percentage: json['percentage'] ?? "",
        selected: false);
  }
}
