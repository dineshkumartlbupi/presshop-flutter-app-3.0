import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/di/injection_container.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';

class HashTagSearchScreen extends StatefulWidget {
  HashTagSearchScreen(
      {super.key,
      required this.country,
      required this.tagData,
      required this.initialSelectedHashTags,
      required this.countryTagId});
  final String country;
  final String countryTagId;
  final List<HashTagData> tagData;
  final List<HashTagData> initialSelectedHashTags;

  @override
  State<StatefulWidget> createState() {
    return HashTagSearchScreenState();
  }
}

class HashTagSearchScreenState extends State<HashTagSearchScreen> {
  TextEditingController hashTagController = TextEditingController();
  List<HashTagData> hashtagSearchList = [];
  List<HashTagData> selectedHashTagList = [];
  bool addNew = false;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    selectedHashTagList = List.from(widget.initialSelectedHashTags);
    if (widget.tagData.isNotEmpty) {
      hashtagSearchList = List.from(widget.tagData);
      syncSelectionState();
    } else {
      searchHashTagsApi("");
    }
  }

  void syncSelectionState() {
    for (var i = 0; i < hashtagSearchList.length; i++) {
      bool isSelected = selectedHashTagList.contains(hashtagSearchList[i]);
      hashtagSearchList[i] =
          hashtagSearchList[i].copyWith(selected: isSelected);
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    hashTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        leadingWidth: 0,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                context.pop();
              },
              child: Image.asset(
                "${iconsPath}ic_arrow_left.png",
                width: size.width * AppDimensions.numD07,
              ),
            ),
            SizedBox(
              width: size.width * AppDimensions.numD04,
            ),
            Expanded(
              child: TextField(
                controller: hashTagController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[^#]*$'))
                ],
                onChanged: (val) {
                  if (debounce?.isActive ?? false) debounce!.cancel();
                  debounce = Timer(const Duration(milliseconds: 500), () {
                    searchHashTagsApi(val);
                  });
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColorTheme.colorLightGrey,
                    hintText: "Search or Add Hashtags",
                    hintStyle: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: AppColorTheme.colorHint,
                        fontWeight: FontWeight.normal),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD08),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        )),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD08),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        )),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD08),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        )),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD08),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        )),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD08),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        )),
                    contentPadding: EdgeInsets.only(
                        left: size.width * AppDimensions.numD06)),
              ),
            ),
            /*    SizedBox(
              width:  size.width * AppDimensions.numD04 ,
            ),
            commonElevatedButton(
                "Add New",
                size,
                commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD025,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
                commonButtonStyle(size, AppColorTheme.colorThemePink), () {
              if(hashTagController.text.trim().isNotEmpty){
                addHashTagsApi();

              }
            })*/
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * AppDimensions.numD035,
              ),
              if (selectedHashTagList.isNotEmpty)
                Wrap(
                  children: List.generate(selectedHashTagList.length, (index) {
                    return Container(
                      margin: EdgeInsets.only(
                          right: size.width * AppDimensions.numD02),
                      child: Chip(
                          label: Text(
                            "#${selectedHashTagList[index].name}",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD03,
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: size.width * AppDimensions.numD045,
                          ),
                          onDeleted: () {
                            final removedTag = selectedHashTagList[index];
                            selectedHashTagList.removeAt(index);

                            final searchIdx =
                                hashtagSearchList.indexOf(removedTag);
                            if (searchIdx != -1) {
                              hashtagSearchList[searchIdx] =
                                  hashtagSearchList[searchIdx]
                                      .copyWith(selected: false);
                            }
                            setState(() {});
                          },
                          backgroundColor: Colors.black),
                    );
                  }),
                ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              if (hashTagController.text.isEmpty &&
                  hashtagSearchList.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: size.width * AppDimensions.numD02),
                  child: Text(
                    "Suggested Tags",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
              Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            final tag = hashtagSearchList[index];
                            if (tag.id.isNotEmpty) {
                              if (!tag.selected) {
                                hashtagSearchList[index] =
                                    tag.copyWith(selected: true);
                                if (!selectedHashTagList.contains(tag)) {
                                  selectedHashTagList
                                      .add(hashtagSearchList[index]);
                                }
                              } else {
                                hashtagSearchList[index] =
                                    tag.copyWith(selected: false);
                                selectedHashTagList.remove(tag);
                              }
                              setState(() {});
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColorTheme.colorLightGrey,
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD02)),
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * AppDimensions.numD02,
                                horizontal: size.width * AppDimensions.numD02),
                            child: Row(
                              children: [
                                Text(
                                  "#${hashtagSearchList[index].name}",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                hashtagSearchList[index].id.isEmpty
                                    ? InkWell(
                                        onTap: () {
                                          final tagName =
                                              hashtagSearchList[index].name;
                                          if (tagName.isNotEmpty) {
                                            hashtagSearchList.removeAt(index);
                                            addHashTagsApi(tagName);
                                            hashTagController.clear();
                                            searchHashTagsApi("");
                                            setState(() {});
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: size.width *
                                                  AppDimensions.numD02,
                                              vertical: size.width *
                                                  AppDimensions.numD005),
                                          decoration: BoxDecoration(
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              borderRadius:
                                                  BorderRadius.circular(size
                                                          .width *
                                                      AppDimensions.numD025)),
                                          child: Text(
                                            "Add",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      )
                                    : (hashtagSearchList[index].selected
                                        ? Icon(
                                            Icons.check,
                                            color: Colors.black,
                                            size: size.width *
                                                AppDimensions.numD06,
                                          )
                                        : Container())
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: size.width * AppDimensions.numD02,
                        );
                      },
                      itemCount: hashtagSearchList.length)),
              SizedBox(
                height: size.width * AppDimensions.numD13,
                width: size.width,
                child: commonElevatedButton(
                    AppStrings.submitText,
                    size,
                    commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    commonButtonStyle(size, AppColorTheme.colorThemePink), () {
                  context.pop(selectedHashTagList);
                }),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD04,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///--------Apis Section------------

  Future<void> getHashTagsApi(
      String searchParam, String tagId, bool showLoader) async {
    Map<String, String> params = {};
    if (searchParam.trim().isNotEmpty) {
      params["tagName"] = searchParam;
      params["type"] = "hopper";
      params["tag_id"] = tagId;
      debugPrint("GetHashTagsQueryParams: $params");
    }

    try {
      final response = await sl<ApiClient>()
          .get(ApiConstantsNew.content.getTags, queryParameters: params);

      if (response.statusCode == 200) {
        var list = response.data;
        if (list is String) list = jsonDecode(list);

        List tags = [];
        if (list is Map<String, dynamic>) {
          tags = list['data'] ?? list['tags'] ?? list['hashtags'] ?? [];
        } else if (list is List) {
          tags = list;
        }

        debugPrint("GetHashTags: $response");
        final List<HashTagData> fetchedTags =
            tags.map((e) => HashTagData.fromJson(e)).toList();

        hashtagSearchList = fetchedTags;
        syncSelectionState();
        setState(() {});
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> searchHashTagsApi(String searchParam) async {
    Map<String, String> params = {};
    if (searchParam.trim().isNotEmpty) {
      params["tagName"] = searchParam;
      params["type"] = "hopper";
      //params["tag_id"] = ;
      debugPrint("GetHashTagsQueryParams: $params");
    }

    try {
      final response = await sl<ApiClient>()
          .get(ApiConstantsNew.content.getTags, queryParameters: params);

      if (response.statusCode == 200) {
        var list = response.data;
        if (list is String) list = jsonDecode(list);

        List tags = [];
        if (list is Map<String, dynamic>) {
          tags = list['data'] ?? list['tags'] ?? list['hashtags'] ?? [];
        } else if (list is List) {
          tags = list;
        }

        debugPrint("SearchHashTags: $response");
        final List<HashTagData> fetchedTags =
            tags.map((e) => HashTagData.fromJson(e)).toList();

        hashtagSearchList = fetchedTags;
        if (hashtagSearchList.isEmpty &&
            hashTagController.text.trim().isNotEmpty) {
          addNew = true;
        } else {
          addNew = false;
        }
        if (hashtagSearchList.isEmpty &&
            hashTagController.text.trim().isNotEmpty) {
          debugPrint("add new:::::::");
          hashtagSearchList.add(HashTagData(
              id: '', name: hashTagController.text.trim(), selected: false));
        }
        syncSelectionState();

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> addHashTagsApi(String tagName) async {
    // 1. Optimistic Update
    final tempTag = HashTagData(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: tagName,
        selected: true);

    selectedHashTagList.insert(0, tempTag);
    setState(() {});

    // 2. Network Request
    Map<String, String> params = {"name": tagName};
    debugPrint("AddHashTagsParams: $params");

    try {
      final response = await sl<ApiClient>().post(
        ApiConstantsNew.content.addTags,
        data: params,
      );

      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);

        HashTagData? realTag;
        if (map["id"] != null) {
          realTag = HashTagData.fromJson(map).copyWith(selected: true);
        } else if (map["code"] == 200 && map['tag'] != null) {
          realTag = HashTagData(
              id: map['tag']["id"] ?? map['tag']["_id"] ?? '',
              name: map['tag']['name'],
              selected: true);
        }

        if (realTag != null) {
          int selIdx = selectedHashTagList.indexOf(tempTag);
          if (selIdx != -1) {
            selectedHashTagList[selIdx] = realTag;
          } else {
            selectedHashTagList.insert(0, realTag);
          }
          setState(() {});
        } else {
          selectedHashTagList.remove(tempTag);
          setState(() {});
        }
      } else {
        selectedHashTagList.remove(tempTag);
        setState(() {});
      }
    } catch (e) {
      debugPrint("$e");
      selectedHashTagList.remove(tempTag);
      setState(() {});
    }
  }
}

class HashTagData extends Equatable {
  HashTagData({
    required this.id,
    required this.name,
    required this.selected,
  });

  factory HashTagData.fromJson(Map<String, dynamic> json) {
    return HashTagData(
        id: json["id"] ?? json["_id"] ?? '',
        name: json["name"] ?? '',
        selected: false);
  }
  final String id;
  final String name;
  final bool selected;

  HashTagData copyWith({
    String? id,
    String? name,
    bool? selected,
  }) {
    return HashTagData(
      id: id ?? this.id,
      name: name ?? this.name,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
