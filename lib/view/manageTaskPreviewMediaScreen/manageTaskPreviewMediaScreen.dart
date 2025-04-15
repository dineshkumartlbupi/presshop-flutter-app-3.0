import 'dart:io';
import 'package:flutter/material.dart';

class ManageTaskPreviewMediaScreen extends StatefulWidget {
  const ManageTaskPreviewMediaScreen({super.key});

  @override
  State<ManageTaskPreviewMediaScreen> createState() => _ManageTaskPreviewMediaScreenState();
}

class _ManageTaskPreviewMediaScreenState extends State<ManageTaskPreviewMediaScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                onPageChanged: (value) {
                 // currentPage = value;
                  setState(() {});
                },
                itemBuilder: (context, index) {
                  return Image.asset("assets/dummyImages/dummy_charity_life.png");
                },
                itemCount: 3,
              ),
            ),
        /*    widget.type == "draft"
                ? Container(
              height: size.width * numD17,
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(
                  left: size.width * numD04,
                  top: size.width * numD02,
                  bottom: size.width * numD02,
                  right: size.width * numD02),
              child: commonElevatedButton(
                  "Next",
                  size,
                  commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  commonButtonStyle(size, colorThemePink), () {
                Navigator.pop(context); //  getImageMetaData();
              }),
            )
                : Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                  left: size.width * numD04,
                  top: size.width * numD02,
                  bottom: size.width * numD03,
                  right: size.width * numD02),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: size.width * numD13,
                      child: commonElevatedButton(
                          "Add More",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(
                              size,
                              isMoreDisable
                                  ? Colors.grey
                                  : Colors.black), () {
                        if (mediaList.length == 10) {
                          isMoreDisable = true;
                          setState(() {});
                          showSnackBar(
                              "PRESSHOP",
                              "Only 10 contents allowed!",
                              colorThemePink);
                        } else {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                              builder: (context) =>
                              const CameraScreen(
                                picAgain: true,
                                previousScreen: ScreenNameEnum
                                    .previewScreen,
                              )))
                              .then((value) {
                            debugPrint(
                                ":::: Inside Picked Again Image :::: $value");
                            if (value != null) {
                              addMediaDataList(value);
                            }
                          });
                        }

                        *//*getImageMetaData(widget.cameraData);*//*
                      }),
                    ),
                  ),
                  SizedBox(width: size.width * numD04),
                  Expanded(
                    child: SizedBox(
                      height: size.width * numD13,
                      child: commonElevatedButton(
                          "Next",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, colorThemePink), () {
                        if (widget.pickAgain) {
                          Navigator.pop(context);
                          if (widget.type == "draft") {
                            for (int i = 0; i < mediaList.length; i++) {
                              var mediaItem = mediaList[i];
                              PublishData(
                                  imagePath: mediaItem.mediaPath,
                                  address: mediaItem.location,
                                  date: mediaItem.dateTime,
                                  city: "",
                                  state: "",
                                  country: "",
                                  latitude: mediaItem.latitude,
                                  longitude: mediaItem.longitude,
                                  mimeType: mediaItem.mimeType,
                                  videoImagePath: mediaItem.mediaPath,
                                  mediaList: mediaList);
                            }
                          } else {
                            Navigator.pop(
                                context,
                                PublishData(
                                    imagePath: widget.cameraData!.path,
                                    address: mediaAddress.isNotEmpty
                                        ? mediaAddress
                                        : widget.cameraListData.first
                                        .location,
                                    date: mediaDate,
                                    city: city.isNotEmpty
                                        ? city
                                        : widget
                                        .cameraListData.first.city,
                                    state: state.isNotEmpty
                                        ? state
                                        : widget
                                        .cameraListData.first.state,
                                    country: country.isNotEmpty
                                        ? country
                                        : widget.cameraListData.first
                                        .country,
                                    latitude:
                                    widget.cameraData!.latitude,
                                    longitude:
                                    widget.cameraData!.longitude,
                                    mimeType:
                                    widget.cameraData!.mimeType,
                                    videoImagePath: widget
                                        .cameraData!.videoImagePath,
                                    mediaList: mediaList));
                          }
                        } else {
                          if (mediaList.isNotEmpty) {
                            if (widget.cameraListData.isNotEmpty) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PublishContentScreen(
                                      publishData: PublishData(
                                          imagePath: widget.cameraData != null
                                              ? widget.cameraData!.path
                                              : widget.cameraListData
                                              .first.path,
                                          address:
                                          mediaAddress.isNotEmpty
                                              ? mediaAddress
                                              : widget
                                              .cameraListData
                                              .first
                                              .location,
                                          date: mediaDate.isNotEmpty
                                              ? mediaDate
                                              : widget.cameraListData
                                              .first.dateTime,
                                          city: city.isNotEmpty
                                              ? city
                                              : widget.cameraListData.first.city,
                                          state: state.isNotEmpty ? state : widget.cameraListData.first.state,
                                          country: country.isNotEmpty ? country : widget.cameraListData.first.country,
                                          latitude: widget.cameraData != null ? widget.cameraData!.latitude : widget.cameraListData.first.latitude,
                                          longitude: widget.cameraData != null ? widget.cameraData!.longitude : widget.cameraListData.first.longitude,
                                          mimeType: widget.cameraData != null ? widget.cameraData!.mimeType : widget.cameraListData.first.mimeType,
                                          videoImagePath: widget.cameraData != null ? widget.cameraData!.videoImagePath : widget.cameraListData.first.videoImagePath,
                                          mediaList: mediaList),
                                      myContentData: null,
                                      hideDraft: false,
                                      docType: widget.type)));
                            }
                          }
                        }

                        //  getImageMetaData();
                      }),
                    ),
                  )
                ],
              ),
            ),*/
          ],
        )
    );
  }
}
